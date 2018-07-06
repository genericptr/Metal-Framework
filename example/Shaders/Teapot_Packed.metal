#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

struct MeshVertex {
	float3 position;
	float3 color;
	float2 texCoord;
	float3 normal;
};

struct VertexOut {
	float4 position [[position]];
	float3 color;
};

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
	float4x4 invertedModelMatrix;
	float4 lightPos;
};

vertex VertexOut vertexShader(  unsigned int vertexID               [[ vertex_id ]],
                                device MeshVertex* verticies    		[[ buffer(0) ]],
																constant Uniforms* uniforms    			[[ buffer(1) ]]
                                ) 
{
	
	float4x4 modelMatrix = uniforms->modelMatrix;
	float4x4 projectionMatrix = uniforms->projectionMatrix;
	
	float4 position = float4(verticies[vertexID].position, 1);
	// float4 normal = verticies[vertexID].normal;

	VertexOut vertexOut;
	vertexOut.position = projectionMatrix * modelMatrix * position;

	float3 depth = vertexOut.position.xyz;
	vertexOut.color = float3(depth.z, depth.z, depth.z) * 0.2;

	return vertexOut;
}

fragment float4 fragmentShader(	VertexOut vertexOut 				[[stage_in]],
																constant Uniforms* uniforms [[ buffer(1) ]]

	)
{

	  float4 fragColor = float4(vertexOut.color, 1);

    return fragColor;
}
