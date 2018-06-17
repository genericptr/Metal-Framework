{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_BasicTexturing;
interface
uses
	SIMDTypes, TGALoader,
	Metal, MetalKit, MetalUtils,
	CocoaAll, MacOSAll, SysUtils;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			device: MTLDeviceProtocol;
			pipelineState: MTLRenderPipelineStateProtocol;
			commandQueue: MTLCommandQueueProtocol;
			viewportSize: vector_uint2;
			viewport: MTLViewport;

			vertexBuffer: MTLBufferProtocol;
			texture: MTLTextureProtocol;

			procedure drawTexturedQuad; message 'drawTexturedQuad';
			procedure loadTexture; message 'loadTexture';

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

// NOTE: these constants are referenced in the shader
const
	AAPLVertexInputIndexVertices     = 0;
	AAPLVertexInputIndexViewportSize = 1;
	AAPLTextureIndexBaseColor = 0;

type
	TAAPLVertex = record
		position: vector_float2;
		texCoord: vector_float2;
	end;

type
	TAAPLQuad = array[0..5] of TAAPLVertex;

function AAPLVertex(constref position: vector_float2; constref texCoord: vector_float2): TAAPLVertex;
begin
	result.position := position;
	result.texCoord := texCoord;
end;

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
	// Save the size of the drawable as we'll pass these
	//   values to our vertex shader when we draw
	viewportSize.x := Trunc(size.width);
	viewportSize.y := Trunc(size.height);

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := viewportSize.x;
	viewport.height := viewportSize.y;			
	viewport.znear := -1;
	viewport.zfar := 1;
end;

procedure TMTKRenderer.drawTexturedQuad; 
var
	size: integer = 150;
	vertices: array[0..5] of TAAPLVertex;
	commandBuffer: MTLCommandBufferProtocol;
	renderPassDescriptor: MTLRenderPassDescriptor;
	renderEncoder: MTLRenderCommandEncoderProtocol;
begin
	

	if vertexBuffer = nil then
		begin
			vertices[0] := AAPLVertex(V2(size,  -size),  V2(1.0, 0.0));
			vertices[1] := AAPLVertex(V2(-size,  -size), V2(0.0, 0.0));
			vertices[2] := AAPLVertex(V2(-size,   size), V2(0.0, 1.0));
			vertices[3] := AAPLVertex(V2(size,  -size),  V2(1.0, 0.0));
			vertices[4] := AAPLVertex(V2(-size,   size), V2(0.0, 1.0));
			vertices[5] := AAPLVertex(V2(size,   size),  V2(1.0, 1.0));
			vertexBuffer := device.newBufferWithBytes_length_options(@vertices, sizeof(vertices), MTLResourceStorageModeShared);
			loadTexture;
		end;

	commandBuffer := commandQueue.commandBuffer;

	renderPassDescriptor := view.currentRenderPassDescriptor;
	if renderPassDescriptor <> nil then
		begin
			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

			renderEncoder.setViewport(viewport);
			renderEncoder.setRenderPipelineState(pipelineState);

			renderEncoder.setVertexBuffer_offset_atIndex(vertexBuffer, 0, AAPLVertexInputIndexVertices);
			renderEncoder.setVertexBytes_length_atIndex(@viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);
			renderEncoder.setFragmentTexture_atIndex(texture, AAPLTextureIndexBaseColor);
			renderEncoder.drawPrimitives_vertexStart_vertexCount(MTLPrimitiveTypeTriangle, 0, 6);

			renderEncoder.endEncoding;
			commandBuffer.presentDrawable(view.currentDrawable);
		end;

	commandBuffer.commit;
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
begin
	drawTexturedQuad;
end;

procedure TMTKRenderer.loadTexture;
var
	imageFileLocation: NSURL;
	image: TGAImage;
	textureDescriptor: MTLTextureDescriptor;
	bytesPerRow: integer;
	region: MTLRegion;
begin
	Fatal(device = nil, 'device must be set before loading textures.');

	imageFileLocation := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('Image'), NSSTR('tga'));
	image := LoadTGAFile(imageFileLocation.relativePath.UTF8String);

	textureDescriptor := MTLTextureDescriptor.alloc.init.autorelease;
	textureDescriptor.setPixelFormat(MTLPixelFormatBGRA8Unorm);
	textureDescriptor.setWidth(image.width);
	textureDescriptor.setHeight(image.height);

	texture := device.newTextureWithDescriptor(textureDescriptor);
	Fatal(texture = nil, 'newTextureWithDescriptor failed');

	bytesPerRow := 4 * image.width;

	region := MTLRegionMake3D(0, 0, 0, image.width, image.height, 1);

	texture.replaceRegion_mipmapLevel_withBytes_bytesPerRow(region, 0, image.bytes, bytesPerRow);
	//show(texture);
end;

procedure TMTKRenderer.dealloc;
begin
	pipelineState.release;
	commandQueue.release;
	vertexBuffer.release;
	texture.release;

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	defaultLibrary: MTLLibraryProtocol;
	vertexFunction: MTLFunctionProtocol;
	fragmentFunction: MTLFunctionProtocol;
	error: NSError;
	url: NSURL;
	attachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;
	imageData: pointer;
begin
	view := inView; // weak retain;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);

	device := view.device;
	Show(device, 'GPU:');

	// Load all the shader files with a .metallib file extension in the project
	//defaultLibrary := device.newDefaultLibrary;
	url := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('BasicTexturing'), NSSTR('metallib'));
	//show(url);
	defaultLibrary := device.newLibraryWithURL_error(url, @error);

	// NOTE: Xcode usually compiles the .metal shader files to a .metallib file
	// and places it at Contents/Resources/default.metallib ut we need to do this manually. 

	// https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW10
	// xcrun -sdk macosx metal AAPLShaders.metal -o AAPLShaders.air
	// xcrun -sdk macosx metallib AAPLShaders.air -o AAPLShaders.metallib

	Fatal(defaultLibrary = nil, 'no .metallib files were found.', error);
		
	Show(defaultLibrary);

	// Load the vertex function from the library
	vertexFunction := defaultLibrary.newFunctionWithName(NSSTR('vertexShader'));
	Fatal(vertexFunction = nil, 'vertex shader not found.');

	// Load the fragment function from the library
	// NOTE: shader names are coded depending on library!
	fragmentFunction := defaultLibrary.newFunctionWithName(NSSTR('samplingShader'));
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

end.