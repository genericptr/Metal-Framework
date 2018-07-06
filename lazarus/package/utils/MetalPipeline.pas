{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MetalPipeline;
interface
uses
	MetalUtils, Metal, MetalKit, CocoaAll, SysUtils;

type
	TMetalPipeline = class
		view: MTKView;
		device: MTLDeviceProtocol;
		pipelineState: MTLRenderPipelineStateProtocol;

		// available between begin/end frame
		commandQueue: MTLCommandQueueProtocol;
		commandBuffer: MTLCommandBufferProtocol;
		renderEncoder: MTLRenderCommandEncoderProtocol;

		// renderPassDescriptor can only be accessed directly after MTLBeginFrame
		// and will be unlinked after subsequent calls to MTLSetXXX
		//renderPassDescriptor: MTLRenderPassDescriptor;

		depthStencilState: MTLDepthStencilStateProtocol;
		drawing: boolean;
	end;

type
	TMetalPipelineOptions = record
		libraryName: string;			// path to compiled .metallib file
		shaderName: string;				// path to .metal shader file which will be compiled at runtime
		vertexFunction: string;		// name of vertex function in shader file (see TMetalPipelineOptions.Default)
		fragmentFunction: string;	// name of fragment function in shader file (see TMetalPipelineOptions.Default)
		vertexDescriptor: MTLVertexDescriptor;

		class function Default: TMetalPipelineOptions; static;
	end;
	TMetalPipelineOptionsPtr = ^TMetalPipelineOptions;

{ Drawing }
procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLDrawIndexed (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);

{ Buffers }
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; index: NSUInteger); overload; inline;
procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

procedure MTLSetFragmentBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

{ Render Encoder }
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (constref viewport: MTLViewport);
procedure MTLSetCullMode (mode: MTLCullMode);
procedure MTLSetFrontFacingWinding (winding: MTLWinding);

{ Persistent States }
procedure MTLSetClearColor (pipeline: TMetalPipeline; clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);

{ Frames }
procedure MTLBeginFrame (pipeline: TMetalPipeline);
procedure MTLEndFrame;

{ Creation }
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
	result.vertexDescriptor := nil;
end;

procedure MTLDrawIndexed(primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset(primitiveType, indexCount, indexType, indexBuffer, indexBufferOffset);
	end;
end;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	end;
end;

procedure MTLSetCullMode (mode: MTLCullMode);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setCullMode(mode);
	end;
end;

procedure MTLSetFrontFacingWinding (winding: MTLWinding);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setFrontFacingWinding(winding);
	end;
end;

procedure MTLSetClearColor (pipeline: TMetalPipeline; clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
begin
	with pipeline do begin
	Fatal(drawing, 'can''t call during drawing operations');
	view.setClearColor(clearColor);
	view.setColorPixelFormat(colorPixelFormat);
	view.setDepthStencilPixelFormat(depthStencilPixelFormat);
	end;
end;

procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);
var
	desc: MTLDepthStencilDescriptor;
begin
	with pipeline do begin

	Fatal(drawing, 'can''t call during drawing operations');
	Fatal(depthStencilState <> nil, 'depth stencil already set');

	desc := MTLDepthStencilDescriptor.alloc.init;
	desc.setDepthCompareFunction(compareFunction);
	desc.setDepthWriteEnabled(depthWriteEnabled);
	desc.setFrontFaceStencil(frontFaceStencil);
	desc.setBackFaceStencil(backFaceStencil);
	desc.setLabel(NSSTR('MTLSetDepthStencil'));

	// NOTE: who owns this now??
	depthStencilState := device.newDepthStencilStateWithDescriptor(desc);
	end;
end;

procedure MTLSetViewPort (constref viewport: MTLViewport);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setViewport(viewport);
	end;
end;
		
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetFragmentBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setFragmentBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetFragmentBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setFragmentBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; index: NSUInteger);
begin
	MTLSetVertexBuffer(buffer, 0, index);
end;

procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLBeginFrame (pipeline: TMetalPipeline);
var
	colorAttachment: MTLRenderPassColorAttachmentDescriptor;
	renderPassDescriptor: MTLRenderPassDescriptor;
begin
	CurrentThreadPipeline := pipeline;
	with CurrentThreadPipeline do begin
	commandBuffer := commandQueue.commandBuffer;

	drawing := true;
	renderPassDescriptor := view.currentRenderPassDescriptor;
	Fatal(renderPassDescriptor = nil, 'views device is not set');

	renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);
	renderEncoder.setRenderPipelineState(pipelineState);
	renderEncoder.setDepthStencilState(depthStencilState);

	// NOTE: MTKView does this for us
	//colorAttachment := renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	//colorAttachment.setTexture(view.currentDrawable.texture);
	//colorAttachment.setClearColor(view.clearColor);
	//colorAttachment.setStoreAction(MTLStoreActionStore);
	//colorAttachment.setLoadAction(MTLLoadActionClear);

	// NOTE: depthAttachment is set automatically by the MTKView
	//show(renderPassDescriptor.depthAttachment);
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
	drawing := false;
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
	colorAttachment: MTLRenderPipelineColorAttachmentDescriptor;
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

			// Create the command queue
			commandQueue := device.newCommandQueue;

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

			// set default pixel formats
			// NOTE: these can be overriden in MTLSetClearColor
			view.setColorPixelFormat(MTLPixelFormatBGRA8Unorm);
			view.setDepthStencilPixelFormat(MTLPixelFormatDepth32Float);

			// TODO: for different shaders we need to make multiple pipelineState's
			// which can be set between begin/end frame calls
			pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init;
			pipelineStateDescriptor.setVertexFunction(vertexFunction);
			pipelineStateDescriptor.setFragmentFunction(fragmentFunction);
			pipelineStateDescriptor.setDepthAttachmentPixelFormat(view.depthStencilPixelFormat);

			if options <> nil then
				pipelineStateDescriptor.setVertexDescriptor(options^.vertexDescriptor);

			colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
			colorAttachment.setPixelFormat(view.colorPixelFormat);

			pipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineStateDescriptor, @error);

			// Pipeline State creation could fail if we haven't properly set up our pipeline descriptor.
			//  If the Metal API validation is enabled, we can find out more information about what
			//  went wrong.  (Metal API validation is enabled by default when a debug build is run
			//  from Xcode)
			Fatal(pipelineState = nil, 'pipeline creation failed.', error);

			// cleanup temporary state
			pipelineStateDescriptor.release;
			vertexFunction.release;
			fragmentFunction.release;
			shaderLibrary.release;
		end;

	result := pipeline;
end;


end.