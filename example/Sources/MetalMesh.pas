{$mode objfpc}
{$modeswitch objectivec1}

unit MetalMesh;
interface
uses
	Metal, MeshLoader, MetalTypes, SysUtils;

type
	TMetalMesh = class (TMesh)
		public
			vertexBuffer: MTLBufferProtocol;
			indexBuffer: MTLBufferProtocol;
			function GetVertexDescriptor: MTLVertexDescriptor;
			destructor Destroy; override;
	end;

implementation

function TMetalMesh.GetVertexDescriptor: MTLVertexDescriptor;
var
	descriptor: MTLVertexDescriptor;

procedure SetAttribute (index: integer; format: MTLVertexFormat; formateByteCount: integer; var offset: integer; bufferIndex: integer = 0);
var
	attribute: MTLVertexAttributeDescriptor;
begin
	attribute := descriptor.attributes.objectAtIndexedSubscript(index);
	attribute.setFormat(format);
	attribute.setOffset(offset);
	attribute.setBufferIndex(0);
	offset += formateByteCount;
end;

var
	attribute: MTLVertexAttributeDescriptor;
	layout: MTLVertexBufferLayoutDescriptor;
	offset: integer = 0;
begin
	descriptor := MTLVertexDescriptor.vertexDescriptor;

	SetAttribute(0, MTLVertexFormatFloat3, sizeof(TVec3), offset); // position
	SetAttribute(1, MTLVertexFormatFloat3, sizeof(TVec3), offset); // color
	SetAttribute(2, MTLVertexFormatFloat2, sizeof(TVec2), offset); // texCoord
	SetAttribute(3, MTLVertexFormatFloat3, sizeof(TVec3), offset); // normal

	layout := descriptor.layouts.objectAtIndexedSubscript(0);
	layout.setStride(sizeof(TMeshVertex));
	//show(descriptor);

	result := descriptor;
end;

destructor TMetalMesh.Destroy;
begin
	vertexBuffer.release;
	indexBuffer.release;

	inherited;
end;


end.