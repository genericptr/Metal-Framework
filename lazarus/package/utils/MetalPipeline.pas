{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MetalPipeline;
interface
uses
	MetalUtils, Metal, MetalKit, CocoaAll, SysUtils;

// https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221-CH1-SW1

type
	TMetalPipeline = class
		view: MTKView;
		device: MTLDeviceProtocol;
		pipelineState: MTLRenderPipelineStateProtocol;
		commandQueue: MTLCommandQueueProtocol;
		commandBuffer: MTLCommandBufferProtocol;
		renderEncoder: MTLRenderCommandEncoderProtocol;
	end;

type
	TMetalPipelineOptions = record
		libraryName: string;
		shaderName: string;
		vertexFunction: string;
		fragmentFunction: string;

		class function Default: TMetalPipelineOptions; static;
	end;
	TMetalPipelineOptionsPtr = ^TMetalPipelineOptions;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (constref viewport: MTLViewport);
procedure MTLSetCullMode (mode: integer);
procedure MTLBeginFrame (pipeline: TMetalPipeline);
procedure MTLEndFrame;

procedure MTLFree (var pipeline: TMetalPipeline);
function MTLCreatePipeline (view: MTKView; options: TMetalPipelineOptionsPtr = nil): TMetalPipeline;

implementation

threadvar
	CurrentThreadPipeline: TMetalPipeline;

class function TMetalPipelineOptions.Default: TMetalPipelineOptions;
begin
	result.libraryName := '';
	result.shaderName := '';
	result.vertexFunction := 'vertexShader';
	result.fragmentFunction := 'fragmentShader';
end;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	end;
end;

procedure MTLSetCullMode (mode: integer);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setCullMode(mode);
	end;
end;

procedure MTLSetViewPort (constref viewport: MTLViewport);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setViewport(viewport);
	end;
end;
		
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil, 'no frame in stack.');
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLBeginFrame (pipeline: TMetalPipeline);
var
	renderPassDescriptor: MTLRenderPassDescriptor;
begin
	CurrentThreadPipeline := pipeline;
	with CurrentThreadPipeline do begin
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

procedure MTLEndFrame;
begin
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil);

	renderEncoder.endEncoding;
	commandBuffer.presentDrawable(view.currentDrawable);

	commandBuffer.commit;

	commandBuffer := nil;
	renderEncoder := nil;
	end;
	CurrentThreadPipeline := nil;
end;

procedure MTLFree (var pipeline: TMetalPipeline);
begin
	with pipeline do begin
	pipelineState.release;
	commandQueue.release;
	end;
	pipeline.Free;
	pipeline := nil;
end;

function MTLCreatePipeline (view: MTKView; options: TMetalPipelineOptionsPtr = nil): TMetalPipeline;
	
	function NSSTR(str: string): NSString; overload;
	begin
		result := NSString.stringWithCString_length(@str[1], length(str));
	end;

	function CompileShader (device: MTLDeviceProtocol; name: string): MTLLibraryProtocol;
	var
		options: MTLCompileOptions;
		source: NSString;
		error: NSError;
	begin
		source := NSString.stringWithContentsOfFile_encoding_error(NSSTR(name), NSUTF8StringEncoding, @error);
		Fatal(source = nil, 'error loading library file', error);

		result := device.newLibraryWithSource_options_error(source, nil, @error);
		Fatal(result = nil, 'error compiling library: ', error);
	end;

var
	shaderLibrary: MTLLibraryProtocol;
	vertexFunction: MTLFunctionProtocol = nil;
	fragmentFunction: MTLFunctionProtocol = nil;
	attachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;

	error: NSError = nil;
	pipeline: TMetalPipeline;
begin
	pipeline := TMetalPipeline.Create;
	pipeline.view := view;
	with pipeline do
		begin
			CurrentThreadPipeline := nil;
			device := view.device;
			Fatal(device = nil, 'no gpu device found.');
			Show(device, 'GPU:');

			if options <> nil then
				begin
					if options^.shaderName <> '' then
						begin
							shaderLibrary := CompileShader(device, options^.shaderName);
						end
					else if options^.libraryName <> '' then
						begin
							if options^.libraryName = '' then
								shaderLibrary := device.newDefaultLibrary
							else
								shaderLibrary := device.newLibraryWithFile_error(NSSTR(options^.libraryName), @error);
						end;
				end
			else
				begin
					shaderLibrary := device.newDefaultLibrary;
				end;

			Fatal(shaderLibrary = nil, 'no metal shaders could be loaded.', error);
				
			Show(shaderLibrary);

			// Load the vertex function from the library
			if options <> nil then
				vertexFunction := shaderLibrary.newFunctionWithName(NSSTR(options^.vertexFunction))
			else
				vertexFunction := shaderLibrary.newFunctionWithName(NSSTR('vertexShader'));

			Fatal(vertexFunction = nil, 'vertex shader not found.');

			// Load the fragment function from the library
			if options <> nil then
				fragmentFunction := shaderLibrary.newFunctionWithName(NSSTR(options^.fragmentFunction))
			else
				fragmentFunction := shaderLibrary.newFunctionWithName(NSSTR('fragmentShader'));

			Fatal(fragmentFunction = nil, 'fragment shader not found.');

			pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init;
			pipelineStateDescriptor.setLabel(NSSTR('Pipeline'));
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

			// cleanup temporary state
			pipelineStateDescriptor.release;
			vertexFunction.release;
			fragmentFunction.release;
			shaderLibrary.release;
		end;

	result := pipeline;
end;


end.