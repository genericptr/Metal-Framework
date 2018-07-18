{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_FBO_2;
interface
uses
	MetalMesh, Scanner, MeshLoader, MetalTypes, Metal, MetalKit, MetalPipeline,
	CocoaAll, MacOSAll, SysUtils, Math, CTypes, FGL;

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

var
	ModelRenderPassDescriptor: MTLRenderPassDescriptor = nil;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single = 3.45;
	size: single = 100;
	quadVertices: array[0..5] of TTexVertex;
	w, h: single;
var
	colorAttachment: MTLRenderPassColorAttachmentDescriptor;
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

	if ModelRenderPassDescriptor = nil then
		begin
			ModelRenderPassDescriptor := MTLRenderPassDescriptor.alloc.init;

	    ModelRenderPassDescriptor.depthAttachment.setTexture(view.depthStencilTexture);

			colorAttachment := ModelRenderPassDescriptor.colorAttachmentAtIndex(1);
			colorAttachment.setTexture(outputColorTexture);
			colorAttachment.setClearColor(view.clearColor);
			colorAttachment.setLoadAction(MTLLoadActionClear);
			colorAttachment.setStoreAction(MTLStoreActionStore);

			colorAttachment := ModelRenderPassDescriptor.colorAttachmentAtIndex(2);
			colorAttachment.setTexture(outputDepthTexture);
			colorAttachment.setClearColor(view.clearColor);
			colorAttachment.setLoadAction(MTLLoadActionClear);
			colorAttachment.setStoreAction(MTLStoreActionStore);
		end;

	MTLBeginCommand;

		// draw model		
		MTLBeginEncoding(modelShader, ModelRenderPassDescriptor);
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
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;
	colorAttachment: MTLRenderPipelineColorAttachmentDescriptor;
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
			vertexBuffer := view.device.newBufferWithBytes_length_options(vertices.list, vertices.count * sizeof(TMeshVertex), MTLResourceOptionCPUCacheModeDefault);
			indexBuffer := view.device.newBufferWithBytes_length_options(indices.list, indices.count * sizeof(UInt32), MTLResourceOptionCPUCacheModeDefault);			
		end;

	worldUniforms.shineDamper := 3;
	worldUniforms.reflectivity := 1;
	worldUniforms.lightColor := V3(1, 0, 0);

	// gui shader
	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('GUI', 'metallib');
	guiShader := MTLCreatePipeline(options);

	// model shader

	{$define DIRECT_RENDER_PIPELINE_DESC}
	{$ifdef DIRECT_RENDER_PIPELINE_DESC}
	pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init.autorelease;
	pipelineStateDescriptor.setDepthAttachmentPixelFormat(view.depthStencilPixelFormat);
	
	colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	colorAttachment.setPixelFormat(MTLPixelFormatInvalid);

	colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(1);
	colorAttachment.setPixelFormat(MTLPixelFormatBGRA8Unorm);

	colorAttachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(2);
	colorAttachment.setPixelFormat(MTLPixelFormatBGRA8Unorm);
	{$endif}

	options := TMetalPipelineOptions.Default;
	options.libraryName := ResourcePath('Teapot_FBO', 'metallib');

	{$ifdef DIRECT_RENDER_PIPELINE_DESC}
	options.pipelineStateDescriptor := pipelineStateDescriptor;
	{$else}
	options.colorAttachments := [
		TMetalPipelineColorAttachment.Create(MTLPixelFormatInvalid),
		TMetalPipelineColorAttachment.Create(MTLPixelFormatBGRA8Unorm),
		TMetalPipelineColorAttachment.Create(MTLPixelFormatBGRA8Unorm)
	];
	{$endif}

	modelShader := MTLCreatePipeline(options);

	MTLSetDepthStencil(modelShader, MTLCompareFunctionLess, true);
	MTLSetClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));

	// output textures
	// TODO: how do we resize these?
	{$ifdef DIRECT_RENDER_PIPELINE_DESC}
	outputColorTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(1).pixelFormat, MTLTextureUsageShaderRead or MTLTextureUsageRenderTarget);
	outputDepthTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(2).pixelFormat, MTLTextureUsageShaderRead or MTLTextureUsageRenderTarget);
	{$else}
	outputColorTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, options.colorAttachments[1].pixelFormat, MTLTextureUsageShaderRead or MTLTextureUsageRenderTarget);
	outputDepthTexture := MTLNewTexture(trunc(view.drawableSize.width), trunc(view.drawableSize.height), MTLTextureType2D, options.colorAttachments[2].pixelFormat, MTLTextureUsageShaderRead or MTLTextureUsageRenderTarget);
	{$endif}
end;

end.