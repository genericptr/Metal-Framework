unit MetalControl;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$interfaces CORBA}

interface

uses
	SIMDTypes,
  Metal, MetalKit, CocoaAll, MacOSAll,
  Classes, SysUtils, FileUtil, Forms, StdCtrls, Controls, Graphics, Dialogs;

type
	IMetalDelegate = interface ['IMetalDelegate']
		procedure Paint;
	end;

type
	TMetalControl = class;

	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inControl: TMetalControl): TMTKRenderer; message 'init:';
		private
			control: TMetalControl;
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

	TMetalControl = class (TWinControl)
		public
			delegate: IMetalDelegate;
			renderView: MTKView;
			viewport: MTLViewport;
		public
			constructor Create(AOwner: TComponent); override;
			procedure LoadMetal;
		protected
			procedure RealizeBounds; override;
			procedure DestroyWnd; override;
			procedure Paint; virtual;
		private
			renderer: TMTKRenderer;
	end;

// some helpers I like for debugging
procedure Fatal (condition: boolean; msg: string = ''; error: NSError = nil);
procedure Fatal (msg: string; error: NSError = nil);
procedure Show (obj: id; msg: string = ''); 

implementation

{=============================================}
{@! ___UTILS___ } 
{=============================================}
procedure Fatal (condition: boolean; msg: string = ''; error: NSError = nil);
begin
	if condition then
		begin
			if error = nil then
				writeln(msg)
			else
				writeln(msg+' -> '+error.localizedDescription.UTF8String);
			//raise Exception.Create('fatal');
			halt;
		end;
end;

procedure Fatal (msg: string; error: NSError = nil);
begin
	Fatal(true, msg, error);
end;

procedure Show (obj: id; msg: string = ''); 
begin
	if msg <> '' then
		msg := msg+' ';
	if obj = nil then
		writeln(msg+'nil')
	else
		writeln(msg+obj.description.UTF8String);
end;

{=============================================}
{@! ___METAL RENDERER___ } 
{=============================================}
procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
	// NOTE: lazarus already knows when the control changes size so we can safely ignore this
end;

procedure TMTKRenderer.drawInMTKView (fromView: MTKView);
begin
	control.Paint;
end;

function TMTKRenderer.init (inControl: TMetalControl): TMTKRenderer;
begin
	control := inControl;
	result := self;
end;

{=============================================}
{@! ___METAL CONTROL___ } 
{=============================================}
constructor TMetalControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // NOTE: laz didn't like this but it feels like we should be able
  // to load metal from inside the constructor
  //Parent := TWinControl(AOwner);
  //LoadMetal;
end;

procedure TMetalControl.LoadMetal;
var
 	superview: NSView; 
 	device: MTLDeviceProtocol;
begin
	writeln('load metal control');

	// NOTE: do we own this??
	device := MTLCreateSystemDefaultDevice;
	renderView := MTKView.alloc.initWithFrame_device(CGRectMake(0, 0, 0, 0), device);

	// device is retained by MTKView so we can release now
	device.release;

	if renderView.device = nil then
		begin
			writeln('metal is not supported on this device');
			halt;
		end;

	// add render view to TWinControl view handle
	superview := NSView(Handle);
	writeln('superview: ', superview.description.UTF8String);

	renderView.setFrame(superview.bounds);
	superview.addSubview(renderView);

	// create objc class for render delegate
	renderer := TMTKRenderer.alloc.init(self);
	renderView.setDelegate(renderer);
end;

procedure TMetalControl.RealizeBounds;
begin
	inherited;

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := Width;
	viewport.height := Height;			
	viewport.znear := -1;
	viewport.zfar := 1;

	renderView.setFrame(NSMakeRect(0, 0, Width, Height));
end;

procedure TMetalControl.DestroyWnd;
begin
	writeln('TMetalControl.DestroyWnd');

	renderer.release;	
	delegate := nil;

	inherited;
end;

procedure TMetalControl.Paint;
begin
	delegate.Paint;
end;

end.

