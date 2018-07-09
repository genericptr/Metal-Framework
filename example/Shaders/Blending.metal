#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

struct TexVertex {
    float2 position;
    float2 texCoord;
};

struct ProjectedVertex {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex ProjectedVertex vertexShader(unsigned int vertexID         [[ vertex_id ]],
                                    constant TexVertex* verticies   [[ buffer(0) ]],
                                    constant Uniforms* uniforms   [[ buffer(1) ]]
                                ) 
{
    
    float4x4 modelMatrix = uniforms->modelMatrix;
    float4x4 projectionMatrix = uniforms->projectionMatrix;
    
    ProjectedVertex out;
    out.position = projectionMatrix * modelMatrix * float4(verticies[vertexID].position, 0, 1);
    out.texCoord = verticies[vertexID].texCoord;

    return out;
}

fragment float4 fragmentShader( ProjectedVertex in              [[ stage_in ]],
                                texture2d<half> colorTexture    [[ texture(0) ]]
                                )               
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    const half4 colorSample = colorTexture.sample(textureSampler, in.texCoord);

   return float4(colorSample);
}
