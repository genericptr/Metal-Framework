#include <metal_stdlib>

using namespace metal;

struct VertexIn {
	float3 position;
	float3 normal;
	float4 color;
};

struct VertexOut {
	float4 position [[position]];
	float4 normal;
	float4 color;
};

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
};


vertex VertexOut vertexShader(  unsigned int vertexID               [[ vertex_id ]],
                                const device VertexIn* verticies    [[ buffer(0) ]],
																const device Uniforms* uniforms    	[[ buffer(1) ]]
                                ) 
{
	
	float4x4 modelMatrix = uniforms->modelMatrix;
	float4x4 projectionMatrix = uniforms->projectionMatrix;
	
	VertexIn VertexIn = verticies[vertexID];
	
	VertexOut VertexOut;
	VertexOut.position = projectionMatrix * modelMatrix * float4(VertexIn.position, 1);
	VertexOut.color = VertexIn.color;
	
	return VertexOut;
}

fragment float4 fragmentShader(VertexIn in [[stage_in]])
{
    return in.color;
}
