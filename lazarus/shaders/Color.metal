/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used for this sample
*/

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
// NOTE: compiling from source at runtime doesn't resolve this path correctly
// using shared headers for Pascal is not useful anyways so we should also ignore these
// #import "ColorTypes.h"

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices     = 0,
    AAPLVertexInputIndexViewportSize = 1,
} AAPLVertexInputIndex;

//  This structure defines the layout of each vertex in the array of vertices set as an input to our
//    Metal vertex shader.  Since this header is shared between our .metal shader and C code,
//    we can be sure that the layout of the vertex array in our C code matches the layout that
//    our .metal vertex shader expects
typedef struct
{
    // Positions in pixel space
    // (e.g. a value of 100 indicates 100 pixels from the center)
    vector_float2 position;

    // Floating-point RGBA colors
    vector_float4 color;
} AAPLVertex;

// Vertex shader outputs and fragment shader inputs
typedef struct
{
    // The [[position]] attribute of this member indicates that this value is the clip space
    // position of the vertex when this structure is returned from the vertex function
    float4 clipSpacePosition [[position]];

    // Since this member does not have a special attribute, the rasterizer interpolates
    // its value with the values of the other triangle vertices and then passes
    // the interpolated value to the fragment shader for each fragment in the triangle
    float4 color;

} RasterizerData;

// Vertex function
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant AAPLVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(AAPLVertexInputIndexViewportSize)]])
{
    RasterizerData out;

    // Initialize our output clip space position
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);

    // Index into our array of positions to get the current vertex
    //   Our positions are specified in pixel dimensions (i.e. a value of 100 is 100 pixels from
    //   the origin)
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // Dereference viewportSizePointer and cast to float so we can do floating-point division
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);

    // The output position of every vertex shader is in clip-space (also known as normalized device
    //   coordinate space, or NDC).   A value of (-1.0, -1.0) in clip-space represents the
    //   lower-left corner of the viewport whereas (1.0, 1.0) represents the upper-right corner of
    //   the viewport.

    // Calculate and write x and y values to our clip-space position.  In order to convert from
    //   positions in pixel space to positions in clip-space, we divide the pixel coordinates by
    //   half the size of the viewport.
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);

    // Pass our input color straight to our output color.  This value will be interpolated
    //   with the other color values of the vertices that make up the triangle to produce
    //   the color value for each fragment in our fragment shader
    out.color = vertices[vertexID].color;

    return out;
}

// Fragment function
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // We return the color we just set which will be written to our color attachment.
    return in.color;
}

