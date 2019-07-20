{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	//MTKRenderer_HelloTriangle,
	//MTKRenderer_BasicBuffers,
	//MTKRenderer_BasicTexturing,
	//MTKRenderer_API,
	//MTKRenderer_Cube,
	MTKRenderer_DepthStencil,
	//MTKRenderer_OBJ,
	//MTKRenderer_Blending,
	//MTKRenderer_HelloCompute,
	//MTKRenderer_FBO,
	//MTKRenderer_FBO_2,
	MetalKit, Metal, CocoaAll, MacOSAll;

type
	TAppController = objcclass(NSObject)
		public
			procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
			procedure newDocument (sender: id); message 'newDocument:';
		private
   		window: NSWindow;
   		renderView: MTKView;
   		renderer: TMTKRenderer;

   		procedure takeScreenshot (sender: id); message 'takeScreenshot:';
 	end;

implementation
uses
	MetalPipeline;

type
	TMTKRendererWindowController = objcclass (NSWindowController)
		renderView: MTKView;
		renderer: TMTKRenderer;
		procedure windowDidLoad; override;
	end;

procedure TMTKRendererWindowController.windowDidLoad;
begin
	renderView := MTKView.alloc.initWithFrame_device(MacOSAll.CGRect(window.contentView.bounds), MTLCreateSystemDefaultDevice);
	renderView.setAutoresizingMask(NSViewWidthSizable + NSViewHeightSizable);
	window.contentView.addSubview(renderView);
 	renderView.setPreferredFramesPerSecond(60);
 	if renderView.device = nil then
 		begin
 			writeln('metal is not supported on this device');
 			halt;
 		end;
 	renderer := TMTKRenderer.alloc.init(renderView);
end;

procedure TAppController.takeScreenshot (sender: id);
begin
	writeln('take screen shot');
	renderView.setFramebufferOnly(false);
	renderView.draw;
	renderView.draw;
	renderView.draw;
	MTLWriteTextureToFile(renderView.currentDrawable.texture, 'metal-triangle.png');
	renderView.setFramebufferOnly(true);
end;

procedure TAppController.newDocument (sender: id);
var
	controller: NSWindowController;
begin
	controller := TMTKRendererWindowController.alloc.initWithWindowNibName(NSSTR('Window'));
	controller.showWindow(nil);
end;

procedure TAppController.applicationDidFinishLaunching(notification: NSNotification);
begin
	renderView := MTKView.alloc.initWithFrame_device(MacOSAll.CGRect(window.contentView.bounds), MTLCreateSystemDefaultDevice);
	renderView.setAutoresizingMask(NSViewWidthSizable + NSViewHeightSizable);

	window.contentView.addSubview(renderView);
 	writeln(window.description.utf8string);

 	renderView.setPreferredFramesPerSecond(60);

 	if renderView.device = nil then
 		begin
 			writeln('metal is not supported on this device');
 			halt;
 		end;
 	
 	renderer := TMTKRenderer.alloc.init(renderView);
end;

end.