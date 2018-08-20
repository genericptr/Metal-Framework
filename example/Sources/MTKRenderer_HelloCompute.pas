{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_HelloCompute;
interface
uses
	SIMDTypes, VectorMath, Metal, MetalKit, MetalPipeline,
	CocoaAll, MacOSAll, SysUtils;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			context: TMetalContext;
			renderShader: TMetalPipeline;
			computeShader: TMetalPipeline;

			viewportSize: vector_uint2;
			viewport: MTLViewport;
			inputTexture, outputTexture: MTLTextureProtocol;

	    threadgroupSize: MTLSize;
	    threadgroupCount: MTLSize;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	TGALoader, CocoaUtils;

const
	AAPLVertexInputIndexVertices     = 0;
	AAPLVertexInputIndexViewportSize = 1;
	AAPLTextureIndexInput  = 0;
	AAPLTextureIndexOutput = 1;

type
	TAAPLVertex = record
		position: TVec2;
		texCoord: TVec2;
	end;

function AAPLVertex(constref position: TVec2; constref texCoord: TVec2): TAAPLVertex;
begin
	result.position := position;
	result.texCoord := texCoord;
end;

type
	TBitmapImage = class
		public
			bytes: pointer;
			width, height: integer;
			bytesPerRow: integer;
		private
			image: NSImage;
			rep: NSBitmapImageRep;
		public
			constructor Create (path: string);
			destructor Destroy; override;
	end;

constructor TBitmapImage.Create (path: string);
var
	data: NSData;
begin
	image := NSImage.alloc.initWithContentsOfFile(NSSTR(path));
	data := image.TIFFRepresentation;
	rep := NSBitmapImageRep.imageRepWithData(data).retain;
	bytes := rep.bitmapData;
	width := trunc(image.size.width);
	height := trunc(image.size.height);
	bytesPerRow := rep.bytesPerRow;
end;

destructor TBitmapImage.Destroy;
begin
	rep.release;
	image.release;

	inherited;
end;

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
	viewportSize.x := Trunc(size.width);
	viewportSize.y := Trunc(size.height);

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := viewportSize.x;
	viewport.height := viewportSize.y;			
	viewport.znear := -1;
	viewport.zfar := 1;
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	size: single = 150;
	vertices: array[0..5] of TAAPLVertex;
begin
	vertices[0] := AAPLVertex(V2(size,  -size),  V2(1.0, 0.0));
	vertices[1] := AAPLVertex(V2(-size,  -size), V2(0.0, 0.0));
	vertices[2] := AAPLVertex(V2(-size,   size), V2(0.0, 1.0));
	vertices[3] := AAPLVertex(V2(size,  -size),  V2(1.0, 0.0));
	vertices[4] := AAPLVertex(V2(-size,   size), V2(0.0, 1.0));
	vertices[5] := AAPLVertex(V2(size,   size),  V2(1.0, 1.0));
	
	MTLBeginCommand;

		MTLBeginEncoding(computeShader);
			MTLSetTexture(inputTexture, AAPLTextureIndexInput);
			MTLSetTexture(outputTexture, AAPLTextureIndexOutput);
			MTLSetDispatchThreadgroups(threadgroupCount, threadgroupSize);
		MTLEndEncoding;

		MTLBeginEncoding(renderShader);
			MTLSetViewport(viewport);
			MTLSetVertexBytes(@vertices, sizeof(vertices), AAPLVertexInputIndexVertices);
			MTLSetVertexBytes(@viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);
			MTLSetFragmentTexture(outputTexture, AAPLTextureIndexOutput);
			MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);
		MTLEndEncoding;

	MTLEndCommand(true);
end;

procedure TMTKRenderer.dealloc;
begin
	renderShader.Free;
	computeShader.Free;
	context.Free;

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	error: NSError;
	options: TMetalPipelineOptions;
	libraryOptions: TMetalLibraryOptions;
	shaderLibrary: TMetalLibrary;
	image: TGAImage;
	//image: TBitmapImage;
	textureDescriptor: MTLTextureDescriptor;
	region: MTLRegion;
begin
	view := inView;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);
	
	// context
	context := MTLCreateContext(view);
	context.SetColorPixelFormat(MTLPixelFormatBGRA8Unorm_sRGB);
	context.SetPreferredFrameRate(0);
	context.MakeCurrent;

	// library
	libraryOptions := TMetalLibraryOptions.Default;
	libraryOptions.name := ResourcePath('Compute', 'metallib');
	shaderLibrary := MTLCreateLibrary(libraryOptions);

	// render shader
	options := TMetalPipelineOptions.Default;
	options.shaderLibrary := shaderLibrary;
	options.vertexShader := 'vertexShader';
	options.fragmentShader := 'samplingShader';
	renderShader := MTLCreatePipeline(options);

	// compute shader
	options := TMetalPipelineOptions.Default;
	options.shaderLibrary := shaderLibrary;
	options.kernelFunction := 'grayscaleKernel';
	computeShader := MTLCreatePipeline(options);

	// input texture
	image := LoadTGAFile(ResourcePath('Image', 'tga'));
	//image := TBitmapImage.Create(ResourcePath('Image', 'tga'));

	textureDescriptor := MTLTextureDescriptor.alloc.init.autorelease;
	textureDescriptor.setTextureType(MTLTextureType2D);
	textureDescriptor.setPixelFormat(MTLPixelFormatBGRA8Unorm);
	textureDescriptor.setWidth(image.width);
	textureDescriptor.setHeight(image.height);
	textureDescriptor.setUsage(MTLTextureUsageShaderRead);
	inputTexture := view.device.newTextureWithDescriptor(textureDescriptor);

	region := MTLRegionMake3D(0, 0, 0, textureDescriptor.width, textureDescriptor.height, 1);
	inputTexture.replaceRegion_mipmapLevel_withBytes_bytesPerRow(region, 0, image.bytes, image.bytesPerRow);

	// output texture
	textureDescriptor.setUsage(MTLTextureUsageShaderWrite or MTLTextureUsageShaderRead);
	outputTexture := view.device.newTextureWithDescriptor(textureDescriptor);

	// Set the  kernel's threadgroup size of 16x16
	threadgroupSize := MTLSizeMake(16, 16, 1);
	threadgroupCount.width  := (inputTexture.width  + threadgroupSize.width -  1) div threadgroupSize.width;
	threadgroupCount.height := (inputTexture.height + threadgroupSize.height - 1) div threadgroupSize.height;
	threadgroupCount.depth := 1;

	context.Draw;
end;

end.