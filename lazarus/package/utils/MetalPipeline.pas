{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MetalPipeline;
interface
uses
	MetalUtils, Metal, MetalKit, CocoaAll, SysUtils;

type
	TMetalPipeline = class
		pipelineState: MTLRenderPipelineStateProtocol;

		// states
		depthStencilState: MTLDepthStencilStateProtocol;

		destructor Destroy; override;
	end;

type
	TMetalContext = class
		view: MTKView;
		device: MTLDeviceProtocol;
		commandQueue: MTLCommandQueueProtocol;
		currentPipeline: TMetalPipeline;

		// drawing
		commandBuffer: MTLCommandBufferProtocol;
		renderEncoder: MTLRenderCommandEncoderProtocol;
		drawing: boolean;

		destructor Destroy; override;
	end;

type
	TMetalLibrary = class
		lib: MTLLibraryProtocol;
		functions: NSMutableDictionary;

		function GetFunction (name: string): MTLFunctionProtocol;
		destructor Destroy; override;
	end;

type
	TMetalLibraryOptions = record
		libraryName: string;			// path to compiled .metallib file
		shaderName: string;				// path to .metal shader file which will be compiled at runtime
		class function Default: TMetalLibraryOptions; static;
	end;

type
	TMetalPipelineOptions = record

		libraryName: string;					// path to compiled .metallib file
		shaderName: string;						// path to .metal shader file which will be compiled at runtime
		shaderLibrary: TMetalLibrary;	// metal library to locate shader functions

		vertexShader: string;				// name of vertex function in shader file (see TMetalPipelineOptions.Default)
		fragmentShader: string;			// name of fragment function in shader file (see TMetalPipelineOptions.Default)
		vertexDescriptor: MTLVertexDescriptor;

		// blending modes
		blendingEnabled: boolean;
		sourceRGBBlendFactor: MTLBlendFactor;
		destinationRGBBlendFactor: MTLBlendFactor;
		rgbBlendOperation: MTLBlendOperation;
		sourceAlphaBlendFactor: MTLBlendFactor;
		destinationAlphaBlendFactor: MTLBlendFactor;
		alphaBlendOperation: MTLBlendOperation;

		class function Default: TMetalPipelineOptions; static;
	end;

{ Drawing }
procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLDrawIndexed (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);

{ Buffers }
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; index: NSUInteger); overload; inline;
procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

procedure MTLSetFragmentBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

{ Textures }
function MTLLoadTexture (bytes: pointer; width, height: integer; pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm): MTLTextureProtocol;

{ Render Encoder }
procedure MTLSetShader(pipeline: TMetalPipeline);

procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (constref viewport: MTLViewport);
procedure MTLSetCullMode (mode: MTLCullMode);
procedure MTLSetFrontFacingWinding (winding: MTLWinding);

{ Context }
procedure MTLSetClearColor (clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);

{ Frames }
procedure MTLBeginFrame (pipeline: TMetalPipeline = nil);
procedure MTLEndFrame;

{ Creation }

function MTLCreateContext (view: MTKView): TMetalContext;
function MTLCreateLibrary (options: TMetalLibraryOptions): TMetalLibrary;
function MTLCreatePipeline (options: TMetalPipelineOptions): TMetalPipeline;

procedure MTLMakeContextCurrent (context: TMetalContext);

implementation

const
	kError_InvalidContext = 'no current context';
	kError_UnopenedFrame = 'must call MTLBeginFrame first';
	kError_NoShader = 'no shader for current frame';

threadvar
	CurrentThreadContext: TMetalContext;
	SharedShaderLibrary: TMetalLibrary;

function NSSTR(str: string): NSString; overload;
begin
	result := NSString.stringWithCString_length(@str[1], length(str));
end;

class function TMetalLibraryOptions.Default: TMetalLibraryOptions;
begin
	result.libraryName := '';
	result.shaderName := '';
end;

class function TMetalPipelineOptions.Default: TMetalPipelineOptions;
begin
	result.libraryName := '';
	result.shaderName := '';
	result.vertexShader := 'vertexShader';
	result.fragmentShader := 'fragmentShader';
	result.vertexDescriptor := nil;
	result.shaderLibrary := nil;

	result.blendingEnabled := false;
	result.sourceRGBBlendFactor := MTLBlendFactorZero;
	result.destinationRGBBlendFactor := MTLBlendFactorZero;
	result.rgbBlendOperation := MTLBlendOperationAdd;
	result.sourceAlphaBlendFactor := MTLBlendFactorZero;
	result.destinationAlphaBlendFactor := MTLBlendFactorZero;
	result.alphaBlendOperation := MTLBlendOperationAdd;
end;

destructor TMetalContext.Destroy;
begin
	commandQueue.release;

	inherited;
end;

function TMetalLibrary.GetFunction (name: string): MTLFunctionProtocol;
var
	func: MTLFunctionProtocol;
begin
	if functions = nil then
		functions := NSMutableDictionary.alloc.init;

	func := functions.objectForKey(NSSTR(name));
	if func = nil then
		begin
			func := lib.newFunctionWithName(NSSTR(name));
			if func <> nil then
				begin
					functions.setObject_forKey(func, NSSTR(name));
					func.release;
				end;
		end;

	result := func;
end;

destructor TMetalLibrary.Destroy;
begin
	lib.release;
	functions.release;

	inherited;
end;

destructor TMetalPipeline.Destroy;
begin
	pipelineState.release;
	depthStencilState.release;

	inherited;
end;

procedure FinalizeDrawing (pipeline: TMetalPipeline);
var
	renderEncoder: MTLRenderCommandEncoderProtocol;
begin
	Fatal(CurrentThreadContext.currentPipeline = nil, kError_NoShader);

	renderEncoder := CurrentThreadContext.renderEncoder;

	// set pipeline state
	renderEncoder.setRenderPipelineState(pipeline.pipelineState);

	// set depth stencil if available
	if pipeline.depthStencilState <> nil then
		renderEncoder.setDepthStencilState(pipeline.depthStencilState);
end;

procedure ValidateRenderFrame;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	Fatal(not CurrentThreadContext.drawing, kError_UnopenedFrame);
end;

procedure MTLSetShader(pipeline: TMetalPipeline);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	Fatal(not CurrentThreadContext.drawing, kError_UnopenedFrame);
	CurrentThreadContext.currentPipeline := pipeline;
end;

procedure MTLDrawIndexed(primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	FinalizeDrawing(currentPipeline);
	renderEncoder.drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset(primitiveType, indexCount, indexType, indexBuffer, indexBufferOffset);
	end;
end;

procedure MTLDraw (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	FinalizeDrawing(currentPipeline);
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	end;
end;

procedure MTLSetCullMode (mode: MTLCullMode);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setCullMode(mode);
	end;
end;

procedure MTLSetFrontFacingWinding (winding: MTLWinding);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFrontFacingWinding(winding);
	end;
end;

procedure MTLSetViewPort (constref viewport: MTLViewport);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setViewport(viewport);
	end;
end;

procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetFragmentBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetFragmentBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; index: NSUInteger);
begin
	MTLSetVertexBuffer(buffer, 0, index);
end;

procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLBeginFrame (pipeline: TMetalPipeline);
var
	colorAttachment: MTLRenderPassColorAttachmentDescriptor;
	renderPassDescriptor: MTLRenderPassDescriptor;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);

	with CurrentThreadContext do begin
	currentPipeline := pipeline;
	commandBuffer := commandQueue.commandBuffer;

	drawing := true;
	renderPassDescriptor := view.currentRenderPassDescriptor;
	Fatal(renderPassDescriptor = nil, 'views device is not set');

	// NOTE: MTKView does this for us
	//colorAttachment := renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	//colorAttachment.setTexture(view.currentDrawable.texture);
	//colorAttachment.setClearColor(view.clearColor);
	//colorAttachment.setStoreAction(MTLStoreActionStore);
	//colorAttachment.setLoadAction(MTLLoadActionClear);

	// NOTE: depthAttachment is set automatically by the MTKView
	//show(renderPassDescriptor.depthAttachment);

	renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);
	end;
end;

procedure MTLEndFrame;
begin
	with CurrentThreadContext do begin
	Fatal(renderEncoder = nil);

	renderEncoder.endEncoding;

	commandBuffer.presentDrawable(CurrentThreadContext.view.currentDrawable);
	commandBuffer.commit;

	commandBuffer := nil;
	renderEncoder := nil;
	drawing := false;
	end;
end;

procedure MTLSetClearColor (clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	view.setClearColor(clearColor);
	view.setColorPixelFormat(colorPixelFormat);
	view.setDepthStencilPixelFormat(depthStencilPixelFormat);
	end;
end;

procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);
var
	desc: MTLDepthStencilDescriptor;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin

	if pipeline.depthStencilState <> nil then
		pipeline.depthStencilState.release;

	desc := MTLDepthStencilDescriptor.alloc.init.autorelease;
	desc.setDepthCompareFunction(compareFunction);
	desc.setDepthWriteEnabled(depthWriteEnabled);
	desc.setFrontFaceStencil(frontFaceStencil);
	desc.setBackFaceStencil(backFaceStencil);
	desc.setLabel(NSSTR('MTLSetDepthStencil'));

	pipeline.depthStencilState := device.newDepthStencilStateWithDescriptor(desc);
	end;
end;

function MTLLoadTexture (bytes: pointer; width, height: integer; pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm): MTLTextureProtocol;
var
	imageFileLocation: NSURL;
	textureDescriptor: MTLTextureDescriptor;
	bytesPerRow: integer;
	region: MTLRegion;
	texture: MTLTextureProtocol;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin

	textureDescriptor := MTLTextureDescriptor.alloc.init.autorelease;
	textureDescriptor.setPixelFormat(pixelFormat);
	textureDescriptor.setWidth(width);
	textureDescriptor.setHeight(height);

	texture := device.newTextureWithDescriptor(textureDescriptor);
	Fatal(texture = nil, 'newTextureWithDescriptor failed');

	bytesPerRow := 4 * width;

	region := MTLRegionMake3D(0, 0, 0, width, height, 1);

	texture.replaceRegion_mipmapLevel_withBytes_bytesPerRow(region, 0, bytes, bytesPerRow);
	//show(texture);
	end;

	result := texture;
end;

procedure MTLMakeContextCurrent (context: TMetalContext);
begin
	CurrentThreadContext := context;
end;

function MTLCreateContext (view: MTKView): TMetalContext;
var
	context: TMetalContext;
begin
	context := TMetalContext.Create;
	context.view := view;
	context.device := view.device;

	Fatal(context.device = nil, 'no gpu device found.');
	Show(context.device, 'GPU:');
	
	context.commandQueue := context.device.newCommandQueue;

	// set default pixel formats
	view.setColorPixelFormat(MTLPixelFormatBGRA8Unorm);
	view.setDepthStencilPixelFormat(MTLPixelFormatDepth32Float);

	result := context;
end;

function MTLCreateLibrary (options: TMetalLibraryOptions): TMetalLibrary;

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
	metalLibrary: TMetalLibrary;
	error: NSError = nil;
	device: MTLDeviceProtocol;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);

	device := CurrentThreadContext.device;
	metalLibrary := TMetalLibrary.Create;

	if options.shaderName <> '' then
		metalLibrary.lib := CompileShader(device, options.shaderName)
	else if options.libraryName <> '' then
		metalLibrary.lib := device.newLibraryWithFile_error(NSSTR(options.libraryName), @error)
	else if options.libraryName = '' then
		metalLibrary.lib := device.newDefaultLibrary;

	Fatal(metalLibrary.lib = nil, 'no metal shaders could be loaded.', error);
	Show(metalLibrary.lib);

	result := metalLibrary;
end;

function MTLCreatePipeline (options: TMetalPipelineOptions): TMetalPipeline;
var
	shaderLibrary: TMetalLibrary;
	vertexFunction: MTLFunctionProtocol = nil;
	fragmentFunction: MTLFunctionProtocol = nil;
	
	colorAttachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;

	error: NSError = nil;
	pipeline: TMetalPipeline;
	device: MTLDeviceProtocol;
	view: MTKView;
	libraryOptions: TMetalLibraryOptions;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);

	pipeline := TMetalPipeline.Create;
	with pipeline do
		begin
			device := CurrentThreadContext.device;
			view := CurrentThreadContext.view;

			// Load shader library
			if options.shaderLibrary = nil then
				begin
					Fatal(SharedShaderLibrary <> nil, 'shared metal library is already loaded.');
					libraryOptions := TMetalLibraryOptions.Default;
					libraryOptions.shaderName := options.shaderName;
					libraryOptions.libraryName := options.libraryName;
					SharedShaderLibrary := MTLCreateLibrary(libraryOptions);
					shaderLibrary := SharedShaderLibrary;
				end
			else
				shaderLibrary := options.shaderLibrary;

			vertexFunction := shaderLibrary.GetFunction(options.vertexShader);
			Fatal(vertexFunction = nil, 'vertex shader not found.');

			fragmentFunction := shaderLibrary.GetFunction(options.fragmentShader);
			Fatal(fragmentFunction = nil, 'fragment shader not found.');

			pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init.autorelease;
			pipelineStateDescriptor.setVertexFunction(vertexFunction);
			pipelineStateDescriptor.setFragmentFunction(fragmentFunction);
			pipelineStateDescriptor.setDepthAttachmentPixelFormat(view.depthStencilPixelFormat);
			pipelineStateDescriptor.setVertexDescriptor(options.vertexDescriptor);

			colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
			colorAttachment.setPixelFormat(view.colorPixelFormat);

			if options.blendingEnabled then
				begin
					colorAttachment.setBlendingEnabled(true);

					colorAttachment.setRgbBlendOperation(options.rgbBlendOperation);
					colorAttachment.setAlphaBlendOperation(options.alphaBlendOperation);

					colorAttachment.setSourceRGBBlendFactor(options.sourceRGBBlendFactor);
					colorAttachment.setDestinationRGBBlendFactor(options.destinationRGBBlendFactor);

					colorAttachment.setSourceAlphaBlendFactor(options.sourceAlphaBlendFactor);
					colorAttachment.setDestinationAlphaBlendFactor(options.destinationAlphaBlendFactor);
				end;

			pipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineStateDescriptor, @error);

			Fatal(pipelineState = nil, 'pipeline creation failed.', error);
		end;

	result := pipeline;
end;


end.