{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MetalPipeline;
interface
uses
	MetalUtils, Metal, MetalKit, CocoaAll, SysUtils,
	{$ifndef COCOA_1010}
	// pre-10.10 FPC RTL CocoaAll.pas doesn't use MacOSAll types!
	// if you're using a compiler which supports the 10.10 headers
	// then enable -dCOCOA_1010 to use all types from MacOSAll.pas
	MacOSAll, CGImage, CGDataProvider, CGColorSpace;
	{$else}
	MacOSAll;
	{$endif}

type
	TMetalLibrary = class
		public
			lib: MTLLibraryProtocol;
			functions: NSMutableDictionary;
		public
			function GetFunction(name: string): MTLFunctionProtocol;
			destructor Destroy; override;
	end;

type
	TMetalPipeline = class
		public
			renderPipelineState: MTLRenderPipelineStateProtocol;
			computePipelineState: MTLComputePipelineStateProtocol;
			depthStencilState: MTLDepthStencilStateProtocol;
			shaderLibrary: TMetalLibrary;
		public
			destructor Destroy; override;
	end;


type
	TMetalContext = class
		private type TFrameState = (kMetalContextFrameStateOpen, kMetalContextFrameStateRender);
		public
			view: MTKView;
			device: MTLDeviceProtocol;
			commandQueue: MTLCommandQueueProtocol;
			currentPipeline: TMetalPipeline;
			textureLoader: MTKTextureLoader;

			// rendering
			commandBuffer: MTLCommandBufferProtocol;
			renderEncoder: MTLRenderCommandEncoderProtocol;
			computeEncoder: MTLComputeCommandEncoderProtocol;
			frameState: set of TFrameState;
		public
			class function SharedContext: TMetalContext;

			procedure SetPreferredFrameRate(newValue: integer);
			procedure SetColorPixelFormat(pixelFormat: MTLPixelFormat);
			procedure MakeCurrent;
			procedure Draw;
			
			destructor Destroy; override;
	end;

type
	TMetalLibraryOptions = record
		public
			name: string;													// path to compiled .metallib file OR .metal file which will be compiled at runtime
			preprocessorMacros: NSDictionary;			// A list of preprocessor macros to apply when compiling the library source.
																						// The macros are specified as key/value pairs, using an NSDictionary. 
																						// The keys must be NSString objects, and the values can be either NSString or NSNumber objects.
			fastMathEnabled: boolean;							// A Boolean value that indicates whether the compiler can perform optimizations for 
																						// floating-point arithmetic that may violate the IEEE 754 standard.
			languageVersion: MTLLanguageVersion;	// The language version used to interpret the library source code.
		public
			class function Default: TMetalLibraryOptions; static;
			constructor Create (_name: string);
	end;

type
	TMetalPipelineOptions = record
		public
			libraryName: string;					// path to compiled .metallib file
			shaderLibrary: TMetalLibrary;	// metal library to locate shader functions

			vertexShader: string;					// name of vertex function in shader file (see TMetalPipelineOptions.Default)
			fragmentShader: string;				// name of fragment function in shader file (see TMetalPipelineOptions.Default)
			kernelFunction: string;
			vertexDescriptor: MTLVertexDescriptor;
			pipelineDescriptor: MTLRenderPipelineDescriptor;
		public
			class function Default: TMetalPipelineOptions; static;
	end;

{ Drawing }
procedure MTLDraw(primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
procedure MTLDrawIndexed(primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);

{ Vertex Buffers }
procedure MTLSetVertexBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetVertexBuffer(buffer: MTLBufferProtocol; index: NSUInteger); overload; inline;
procedure MTLSetVertexBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);

procedure MTLSetFragmentBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);

{ Textures }
function MTLNewTexture(width, height: integer; textureType: MTLTextureType; pixelFormat: MTLPixelFormat; usage: MTLTextureUsage): MTLTextureProtocol; overload;
function MTLNewTexture(desc: MTLTextureDescriptor): MTLTextureProtocol; overload;

function MTLLoadTexture(path: string): MTLTextureProtocol;
function MTLLoadTexture(	bytes: pointer; 
													width, height: integer; textureType: MTLTextureType = MTLTextureType2D; 
													pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; 
													bytesPerComponent: integer = 4;
													usage: MTLTextureUsage = MTLTextureUsageShaderRead
													): MTLTextureProtocol;

function MTLCopyLastFrameTexture(texture: MTLTextureProtocol; hasAlpha: boolean = true): CGImageRef;
procedure MTLWriteTextureToFile(texture: MTLTextureProtocol; path: pchar; hasAlpha: boolean = true; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil); overload;
procedure MTLWriteTextureToFile(path: pchar; hasAlpha: boolean = true; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil); overload;
procedure MTLWriteTextureToClipboard(texture: MTLTextureProtocol; hasAlpha: boolean = true); overload;
procedure MTLWriteTextureToClipboard(hasAlpha: boolean = true); overload;

{ Buffers }
function MTLNewBuffer(bytes: pointer; len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol; overload;
function MTLNewBuffer(len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol; overload;

{ Rendering }
procedure MTLBeginFrame(pipeline: TMetalPipeline = nil); inline;
procedure MTLEndFrame; inline;

procedure MTLSetShader(pipeline: TMetalPipeline);

procedure MTLSetFragmentTexture(texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort(constref viewport: MTLViewport);
procedure MTLSetCullMode(mode: MTLCullMode);
procedure MTLSetFrontFacingWinding(winding: MTLWinding);

{ Compute }
procedure MTLBeginCommand;
procedure MTLEndCommand(waitUntilCompleted: boolean = false);
procedure MTLBeginEncoding(pipeline: TMetalPipeline; renderPassDescriptor: MTLRenderPassDescriptor = nil);
procedure MTLEndEncoding;

procedure MTLSetBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);
procedure MTLSetBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetBuffer(offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetBuffers(buffers: MTLBufferProtocol; offsets: NSUIntegerPtr; range: NSRange);
procedure MTLSetTexture(texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetTextures(textures: MTLTextureProtocol; range: NSRange);
procedure MTLSetDispatchThreadgroups(threadgroupsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize);

{ Context }
procedure MTLSetClearColor(clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
procedure MTLSetDepthStencil(pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);

{ Creation }
function MTLCreateContext(view: MTKView): TMetalContext;
function MTLCreateLibrary(options: TMetalLibraryOptions): TMetalLibrary;
function MTLCreatePipeline(options: TMetalPipelineOptions): TMetalPipeline;

procedure MTLMakeContextCurrent(context: TMetalContext);

function MTLCreatePipelineDescriptor: MTLRenderPipelineDescriptor;

{ Categories }
type
	MTLRenderPassDescriptorHelper = objccategory (MTLRenderPassDescriptor)
		function colorAttachmentAtIndex(index: integer): MTLRenderPassColorAttachmentDescriptor; message 'colorAttachmentAtIndex:';
	end;

type
	MTLRenderPipelineDescriptorHelper = objccategory (MTLRenderPipelineDescriptor)
		function colorAttachmentAtIndex(index: integer): MTLRenderPipelineColorAttachmentDescriptor; message 'colorAttachmentAtIndex:';
	end;

implementation
uses
	Variants;

const
	kError_InvalidContext = 'no current context';
	kError_UnopenedFrame = 'must call MTLBeginFrame first';
	kError_NoShader = 'no shader for current frame';

threadvar
	CurrentThreadContext: TMetalContext;

{=============================================}
{@! ___UTILS___ } 
{=============================================}

function NSSTR(str: string): NSString; overload;
begin
	result := NSString.stringWithCString_length(@str[1], length(str));
end;

function MTLCreatePipelineDescriptor: MTLRenderPipelineDescriptor;
var
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;
	colorAttachment: MTLRenderPipelineColorAttachmentDescriptor;
	view: MTKView;
begin
	view := CurrentThreadContext.view;

	pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init.autorelease;
	pipelineStateDescriptor.setDepthAttachmentPixelFormat(view.depthStencilPixelFormat);
	pipelineStateDescriptor.setSampleCount(view.sampleCount);

	colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	colorAttachment.setPixelFormat(view.colorPixelFormat);

	result := pipelineStateDescriptor;
end;

function MTLRenderPassDescriptorHelper.colorAttachmentAtIndex(index: integer): MTLRenderPassColorAttachmentDescriptor;
begin
	result := self.colorAttachments.objectAtIndexedSubscript(index);
end;

function MTLRenderPipelineDescriptorHelper.colorAttachmentAtIndex(index: integer): MTLRenderPipelineColorAttachmentDescriptor;
begin
	result := self.colorAttachments.objectAtIndexedSubscript(index);
end;

{=============================================}
{@! ___METAL LIBRARY OPTIONS___ } 
{=============================================}

constructor TMetalLibraryOptions.Create (_name: string);
begin
	name := _name;
end;

class function TMetalLibraryOptions.Default: TMetalLibraryOptions;
begin
	result.name := '';
	result.preprocessorMacros := nil;
	result.fastMathEnabled := true;
end;

class function TMetalPipelineOptions.Default: TMetalPipelineOptions;
begin
	result.libraryName := '';
	result.vertexShader := 'vertexShader';
	result.fragmentShader := 'fragmentShader';
	result.kernelFunction := '';
	result.vertexDescriptor := nil;
	result.shaderLibrary := nil;
	result.pipelineDescriptor := nil;
end;

{=============================================}
{@! ___METAL CONTEXT___ } 
{=============================================}

class function TMetalContext.SharedContext: TMetalContext;
begin
	result := CurrentThreadContext;
end;

procedure TMetalContext.Draw;
begin
	view.draw
end;

procedure TMetalContext.SetPreferredFrameRate(newValue: integer);
begin
	view.setPreferredFramesPerSecond(newValue);
end;

procedure TMetalContext.SetColorPixelFormat(pixelFormat: MTLPixelFormat);
begin
	view.setColorPixelFormat(pixelFormat);
end;

procedure TMetalContext.MakeCurrent;
begin
	CurrentThreadContext := self;
end;

destructor TMetalContext.Destroy;
begin
	commandQueue.release;
	textureLoader.release;

	inherited;
end;

{=============================================}
{@! ___METAL LIBRARY___ } 
{=============================================}

function TMetalLibrary.GetFunction(name: string): MTLFunctionProtocol;
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

{=============================================}
{@! ___METAL PIPELINE___ } 
{=============================================}

destructor TMetalPipeline.Destroy;
begin
	renderPipelineState.release;
	computePipelineState.release;
	depthStencilState.release;
	if shaderLibrary <> nil then
		shaderLibrary.Free;
	inherited;
end;

procedure FinalizeDrawing(pipeline: TMetalPipeline);
var
	renderEncoder: MTLRenderCommandEncoderProtocol;
begin
	Fatal(CurrentThreadContext.currentPipeline = nil, kError_NoShader);

	renderEncoder := CurrentThreadContext.renderEncoder;

	// set pipeline state
	renderEncoder.setRenderPipelineState(pipeline.renderPipelineState);

	// set depth stencil if available
	if pipeline.depthStencilState <> nil then
		renderEncoder.setDepthStencilState(pipeline.depthStencilState);
end;

procedure ValidateRenderFrame;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	Fatal(CurrentThreadContext.frameState = [], kError_UnopenedFrame);
end;

procedure MTLSetShader(pipeline: TMetalPipeline);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	Fatal(CurrentThreadContext.frameState = [], kError_UnopenedFrame);
	CurrentThreadContext.currentPipeline := pipeline;
end;

procedure MTLDrawIndexed(primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	FinalizeDrawing(currentPipeline);
	renderEncoder.drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset(primitiveType, indexCount, indexType, indexBuffer, indexBufferOffset);
	frameState += [kMetalContextFrameStateRender];
	end;
end;

procedure MTLDraw(primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	FinalizeDrawing(currentPipeline);
	renderEncoder.drawPrimitives_vertexStart_vertexCount(primitiveType, vertexStart, vertexCount);
	frameState += [kMetalContextFrameStateRender];
	end;
end;

procedure MTLSetCullMode(mode: MTLCullMode);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setCullMode(mode);
	end;
end;

procedure MTLSetFrontFacingWinding(winding: MTLWinding);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFrontFacingWinding(winding);
	end;
end;

procedure MTLSetViewPort(constref viewport: MTLViewport);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setViewport(viewport);
	end;
end;

procedure MTLSetFragmentTexture(texture: MTLTextureProtocol; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetFragmentBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetFragmentBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setFragmentBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetVertexBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setVertexBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetVertexBuffer(buffer: MTLBufferProtocol; index: NSUInteger);
begin
	MTLSetVertexBuffer(buffer, 0, index);
end;

procedure MTLSetVertexBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	ValidateRenderFrame;
	with CurrentThreadContext do begin
	renderEncoder.setVertexBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLBeginFrame(pipeline: TMetalPipeline);
begin
	MTLBeginCommand;
	MTLBeginEncoding(pipeline);
end;

procedure MTLEndFrame;
begin
	MTLEndEncoding;
	MTLEndCommand;
end;

procedure MTLBeginEncoding(pipeline: TMetalPipeline; renderPassDescriptor: MTLRenderPassDescriptor = nil);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	currentPipeline := pipeline;
	if (pipeline = nil) or (pipeline.renderPipelineState <> nil) then
		begin
			if renderPassDescriptor = nil then
				renderPassDescriptor := view.currentRenderPassDescriptor;
			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);
		end
	else if pipeline.computePipelineState <> nil then
		begin
			computeEncoder := commandBuffer.computeCommandEncoder;
			computeEncoder.setComputePipelineState(currentPipeline.computePipelineState);
		end
	else
		Fatal('invalid pipline state');
	end;
end;

procedure MTLEndEncoding; 
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	if renderEncoder <> nil then
		begin
			renderEncoder.endEncoding;
			renderEncoder := nil;
		end
	else if computeEncoder <> nil then
		begin
			computeEncoder.endEncoding;
			computeEncoder := nil;
		end;
	currentPipeline := nil;
	end;
end;

procedure MTLBeginCommand;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	commandBuffer := commandQueue.commandBuffer;
	frameState += [kMetalContextFrameStateOpen];
	end;
end;

procedure MTLEndCommand(waitUntilCompleted: boolean = false);
begin
	with CurrentThreadContext do begin
	if kMetalContextFrameStateRender in frameState then
		commandBuffer.presentDrawable(CurrentThreadContext.view.currentDrawable);
	commandBuffer.commit;
	if waitUntilCompleted then
		commandBuffer.waitUntilCompleted;
	// we need the most recent commandBuffer for saving textures
	// so keep the refence alive
	//commandBuffer := nil;
	frameState := [];
	end;
end;

procedure MTLSetBytes(bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetBuffer(buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetBuffer(offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBufferOffset_atIndex(offset, index);
	end;
end;

procedure MTLSetBuffers(buffers: MTLBufferProtocol; offsets: NSUIntegerPtr; range: NSRange);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBuffers_offsets_withRange(buffers, offsets, range);
	end;
end;

procedure MTLSetTexture(texture: MTLTextureProtocol; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetTextures(textures: MTLTextureProtocol; range: NSRange);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setTextures_withRange(textures, range);
	end;
end;

procedure MTLSetDispatchThreadgroups(threadgroupsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.dispatchThreadgroups_threadsPerThreadgroup(threadgroupsPerGrid, threadsPerThreadgroup);
	end;
end;

procedure MTLSetClearColor(clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	view.setClearColor(clearColor);
	view.setColorPixelFormat(colorPixelFormat);
	view.setDepthStencilPixelFormat(depthStencilPixelFormat);
	end;
end;

procedure MTLSetDepthStencil(pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);
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

function MTLNewBuffer(bytes: pointer; len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	result := CurrentThreadContext.device.newBufferWithBytes_length_options(bytes, len, options);
end;

function MTLNewBuffer(len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	result := CurrentThreadContext.device.newBufferWithLength_options(len, options);
end;

function MTLLoadTexture(path: string): MTLTextureProtocol;
var
	error: NSError;
	data: NSData;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	if textureLoader = nil then
		textureLoader := MTKTextureLoader.alloc.initWithDevice(device);

	data := NSData.dataWithContentsOfFile_options_error(NSSTR(path), 0, @error);
	Fatal(data = nil, 'Error loading texture', error);

	result := textureLoader.newTextureWithData_options_error(data, nil, @error);
	Fatal(result = nil, 'Error loading texture', error);
	end;
end;

function MTLLoadTexture(	bytes: pointer; 
													width, height: integer; textureType: MTLTextureType = MTLTextureType2D; 
													pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; 
													bytesPerComponent: integer = 4;
													usage: MTLTextureUsage = MTLTextureUsageShaderRead
													): MTLTextureProtocol;
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
	textureDescriptor.setTextureType(MTLTextureType2D);
	textureDescriptor.setPixelFormat(pixelFormat);
	textureDescriptor.setWidth(width);
	textureDescriptor.setHeight(height);
	textureDescriptor.setUsage(usage);

	texture := device.newTextureWithDescriptor(textureDescriptor);
	Fatal(texture = nil, 'newTextureWithDescriptor failed');

	if bytes <> nil then
		begin
			bytesPerRow := bytesPerComponent * width;
			region := MTLRegionMake3D(0, 0, 0, width, height, 1);
			texture.replaceRegion_mipmapLevel_withBytes_bytesPerRow(region, 0, bytes, bytesPerRow);
		end;

	end;

	result := texture;
end;

function MTLNewTexture(width, height: integer; textureType: MTLTextureType; pixelFormat: MTLPixelFormat; usage: MTLTextureUsage): MTLTextureProtocol;
begin
	result := MTLLoadTexture(nil, width, height, textureType, pixelFormat, 0, usage);
end;

function MTLNewTexture(desc: MTLTextureDescriptor): MTLTextureProtocol;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	result :=  CurrentThreadContext.device.newTextureWithDescriptor(desc);
end;

procedure MTLWriteTextureToFile(path: pchar; hasAlpha: boolean; fileType: NSBitmapImageFileType; imageProps: NSDictionary);
begin
  Fatal(CurrentThreadContext = nil, kError_InvalidContext);
  with CurrentThreadContext do begin
    view.setFramebufferOnly(false);
    MTLWriteTextureToFile(view.currentDrawable.texture, path, hasAlpha, fileType, imageProps);
    view.setFramebufferOnly(true);
  end;
end;

function MTLCopyLastFrameTexture(texture: MTLTextureProtocol; hasAlpha: boolean): CGImageRef;
var
  width, height, bytesPerRow, bytesCount: integer;
  bytes: pointer;
  colorSpace: CGColorSpaceRef;
  bitmapInfo: CGBitmapInfo;
  provider: CGDataProviderRef;
  imageRef: CGImageRef;
  blitEncoder: MTLBlitCommandEncoderProtocol;
  bitmapContext: CGContextRef;
  decompressedImageRef: CGImageRef;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	Fatal(texture.pixelFormat <> MTLPixelFormatBGRA8Unorm, 'texture must be MTLPixelFormatBGRA8Unorm pixel format.');

	// read bytes
	width := texture.width;
	height := texture.height;
  bytesPerRow := texture.width * 4;
	bytesCount := width * height * 4;
	bytes := GetMem(bytesCount);

	// blit from last command buffer
	with CurrentThreadContext do 
	begin
		commandBuffer := commandQueue.commandBuffer;
		blitEncoder := commandBuffer.blitCommandEncoder;
		view.draw;
		blitEncoder.synchronizeResource(texture);
		blitEncoder.endEncoding;
		commandBuffer.waitUntilCompleted;
	end;

	// get bytes from texture
  texture.getBytes_bytesPerRow_fromRegion_mipmapLevel(bytes, bytesPerRow, MTLRegionMake2D(0, 0, width, height), 0);

  // create CGImage from texture bytes
  colorSpace := CGColorSpaceCreateDeviceRGB;
	bitmapInfo := kCGImageAlphaFirst or kCGBitmapByteOrder32Little;
	provider := CGDataProviderCreateWithData(nil, bytes, bytesCount, nil);
	imageRef := CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, bitmapInfo, provider, nil, 1, kCGRenderingIntentDefault);

	if not hasAlpha then
		begin
		  bitmapInfo := kCGImageAlphaNoneSkipLast or kCGBitmapByteOrder32Little;
		  bitmapContext := CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef),  colorSpace, bitmapInfo);
		  CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
		  decompressedImageRef := CGBitmapContextCreateImage(bitmapContext);
		  CFRelease(imageRef);
		  CFRelease(bitmapContext);
		  result := decompressedImageRef;
	  end
	else
		result := imageRef;

	CFRelease(provider);
	CFRelease(colorSpace);
end; 

procedure MTLWriteTextureToFile(texture: MTLTextureProtocol; path: pchar; hasAlpha: boolean; fileType: NSBitmapImageFileType; imageProps: NSDictionary);
var
  imageRef: CGImageRef;
  finalImage: NSImage;
  imageData: NSData;
  imageRep: NSBitmapImageRep;
begin
	imageRef := MTLCopyLastFrameTexture(texture, hasAlpha);

	if imageRef <> nil then
		begin
			finalImage := NSImage.alloc.initWithCGImage_size(imageRef, NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
			imageData := finalImage.TIFFRepresentation;
			imageRep := NSBitmapImageRep.imageRepWithData(imageData);
			imageData := imageRep.representationUsingType_properties(fileType, imageProps);
			imageData.writeToFile_atomically(NSSTR(path), false);
			finalImage.release;
			CFRelease(imageRef);
		end;
end;

procedure MTLWriteTextureToClipboard(hasAlpha: boolean);
begin
	MTLWriteTextureToClipboard(nil, hasAlpha);
end;

procedure MTLWriteTextureToClipboard(texture: MTLTextureProtocol; hasAlpha: boolean);
var
  imageRef: CGImageRef;
  finalImage: NSImage;
  pb: NSPasteboard;
begin
	if texture = nil then
		begin
			Fatal(CurrentThreadContext = nil, kError_InvalidContext);
			with CurrentThreadContext do begin
			  view.setFramebufferOnly(false);
			  texture := view.currentDrawable.texture;
			  view.setFramebufferOnly(true);
			end;
		end;

	imageRef := MTLCopyLastFrameTexture(texture, hasAlpha);
	if imageRef <> nil then
		begin
			finalImage := NSImage.alloc.initWithCGImage_size(imageRef, NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
			
			pb := NSPasteboard.generalPasteboard;
			pb.clearContents;
			pb.writeObjects(NSArray.arrayWithObject(finalImage));
			
			finalImage.release;
			CFRelease(imageRef);
		end;
end;

procedure MTLMakeContextCurrent(context: TMetalContext);
begin
	CurrentThreadContext := context;
end;

function MTLCreateContext(view: MTKView): TMetalContext;
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

function MTLCreateLibrary(options: TMetalLibraryOptions): TMetalLibrary;

	function CompileShader(device: MTLDeviceProtocol; name: string): MTLLibraryProtocol;
	var
		source: NSString;
		error: NSError;
		compileOptions: MTLCompileOptions;
	begin
		source := NSString.stringWithContentsOfFile_encoding_error(NSSTR(name), NSUTF8StringEncoding, @error);
		Fatal(source = nil, 'error loading library file', error);

		compileOptions := MTLCompileOptions.alloc.init.autorelease;
		compileOptions.setPreprocessorMacros(options.preprocessorMacros);
		compileOptions.setFastMathEnabled(options.fastMathEnabled);
		// if the there is language version specified use this
		// otherwise if no version is given MTLCompileOptions will
		// use the latest version available
		if options.languageVersion > 0 then 
			compileOptions.setLanguageVersion(compileOptions.languageVersion);

		result := device.newLibraryWithSource_options_error(source, compileOptions, @error);
		Fatal(result = nil, 'error compiling library: ', error);
	end;

var
	metalLibrary: TMetalLibrary;
	error: NSError = nil;
	device: MTLDeviceProtocol;
	extension: string;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);

	device := CurrentThreadContext.device;
	metalLibrary := TMetalLibrary.Create;
	extension := ExtractFileExt(options.name);

	if extension = '.metal' then
		metalLibrary.lib := CompileShader(device, options.name)
	else if extension = '.metallib' then
		metalLibrary.lib := device.newLibraryWithFile_error(NSSTR(options.name), @error)
	else if options.name = '' then
		metalLibrary.lib := device.newDefaultLibrary
	else
		Fatal('invalid library name');

	Fatal(metalLibrary.lib = nil, 'no metal shaders could be loaded.', error);
	Show(metalLibrary.lib);

	result := metalLibrary;
end;

function MTLCreatePipeline(options: TMetalPipelineOptions): TMetalPipeline;
var
	vertexFunction: MTLFunctionProtocol = nil;
	fragmentFunction: MTLFunctionProtocol = nil;
	kernelFunction: MTLFunctionProtocol = nil;

	colorAttachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineDescriptor: MTLRenderPipelineDescriptor;

	error: NSError = nil;
	pipeline: TMetalPipeline;
	device: MTLDeviceProtocol;
	view: MTKView;
	libraryOptions: TMetalLibraryOptions;
	i: integer;
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
					libraryOptions := TMetalLibraryOptions.Create(options.libraryName);
					shaderLibrary := MTLCreateLibrary(libraryOptions);
				end
			else
				shaderLibrary := options.shaderLibrary;

			if options.kernelFunction <> '' then
				begin
					kernelFunction := shaderLibrary.GetFunction(options.kernelFunction);
					Fatal(kernelFunction = nil, 'kernel function not found.');

					computePipelineState := device.newComputePipelineStateWithFunction_error(kernelFunction, @error);
					Fatal(computePipelineState = nil, 'pipeline creation failed.', error);
				end
			else
				begin
					vertexFunction := shaderLibrary.GetFunction(options.vertexShader);
					Fatal(vertexFunction = nil, 'vertex function not found.');

					fragmentFunction := shaderLibrary.GetFunction(options.fragmentShader);
					Fatal(fragmentFunction = nil, 'fragment function not found.');

					if options.pipelineDescriptor <> nil then
						pipelineDescriptor := options.pipelineDescriptor
					else
						begin
							pipelineDescriptor := MTLRenderPipelineDescriptor.alloc.init.autorelease;
							pipelineDescriptor.setDepthAttachmentPixelFormat(view.depthStencilPixelFormat);
							pipelineDescriptor.setVertexDescriptor(options.vertexDescriptor);
							
							// default color attachment
							pipelineDescriptor.colorAttachmentAtIndex(0).setPixelFormat(view.colorPixelFormat);
						end;

					// always seting vertex/fragment function
					pipelineDescriptor.setVertexFunction(vertexFunction);
					pipelineDescriptor.setFragmentFunction(fragmentFunction);

					renderPipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineDescriptor, @error);

					Fatal(renderPipelineState = nil, 'pipeline creation failed.', error);
				end;
		end;

	result := pipeline;
end;


end.