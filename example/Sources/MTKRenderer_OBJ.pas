{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_OBJ;
interface
uses
	Scanner, MeshLoader, MetalTypes, Metal, MetalKit, MetalPipeline,
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

			pipeline: TMetalPipeline;
			viewport: MTLViewport;
			uniformBuffer: MTLBufferProtocol;
			rotation: single;
			uniforms: TWorldUniforms;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

type
	TFPGFloatList = specialize TFPGList<single>;
	TFPGIntegerList = specialize TFPGList<UInt16>;
	THeaderMesh = record
		vertices: TFPGFloatList;
		normals: TFPGFloatList;
		uvs: TFPGFloatList;
		indices: TFPGIntegerList;

		vertexBuffer: MTLBufferProtocol;
		normalBuffer: MTLBufferProtocol;
		indexBuffer: MTLBufferProtocol;

		procedure Load (device: MTLDeviceProtocol; dataFile: string);
		procedure Free;
	end;

var
	SmallHouseMesh: THeaderMesh;

type
	TVertexFileScanner = class (TCLangScanner)
		mesh: THeaderMesh;
		procedure Parse; override;
	end;

{=============================================}
{@! ___SCANNER___ } 
{=============================================}

procedure TVertexFileScanner.Parse;
var
	floatList: TFPGFloatList;
	intList: TFPGIntegerList;
	name: string;
begin
	while true do
		begin

			while true do
				begin
					ReadToken;
					if (pattern = 'float') or (pattern = 'const') or (pattern = 'uint16_t') then // types/keywords
						continue
					else
						break;
				end;

			if token = kTokenID then
				begin
					name := pattern;
					floatList := nil;
					intList := nil;

					if name = 'smallHouseVertices' then
						floatList := mesh.vertices
					else if name = 'smallHouseNormals' then
						floatList := mesh.normals
					else if name = 'smallHouseUV' then
						floatList := mesh.uvs
					else if name = 'smallHouseIndices' then
						intList := mesh.indices
					else
						ParserError('bad name');

					if ReadTokenTo(kTokenSymbol, '[') then
					if ReadTokenTo(kTokenSymbol, ']') then
					if ReadTokenTo(kTokenSymbol, '=') then
					if ReadTokenTo(kTokenSymbol, '{') then
						begin
							repeat
								ReadToken;
								if token = kTokenNumber then
									begin
										if floatList <> nil then
											floatList.Add(StrToFloat(pattern))
										else
											intList.Add(StrToInt(pattern));
										ReadTokenTo(kTokenSymbol, ',');
									end
								else if c = ',' then // trailing ,
									ReadToken;
							until c = '}';

							if not ReadTokenTo(kTokenSymbol, ';') then
								ParserError('missing semicolon');
						end;
				end;

			if token = kTokenEOF then
				break;
		end;
end;

{=============================================}
{@! ___MESH___ } 
{=============================================}

procedure THeaderMesh.Free;
begin
	vertices.Free;
	normals.Free;
	uvs.Free;
	indices.Free;

	vertexBuffer.release;
	normalBuffer.release;
	indexBuffer.release;
end;

procedure THeaderMesh.Load (device: MTLDeviceProtocol; dataFile: string);
var
	scanner: TVertexFileScanner;
begin
	vertices := TFPGFloatList.Create;
	normals := TFPGFloatList.Create;
	uvs := TFPGFloatList.Create;
	indices := TFPGIntegerList.Create;

	scanner := TVertexFileScanner.Create;
	scanner.mesh := self;
	scanner.LoadFile(dataFile);
	scanner.Parse;
	scanner.Free;

	vertexBuffer := device.newBufferWithBytes_length_options(vertices.list, vertices.count * sizeof(TScalar), MTLResourceOptionCPUCacheModeDefault);
	normalBuffer := device.newBufferWithBytes_length_options(normals.list, normals.count * sizeof(TScalar), MTLResourceOptionCPUCacheModeDefault);
	indexBuffer := device.newBufferWithBytes_length_options(indices.list, indices.count * sizeof(UInt16), MTLResourceOptionCPUCacheModeDefault);
end;

{=============================================}
{@! ___RENDERER___ } 
{=============================================}

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
	//uniforms.projectionMatrix := TMat4.Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);

	zs := viewport.zfar / (viewport.znear - viewport.zfar);
	uniforms.projectionMatrix.m[2][2] := zs;
	uniforms.projectionMatrix.m[3][2] := zs * viewport.znear;

	//uniforms.projectionMatrix := TMat4.Perspective_Metal((2 * pi) / 5, view.frame.size.width / view.frame.size.height, viewport.znear, viewport.zfar);
	//uniforms.projectionMatrix.show;

	uniforms.lightPos := V4(-1, 1, 0, 0);
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single;
	v: TVec3;
begin
	scale := 0.45;

	// TODO: slamming all uniforms into a single struct we need
	// to copy each frame is a really stupid idea
	uniforms.modelMatrix := TMat4.Identity;
	uniforms.modelMatrix *= TMat4.Translate(0, 0, -4);
	uniforms.modelMatrix *= TMat4.RotateY(DegToRad(rotation));
	uniforms.modelMatrix *= TMat4.Scale(scale, scale, scale);
	rotation += 0.2;

	uniforms.invertedModelMatrix := uniforms.modelMatrix.Inverse.Transpose;

	//v := uniforms.projectionMatrix * uniforms.modelMatrix * V3(SmallHouseMesh.vertices[0], SmallHouseMesh.vertices[1], SmallHouseMesh.vertices[2]);
	//v.show;
	//halt;

	BlockMove(uniformBuffer.contents, @uniforms, uniformBuffer.length);

	MTLBeginFrame(pipeline);
		MTLSetViewPort(viewport);
		MTLSetVertexBuffer(SmallHouseMesh.vertexBuffer, 0);
		MTLSetVertexBuffer(SmallHouseMesh.normalBuffer, 1);
		MTLSetVertexBuffer(uniformBuffer, 2);
		MTLSetCullMode(MTLCullModeFront);
		MTLDrawIndexed(MTLPrimitiveTypeTriangle, SmallHouseMesh.indices.count, MTLIndexTypeUInt16, SmallHouseMesh.indexBuffer, 0);
	MTLEndFrame;
end;

procedure TMTKRenderer.dealloc;
begin
	MTLFree(pipeline);
	SmallHouseMesh.Free;

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	error: NSError;
	options: TMetalPipelineOptions;
	scanner: TVertexFileScanner;
	potMesh: TMesh;
begin
	view := inView;

	view.setClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));
	view.setColorPixelFormat(MTLPixelFormatBGRA8Unorm);
	view.setDepthStencilPixelFormat(MTLPixelFormatDepth32Float);

	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);
 	
	//potMesh := LoadOBJModel(ResourcePath('teapot', 'obj'));
	//writeln('verts: ', potMesh.vertices.count);
	//writeln('index: ', potMesh.indices.count);

	//halt;

	SmallHouseMesh.Load(view.device, '/Developer/Projects/FPC/Metal-Framework/example/Sources/smallhouse.h');

	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('SmallHouse', 'metallib');
	pipeline := MTLCreatePipeline(view, @options);

	MTLSetDepthStencil(pipeline, MTLCompareFunctionLess, true);

	uniformBuffer := view.device.newBufferWithLength_options(sizeof(TWorldUniforms), MTLResourceOptionCPUCacheModeDefault);
end;

end.