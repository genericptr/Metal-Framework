{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch advancedrecords}

unit MTKRenderer_Blending;
interface
uses
	MetalTypes, Metal, MetalKit, MetalPipeline,
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
	TTexQuad = record
		position: TVec2;
		texCoord: TVec2;
	end;

function TexQuad(constref position: TVec2; constref texCoord: TVec2): TTexQuad;
begin
	result.position := position;
	result.texCoord := texCoord;
end;

{=============================================}
{@! ___RENDERER___ } 
{=============================================}
function Mat4Ortho (Left,Right,Bottom,Top,Near,Far:TScalar): TMat4;
//https://stackoverflow.com/questions/36295339/metal-nothing-is-rendered-when-using-orthographic-projection-matrix#40856855
var
  sLength,sHeight, sDepth: single;
begin
  sLength := 1.0 / (Right - left);
  sHeight := 1.0 / (Top   - bottom);
  sDepth  := 1.0 / (Far   - Near);
  result[0,0] := 2.0 * sLength;
  result[0,1] := 0.0;
  result[0,2] := 0.0;
  result[0,3] := 0.0;
  result[1,0] := 0.0;
  result[1,1] := 2.0 * sHeight;
  result[1,2] := 0.0;
  result[1,3] := 0.0;
  result[2,0] := 0.0;
  result[2,1] := 0.0;
  result[2,2] := sDepth;
  result[2,3] := 0.0;
  result[3,0] := 0.0;
  result[3,1] := 0.0;
  result[3,2] := -near  * sDepth;;
  result[3,3] := 1.0;
end;

type
	NSScreenMissing = objccategory external (NSScreen)
		function backingScaleFactor: CGFloat; message 'backingScaleFactor';
	end;

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
var
	scale: single;
begin
	//scale := fromView.window.screen.backingScaleFactor;

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := size.width;
	viewport.height := size.height;			
	viewport.znear := 0;
	viewport.zfar := 100;

	//uniforms.projectionMatrix := TMat4.Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);
	uniforms.projectionMatrix := Mat4Ortho(0, viewport.width, viewport.height, 0, viewport.znear, viewport.zfar);
end;


procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
var
	scale: single;
	size: single = 200 / 2;
	vertices: array[0..5] of TTexQuad;
begin
	scale := 3.45;

	//uniforms.modelMatrix := TMat4.Identity;
	//uniforms.modelMatrix *= TMat4.Translate(0, 0, 0);
	//uniforms.modelMatrix *= TMat4.RotateY(DegToRad(rotation));
	//uniforms.modelMatrix *= TMat4.Scale(scale, scale, scale);
	//rotation += 0.8;

	vertices[0] := TexQuad(V2(size,  -size),  V2(1, 0));
	vertices[1] := TexQuad(V2(-size,  -size), V2(0, 0));
	vertices[2] := TexQuad(V2(-size,   size), V2(0, 1));
	vertices[3] := TexQuad(V2(size,  -size),  V2(1, 0));
	vertices[4] := TexQuad(V2(-size,   size), V2(0, 1));
	vertices[5] := TexQuad(V2(size,   size),  V2(1, 1));


	// single shader
	//MTLBeginFrame(defaultShader);
	//	MTLSetFragmentTexture(texture, 0);
	//	MTLSetVertexBytes(@vertices, sizeof(vertices), 0);
	//	uniforms.modelMatrix := TMat4.Identity;
	//	MTLSetVertexBytes(@uniforms, sizeof(uniforms), TWorldUniforms.Index);
	//	MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);
	//MTLEndFrame;

	MTLBeginFrame;

		MTLSetFragmentTexture(texture, 0);
		MTLSetVertexBytes(@vertices, sizeof(vertices), 0);
		
		MTLSetShader(defaultShader);
			uniforms.modelMatrix := TMat4.Identity;
			MTLSetVertexBytes(@uniforms, sizeof(uniforms), TWorldUniforms.Index);
			MTLDraw(MTLPrimitiveTypeTriangle, 0, 6);

		MTLSetShader(blendShader);
			uniforms.modelMatrix := TMat4.Translate(20, 20, 0);
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
	i: integer;
	image: TGAImage;
	url: NSURL;
begin
	view := inView;
	view.setDelegate(self);
	view.delegate.mtkView_drawableSizeWillChange(view, view.drawableSize);
 	
	// context
	context := MTLCreateContext(view);
	MTLMakeContextCurrent(context);

	// library
	libraryOptions := TMetalLibraryOptions.Default;
	libraryOptions.libraryName := ResourcePath('Blending', 'metallib');
	shaderLibrary := MTLCreateLibrary(libraryOptions);

	// shaders
	options := TMetalPipelineOptions.Default;
	options.shaderLibrary := shaderLibrary;
	defaultShader := MTLCreatePipeline(options);

	options := TMetalPipelineOptions.Default;
	options.shaderLibrary := shaderLibrary;
	options.blendingEnabled := true;
	options.destinationRGBBlendFactor := MTLBlendFactorOneMinusDestinationColor;
	blendShader := MTLCreatePipeline(options);

	//MTLSetDepthStencil(blendShader, MTLCompareFunctionLess, true);

	MTLSetClearColor(MTLClearColorMake(0.2, 0.2, 0.2, 1));

	url := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('Image'), NSSTR('tga'));
	image := LoadTGAFile(url.relativePath.UTF8String);
	texture := MTLLoadTexture(image.bytes, image.width, image.height);
end;

end.