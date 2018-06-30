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
		renderPassDescriptor: MTLRenderPassDescriptor;

		// ...
		depthStencilState: MTLDepthStencilStateProtocol;
	end;

type
	TMetalPipelineOptions = record
		libraryName: string;			// path to compiled .metallib file
		shaderName: string;				// path to .metal shader file which will be compiled at runtime
		vertexFunction: string;		// name of vertex function in shader file (see TMetalPipelineOptions.Default)
		fragmentFunction: string;	// name of fragment function in shader file (see TMetalPipelineOptions.Default)

		class function Default: TMetalPipelineOptions; static;
	end;
	TMetalPipelineOptionsPtr = ^TMetalPipelineOptions;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLDrawIndexed (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (constref viewport: MTLViewport);
procedure MTLSetCullMode (mode: integer);

procedure MTLSetClearColor (r, g, b, a: double);
procedure MTLSetDepthStencil (pipeline: TMetalPipeline; newState: MTLDepthStencilStateProtocol); overload;
procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: integer = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);

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

procedure CommitRenderPassEnconder;
begin
	with CurrentThreadPipeline do begin
	Fatal(commandBuffer = nil, 'must call begin frame first.');
	if renderEncoder = nil then
		begin
			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);
			renderEncoder.setRenderPipelineState(pipelineState);
			renderPassDescriptor := nil;
		end;
	end;
end;

procedure MTLDrawIndexed(primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset(primitiveType, indexCount, indexType, indexBuffer, indexBufferOffset);
	end;
end;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	end;
end;

procedure MTLSetCullMode (mode: integer);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.setCullMode(mode);
	end;
end;

procedure MTLSetDepthStencil (pipeline: TMetalPipeline; newState: MTLDepthStencilStateProtocol);
begin
	with pipeline do begin
	depthStencilState.release;
	depthStencilState := newState.retain;
	end;
end;

procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: integer = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);
var
	descriptor: MTLDepthStencilDescriptor;
	state: MTLDepthStencilStateProtocol;
begin
	with pipeline do begin

	descriptor := MTLDepthStencilDescriptor.alloc.init;
	descriptor.setDepthCompareFunction(compareFunction);
	descriptor.setDepthWriteEnabled(depthWriteEnabled);
	descriptor.setFrontFaceStencil(frontFaceStencil);
	descriptor.setBackFaceStencil(backFaceStencil);

	state := device.newDepthStencilStateWithDescriptor(descriptor);
	MTLSetDepthStencil(pipeline, state);
	state.release;

	descriptor.release;
	end;
end;

procedure MTLSetViewPort (constref viewport: MTLViewport);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.setViewport(viewport);
	end;
end;
		
procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	CommitRenderPassEnconder;
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetClearColor (r, g, b, a: double);
var
	clearColor: MTLClearColor;
	colorAttachment: MTLRenderPassColorAttachmentDescriptor;
begin
	Fatal(CurrentThreadPipeline = nil, 'must call MTLBeginFrame first');
	with CurrentThreadPipeline do begin
	Fatal(renderPassDescriptor = nil, 'already commited current render pass descriptor.');
	colorAttachment := renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	clearColor.red := r;
	clearColor.green := g;
	clearColor.blue:= b;
	clearColor.alpha := a;
	colorAttachment.setClearColor(clearColor);
	end;
end;

procedure MTLBeginFrame (pipeline: TMetalPipeline);
begin
	CurrentThreadPipeline := pipeline;
	with CurrentThreadPipeline do begin
	commandBuffer := commandQueue.commandBuffer;
	renderPassDescriptor := view.currentRenderPassDescriptor;
	Fatal(renderPassDescriptor = nil, 'views device is not set');
	end;
end;

procedure MTLEndFrame;
begin
	with CurrentThreadPipeline do begin
	Fatal(renderEncoder = nil);

	if depthStencilState <> nil then
		renderEncoder.setDepthStencilState(depthStencilState);

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