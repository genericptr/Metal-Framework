unit MetalControl;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}

interface

uses
	Metal, MetalKit, CocoaAll, MacOSAll,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

// http://wiki.freepascal.org/How_To_Write_Lazarus_Component

type
	TMetalBaseControl = class;

	TMTKRenderer = objcclass (NSObject, MTKViewDelegateProtocol)
		public
			function init (inControl: TMetalBaseControl): TMTKRenderer; message 'init:';
		private
			control: TMetalBaseControl;
			procedure mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize); message 'mtkView:drawableSizeWillChange:';
			procedure drawInMTKView (fromView: MTKView); message 'drawInMTKView:';
	end;

	TMetalBaseControl = class (TWinControl)
		private
			FOnPaint: TNotifyEvent;
		public
			property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
		public
			renderView: MTKView;
			viewport: MTLViewport;
		public
			constructor Create(AOwner: TComponent); override;
			procedure LoadMetal;
		protected
			procedure RealizeBounds; override;
			procedure CreateWnd; override;
			procedure DestroyWnd; override;
			procedure Paint; virtual;
		private
			renderer: TMTKRenderer;
	end;

type
  TMetalControl = class(TMetalBaseControl)
  public
  	property OnChangeBounds;
  	property OnClick;
  	property OnDblClick;
  	property OnEnter;
  	property OnExit;
  	property OnKeyDown;
  	property OnKeyPress;
  	property OnKeyUp;
  	property OnMouseDown;
  	property OnMouseMove;
  	property OnMouseUp;
  end;

procedure Register;

implementation

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

function TMTKRenderer.init (inControl: TMetalBaseControl): TMTKRenderer;
begin
	control := inControl;
	result := self;
end;

{=============================================}
{@! ___METAL CONTROL___ } 
{=============================================}
constructor TMetalBaseControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  SetInitialBounds(0, 0, 160, 90);
  //LoadMetal;
end;

procedure TMetalBaseControl.LoadMetal;
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

procedure TMetalBaseControl.RealizeBounds;
begin
	inherited;

	//if HandleAllocated and not Assigned(renderView) then
	//	LoadMetal;

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := Width;
	viewport.height := Height;			
	viewport.znear := -1;
	viewport.zfar := 1;

	renderView.setFrame(NSMakeRect(0, 0, Width, Height));
end;

procedure TMetalBaseControl.CreateWnd;
begin
	inherited;

	writeln('TMetalBaseControl.CreateWnd');
	LoadMetal;
end;

procedure TMetalBaseControl.DestroyWnd;
begin
	writeln('TMetalBaseControl.DestroyWnd');

	renderer.release;	

	inherited;
end;

procedure TMetalBaseControl.Paint;
begin
	//if HandleAllocated and not Assigned(renderView) then
	//	LoadMetal;

	if Assigned(OnPaint) then OnPaint(Self);
end;

{=============================================}
{@! ___LAZARUS___ } 
{=============================================}

procedure Register;
begin
  {$I metalcontrol_icon.lrs}
  RegisterComponents('OpenGL',[TMetalControl]);
end;

end.
