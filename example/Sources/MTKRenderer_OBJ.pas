{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_OBJ;
interface
uses
	MetalMesh, Scanner, MeshLoader, MetalTypes, Metal, MetalKit, MetalPipeline,
	CocoaAll, MacOSAll, SysUtils, Math, FGL;

// https://www.raywenderlich.com/146416/metal-tutorial-swift-3-part-2-moving-3d
// https://www.haroldserrano.com/blog/rendering-3d-objects-in-metal
// http://metalbyexample.com/up-and-running-3/

type
	TWorldUniforms = record
		modelMatrix: TMat4;
		projectionMatrix: TMat4;
		invertedModelMatrix: TMat4;
		lightPos: TVec4;
	end;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			context: TMetalContext;
			pipeline: TMetalPipeline;
			viewport: MTLViewport;
			uniformBuffer: MTLBufferProtocol;
			rotation: single;
			uniforms: TWorldUniforms;
			teapotMesh: TMetalMesh;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

{=============================================}
{@! ___RENDERER___ } 
{=============================================}

function Perspective_Metal(fovy, aspect, near, far: TScalar): TMat4;
var
	yscale: TScalar;
	xscale: TScalar;
	q: TScalar;
begin
	yscale := 1.0 / tan(fovy * 0.5); // 1 / tan == cot
	xscale := yscale / aspect;
	q := far / (far - near);

	result.column[0] := V4(xscale, 0, 0, 0);
	result.column[1] := V4(0, yscale, 0, 0);
	result.column[2] := V4(0, 0, q, 1);
	result.column[3] := V4(0, 0, q * -near, 0);
end;

// from lighting.xcodeproj
function Perspective_Metal_2(fovy, aspect, near, far: TScalar): TMat4;
var
	yScale: TScalar;
	xScale: TScalar;
	zRange: TScalar;
	zScale: TScalar;
	wzScale: TScalar;
begin
	yScale := 1 / tan(fovy * 0.5);
	xScale := yScale / aspect;
	zRange := far - near;
	zScale := -(far + near) / zRange;
	wzScale := -2 * far * near / zRange;

	result.column[0] := V4(xScale, 0, 0, 0);
	result.column[1] := V4(0, yScale, 0, 0);
	result.column[2] := V4(0, 0, zScale, -1);
	result.column[3] := V4(0, 0, wzScale, 0);
end;

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
var
	zs: TScalar;
begin
	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := size.width;
	viewport.height := size.height;			
	viewport.znear := 0.1;
	viewport.zfar := 100;

	uniforms.projectionMatrix := TMat4.Perspective(60, viewport.width / viewport.height, viewport.znear, viewport.zfar);
	//uniforms.projectionMatrix := Perspective_Metal(45 * (PI / 180), viewport.width / viewport.height, viewport.znear, viewport.zfar);
	//uniforms.projectionMatrix := Perspective_Metal_2((2 * PI) / 5, viewport.width / viewport.height, viewport.znear, viewport.zfar);

	//uniforms.projectionMatrix := TMat4.Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);
	//uniforms.projectionMatrix := Mat4Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);
	//zs := viewport.zfar / (viewport.znear - viewport.zfar);
	//uniforms.projectionMatrix.m[2][2] := zs;
	//uniforms.projectionMatrix.m[3][2] := zs * viewport.znear;

	//uniforms.projectionMatrix := TMat4.Perspective_Metal((2 * pi) / 5, view.frame.size.width / view.frame.size.height, viewport.znear, viewport.zfar);
	//uniforms.projectionMatrix.show;

	uniforms.lightPos := V4(-1, 1, 0, 0);
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single;
	v: TVec3;
begin
	scale := 3.45;

	// TODO: slamming all uniforms into a single struct we need
	// to copy each frame is a really stupid idea
	uniforms.modelMatrix := TMat4.Identity;
	uniforms.modelMatrix *= TMat4.Translate(0, 0, -4);
	uniforms.modelMatrix *= TMat4.RotateY(DegToRad(rotation));
	uniforms.modelMatrix *= TMat4.Scale(scale, scale, scale);
	rotation += 0.8;

	uniforms.invertedModelMatrix := uniforms.modelMatrix.Inverse.Transpose;

	BlockMove(uniformBuffer.contents, @uniforms, uniformBuffer.length);

	MTLBeginFrame(pipeline);
		MTLSetVertexBuffer(teapotMesh.vertexBuffer, 0);
		MTLSetVertexBuffer(uniformBuffer, 1);
		MTLSetCullMode(MTLCullModeBack);
		MTLSetFrontFacingWinding(MTLWindingClockwise);
		MTLDrawIndexed(MTLPrimitiveTypeTriangle, teapotMesh.indices.count, MTLIndexTypeUInt32, teapotMesh.indexBuffer, 0);
	MTLEndFrame;
end;

procedure TMTKRenderer.dealloc;
begin
	pipeline.Free;
	teapotMesh.Free;

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	error: NSError;
	options: TMetalPipelineOptions;
	i: integer;
begin
	view := inView;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);

	context := MTLCreateContext(view);
	MTLMakeContextCurrent(context);

	teapotMesh := LoadOBJModel(ResourcePath('teapot', 'obj'), TMetalMesh) as TMetalMesh;

	with teapotMesh do
		begin
			writeln('verts: ', vertices.count);
			writeln('index: ', indices.count);
			vertexBuffer := view.device.newBufferWithBytes_length_options(vertices.list, vertices.count * sizeof(TMeshVertex), MTLResourceOptionCPUCacheModeDefault);
			indexBuffer := view.device.newBufferWithBytes_length_options(indices.list, indices.count * sizeof(UInt32), MTLResourceOptionCPUCacheModeDefault);			
		end;

	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('Teapot_Packed', 'metallib');
	// NOTE: why don't we need this??
	//options.vertexDescriptor := teapotMesh.GetVertexDescriptor;
	pipeline := MTLCreatePipeline(options);

	MTLSetDepthStencil(pipeline, MTLCompareFunctionLess, true);
	MTLSetClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));

	uniformBuffer := view.device.newBufferWithLength_options(sizeof(TWorldUniforms), MTLResourceOptionCPUCacheModeDefault);
end;

end.