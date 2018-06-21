{$mode objfpc}
{$modeswitch objectivec1}

unit MTKRenderer_IndexedPrimitives;
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

class function TShape.MakeCube: TShape;
var
	stackIndices: array[0..35] of TVertexIndex = (
		0,   1,  2,  0,  2,  3, // Top
		4,   5,  6,  4,  6,  7, // Front
		8,   9, 10,  8, 10, 11, // Right
		12, 13, 14, 12, 14, 15, // Left
		16, 17, 18, 16, 18, 19, // Back
		20, 22, 21, 20, 23, 22 	// Bottom
	);
	i: integer;
begin
	result.SetVerticies(24);
	
	result.v[0].pos := TVec3.Make(-1.0, +1.0, +1.0);
	result.v[0].col := TVec3.Make(+1.0, +0.0, +0.0);
	result.v[0].nrm := TVec3.Make(+0.0, +1.0, +0.0);
	result.v[1].pos := TVec3.Make(+1.0, +1.0, +1.0);
	result.v[1].col := TVec3.Make(+0.0, +1.0, +0.0);
	result.v[1].nrm := TVec3.Make(+0.0, +1.0, +0.0);
	result.v[2].pos := TVec3.Make(+1.0, +1.0, -1.0);
	result.v[2].col := TVec3.Make(+0.0, +0.0, +1.0);
	result.v[2].nrm := TVec3.Make(+0.0, +1.0, +0.0);
	result.v[3].pos := TVec3.Make(-1.0, +1.0, -1.0);
	result.v[3].col := TVec3.Make(+1.0, +1.0, +1.0);
	result.v[3].nrm := TVec3.Make(+0.0, +1.0, +0.0);
	      
	result.v[4].pos := TVec3.Make(-1.0, +1.0, -1.0);
	result.v[4].col := TVec3.Make(+1.0, +0.0, +1.0);
	result.v[4].nrm := TVec3.Make(+0.0, +0.0, -1.0);
	result.v[5].pos := TVec3.Make(+1.0, +1.0, -1.0);
	result.v[5].col := TVec3.Make(+0.0, +0.5, +0.2);
	result.v[5].nrm := TVec3.Make(+0.0, +0.0, -1.0);
	result.v[6].pos := TVec3.Make(+1.0, -1.0, -1.0);
	result.v[6].col := TVec3.Make(+0.8, +0.6, +0.4);
	result.v[6].nrm := TVec3.Make(+0.0, +0.0, -1.0);
	result.v[7].pos := TVec3.Make(-1.0, -1.0, -1.0);
	result.v[7].col := TVec3.Make(+0.3, +1.0, +0.5);
	result.v[7].nrm := TVec3.Make(+0.0, +0.0, -1.0);
	
	result.v[8].pos := TVec3.Make(+1.0, +1.0, -1.0);
	result.v[8].col := TVec3.Make(+0.2, +0.5, +0.2);
	result.v[8].nrm := TVec3.Make(+1.0, +0.0, +0.0);
	result.v[9].pos := TVec3.Make(+1.0, +1.0, +1.0);
	result.v[9].col := TVec3.Make(+0.9, +0.3, +0.7);
	result.v[9].nrm := TVec3.Make(+1.0, +0.0, +0.0);
	result.v[10].pos := TVec3.Make(+1.0, -1.0, +1.0);
	result.v[10].col := TVec3.Make(+0.3, +0.7, +0.5);
	result.v[10].nrm := TVec3.Make(+1.0, +0.0, +0.0);
	result.v[11].pos := TVec3.Make(+1.0, -1.0, -1.0);
	result.v[11].col := TVec3.Make(+0.5, +0.7, +0.5);
	result.v[11].nrm := TVec3.Make(+1.0, +0.0, +0.0);
	
	result.v[12].pos := TVec3.Make(-1.0, +1.0, +1.0);
	result.v[12].col := TVec3.Make(+0.7, +0.8, +0.2);
	result.v[12].nrm := TVec3.Make(-1.0, +0.0, +0.0);
	result.v[13].pos := TVec3.Make(-1.0, +1.0, -1.0);
	result.v[13].col := TVec3.Make(+0.5, +0.7, +0.3);
	result.v[13].nrm := TVec3.Make(-1.0, +0.0, +0.0);
	result.v[14].pos := TVec3.Make(-1.0, -1.0, -1.0);
	result.v[14].col := TVec3.Make(+0.4, +0.7, +0.7);
	result.v[14].nrm := TVec3.Make(-1.0, +0.0, +0.0);
	result.v[15].pos := TVec3.Make(-1.0, -1.0, +1.0);
	result.v[15].col := TVec3.Make(+0.2, +0.5, +1.0);
	result.v[15].nrm := TVec3.Make(-1.0, +0.0, +0.0);
	
	result.v[16].pos := TVec3.Make(+1.0, +1.0, +1.0);
	result.v[16].col := TVec3.Make(+0.6, +1.0, +0.7);
	result.v[16].nrm := TVec3.Make(+0.0, +0.0, +1.0);
	result.v[17].pos := TVec3.Make(-1.0, +1.0, +1.0);
	result.v[17].col := TVec3.Make(+0.6, +0.4, +0.8);
	result.v[17].nrm := TVec3.Make(+0.0, +0.0, +1.0);
	result.v[18].pos := TVec3.Make(-1.0, -1.0, +1.0);
	result.v[18].col := TVec3.Make(+0.2, +0.8, +0.7);
	result.v[18].nrm := TVec3.Make(+0.0, +0.0, +1.0);
	result.v[19].pos := TVec3.Make(+1.0, -1.0, +1.0);
	result.v[19].col := TVec3.Make(+0.2, +0.7, +1.0);
	result.v[19].nrm := TVec3.Make(+0.0, +0.0, +1.0);
	
	result.v[20].pos := TVec3.Make(+1.0, -1.0, -1.0);
	result.v[20].col := TVec3.Make(+0.8, +0.3, +0.7);
	result.v[20].nrm := TVec3.Make(+0.0, -1.0, +0.0);
	result.v[21].pos := TVec3.Make(-1.0, -1.0, -1.0);
	result.v[21].col := TVec3.Make(+0.8, +0.9, +0.5);
	result.v[21].nrm := TVec3.Make(+0.0, -1.0, +0.0);
	result.v[22].pos := TVec3.Make(-1.0, -1.0, +1.0);
	result.v[22].col := TVec3.Make(+0.5, +0.8, +0.5);
	result.v[22].nrm := TVec3.Make(+0.0, -1.0, +0.0);
	result.v[23].pos := TVec3.Make(+1.0, -1.0, +1.0);
	result.v[23].col := TVec3.Make(+0.9, +1.0, +0.2);
	result.v[23].nrm := TVec3.Make(+0.0, -1.0, +0.0);
	
	SetLength(result.ind, Length(stackIndices));
	result.ind := stackIndices;
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	A, B, C, D, Q, R, S, T: TAAPLVertex;
var
	size: single = 150;
	verticies: array[0..35] of TAAPLVertex;
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
		
	//Front
	verticies[0] := A;
	verticies[1] := B;
	verticies[2] := C;
	verticies[3] := A;
	verticies[4] := C;
	verticies[5] := D;

	//Back
	verticies[6] := R;
	verticies[7] := T;
	verticies[8] := S;
	verticies[9] := Q;
	verticies[10] := R;
	verticies[11] := S;

	//Left
	verticies[12] := Q;
	verticies[13] := S;
	verticies[14] := B;
	verticies[15] := Q;
	verticies[16] := B;
	verticies[17] := A;

	//Right
	verticies[18] := D;
	verticies[19] := C;
	verticies[20] := T;
	verticies[21] := D;
	verticies[22] := T;
	verticies[23] := R;

	//Top
	verticies[24] := Q;
	verticies[25] := A;
	verticies[26] := D;
	verticies[27] := Q;
	verticies[28] := D;
	verticies[29] := R;

	//Bottom
	verticies[30] := B;
	verticies[31] := S;
	verticies[32] := T;
	verticies[33] := B;
	verticies[34] := T;
	verticies[35] := C;

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
		MTLSetVertexBytes(api, @verticies, sizeof(verticies), 0);
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