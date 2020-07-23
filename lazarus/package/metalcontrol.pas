unit MetalControl;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}

interface

uses
	MetalPipeline, Metal, MetalKit, CocoaAll, MacOSAll,
  Classes, SysUtils, 
  LResources, CocoaWSCommon, LCLType,
  Forms, Controls, Graphics, Dialogs;

// http://wiki.freepascal.org/Lazarus_Packages
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
			FOnPrepare: TNotifyEvent;
		published
			property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
			property OnPrepare: TNotifyEvent read FOnPrepare write FOnPrepare;
		public
			renderView: MTKView;
			viewport: MTLViewport;
			invalidateOnResize: boolean;
		public
			constructor Create(AOwner: TComponent); override;
			procedure SetPreferredFrameRate(newValue: integer);
			procedure MakeCurrent;
		protected
			procedure RealizeBounds; override;
			procedure CreateWnd; override;
			procedure DestroyWnd; override;
			procedure Invalidate; override;
		protected
			procedure Paint; virtual;
			procedure Prepare; virtual;
		private
			renderer: TMTKRenderer;
			context: TMetalContext;
			procedure LoadMetal;
	end;

type
  TMetalControl = class(TMetalBaseControl)
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Constraints;

  	// TODO: what are the differences between these?? we need to
  	// to tell the user when the viewport changed but which one do we use?
  	property OnChangeBounds;
  	property OnConstrainedResize;
  	property OnResize;

  	property OnKeyDown;
  	property OnKeyPress;
  	property OnKeyUp;

  	property OnClick;
  	property OnDblClick;
  	property OnEnter;
  	property OnExit;

  	property OnMouseDown;
  	property OnMouseMove;
  	property OnMouseUp;
  	property OnMouseWheel;
  	property OnMouseWheelDown;
  	property OnMouseWheelUp;
  end;

function MTLCreateContext (control: TMetalControl): TMetalContext; overload; inline;

procedure Register;

implementation

{ LazMTKView }

type
  TLazMTKView = objcclass (MTKView)
    callback: TLCLCommonCallback;
    procedure mouseDown(event: NSEvent); override;
    procedure scrollWheel(event: NSEvent); override;
  end;

procedure TLazMTKView.mouseDown(event: NSEvent);
begin
  if not assigned(callback) or not callback.MouseUpDownEvent(event) then
    begin
      // do not pass mouseDown below or it will pass it to the parent control
      // causing double events
      //inherited mouseDown(event);
    end;
end;

procedure TLazMTKView.scrollWheel(event: NSEvent);
begin
  if assigned(callback) then
    callback.scrollWheel(event)
  else
    inherited scrollWheel(event);
end;

{ Metal Utilities }

function MTLCreateContext (control: TMetalControl): TMetalContext;
begin
	result := MTLCreateContext(control.renderView);
end;

{ MTKRenderer }

procedure TMTKRenderer.mtkView_drawableSizeWillChange (fromView: MTKView; size: CGSize);
begin
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

{ MetalBaseControl}

constructor TMetalBaseControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  SetInitialBounds(0, 0, 200, 200);
end;

procedure TMetalBaseControl.SetPreferredFrameRate(newValue: integer);
begin
	context.SetPreferredFrameRate(newValue);
end;

procedure TMetalBaseControl.MakeCurrent;
begin
	context.MakeCurrent;
end;

procedure TMetalBaseControl.LoadMetal;
var
 	superview: NSView; 
 	device: MTLDeviceProtocol;
begin
	// NOTE: do we own device?
	device := MTLCreateSystemDefaultDevice;
	renderView := TLazMTKView.alloc.initWithFrame_device(CGRectMake(0, 0, 0, 0), device);
	
	if renderView.device = nil then
		begin
			writeln('metal is not supported on this device');
			halt;
		end;

	context := MTLCreateContext(renderView);
	context.MakeCurrent;

	// add render view to TWinControl view handle
	superview := NSView(Handle);

	renderView.setFrame(superview.bounds);
	superview.addSubview(renderView);

	// create objc class for render delegate
	renderer := TMTKRenderer.alloc.init(self);
	renderView.setDelegate(renderer);
  
  TLazMTKView(renderView).callback := TLCLCommonCallback.Create(renderView, self);

	// let the user setup the pipeline now that metal is loaded
	Prepare;
end;

procedure TMetalBaseControl.RealizeBounds;
begin
	inherited;

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := Width;
	viewport.height := Height;			
	viewport.znear := -1;
	viewport.zfar := 1;

	renderView.setFrame(NSMakeRect(0, 0, Width, Height));

	if invalidateOnResize then
		Invalidate;
end;

procedure TMetalBaseControl.CreateWnd;
begin
	inherited;

	LoadMetal;
end;

procedure TMetalBaseControl.DestroyWnd;
begin
	renderer.release;	
	context.Free;

	inherited;
end;

procedure TMetalBaseControl.Invalidate;
begin
	inherited;

	renderView.draw;
end;

procedure TMetalBaseControl.Prepare;
begin
	if Assigned(OnPrepare) then OnPrepare(Self);
end;

procedure TMetalBaseControl.Paint;
begin
	if Assigned(OnPaint) and IsVisible then
    begin
      MTLMakeContextCurrent(context);
      OnPaint(Self);
    end;
end;

{ Lazarus }

procedure Register;
begin
  {$I metalcontrol_icon.lrs}
  RegisterComponents('OpenGL',[TMetalControl]);
end;

end.
