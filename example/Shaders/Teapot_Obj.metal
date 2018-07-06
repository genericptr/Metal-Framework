#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
    // float4x4 modelViewMatrix;
    // float3x3 normalMatrix;
};

struct Vertex
{
    float4 position;
    float4 normal;
};

struct ProjectedVertex
{
    float4 position [[position]];
    // float3 eye;
    // float3 normal;
    float3 color;
};

vertex ProjectedVertex vertexShader(device Vertex *vertices [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid [[vertex_id]])
{
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * vertices[vid].position;
//    outVert.eye =  -(uniforms.modelViewMatrix * vertices[vid].position).xyz;
//    outVert.normal = uniforms.normalMatrix * vertices[vid].normal.xyz;
    outVert.color = float3(outVert.position.z, outVert.position.z, outVert.position.z) * 0.3;
    
    return outVert;
}

fragment float4 fragmentShader(ProjectedVertex vert [[stage_in]],
                               constant Uniforms &uniforms [[buffer(0)]])
{
//    float3 ambientTerm = light.ambientColor * material.ambientColor;
//
//    float3 normal = normalize(vert.normal);
//    float diffuseIntensity = saturate(dot(normal, light.direction));
//    float3 diffuseTerm = light.diffuseColor * material.diffuseColor * diffuseIntensity;
//
//    float3 specularTerm(0);
//    if (diffuseIntensity > 0)
//    {
//        float3 eyeDirection = normalize(vert.eye);
//        float3 halfway = normalize(light.direction + eyeDirection);
//        float specularFactor = pow(saturate(dot(normal, halfway)), material.specularPower);
//        specularTerm = light.specularColor * material.specularColor * specularFactor;
//    }
//
//    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
    
    return float4(vert.color, 1);
}
