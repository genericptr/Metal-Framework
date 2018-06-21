{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	//MTKRenderer_HelloTriangle,
	//MTKRenderer_BasicBuffers,
	//MTKRenderer_BasicTexturing,
	//MTKRenderer_API,
	MTKRenderer_Cube,
	MetalKit, Metal, CocoaAll;

type
	TAppController = objcclass(NSObject)
		public
			procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
		private
   		window: NSWindow;
   		renderView: MTKView;
   		renderer: TMTKRenderer;
 	end;

implementation

procedure TAppController.applicationDidFinishLaunching(notification: NSNotification);
begin
	{$macro on}
	{$define my_foo:='foo'}
	{$define do_this(x):='do_this_x'}
	writeln(my_foo, ' = ', {$I %FPCTARGETCPU%});
	//writeln(do_this(100));

	// Insert code here to initialize your application 
	renderView := window.contentView;
 	writeln(renderView.description.utf8string);

 	// Set the view to use the default device
 	renderView.setDevice(MTLCreateSystemDefaultDevice);

 	if renderView.device = nil then
 		begin
 			writeln('metal is not supported on this device');
 			halt;
 		end;

 	renderer := TMTKRenderer.alloc.init(renderView);
end;

end.