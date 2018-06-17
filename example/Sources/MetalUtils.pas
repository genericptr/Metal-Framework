{$mode objfpc}
{$modeswitch objectivec1}

unit MetalUtils;
interface
uses
	Metal, MetalKit, CocoaAll, CocoaUtils, SysUtils;

// https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221-CH1-SW1

type
	TMetalAPI = class
		private
			device: MTLDeviceProtocol;
			pipelineState: MTLRenderPipelineStateProtocol;
			commandQueue: MTLCommandQueueProtocol;

			view: MTKView;
			commandBuffer: MTLCommandBufferProtocol;
			renderEncoder: MTLRenderCommandEncoderProtocol;
	end;

type
	TMetalPipelineOptions = record
		libraryName: string;
		vertexFunction: string;
		fragmentFunction: string;
	end;
	TMetalPipelineOptionsPtr = ^TMetalPipelineOptions;

procedure MTLDraw (api: TMetalAPI; primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLSetVertexBuffer (api: TMetalAPI; buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetVertexBytes (api: TMetalAPI; bytes: pointer; len: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentTexture (api: TMetalAPI; texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (api: TMetalAPI; constref viewport: MTLViewport);
procedure MTLBeginFrame (api: TMetalAPI; view: MTKView);
procedure MTLEndFrame (api: TMetalAPI);
procedure MTLFree (var api: TMetalAPI);
function MTLCreate (view: MTKView; options: TMetalPipelineOptionsPtr = nil): TMetalAPI;

implementation

procedure MTLDraw (api: TMetalAPI; primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	with api do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	end;
end;

procedure MTLSetViewPort (api: TMetalAPI; constref viewport: MTLViewport);
begin
	with api do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setViewport(viewport);
	end;
end;

			
procedure MTLSetFragmentTexture (api: TMetalAPI; texture: MTLTextureProtocol; index: NSUInteger);
begin
	with api do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetVertexBuffer (api: TMetalAPI; buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	with api do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBytes (api: TMetalAPI; bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	with api do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLBeginFrame (api: TMetalAPI; view: MTKView);
var
	renderPassDescriptor: MTLRenderPassDescriptor;
begin
	api.view := view;
	with api do begin
	commandBuffer := commandQueue.commandBuffer;

	// use renderPassDescriptor to set attachments like color, depth, stencil
	// we need to set attachments before renderCommandEncoderWithDescriptor is
	// called so move this outside of begin if any attachments need to be set
	renderPassDescriptor := view.currentRenderPassDescriptor;
	Fatal(renderPassDescriptor = nil, 'views device is not set');

	renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

	renderEncoder.setRenderPipelineState(pipelineState);
	end;
end;

procedure MTLEndFrame (api: TMetalAPI);
begin
	with api do begin
	Fatal(renderEncoder = nil);

	renderEncoder.endEncoding;
	commandBuffer.presentDrawable(view.currentDrawable);

	commandBuffer.commit;

	commandBuffer := nil;
	renderEncoder := nil;
	end;
end;

procedure MTLFree (var api: TMetalAPI);
begin
	with api do begin
	pipelineState.release;
	commandQueue.release;
	end;
	api.Free;
	api := nil;
end;

function MTLCreate (view: MTKView; options: TMetalPipelineOptionsPtr = nil): TMetalAPI;
var
	defaultLibrary: MTLLibraryProtocol;
	vertexFunction: MTLFunctionProtocol = nil;
	fragmentFunction: MTLFunctionProtocol = nil;
	attachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;

	error: NSError = nil;
	api: TMetalAPI;
begin
	api := TMetalAPI.Create;
	api.view := view;
	with api do
		begin
			device := view.device;
			Fatal(device = nil, 'no gpu device found.');
			Show(device, 'GPU:');

			// TODO: how do we handle multiple shaders? we need to split up MetalInit I guess

			// Load all the shader files with a .metallib file extension in the project
			if options^.libraryName = '' then
				defaultLibrary := device.newDefaultLibrary
			else
				defaultLibrary := device.newLibraryWithFile_error(NSSTR(options^.libraryName), @error);

			// NOTE: Xcode usually compiles the .metal shader files to a .metallib file
			// and places it at Contents/Resources/default.metallib ut we need to do this manually. 

			// https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW10
			// xcrun -sdk macosx metal AAPLShaders.metal -o AAPLShaders.air
			// xcrun -sdk macosx metallib AAPLShaders.air -o AAPLShaders.metallib

			Fatal(defaultLibrary = nil, 'no .metallib files were found.', error);
				
			Show(defaultLibrary);

			// Load the vertex function from the library
			vertexFunction := defaultLibrary.newFunctionWithName(NSSTR(options^.vertexFunction));
			Fatal(vertexFunction = nil, 'vertex shader not found.');

			// Load the fragment function from the library
			fragmentFunction := defaultLibrary.newFunctionWithName(NSSTR(options^.fragmentFunction));
			Fatal(fragmentFunction = nil, 'fragment shader not found.');

			pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init;
			pipelineStateDescriptor.setLabel(NSSTR('Simple Pipeline'));
			pipelineStateDescriptor.setVertexFunction(vertexFunction);
			pipelineStateDescriptor.setFragmentFunction(fragmentFunction);

			// pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
			attachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
			attachment.setPixelFormat(view.colorPixelFormat);

			pipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineStateDescriptor, @error);

			// Pipeline State creation could fail if we haven't properly set up our pipeline descriptor.
			//  If the Metal API validation is enabled, we can find out more information about what
			//  went wrong.  (Metal API validation is enabled by default when a debug build is run
			//  from Xcode)
			Fatal(pipelineState = nil, 'pipeline creation failed.', error);

			// Create the command queue
			commandQueue := device.newCommandQueue;

			// NOTE: Appe's example project uses ARC but we need to
			// manually clean up
			pipelineStateDescriptor.release;
			vertexFunction.release;
			fragmentFunction.release;
			defaultLibrary.release;
		end;

	result := api;
end;


end.