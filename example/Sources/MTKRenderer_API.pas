{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_API;
interface
uses
	SIMDTypes, Metal, MetalKit, MetalUtils,
	CocoaAll, MacOSAll, SysUtils;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			api: TMetalAPI;
			viewportSize: vector_uint2;
			viewport: MTLViewport;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

const
	AAPLVertexInputIndexVertices     = 0;
	AAPLVertexInputIndexViewportSize = 1;

type
	TAAPLVertex = record
		position: vector_float2;
		padding: array[0..1] of simd_float;
		color: vector_float4;
	end;

function AAPLVertex(constref position: vector_float2; constref color: vector_float4): TAAPLVertex;
begin
	result.position := position;
	result.color := color;
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
	verticies: array[0..2] of TAAPLVertex;
begin
	verticies[0] := AAPLVertex(V2(size, -size), V4(1, 0, 0, 1));
	verticies[1] := AAPLVertex(V2(-size, -size), V4(0, 1, 0, 1 ));
	verticies[2] := AAPLVertex(V2(0, size), V4(0, 0, 1, 1));

	MTLBeginFrame(api, view);
		MTLSetViewPort(api, viewport);
		MTLSetVertexBytes(api, @verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
		MTLSetVertexBytes(api, @viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);
		MTLDraw(api, MTLPrimitiveTypeTriangle, 0, 3);
	MTLEndFrame(api);
end;

procedure TMTKRenderer.dealloc;
begin
	MTLFree(api);

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	error: NSError;
	options: TMetalPipelineOptions;
begin
	view := inView; // weak retain;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);

	options.libraryName := ResourcePath('Color', 'metallib');
	options.vertexFunction := 'vertexShader';
	options.fragmentFunction := 'fragmentShader';

	api := MTLCreate(view, @options);
end;

end.