{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_HelloTriangle;
interface
uses
	SIMDTypes, TGALoader,
	MetalPipeline, Metal, MetalKit, MetalUtils,
	MacOSAll, CocoaAll, SysUtils;

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

			procedure drawTriangle; message 'drawTriangle';
			procedure takeScreenshot; message 'takeScreenshot';

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

type
	TAAPLVertex = record
		position: vector_float2;
		padding: array[0..1] of simd_float; // NOTE: we need these fields for proper alignment.
		color: vector_float4;
	end;

function AAPLVertex(constref position: vector_float2; constref color: vector_float4): TAAPLVertex;
begin
	result.position := position;
	result.color := color;
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

// https://forums.developer.apple.com/thread/30488
// https://forums.developer.apple.com/thread/65037
// https://stackoverflow.com/questions/33844130/take-a-snapshot-of-current-screen-with-metal-in-swift

type
  CAMetalDrawableProtocol = objcprotocol external name 'CAMetalDrawable' (NSObjectProtocol)
  	function layer: id{CAMetalLayer}; message 'layer';
  	function texture: MTLTextureProtocol; message 'texture';
  end;

type
	CAMetalLayer = objccategory external (CALayer)
  	function nextDrawable: CAMetalDrawableProtocol; message 'nextDrawable';
	end;

procedure TMTKRenderer.drawTriangle;
var
	size: single = 150;
	verticies: array[0..2] of TAAPLVertex;
	commandBuffer: MTLCommandBufferProtocol;
	renderPassDescriptor: MTLRenderPassDescriptor;
	renderEncoder: MTLRenderCommandEncoderProtocol;
	colorAttachment: MTLRenderPassColorAttachmentDescriptor;
	renderTextureDescriptor: MTLTextureDescriptor;
	renderTexture: MTLTextureProtocol;
begin
	verticies[0] := AAPLVertex(V2(size, -size), V4(1, 0, 0, 1));
	verticies[1] := AAPLVertex(V2(-size, -size), V4(0, 1, 0, 1 ));
	verticies[2] := AAPLVertex(V2(0, size), V4(0, 0, 1, 1));

	commandBuffer := commandQueue.commandBuffer;

	renderPassDescriptor := view.currentRenderPassDescriptor;
	if renderPassDescriptor <> nil then
		begin

			// NOTE: integrating this into a frame is too messy to bother with
			//renderTextureDescriptor := MTLTextureDescriptor.texture2DDescriptorWithPixelFormat_width_height_mipmapped(
			//		view.currentDrawable.texture.pixelFormat,
			//		view.currentDrawable.texture.width,
			//		view.currentDrawable.texture.height,
			//		false
			//	);
			//renderTextureDescriptor.setUsage(MTLTextureUsageRenderTarget);
			//renderTextureDescriptor.setStorageMode(MTLStorageModeManaged);
			//renderTextureDescriptor.setTextureType(MTLTextureType2D);
			//renderTextureDescriptor.setCpuCacheMode(MTLResourceCPUCacheModeDefaultCache);

			//renderTexture := view.device.newTextureWithDescriptor(renderTextureDescriptor);
			//Fatal(renderTexture = nil, 'newTextureWithDescriptor failed');

			//colorAttachment := renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
			//colorAttachment.setTexture(renderTexture);
			//colorAttachment.setClearColor(view.clearColor);
			//colorAttachment.setStoreAction(MTLStoreActionStore);
			//colorAttachment.setLoadAction(MTLLoadActionClear);

			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);
			renderEncoder.setRenderPipelineState(pipelineState);

			renderEncoder.setViewport(viewport);
			renderEncoder.setVertexBytes_length_atIndex(@verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
			renderEncoder.setVertexBytes_length_atIndex(@viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);

			renderEncoder.drawPrimitives_vertexStart_vertexCount(MTLPrimitiveTypeTriangle, 0, 3);

			renderEncoder.endEncoding;
			commandBuffer.presentDrawable(view.currentDrawable);
		end;

	commandBuffer.commit;
	//commandBuffer.waitUntilCompleted;
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
begin
	drawTriangle;
end;

procedure TMTKRenderer.takeScreenshot;
begin
	//view.draw;
	//MTLWriteTextureToFile(renderTexture, 'metal-triangle.png');
	//halt;
end;

procedure TMTKRenderer.dealloc;
begin
	pipelineState.release;
	commandQueue.release;

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
	url := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('Color'), NSSTR('metallib'));
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
	fragmentFunction := defaultLibrary.newFunctionWithName(NSSTR('fragmentShader'));
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