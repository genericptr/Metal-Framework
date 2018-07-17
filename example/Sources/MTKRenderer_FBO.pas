{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_FBO;
interface
uses
	MetalMesh, Scanner, MeshLoader, MetalTypes, Metal, MetalKit, MetalPipeline,
	CocoaAll, MacOSAll, SysUtils, Math, CTypes, FGL;

const
	kRenderModeColor = 0;
	kRenderModeDepth = 1;

type
	TModelUniforms = record
		modelMatrix: TMat4;
		projectionMatrix: TMat4;
		invertedModelMatrix: TMat4;
		lightPos: TVec4;
	end;

type
	TGUIUniforms = record
		modelMatrix: TMat4;
		projectionMatrix: TMat4;
	end;

type
	TWorldUniforms = record
		shineDamper: single;
		reflectivity: single;
		// TODO: this sucks. how can we fix it?
			padding_0: single;
			padding_1: single;
		lightColor: TVec3;
			padding_2: single;
		mode: integer;
	end;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			context: TMetalContext;
			guiShader: TMetalPipeline;
			modelShader: TMetalPipeline;
			viewport: MTLViewport;
			rotation: single;
			modelUniforms: TModelUniforms;
			guiUniforms: TGUIUniforms;
			worldUniforms: TWorldUniforms;
			teapotMesh: TMetalMesh;
			outputColorTexture: MTLTextureProtocol;
			outputDepthTexture: MTLTextureProtocol;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	CocoaUtils;

type
	TTexVertex = record
		position: TVec2;
		texCoord: TVec2;
	end;

function TexVertex(constref position: TVec2; constref texCoord: TVec2): TTexVertex;
begin
	result.position := position;
	result.texCoord := texCoord;
end;

{=============================================}
{@! ___RENDERER___ } 
{=============================================}

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := size.width;
	viewport.height := size.height;			

	//viewport.znear := 0;
	//viewport.zfar := 100;

	modelUniforms.projectionMatrix := TMat4.Perspective(60, viewport.width / viewport.height, {viewport.znear, viewport.zfar}0.1, 100);
	modelUniforms.lightPos := V4(-1, 1, 0, 0);

	guiUniforms.projectionMatrix := TMat4.Ortho(0, viewport.width, viewport.height, 0, {viewport.znear, viewport.zfar}0, 100);
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single = 3.45;
	size: single = 100;
	quadVertices: array[0..5] of TTexVertex;
	w, h: single;
begin

	// model
	modelUniforms.modelMatrix := TMat4.Identity;
	modelUniforms.modelMatrix *= TMat4.Translate(0, 0, -4);
	modelUniforms.modelMatrix *= TMat4.RotateY(DegToRad(rotation));
	modelUniforms.modelMatrix *= TMat4.Scale(scale, scale, scale);
	rotation += 0.8;
	modelUniforms.invertedModelMatrix := modelUniforms.modelMatrix.Inverse.Transpose;

	// gui
	w := viewport.width / 5;
	h := viewport.height / 5;
	quadVertices[0] := TexVertex(V2( w,  -h), V2(1, 0));
	quadVertices[1] := TexVertex(V2(-w, -h), 	V2(0, 0));
	quadVertices[2] := TexVertex(V2(-w,  h), 	V2(0, 1));
	quadVertices[3] := TexVertex(V2( w,  -h), V2(1, 0));
	quadVertices[4] := TexVertex(V2(-w,  h), 	V2(0, 1));
	quadVertices[5] := TexVertex(V2( w,   h), V2(1, 1));

	MTLBeginCommand;

		// draw model
		MTLBeginEncoding(modelShader, outputColorTexture);
			worldUniforms.mode := kRenderModeColor;
			// TODO: set clear color for encoder as param to MTLBeginEncoding
			// otherwise give error if calling MTLSetClearColor during draw loop
			MTLSetVertexBuffer(teapotMesh.vertexBuffer, 0);
			MTLSetVertexBytes(@modelUniforms, sizeof(modelUniforms), 1);
			MTLSetCullMode(MTLCullModeBack);
			MTLSetFrontFacingWinding(MTLWindingClockwise);
			MTLSetFragmentBytes(@worldUniforms, sizeof(worldUniforms), 0);
			MTLDrawIndexed(MTLPrimitiveTypeTriangle, teapotMesh.indices.count, MTLIndexTypeUInt32, teapotMesh.indexBuffer, 0);
		MTLEndEncoding;

		MTLBeginEncoding(modelShader, outputDepthTexture);
			worldUniforms.mode := kRenderModeDepth;
			MTLSetVertexBuffer(teapotMesh.vertexBuffer, 0);
			MTLSetVertexBytes(@modelUniforms, sizeof(modelUniforms), 1);
			MTLSetCullMode(MTLCullModeBack);
			MTLSetFrontFacingWinding(MTLWindingClockwise);
			MTLSetFragmentBytes(@worldUniforms, sizeof(worldUniforms), 0);
			MTLDrawIndexed(MTLPrimitiveTypeTriangle, teapotMesh.indices.count, MTLIndexTypeUInt32, teapotMesh.indexBuffer, 0);
		MTLEndEncoding;

		// draw gui
		MTLBeginEncoding(guiShader);

			MTLSetFragmentTexture(outputColorTexture, 0);
			MTLSetVertexBytes(@quadVertices, sizeof(quadVertices), 0);
			guiUniforms.modelMatrix := TMat4.Translate(150, 100, 0);
			MTLSetVertexBytes(@guiUniforms, sizeof(guiUniforms), 1);
			MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);

			MTLSetFragmentTexture(outputDepthTexture, 0);
			MTLSetVertexBytes(@quadVertices, sizeof(quadVertices), 0);
			guiUniforms.modelMatrix := TMat4.Translate(150, 300, 0);
			MTLSetVertexBytes(@guiUniforms, sizeof(guiUniforms), 1);
			MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);

		MTLEndEncoding;

	MTLEndCommand;
end;

procedure TMTKRenderer.dealloc;
begin
	modelShader.Free;
	guiShader.Free;
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
	show(view.currentDrawable.texture);

	context := MTLCreateContext(view);
	MTLMakeContextCurrent(context);

	teapotMesh := LoadOBJModel(ResourcePath('teapot', 'obj'), TMetalMesh) as TMetalMesh;

	with teapotMesh do
		begin
			vertexBuffer := view.device.newBufferWithBytes_length_options(vertices.list, vertices.count * sizeof(TMeshVertex), MTLResourceOptionCPUCacheModeDefault);
			indexBuffer := view.device.newBufferWithBytes_length_options(indices.list, indices.count * sizeof(UInt32), MTLResourceOptionCPUCacheModeDefault);			
		end;

	worldUniforms.shineDamper := 3;
	worldUniforms.reflectivity := 1;
	worldUniforms.lightColor := V3(1, 0, 0);
	worldUniforms.mode := 0;

	// shaders
	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('GUI', 'metallib');
	guiShader := MTLCreatePipeline(options);

	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('Teapot', 'metallib');
	modelShader := MTLCreatePipeline(options);

	MTLSetDepthStencil(modelShader, MTLCompareFunctionLess, true);
	MTLSetClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));

	// output textures
	// TODO: how do we resize these?
	outputColorTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, MTLPixelFormatBGRA8Unorm);
	outputDepthTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, MTLPixelFormatRGBA16Float);
end;

end.