unit Unit1;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, 
  VectorMath, MetalPipeline, MetalUtils, MetalControl, Metal;

type

  { TForm1 }

  TForm1 = class(TForm)
  published
    MetalControl1: TMetalControl;
    procedure Draw(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ResizeViewPort(Sender: TObject);
    procedure SetupMetal(Sender: TObject);
  private
    pipeline: TMetalPipeline;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  CTypes, Math;

const
  AAPLVertexInputIndexVertices     = 0;
  AAPLVertexInputIndexViewportSize = 1;

type
  TAAPLVertex = record
    position: TVec2;
    // align each vertex attribute on 16 byte boundries
    padding: array[0..1] of TScalar; 
    color: TVec4;
  end;

function AAPLVertex(constref position: TVec2; constref color: TVec4): TAAPLVertex;
begin
  result.position := position;
  result.color := color;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.ResizeViewPort(Sender: TObject);
begin
  // NOTE: not tested
end;

procedure TForm1.SetupMetal(Sender: TObject);
var
  options: TMetalPipelineOptions;
begin
  options := TMetalPipelineOptions.Default;
  options.shaderName := ResourcePath('Color', 'metal');
  pipeline := MTLCreatePipeline(MetalControl1, @options);
end;

procedure TForm1.Draw(Sender: TObject);
var
  verticies: array[0..2] of TAAPLVertex;
  viewportSize: array[0..1] of cuint;
  size: single;
  clearColor: MTLClearColor;
  colorAttachment: MTLRenderPassColorAttachmentDescriptor;
begin
  size := 100;

  verticies[0] := AAPLVertex(V2(size, -size), V4(1, 0, 0, 1));
  verticies[1] := AAPLVertex(V2(-size, -size), V4(0, 1, 0, 1));
  verticies[2] := AAPLVertex(V2(0, size), V4(0, 0, 1, 1));

  viewportSize[0] := MetalControl1.Width;
  viewportSize[1] := MetalControl1.Height;

  MTLBeginFrame(pipeline);

    // TMetalPipeline.renderPassDescriptor can only be accessed directly after MTLBeginFrame
    // and will be unlinked after subsequent calls to MTLSetXXX

    // access the color attachment directly or use MTLSetClearColor
    {
    colorAttachment := pipeline.renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0);
    clearColor.red := 0.7;
    clearColor.green := 0.7;
    clearColor.blue:= 0.9;
    clearColor.alpha := 1;
    colorAttachment.setClearColor(clearColor);
    }

    MTLSetClearColor(0.7, 0.7, 0.9, 1);

    MTLSetViewport(MetalControl1.viewport);
    MTLSetVertexBytes(@verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
    MTLSetVertexBytes(@viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);
    MTLDraw(MTLPrimitiveTypeTriangle, 0, 3);
  MTLEndFrame;
end;

end.

