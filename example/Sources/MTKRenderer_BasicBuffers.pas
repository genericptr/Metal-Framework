{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_BasicBuffers;
interface
uses
	SIMDTypes, TGALoader,
	Metal, MetalKit, MetalPipeline,
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

			procedure drawVertexBuffer; message 'drawVertexBuffer';

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

type
	TAAPLQuad = array[0..5] of TAAPLVertex;

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

procedure TMTKRenderer.drawVertexBuffer;
const
	kSize = 10;
	kRows = 10;
	kColumns = 10;
	kSpacing = 30;
var
	verticies: TAAPLQuad;
	currentQuad: integer = 0;
	quads: array[0..(kRows*kColumns)-1] of TAAPLQuad;
	x, y, v: integer;
	upperLeftPosition: vector_float2;

	commandBuffer: MTLCommandBufferProtocol;
	renderPassDescriptor: MTLRenderPassDescriptor;
	renderEncoder: MTLRenderCommandEncoderProtocol;
begin

	if vertexBuffer = nil then
		begin
			verticies[0] := AAPLVertex(V2(-kSize, kSize),  V4(1, 0, 0, 1));
			verticies[1] := AAPLVertex(V2(kSize, kSize),   V4(0, 0, 1, 1));
			verticies[2] := AAPLVertex(V2(-kSize,-kSize),  V4(0, 1, 0, 1));
			verticies[3] := AAPLVertex(V2(kSize, -kSize),  V4(1, 0, 0, 1));
			verticies[4] := AAPLVertex(V2(-kSize, -kSize), V4(0, 1, 0, 1));
			verticies[5] := AAPLVertex(V2(kSize, kSize),   V4(0, 0, 1, 1));

			for y := 0 to kRows - 1 do
			for x := 0 to kColumns - 1 do
				begin
					upperLeftPosition.x := ((-(kColumns) / 2.0) + x) * kSpacing + kSpacing/2.0;
					upperLeftPosition.y := ((-(kRows) / 2.0) + y) * kSpacing + kSpacing/2.0;

					for v := 0 to 5 do
						begin
							quads[currentQuad][v].position := verticies[v].position + upperLeftPosition;
							quads[currentQuad][v].color := verticies[v].color;
						end;

					currentQuad += 1;
				end;


			vertexBuffer := device.newBufferWithLength_options(sizeof(TAAPLVertex) * (kRows * kColumns) * 6, MTLResourceStorageModeShared);

			// MTLBuffer gives us direct pointer access so just move the bytes
			// from the stack to the storage
			BlockMove(vertexBuffer.contents, @quads, vertexBuffer.length);
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

			renderEncoder.drawPrimitives_vertexStart_vertexCount(MTLPrimitiveTypeTriangle, 0, (kRows * kColumns) * 6);

			renderEncoder.endEncoding;
			commandBuffer.presentDrawable(view.currentDrawable);
		end;

	commandBuffer.commit;
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
begin
	drawVertexBuffer;
end;

procedure TMTKRenderer.dealloc;
begin
	pipelineState.release;
	commandQueue.release;
	vertexBuffer.release;

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