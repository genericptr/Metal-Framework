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
	float3 normal;
	float depth;
	float3 toLight;
	float3 toCamera;
};

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
	float4x4 invertedModelMatrix;
	float4 lightPos;
};

struct WorldUniforms {
	float shineDamper;
	float reflectivity;
	float3 lightColor;
};

struct GBufferData
{
	float4 color [[color(1), raster_order_group(0)]];
	float4 depth [[color(2), raster_order_group(0)]];
};

vertex VertexOut vertexShader(  unsigned int vertexID               		[[ vertex_id ]],
                                const device MeshVertex*   verticies    [[ buffer(0) ]],
																const device Uniforms* uniforms    			[[ buffer(1) ]]
                                ) 
{
	
	float4x4 modelMatrix = uniforms->modelMatrix;
	float4x4 projectionMatrix = uniforms->projectionMatrix;
	
	float4 position = float4(verticies[vertexID].position, 1);
	float4 normal = float4(verticies[vertexID].normal, 0);

	float4 worldPosition = modelMatrix * position;

	VertexOut vertexOut;
	vertexOut.position = projectionMatrix * worldPosition;
	vertexOut.normal = normalize((modelMatrix * normal).xyz);
	vertexOut.toLight = normalize(uniforms->lightPos.xyz - worldPosition.xyz);
	vertexOut.toCamera = normalize((uniforms->invertedModelMatrix * float4(0, 0, 0, 1)).xyz - worldPosition.xyz);
	vertexOut.depth = position.z;

	return vertexOut;
}

fragment GBufferData fragmentShader(	VertexOut vertexOut 													[[ stage_in ]],
																			const device WorldUniforms* worldUniforms    	[[ buffer(0) ]]
																		)
{
    float brightness = dot(vertexOut.toLight, vertexOut.normal);
    brightness = max(brightness, 0.0);
    float3 diffuse = worldUniforms->lightColor.xyz * brightness;

    float3 lightDirection = -vertexOut.toLight;
    float3 reflectedDirection = reflect(lightDirection, vertexOut.normal);
    float specular = dot(reflectedDirection, vertexOut.toCamera);
    specular = max(specular, 0.0);
    float damper = pow(specular, worldUniforms->shineDamper);
    float3 specularColor = damper * worldUniforms->reflectivity * worldUniforms->lightColor.xyz;

    GBufferData bufferData;

    bufferData.color = float4(diffuse, 1) * float4(0.3, 0.8, 0.2, 1) + float4(specularColor, 1);	
    bufferData.depth = float4(vertexOut.depth, vertexOut.depth, vertexOut.depth, 1);

    return bufferData;
}
