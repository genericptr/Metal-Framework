{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MetalPipeline;
interface
uses
	MetalUtils, Metal, MetalKit, CocoaAll, SysUtils;

type
	TMetalLibrary = class
		lib: MTLLibraryProtocol;
		functions: NSMutableDictionary;

		function GetFunction (name: string): MTLFunctionProtocol;
		destructor Destroy; override;
	end;

type
	TMetalPipeline = class
		renderPipelineState: MTLRenderPipelineStateProtocol;
		computePipelineState: MTLComputePipelineStateProtocol;
		depthStencilState: MTLDepthStencilStateProtocol;
		shaderLibrary: TMetalLibrary;

		destructor Destroy; override;
	end;


type
	TMetalContext = class
		view: MTKView;
		device: MTLDeviceProtocol;
		commandQueue: MTLCommandQueueProtocol;
		currentPipeline: TMetalPipeline;
		textureLoader: MTKTextureLoader;

		// rendering
		commandBuffer: MTLCommandBufferProtocol;
		renderEncoder: MTLRenderCommandEncoderProtocol;
		computeEncoder: MTLComputeCommandEncoderProtocol;
		drawing: boolean;

		class function SharedContext: TMetalContext;

		procedure SetPreferredFrameRate(newValue: integer);
		procedure SetColorPixelFormat(pixelFormat: MTLPixelFormat);
		procedure MakeCurrent;
		procedure Draw;
		
		destructor Destroy; override;
	end;

type
	TMetalLibraryOptions = record
		name: string;			// path to compiled .metallib file OR .metal file which will be compiled at runtime
		class function Default: TMetalLibraryOptions; static;
		constructor Create (_name: string);
	end;

type
	TMetalPipelineOptions = record

		libraryName: string;					// path to compiled .metallib file
		shaderLibrary: TMetalLibrary;	// metal library to locate shader functions

		vertexShader: string;				// name of vertex function in shader file (see TMetalPipelineOptions.Default)
		fragmentShader: string;			// name of fragment function in shader file (see TMetalPipelineOptions.Default)
		kernelFunction: string;
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

{ Vertex Buffers }
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetVertexBuffer (buffer: MTLBufferProtocol; index: NSUInteger); overload; inline;
procedure MTLSetVertexBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

procedure MTLSetFragmentBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
procedure MTLSetFragmentBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);

{ Textures }
function MTLLoadTexture (path: string): MTLTextureProtocol;
function MTLLoadTexture (bytes: pointer; width, height: integer; textureType: MTLTextureType = MTLTextureType2D; pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; bytesPerComponent: integer = 4): MTLTextureProtocol;

procedure MTLWriteTextureToFile(texture: MTLTextureProtocol; path: pchar; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil); overload;
procedure MTLWriteTextureToFile(path: pchar; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil); overload;

{ Buffers }
function MTLNewBuffer (bytes: pointer; len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol; overload;
function MTLNewBuffer (len: NSUInteger; options: MTLResourceOptions = MTLResourceCPUCacheModeDefaultCache): MTLBufferProtocol; overload;

{ Rendering }
procedure MTLBeginFrame (pipeline: TMetalPipeline = nil); inline;
procedure MTLEndFrame; inline;

procedure MTLSetShader (pipeline: TMetalPipeline);

procedure MTLSetFragmentTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetViewPort (constref viewport: MTLViewport);
procedure MTLSetCullMode (mode: MTLCullMode);
procedure MTLSetFrontFacingWinding (winding: MTLWinding);

{ Compute }
procedure MTLBeginCommand;
procedure MTLEndCommand;
procedure MTLBeginEncoding (pipeline: TMetalPipeline);
procedure MTLEndEncoding;

procedure MTLSetBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
procedure MTLSetBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetBuffer (offset: NSUInteger; index: NSUInteger); overload;
procedure MTLSetBuffers (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr; range: NSRange);
procedure MTLSetTexture (texture: MTLTextureProtocol; index: NSUInteger);
procedure MTLSetTextures (textures: MTLTextureProtocol; range: NSRange);
procedure MTLSetDispatchThreadgroups (threadgroupsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize);

{ Context }
procedure MTLSetClearColor (clearColor: MTLClearColor; colorPixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; depthStencilPixelFormat: MTLPixelFormat = MTLPixelFormatDepth32Float);
procedure MTLSetDepthStencil (pipeline: TMetalPipeline; compareFunction: MTLCompareFunction = MTLCompareFunctionAlways; depthWriteEnabled: boolean = false; frontFaceStencil: MTLStencilDescriptor = nil; backFaceStencil: MTLStencilDescriptor = nil);

{ Creation }
function MTLCreateContext (view: MTKView): TMetalContext;
function MTLCreateLibrary (options: TMetalLibraryOptions): TMetalLibrary;
function MTLCreatePipeline (options: TMetalPipelineOptions): TMetalPipeline;

procedure MTLMakeContextCurrent (context: TMetalContext);

implementation
uses
	MacOSAll,
	CGImage, CGDataProvider, CGColorSpace; // FPC RTL CocoaAll.pas doesn't use MacOSAll types!

const
	kError_InvalidContext = 'no current context';
	kError_UnopenedFrame = 'must call MTLBeginFrame first';
	kError_NoShader = 'no shader for current frame';

threadvar
	CurrentThreadContext: TMetalContext;

function NSSTR(str: string): NSString; overload;
begin
	result := NSString.stringWithCString_length(@str[1], length(str));
end;

constructor TMetalLibraryOptions.Create (_name: string);
begin
	name := _name;
end;

class function TMetalLibraryOptions.Default: TMetalLibraryOptions;
begin
	result.name := '';
end;

class function TMetalPipelineOptions.Default: TMetalPipelineOptions;
begin
	result.libraryName := '';
	result.vertexShader := 'vertexShader';
	result.fragmentShader := 'fragmentShader';
	result.kernelFunction := '';
	result.vertexDescriptor := nil;
	result.shaderLibrary := nil;

	result.blendingEnabled := false;
	result.sourceRGBBlendFactor := MTLBlendFactorOne;
	result.destinationRGBBlendFactor := MTLBlendFactorZero;
	result.rgbBlendOperation := MTLBlendOperationAdd;
	result.sourceAlphaBlendFactor := MTLBlendFactorOne;
	result.destinationAlphaBlendFactor := MTLBlendFactorZero;
	result.alphaBlendOperation := MTLBlendOperationAdd;
end;

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
	renderPipelineState.release;
	computePipelineState.release;
	depthStencilState.release;
	if shaderLibrary <> nil then
		shaderLibrary.Free;
	inherited;
end;

procedure FinalizeDrawing (pipeline: TMetalPipeline);
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
begin
	MTLBeginCommand;
	MTLBeginEncoding(pipeline);
end;

procedure MTLEndFrame;
begin
	MTLEndEncoding;
	MTLEndCommand;
end;

procedure MTLBeginEncoding (pipeline: TMetalPipeline);
var
	renderPassDescriptor: MTLRenderPassDescriptor;
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	currentPipeline := pipeline;
	if (pipeline = nil) or (pipeline.renderPipelineState <> nil) then
		begin
			renderPassDescriptor := view.currentRenderPassDescriptor;

			// NOTE: MTKView does this for us
			//colorAttachment := renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
			//colorAttachment.setTexture(view.currentDrawable.texture);
			//colorAttachment.setClearColor(view.clearColor);
			//colorAttachment.setStoreAction(MTLStoreActionStore);
			//colorAttachment.setLoadAction(MTLLoadActionClear);

			// NOTE: depthAttachment is set automatically by the MTKView
			//show(renderPassDescriptor.depthAttachment);

			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

			// NOTE: this is called in MTLDraw so multiple shader can be used inside Begin/EndFrame calls
			//if currentPipeline <> nil then
			//	begin
			//		renderEncoder.setRenderPipelineState(currentPipeline.renderPipelineState);
			//		if currentPipeline.depthStencilState <> nil then
			//			renderEncoder.setDepthStencilState(currentPipeline.depthStencilState);
			//	end;
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
	drawing := true;
	end;
end;

procedure MTLEndCommand;
begin
	with CurrentThreadContext do begin
	commandBuffer.presentDrawable(CurrentThreadContext.view.currentDrawable);
	commandBuffer.commit;
	commandBuffer := nil;
	drawing := false;
	end;
end;

procedure MTLSetBytes (bytes: pointer; len: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBytes_length_atIndex(bytes, len, index);
	end;
end;

procedure MTLSetBuffer (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBuffer_offset_atIndex(buffer, offset, index);
	end;
end;

procedure MTLSetBuffer (offset: NSUInteger; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBufferOffset_atIndex(offset, index);
	end;
end;

procedure MTLSetBuffers (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr; range: NSRange);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setBuffers_offsets_withRange(buffers, offsets, range);
	end;
end;

procedure MTLSetTexture (texture: MTLTextureProtocol; index: NSUInteger);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setTexture_atIndex(texture, index);
	end;
end;

procedure MTLSetTextures (textures: MTLTextureProtocol; range: NSRange);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.setTextures_withRange(textures, range);
	end;
end;

procedure MTLSetDispatchThreadgroups (threadgroupsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	computeEncoder.dispatchThreadgroups_threadsPerThreadgroup(threadgroupsPerGrid, threadsPerThreadgroup);
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

function MTLLoadTexture (path: string): MTLTextureProtocol;
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

function MTLLoadTexture (bytes: pointer; width, height: integer; textureType: MTLTextureType = MTLTextureType2D; pixelFormat: MTLPixelFormat = MTLPixelFormatBGRA8Unorm; bytesPerComponent: integer = 4): MTLTextureProtocol;
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

	texture := device.newTextureWithDescriptor(textureDescriptor);
	Fatal(texture = nil, 'newTextureWithDescriptor failed');

	bytesPerRow := bytesPerComponent * width;

	region := MTLRegionMake3D(0, 0, 0, width, height, 1);

	texture.replaceRegion_mipmapLevel_withBytes_bytesPerRow(region, 0, bytes, bytesPerRow);
	//show(texture);
	end;

	result := texture;
end;

procedure MTLWriteTextureToFile(path: pchar; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil);
begin
	Fatal(CurrentThreadContext = nil, kError_InvalidContext);
	with CurrentThreadContext do begin
	view.setFramebufferOnly(false);
	view.draw;
	view.draw;
	view.draw;
	MTLWriteTextureToFile(view.currentDrawable.texture, path);
	view.setFramebufferOnly(true);
	end;
end;

procedure MTLWriteTextureToFile(texture: MTLTextureProtocol; path: pchar; fileType: NSBitmapImageFileType = NSPNGFileType; imageProps: NSDictionary = nil);
var
  width, height, bytesPerRow, bytesCount: integer;
  bytes: pointer;
  colorSpace: CGColorSpaceRef;
  bitmapInfo: CGBitmapInfo;
  provider: CGDataProviderRef;
  imageRef: CGImageRef;
  finalImage: NSImage;
  imageData: NSData;
  imageRep: NSBitmapImageRep;
begin  
	
	Fatal(texture.pixelFormat <> MTLPixelFormatBGRA8Unorm, 'texture must be MTLPixelFormatBGRA8Unorm pixel format.');

	// read bytes
	width := texture.width;
	height := texture.height;
	bytesPerRow := texture.width * 4;
	bytesCount := width * height * 4;
	bytes := GetMem(bytesCount);

(*
	//https://forums.developer.apple.com/thread/95327
	blitEncoder: MTLBlitCommandEncoderProtocol;
	imageBuffer: MTLBufferProtocol;

	imageBuffer := view.device.newBufferWithLength_options(bytesCount, MTLResourceCPUCacheModeDefaultCache);
	blitEncoder := commandBuffer.blitCommandEncoder;
	blitEncoder.copyFromTexture(
															texture,  
					                    {sourceSlice:} 0,  
					                    {sourceLevel:} 0,  
					                    {sourceOrigin:} MTLOriginMake(0, 0, 0),  
					                    {sourceSize:} MTLSizeMake(width, height, 1),  
					                    {toBuffer:} imageBuffer,  
					                    {destinationOffset:} 0,  
					                    {destinationBytesPerRow:} bytesPerRow,  
					                    {destinationBytesPerImage:} 0);
	blitEncoder.endEncoding;

	//BlockMove(bytes, imageBuffer.contents, imageBuffer.length);  
*)

	texture.getBytes_bytesPerRow_fromRegion_mipmapLevel(bytes, bytesPerRow, MTLRegionMake2D(0, 0, width, height), 0);

	colorSpace := CGColorSpaceCreateDeviceRGB;
	bitmapInfo := kCGImageAlphaFirst or kCGBitmapByteOrder32Little;
	provider := CGDataProviderCreateWithData(nil, bytes, bytesCount, nil);
	imageRef := CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, bitmapInfo, provider, nil, 1, kCGRenderingIntentDefault);

	finalImage := NSImage.alloc.initWithCGImage_size(imageRef, NSMakeSize(width, height));
	imageData := finalImage.TIFFRepresentation;
	imageRep := NSBitmapImageRep.imageRepWithData(imageData);
	//imageProps := NSDictionary.dictionaryWithObject_forKey(NSNumber.numberWithFloat(1), NSImageCompressionFactor);
	imageData := imageRep.representationUsingType_properties(fileType, imageProps);
	imageData.writeToFile_atomically(NSSTR(path), false);

	CFRelease(provider);
	CFRelease(imageRef);
	CFRelease(colorSpace);
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

function MTLCreatePipeline (options: TMetalPipelineOptions): TMetalPipeline;
var
	vertexFunction: MTLFunctionProtocol = nil;
	fragmentFunction: MTLFunctionProtocol = nil;
	kernelFunction: MTLFunctionProtocol = nil;

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

					renderPipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineStateDescriptor, @error);

					Fatal(renderPipelineState = nil, 'pipeline creation failed.', error);
				end;
		end;

	result := pipeline;
end;


end.