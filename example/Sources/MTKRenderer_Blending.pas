{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_Blending;
interface
uses
	VectorMath, Metal, MetalKit, MetalPipeline,
	CocoaAll, MacOSAll, SysUtils, Math, FGL;

type
	TWorldUniforms = record
		public
			type const Index = 1;
		public
			modelMatrix: TMat4;
			projectionMatrix: TMat4;
	end;

type
	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inView: MTKView): TMTKRenderer; message 'init:';
		private
			view: MTKView;

			context: TMetalContext;
			shaderLibrary: TMetalLibrary;
			defaultShader: TMetalPipeline;
			blendShader: TMetalPipeline;
			viewport: MTLViewport;
			uniforms: TWorldUniforms;
			texture: MTLTextureProtocol;

			procedure dealloc; override;

			{ MTKViewDelegateProtocol }
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

implementation
uses
	TGALoader, CocoaUtils;

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
	viewport.znear := 0;
	viewport.zfar := 100;

	uniforms.projectionMatrix := TMat4.Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single;
	size: single = 200 / 2;
	vertices: array[0..5] of TTexVertex;
begin
	scale := 3.45;

	vertices[0] := TexVertex(V2(size,  -size),  V2(1, 0));
	vertices[1] := TexVertex(V2(-size,  -size), V2(0, 0));
	vertices[2] := TexVertex(V2(-size,   size), V2(0, 1));
	vertices[3] := TexVertex(V2(size,  -size),  V2(1, 0));
	vertices[4] := TexVertex(V2(-size,   size), V2(0, 1));
	vertices[5] := TexVertex(V2(size,   size),  V2(1, 1));
	
	MTLMakeContextCurrent(context);

	MTLBeginFrame;
		
		MTLSetFragmentTexture(texture, 0);
		MTLSetVertexBytes(@vertices, sizeof(vertices), 0);
		
		MTLSetShader(defaultShader);
			uniforms.modelMatrix := TMat4.Translate(200, 200, 0);
			MTLSetVertexBytes(@uniforms, sizeof(uniforms), TWorldUniforms.Index);
		MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);

		MTLSetShader(blendShader);
			uniforms.modelMatrix := TMat4.Translate(220, 220, 0);
			MTLSetVertexBytes(@uniforms, sizeof(uniforms), TWorldUniforms.Index);
		MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);

	MTLEndFrame;
end;

procedure TMTKRenderer.dealloc;
begin
	defaultShader.Free;
	blendShader.Free;
	context.Free;
	shaderLibrary.Free;

	inherited dealloc;
end;

function TMTKRenderer.init (inView: MTKView): TMTKRenderer;
var
	error: NSError;
	options: TMetalPipelineOptions;
	libraryOptions: TMetalLibraryOptions;
begin
	view := inView;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);
 	
	// context
	context := MTLCreateContext(view);
	MTLMakeContextCurrent(context);

	// library
	libraryOptions := TMetalLibraryOptions.Create;
	//libraryOptions.name := ResourcePath('Blending', 'metallib');

	libraryOptions.name := '/Users/ryanjoseph/Developer/Projects/FPC/Metal-Framework/example/Shaders/Blending.metal';
	libraryOptions.preprocessorMacros := NSDictionary.dictionaryWithObject_forKey(NSNull.null, NSSTR('MY_MACRO'));

	shaderLibrary := MTLCreateLibrary(libraryOptions);

	// shaders
	options := TMetalPipelineOptions.Create;
	options.shaderLibrary := shaderLibrary;
	defaultShader := MTLCreatePipeline(options);

	options := TMetalPipelineOptions.Create;
	options.shaderLibrary := shaderLibrary;

	options.pipelineDescriptor := MTLCreatePipelineDescriptor;
	options.pipelineDescriptor.colorAttachmentAtIndex(0).setBlendingEnabled(true);
	options.pipelineDescriptor.colorAttachmentAtIndex(0).setDestinationRGBBlendFactor(MTLBlendFactorOneMinusDestinationColor);	
	
	blendShader := MTLCreatePipeline(options);

	MTLSetClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));

	texture := MTLLoadTexture(ResourcePath('Image', 'tga'));
end;

end.