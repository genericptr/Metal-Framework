unit MetalForm;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$interfaces CORBA}

interface

uses
	SIMDTypes,
  Metal, MetalKit, CocoaAll, MacOSAll,
  Classes, SysUtils, FileUtil, Forms, StdCtrls, Controls, Graphics, Dialogs;


type
	TMetalControl = class;

	type
		IMetalDelegate = interface ['IMetalDelegate']
			procedure Paint;
		end;

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
		public
			constructor Create(AOwner: TComponent); override;
		protected

			procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
			procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
			procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;

			procedure RealizeBounds; override;
			procedure DestroyWnd; override;
			procedure Paint; virtual;
		private
			renderer: TMTKRenderer;
			viewportSize: vector_uint2;
			viewport: MTLViewport;

			procedure LoadMetal;
	end;

type
	THelloTriangle = class (IMetalDelegate)
		public
			constructor Create (inControl: TMetalControl);
			procedure Paint;
			destructor Destroy; override;
		private
			control: TMetalControl;

			pipelineState: MTLRenderPipelineStateProtocol;
			commandQueue: MTLCommandQueueProtocol;
	end;

type
  TMetalForm = class(TForm)
  	public
    	constructor Create(TheOwner: TComponent); override;
    	destructor Destroy; override;
	  private
  		ExitButton1: TButton;
  		metalControl: TMetalControl;
  		drawingDelegate: THelloTriangle;

	  	procedure ExitButton1Click(Sender: TObject);
	  	procedure FormResize(Sender: TObject);
  end;

var
  Form1: TMetalForm;

implementation

{$R *.lfm}

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

	// NOTE: why do we even need this???
	//renderView.delegate.mtkView_drawableSizeWillChange(renderView, renderView.drawableSize);
	//Width := Trunc(renderView.drawableSize.width);
	//Height := Trunc(renderView.drawableSize.height);

end;

procedure TMetalControl.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
	inherited;
	writeln('mouse down ', x, ',', y);
end;

procedure TMetalControl.MouseMove(Shift: TShiftState; X,Y: Integer);
begin
	inherited;

	writeln('mouse moved ', x, ',', y);
end;

procedure TMetalControl.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
	inherited;

	writeln('mouse up ', x, ',', y);
end;

procedure TMetalControl.RealizeBounds;
begin
	inherited;
	
	//writeln('resize ', Width,'x',Height);

	viewportSize.x := Width;
	viewportSize.y := Height;

	viewport.originX := 0;
	viewport.originY := 0;
	viewport.width := viewportSize.x;
	viewport.height := viewportSize.y;			
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

{=============================================}
{@! ___DRAWING DELEGATE___ } 
{=============================================}
const
	AAPLVertexInputIndexVertices     = 0;
	AAPLVertexInputIndexViewportSize = 1;

type
	TAAPLVertex = record
		position: vector_float2;
		// align each vertex attribute on 4 byte boundries
		padding: array[0..1] of simd_float;
		color: vector_float4;
	end;

function AAPLVertex(constref position: vector_float2; constref color: vector_float4): TAAPLVertex;
begin
	result.position := position;
	result.color := color;
end;

constructor THelloTriangle.Create (inControl: TMetalControl);
var
	defaultLibrary: MTLLibraryProtocol;
	vertexFunction: MTLFunctionProtocol;
	fragmentFunction: MTLFunctionProtocol;
	error: NSError;
	url: NSURL;
	attachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;
	imageData: pointer;
	device: MTLDeviceProtocol;
begin
	control := inControl;
	Fatal(control.renderView = nil, 'metal control has no render target.');

	device := control.renderView.device;
	Fatal(device = nil, 'no device found in render view.');

	Show(device, 'GPU:');

	// Load all the shader files with a .metallib file extension in the project
	//defaultLibrary := device.newDefaultLibrary;
	url := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('Color'), NSSTR('metallib'));
	Show(url);

	defaultLibrary := device.newLibraryWithURL_error(url, @error);
	Fatal(defaultLibrary = nil, 'no .metallib files were found.', error);
	Show(defaultLibrary);

	// Load the vertex function from the library
	vertexFunction := defaultLibrary.newFunctionWithName(NSSTR('vertexShader'));
	Fatal(vertexFunction = nil, 'vertex shader not found.');

	// Load the fragment function from the library
	fragmentFunction := defaultLibrary.newFunctionWithName(NSSTR('fragmentShader'));
	Fatal(fragmentFunction = nil, 'fragment shader not found.');

	pipelineStateDescriptor := MTLRenderPipelineDescriptor.alloc.init;
	pipelineStateDescriptor.setLabel(NSSTR('Simple Pipeline'));
	pipelineStateDescriptor.setVertexFunction(vertexFunction);
	pipelineStateDescriptor.setFragmentFunction(fragmentFunction);

	attachment := pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0);
	attachment.setPixelFormat(control.renderView.colorPixelFormat);

	pipelineState := device.newRenderPipelineStateWithDescriptor_error(pipelineStateDescriptor, @error);
	Fatal(pipelineState = nil, 'pipeline creation failed.', error);

	commandQueue := device.newCommandQueue;

	pipelineStateDescriptor.release;
	vertexFunction.release;
	fragmentFunction.release;
	defaultLibrary.release;
end;

procedure THelloTriangle.Paint;
const
	kSize = 100;
var
	verticies: array[0..2] of TAAPLVertex;
	commandBuffer: MTLCommandBufferProtocol;
	renderPassDescriptor: MTLRenderPassDescriptor;
	renderEncoder: MTLRenderCommandEncoderProtocol;
begin
	verticies[0] := AAPLVertex(V2(kSize, -kSize), V4(1, 0, 0, 1));
	verticies[1] := AAPLVertex(V2(-kSize, -kSize), V4(0, 1, 0, 1 ));
	verticies[2] := AAPLVertex(V2(0, kSize), V4(0, 0, 1, 1));

	commandBuffer := commandQueue.commandBuffer;

	renderPassDescriptor := control.renderView.currentRenderPassDescriptor;
	if renderPassDescriptor <> nil then
		begin
			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

			renderEncoder.setViewport(control.viewport);
			renderEncoder.setRenderPipelineState(pipelineState);

			renderEncoder.setVertexBytes_length_atIndex(@verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
			renderEncoder.setVertexBytes_length_atIndex(@control.viewportSize, sizeof(vector_float2), AAPLVertexInputIndexViewportSize);
			renderEncoder.drawPrimitives_vertexStart_vertexCount(MTLPrimitiveTypeTriangle, 0, 3);

			renderEncoder.endEncoding;
			commandBuffer.presentDrawable(control.renderView.currentDrawable);
		end;

	commandBuffer.commit;
end;

destructor THelloTriangle.Destroy;
begin
	writeln('THelloTriangle.Destroy');

	pipelineState.release;
	commandQueue.release;

	inherited;
end;

{=============================================}
{@! ___FORM___ } 
{=============================================}

procedure TMetalForm.FormResize(Sender: TObject);
begin
  ExitButton1.SetBounds(Width-90, 5, 80, 25);

  metalControl.SetBounds(0, 0, Width - 100, Height);
end;

procedure TMetalForm.ExitButton1Click(Sender: TObject);
begin
	writeln('exit');
  Close;
end;

constructor TMetalForm.Create(TheOwner: TComponent);
begin
	inherited CreateNew(TheOwner);


  {$ifndef LCLCocoa}
  writeln('must  be cocoa!');
  halt;
  {$endif}


  // TODO: leaking!
	metalControl := TMetalControl.Create(self);
  metalControl.Parent := self;
  metalControl.SetBounds(0, 0, 250, 250);
  metalControl.Anchors := [akLeft,akTop];
  metalControl.LoadMetal;

  drawingDelegate := THelloTriangle.Create(metalControl);
  metalControl.delegate := drawingDelegate;

	OnResize:=@FormResize;

	ExitButton1:=TButton.Create(Self);
	with ExitButton1 do begin
	  Name:='ExitButton1';
	  Parent:=Self;
	  SetBounds(320,10,80,25);
	  Caption:='Exit';
	  OnClick:=@ExitButton1Click;
	end;
end;

destructor TMetalForm.Destroy;
begin
	writeln('TMetalForm.Destroy');
	FreeAndNil(drawingDelegate);

	inherited Destroy;
end;

end.

