{$mode objfpc}
{$modeswitch advancedrecords}
{$modeswitch typehelpers}

unit MeshLoader;
interface
uses
	MetalTypes, SysUtils, FGL, Classes;

// NOTE: i think these offset are needed because
// we didn't set the vertex attributes MTLVertexAttribute

(*

- (MTLVertexDescriptor )newVertexDescriptor
{
    MTLVertexDescriptor *descriptor = [MTLVertexDescriptor vertexDescriptor];
    
    descriptor.attributes[0].format = MTLVertexFormatFloat4;
    descriptor.attributes[0].offset = 0;
    descriptor.attributes[0].bufferIndex = 0;

    descriptor.attributes[1].format = MTLVertexFormatFloat2;
    descriptor.attributes[1].offset = offsetof(MBEVertex, texCoords);
    descriptor.attributes[1].bufferIndex = 0;

    descriptor.layouts[0].stride = sizeof(MBEVertex);

    return descriptor;
}

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    [pipelineDescriptor reset];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = [self newVertexDescriptor];


*)

type
	TMeshVertex = record
		position: TVec3; 	//padding_0: array[0..0] of TScalar;
		color: TVec3;			//padding_1: array[0..0] of TScalar;
		texCoord: TVec2; 	//padding_2: array[0..1] of TScalar;
		normal: TVec3; 		//padding_3: array[0..0] of TScalar;
		tangent: TVec3; 	//padding_4: array[0..0] of TScalar;

		class operator = (constref left: TMeshVertex; constref right: TMeshVertex): boolean;
	end;
	TMeshVertexList = specialize TFPGList<TMeshVertex>;

type 
	TIntegerList = specialize TFPGList<integer>;
	TVec3List = specialize TFPGList<TVec3>;
	TVec2List = specialize TFPGList<TVec2>;

type
	TMesh = class
		public
			vertices: TMeshVertexList;
			indices: TIntegerList;
		public
			constructor Create;
			destructor Destroy; override;
	end;

function LoadOBJModel (path: string; normalMap: boolean = false): TMesh; 

implementation


type
	TOBJVertex = class
		private const NO_INDEX = -1;
		public
			position: TVec3;
			textureIndex: integer;
			normalIndex: integer;
			duplicateVertex: TOBJVertex;
			index: integer;
			tangents: TVec3List;
			averagedTangent: TVec3;
		public
			constructor Create (_index: integer; _position: TVec3);
			function IsSet: boolean;
			function HasSameTextureAndNormal (textureIndexOther, normalIndexOther: integer): boolean; 
			function Duplicate (newIndex: integer): TOBJVertex;
			procedure AddTangent (tangent: TVec3);
			procedure AverageTangents;
			destructor Destroy; override;
	end;
	TOBJVertexList = specialize TFPGObjectList<TOBJVertex>;

constructor TMesh.Create;
begin
	vertices := TMeshVertexList.Create;
	indices := TIntegerList.Create;
end;

destructor TMesh.Destroy;
begin
	vertices.Free;
	indices.Free;

	inherited;
end;


class operator TMeshVertex.= (constref left: TMeshVertex; constref right: TMeshVertex): boolean;
begin
	result := false;
end;

procedure TOBJVertex.AddTangent (tangent: TVec3);
begin
	tangents.Add(tangent);
end;

function TOBJVertex.Duplicate (newIndex: integer): TOBJVertex; 
begin
	result := TOBJVertex.Create(newIndex, position);
	result.tangents := tangents;
end;	
 
procedure TOBJVertex.AverageTangents;
var
	tangent: TVec3;
	i: integer;
begin
	if tangents.Count = 0 then
		exit;
	averagedTangent := Vec3(0, 0, 0);
	for i := 0 to tangents.Count - 1 do
		averagedTangent += tangents[i];
	averagedTangent := averagedTangent.Normalize;
end;
	
constructor TOBJVertex.Create (_index: integer; _position: TVec3);
begin
	index := _index;
	position := _position;
	textureIndex := NO_INDEX;
	normalIndex := NO_INDEX;
	duplicateVertex := nil;
	tangents := TVec3List.Create;
	averagedTangent := Vec3(0, 0, 0);
end;

destructor TOBJVertex.Destroy;
begin
	tangents.Free;
	inherited;
end;

function TOBJVertex.IsSet: boolean;
begin
	result := (textureIndex <> NO_INDEX) or (normalIndex <> NO_INDEX);
end;

function TOBJVertex.HasSameTextureAndNormal (textureIndexOther, normalIndexOther: integer): boolean; 
begin
	result := (textureIndexOther = textureIndex) and (normalIndexOther = normalIndex);
end;

function LoadOBJModel (path: string; normalMap: boolean = false): TMesh; 

function DealWithAlreadyProcessedVertex (previousVertex: TOBJVertex; newTextureIndex, newNormalIndex: integer; indices: TIntegerList; vertices: TOBJVertexList): TOBJVertex;
var
	duplicateVertex: TOBJVertex;
	anotherVertex: TOBJVertex;
begin
	if previousVertex.HasSameTextureAndNormal(newTextureIndex, newNormalIndex) then
		begin
			indices.Add(previousVertex.index);
			result := previousVertex;
		end
	else
		begin
			anotherVertex := previousVertex.duplicateVertex;
			if anotherVertex <> nil then
				result := DealWithAlreadyProcessedVertex(anotherVertex, newTextureIndex, newNormalIndex, indices, vertices)
			else
				begin
					duplicateVertex := TOBJVertex.Create(vertices.Count, previousVertex.position);
          duplicateVertex.textureIndex := newTextureIndex;
          duplicateVertex.normalIndex := newNormalIndex;
          previousVertex.duplicateVertex := duplicateVertex;
          vertices.Add(duplicateVertex);
          indices.Add(duplicateVertex.index);
					//duplicateVertex.Free;
					result := duplicateVertex;
				end;
		end;
end;

procedure CalculateTangents (var v0, v1, v2: TOBJVertex; textures: TVec2List); 
var
	delatPos1, delatPos2: TVec3;
	uv0, uv1, uv2: TVec2;
	deltaUv1, deltaUv2: TVec2;
	r: TScalar;
	tangent: TVec3;
begin
	delatPos1 := v1.position - v0.position;
	delatPos2 := v2.position - v0.position;
	uv0 := textures[v0.textureIndex];
  uv1 := textures[v1.textureIndex];
  uv2 := textures[v2.textureIndex];
  deltaUv1 := uv1 - uv0;
  deltaUv2 := uv2 - uv0;
	
	r := 1.0 / (deltaUv1.x * deltaUv2.y - deltaUv1.y * deltaUv2.x);
	delatPos1 *= deltaUv2.y;
	delatPos2 *= deltaUv1.y;
	tangent := (delatPos1 - delatPos2) * r;

	v0.AddTangent(tangent);
	v1.AddTangent(tangent);
	v2.AddTangent(tangent);
end;

function ProcessFace (vertices: TOBJVertexList; indices: TIntegerList; face: TStringList): TOBJVertex;
var
	index: integer;
	textureIndex: integer;
	normalIndex: integer;
	currentVertex: TOBJVertex;
begin
	index := StrToInt(face[0]) - 1;
	currentVertex := vertices[index];
	textureIndex := StrToInt(face[1]) - 1;
	normalIndex := StrToInt(face[2]) - 1;
	if not currentVertex.IsSet then
		begin
			currentVertex.textureIndex := textureIndex;
			currentVertex.normalIndex := normalIndex;
			indices.Add(index);
			result := currentVertex;
		end
	else
		result := DealWithAlreadyProcessedVertex(currentVertex, textureIndex, normalIndex, indices, vertices);
end;

// TODO: dynamic array??
function Split (str: string; delimiter: char): TStringList;
var
	i: integer;
	c: char;
	part: string = '';
	parts: TStringList;
begin
	parts := TStringList.Create; 
	for i := 1 to Length(str) do
		begin
			c := str[i];
			if (c = delimiter) or (i = Length(str)) then
				begin
					if (i = Length(str)) then
						part += c;
					parts.Add(part);
					part := '';
				end
			else
				part += c;
		end;
	result := parts;
end;

function HasPrefix (str: string; prefix: string): boolean;
var
	i: integer;
begin
	if length(str) < length(prefix) then
		exit(false);
	result := true;
	for i := 1 to Length(prefix) do
	if str[i] <> prefix[i] then
		exit(false);
end;

var
	lines: TStringList;
	line: string;
	
	vertices: TOBJVertexList;
	textures: TVec2List;
	normals: TVec3List;
	indices: TIntegerList;
	
	parts: TStringList;
	face: TStringList;
	objVertex: TOBJVertex;
	meshVertex: TMeshVertex;
	
	pos: TVec3;
	i: integer;
	mesh: TMesh;
	name, directory: string;
	v0, v1, v2: TOBJVertex;
begin	

	mesh := TMesh.Create;
	vertices := TOBJVertexList.Create;
	textures := TVec2List.Create;
	normals := TVec3List.Create;
	indices := TIntegerList.Create;
	
	lines := TStringList.Create;
  lines.LoadFromFile(path);
	
	// process vertex data
	for line in lines do
		begin
			parts := Split(line, ' ');
			if HasPrefix(line, 'v ') then
				begin
					objVertex := TOBJVertex.Create(vertices.Count, Vec3(StrToFloat(parts[1]), StrToFloat(parts[2]), StrToFloat(parts[3])));
					vertices.Add(objVertex);
				end
			else if HasPrefix(line, 'vt ') then
				// flip y-coord
				textures.Add(Vec2(StrToFloat(parts[1]), 1-StrToFloat(parts[2])))
			else if HasPrefix(line, 'vn ') then
				normals.Add(Vec3(StrToFloat(parts[1]), StrToFloat(parts[2]), StrToFloat(parts[3])))
			else if HasPrefix(line, 'f ') then
				begin
					// TODO: start from this location instead of finding it again in the next loop
          break;
				end;
		end;

	// process faces
	for line in lines do
		if HasPrefix(line, 'f ') then
			begin
				parts := Split(line, ' '); 
				v0 := ProcessFace(vertices, indices, Split(parts[1], '/'));
				v1 := ProcessFace(vertices, indices, Split(parts[2], '/'));
				v2 := ProcessFace(vertices, indices, Split(parts[3], '/'));
				if normalMap then
					CalculateTangents(v0, v1, v2, textures);
			end;
	
	// remove unused vertices
	for objVertex in vertices do
		begin
			if normalMap then
				objVertex.AverageTangents;
			if not objVertex.IsSet then
				begin
					objVertex.textureIndex := TOBJVertex.NO_INDEX;
					objVertex.normalIndex := TOBJVertex.NO_INDEX;
				end;
		end;
	
	for objVertex in vertices do
	if objVertex.IsSet then
		begin
			meshVertex := Default(TMeshVertex);
			meshVertex.position := objVertex.position;
			if textures.Count > 0 then
				meshVertex.texCoord := textures[objVertex.textureIndex];
			if normals.Count > 0 then
				meshVertex.normal := normals[objVertex.normalIndex];
			meshVertex.tangent := objVertex.averagedTangent;
			mesh.vertices.Add(meshVertex);	
			
			//if normalMap then
			//	mesh.AddVertexAttribute(meshVertex.tan);
		end;
	
	for i in indices do
		mesh.indices.Add(i);
			
	// cleanup
	vertices.Free;
	textures.Free;
	normals.Free;
	indices.Free;
	lines.Free;
	
	result := mesh;
end;

end.