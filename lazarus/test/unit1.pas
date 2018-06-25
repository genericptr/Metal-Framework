unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, 
  MetalPipeline, MetalUtils, MetalControl, Metal;

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
  SIMDTypes, Math;

const
  AAPLVertexInputIndexVertices     = 0;
  AAPLVertexInputIndexViewportSize = 1;

type
  TAAPLVertex = record
    position: vector_float2;
    // NOTE: why doesn't {$align 16} on 
    // align each vertex attribute on 16 byte boundries
    padding: array[0..1] of simd_float; 
    color: vector_float4;
  end;

function AAPLVertex(constref position: vector_float2; constref color: vector_float4): TAAPLVertex;
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
  writeln('viewport resized');
end;

procedure TForm1.SetupMetal(Sender: TObject);
var
  options: TMetalPipelineOptions;
begin
  options := TMetalPipelineOptions.Default;
  options.shaderName := ResourcePath('Color', 'metal');

  writeln('setup metal: ', options.shaderName);
  pipeline := MTLCreatePipeline(MetalControl1, @options);
end;

procedure TForm1.Draw(Sender: TObject);
var
  verticies: array[0..2] of TAAPLVertex;
  viewportSize: vector_uint2;
  size: single;
begin
  size := 100;

  verticies[0] := AAPLVertex(V2(size, -size), V4(1, 0, 0, 1));
  verticies[1] := AAPLVertex(V2(-size, -size), V4(0, 1, 0, 1));
  verticies[2] := AAPLVertex(V2(0, size), V4(0, 0, 1, 1));

  viewportSize.x := MetalControl1.Width;
  viewportSize.y := MetalControl1.Height;

  MTLBeginFrame(pipeline);
    MTLSetViewport(MetalControl1.viewport);
    MTLSetVertexBytes(@verticies, sizeof(verticies), AAPLVertexInputIndexVertices);
    MTLSetVertexBytes(@viewportSize, sizeof(viewportSize), AAPLVertexInputIndexViewportSize);
    MTLDraw(MTLPrimitiveTypeTriangle, 0, 3);
  MTLEndFrame;

end;

end.

