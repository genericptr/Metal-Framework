#include <metal_stdlib>

using namespace metal;

struct VertexOut {
	float4 position [[position]];
	float3 normal;
	float3 toLight;
	float3 toCamera;
};

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
	float4x4 invertedModelMatrix;
	float4 lightPos;
};

// vec4 worldPosition = modelTransform * vec4(in_position, 1);
// gl_Position = projTransform * viewTransform * worldPosition;
// surfaceNormal = (modelTransform * vec4(in_normal, 0)).xyz;
// toLight = lightPosition - worldPosition.xyz;
// toCamera = (inverseViewTransform * vec4(0, 0, 0, 1)).xyz - worldPosition.xyz;

vertex VertexOut vertexShader(  unsigned int vertexID               [[ vertex_id ]],
                                const device float4*   verticies    [[ buffer(0) ]],
                                const device float4*   normals    	[[ buffer(1) ]],
																const device Uniforms* uniforms    	[[ buffer(2) ]]
                                ) 
{
	
	float4x4 modelMatrix = uniforms->modelMatrix;
	float4x4 projectionMatrix = uniforms->projectionMatrix;
	
	float4 position = verticies[vertexID];
	float4 normal = normals[vertexID];

	float4 worldPosition = modelMatrix * position;

	VertexOut vertexOut;
	vertexOut.position = projectionMatrix * worldPosition;
	vertexOut.normal = normalize((modelMatrix * normal).xyz);
	vertexOut.toLight = normalize(uniforms->lightPos.xyz - worldPosition.xyz);
	vertexOut.toCamera = normalize((uniforms->invertedModelMatrix * float4(0, 0, 0, 1)).xyz - worldPosition.xyz);

	return vertexOut;
}

// float brightness = dot(normalize(toLight), normalize(surfaceNormal));
// brightness = max(brightness, 0.0);
// vec3 diffuse = lightColor * brightness;

// vec3 lightDirection = -normalize(toLight);
// vec3 reflectedDirection = reflect(lightDirection, normalize(surfaceNormal));
// float specular = dot(reflectedDirection, normalize(toCamera));
// specular = max(specular, 0.0);
// float damper = pow(specular, shineDamper);
// vec3 specularColor = damper * reflectivity * lightColor;

// gl_FragColor = vec4(diffuse, 1) * vec4(0.3, 0.8, 0.2, 1) + vec4(specularColor, 1);

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
	  float4 fragColor = float4(vertexOut.normal, 1) * 3;

    return fragColor;//float4(0.3, 0.8, 0.2, 1);
}
