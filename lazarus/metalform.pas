unit MetalForm;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$interfaces CORBA}

interface

uses
	MetalControl, SIMDTypes,
  Metal, MetalKit, CocoaAll, MacOSAll,
  Classes, SysUtils, FileUtil, Forms, StdCtrls, Controls, Graphics, Dialogs;

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
{@! ___DRAWING DELEGATE___ } 
{=============================================}
const
	AAPLVertexInputIndexVertices     = 0;
	AAPLVertexInputIndexViewportSize = 1;

type
	TAAPLVertex = record
		position: vector_float2;
		// align each vertex attribute on 16 byte boundries
		padding: array[0..1] of simd_float;
		color: vector_float4;
	end;

function AAPLVertex(constref position: vector_float2; constref color: vector_float4): TAAPLVertex;
begin
	result.position := position;
	result.color := color;
end;

function NSSTR(str: string): NSString; overload;
begin
	result := NSString.stringWithCString_length(@str[1], length(str));
end;

function CompileShader (device: MTLDeviceProtocol; name: string): MTLLibraryProtocol;
var
	options: MTLCompileOptions;
	source: NSString;
	error: NSError;
begin
	source := NSString.stringWithContentsOfFile_encoding_error(NSSTR(name), NSUTF8StringEncoding, @error);
	Fatal(source = nil, 'error loading library file', error);

	result := device.newLibraryWithSource_options_error(source, nil, @error);
	Fatal(result = nil, 'error compiling library: ', error);
end;

{$macros on}
{$define MANUAL_COMPILE}

constructor THelloTriangle.Create (inControl: TMetalControl);
var
	shaderLibrary: MTLLibraryProtocol;
	vertexFunction: MTLFunctionProtocol;
	fragmentFunction: MTLFunctionProtocol;
	error: NSError;
	url: NSURL;
	attachment: MTLRenderPipelineColorAttachmentDescriptor;
	pipelineStateDescriptor: MTLRenderPipelineDescriptor;
	imageData: pointer;
	device: MTLDeviceProtocol;
	cwd: string;
begin
	control := inControl;
	Fatal(control.renderView = nil, 'metal control has no render target.');

	device := control.renderView.device;
	Fatal(device = nil, 'no device found in render view.');

	Show(device, 'GPU:');

	{$ifdef MANUAL_COMPILE}
	shaderLibrary := CompileShader(device, 'shaders/Color.metal');
	Show(shaderLibrary);
	{$else}
	url := NSBundle.mainBundle.URLForResource_withExtension(NSSTR('Color'), NSSTR('metallib'));
	shaderLibrary := device.newLibraryWithURL_error(url, @error);
	Fatal(shaderLibrary = nil, 'no .metallib files were found.', error);
	Show(shaderLibrary);
	{$endif}

	// Load the vertex function from the library
	vertexFunction := shaderLibrary.newFunctionWithName(NSSTR('vertexShader'));
	Fatal(vertexFunction = nil, 'vertex shader not found.');

	// Load the fragment function from the library
	fragmentFunction := shaderLibrary.newFunctionWithName(NSSTR('fragmentShader'));
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
	shaderLibrary.release;
end;

procedure THelloTriangle.Paint;
const
	kSize = 100;
var
	verticies: array[0..2] of TAAPLVertex;
	commandBuffer: MTLCommandBufferProtocol;
	renderPassDescriptor: MTLRenderPassDescriptor;
	renderEncoder: MTLRenderCommandEncoderProtocol;
	viewportSize: vector_uint2;
begin
	verticies[0] := AAPLVertex(V2(kSize, -kSize), V4(1, 0, 0, 1));
	verticies[1] := AAPLVertex(V2(-kSize, -kSize), V4(0, 1, 0, 1 ));
	verticies[2] := AAPLVertex(V2(0, kSize), V4(0, 0, 1, 1));

	viewportSize.x := control.Width;
	viewportSize.y := control.Height;

	commandBuffer := commandQueue.commandBuffer;

	renderPassDescriptor := control.renderView.currentRenderPassDescriptor;
	if renderPassDescriptor <> nil then
		begin
			renderEncoder := commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

			renderEncoder.setViewport(control.viewport);
			renderEncoder.setRenderPipelineState(pipelineState);

			renderEncoder.setVertexBytes_length_atIndex(@verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
			renderEncoder.setVertexBytes_length_atIndex(@viewportSize, sizeof(vector_float2), AAPLVertexInputIndexViewportSize);
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
  FreeAndNil(metalControl);

	inherited Destroy;
end;

end.

