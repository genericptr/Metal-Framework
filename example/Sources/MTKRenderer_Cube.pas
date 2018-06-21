{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_Cube;
interface
uses
	GLTypes, SIMDTypes, Metal, MetalKit, MetalUtils,
	CocoaAll, MacOSAll, SysUtils, Math;

// https://www.raywenderlich.com/146416/metal-tutorial-swift-3-part-2-moving-3d
// https://www.haroldserrano.com/blog/rendering-3d-objects-in-metal

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			api: TMetalAPI;
			viewport: MTLViewport;
			uniformBuffer: MTLBufferProtocol;
			rotation: single;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

type
	TAAPLVertex = record
		position: vector_float3;
		padding: array[0..0] of simd_float;
		color: vector_float4;
	end;

type
	TAAPLUniforms = record
		modelMatrix: TMat4;
		projectionMatrix: TMat4;
	end;

function AAPLVertex(x, y, z: simd_float; r, g, b, a: simd_float): TAAPLVertex;
begin
	result.position := V3(x, y, z);
	result.color := V4(r, g, b, a);
end;

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := size.width;
	viewport.height := size.height;			
	viewport.znear := 0;
	viewport.zfar := 1000;
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	A, B, C, D, Q, R, S, T: TAAPLVertex;
var
	verticies: array of TAAPLVertex;
var
	size: single = 150;
	uniforms: TAAPLUniforms;
	scale: single;
begin
	A := AAPLVertex(-1.0,  1.0,  1.0, 1.0, 0.0, 0.0, 1.0);
	B := AAPLVertex(-1.0, -1.0,  1.0, 0.0, 1.0, 0.0, 1.0);
	C := AAPLVertex( 1.0, -1.0,  1.0, 0.0, 0.0, 1.0, 1.0);
	D := AAPLVertex( 1.0,  1.0,  1.0, 0.1, 0.6, 0.4, 1.0);

	Q := AAPLVertex(-1.0,  1.0, -1.0, 1.0, 0.0, 0.0, 1.0);
	R := AAPLVertex( 1.0,  1.0, -1.0, 0.0, 1.0, 0.0, 1.0);
	S := AAPLVertex(-1.0, -1.0, -1.0, 0.0, 0.0, 1.0, 1.0);
	T := AAPLVertex( 1.0, -1.0, -1.0, 0.1, 0.6, 0.4, 1.0);
		
	verticies := [
		A,B,C ,A,C,D,   //Front
		R,T,S ,Q,R,S,   //Back
		
		Q,S,B ,Q,B,A,   //Left
		D,C,T ,D,T,R,   //Right
		
		Q,A,D ,Q,D,R,   //Top
		B,S,T ,B,T,C    //Bot
	];

	scale := 0.5;

	uniforms.modelMatrix := TMat4.Identity;
	uniforms.modelMatrix *= TMat4.Translate(0, 0, -3);
	uniforms.modelMatrix *= TMat4.RotateX(DegToRad(rotation));
	uniforms.modelMatrix *= TMat4.Scale(scale, scale, scale);

	rotation += 0.2;

	uniforms.projectionMatrix := TMat4.Perspective(60, view.frame.size.width / view.frame.size.height, viewport.znear, viewport.zfar);

	BlockMove(uniformBuffer.contents, @uniforms, uniformBuffer.length);

	MTLBeginFrame(api, view);
		MTLSetViewPort(api, viewport);
		MTLSetVertexBytes(api, pointer(verticies), sizeof(TAAPLVertex) * Length(verticies), 0);
		MTLSetVertexBuffer(api, uniformBuffer, 0, 1);
		MTLSetCullMode(api, MTLCullModeFront);
		MTLDraw(api, MTLPrimitiveTypeTriangle, 0, 36);
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

	options.libraryName := ResourcePath('Transforms', 'metallib');
	options.vertexFunction := 'vertexShader';
	options.fragmentFunction := 'fragmentShader';
	
	uniformBuffer := view.device.newBufferWithLength_options(sizeof(TAAPLUniforms), MTLResourceOptionCPUCacheModeDefault);

	api := MTLCreate(view, @options);
end;

end.