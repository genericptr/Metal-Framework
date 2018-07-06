#include <metal_stdlib>

using namespace metal;

struct MeshVertex {
	float3 position;
	float3 color;
	float2 texCoord;
	float3 normal;
	// float3 tangent;
};

struct VertexOut {
	float4 position [[position]];
	float3 normal;
	float3 color;
	float3 toLight;
	float3 toCamera;
};

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
	float4x4 invertedModelMatrix;
	float4 lightPos;
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
	vertexOut.color = float3(position.z, position.z, position.z);

	return vertexOut;
}

fragment float4 fragmentShader(VertexOut vertexOut [[stage_in]])
{

		// TODO: these should be frag uniforms
		const float shineDamper = 3;
		const float reflectivity = 1;
		const float3 lightColor = float3(1, 1, 1);

    float brightness = dot(vertexOut.toLight, vertexOut.normal);
    brightness = max(brightness, 0.0);
    float3 diffuse = lightColor * brightness;

    float3 lightDirection = -vertexOut.toLight;
    float3 reflectedDirection = reflect(lightDirection, vertexOut.normal);
    float specular = dot(reflectedDirection, vertexOut.toCamera);
    specular = max(specular, 0.0);
    float damper = pow(specular, shineDamper);
    float3 specularColor = damper * reflectivity * lightColor;

	  // float4 fragColor = float4(diffuse, 1) * float4(0.3, 0.8, 0.2, 1) + float4(specularColor, 1);
	  // float4 fragColor = float4(vertexOut.normal, 1) * 3;
	  float4 fragColor = float4(vertexOut.color, 1);

    return fragColor;
}
