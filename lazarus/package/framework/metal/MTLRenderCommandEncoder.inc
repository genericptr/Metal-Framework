{ Parsed from Metal.framework MTLRenderCommandEncoder.h }

{$ifdef TYPES}
type
  MTLRenderCommandEncoderProtocolPtr = ^MTLRenderCommandEncoderProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLPrimitiveType = NSUInteger;
  MTLPrimitiveTypePtr = ^MTLPrimitiveType;

const
  MTLPrimitiveTypePoint = 0;
  MTLPrimitiveTypeLine = 1;
  MTLPrimitiveTypeLineStrip = 2;
  MTLPrimitiveTypeTriangle = 3;
  MTLPrimitiveTypeTriangleStrip = 4;

type
  MTLVisibilityResultMode = NSUInteger;
  MTLVisibilityResultModePtr = ^MTLVisibilityResultMode;

const
  MTLVisibilityResultModeDisabled = 0;
  MTLVisibilityResultModeBoolean = 1;
  MTLVisibilityResultModeCounting = 2 { available in 10_11, 9_0 };

type
  MTLScissorRect = record
    x, y, width, height: NSUInteger;
  end;
type
  MTLScissorRectPtr = ^MTLScissorRect;
type
  MTLViewport = record
    originX, originY, width, height, znear, zfar: double;
  end;
type
  MTLViewportPtr = ^MTLViewport;

type
  MTLCullMode = NSUInteger;
  MTLCullModePtr = ^MTLCullMode;

const
  MTLCullModeNone = 0;
  MTLCullModeFront = 1;
  MTLCullModeBack = 2;

type
  MTLWinding = NSUInteger;
  MTLWindingPtr = ^MTLWinding;

const
  MTLWindingClockwise = 0;
  MTLWindingCounterClockwise = 1;

type
  MTLDepthClipMode = NSUInteger;
  MTLDepthClipModePtr = ^MTLDepthClipMode;

const
  MTLDepthClipModeClip = 0;
  MTLDepthClipModeClamp = 1;

type
  MTLTriangleFillMode = NSUInteger;
  MTLTriangleFillModePtr = ^MTLTriangleFillMode;

const
  MTLTriangleFillModeFill = 0;
  MTLTriangleFillModeLines = 1;

type
  MTLDrawPrimitivesIndirectArguments = record
    vertexCount: cuint32;
    instanceCount: cuint32;
    vertexStart: cuint32;
    baseInstance: cuint32;
  end;
type
  MTLDrawPrimitivesIndirectArgumentsPtr = ^MTLDrawPrimitivesIndirectArguments;
type
  MTLDrawIndexedPrimitivesIndirectArguments = record
    indexCount: cuint32;
    instanceCount: cuint32;
    indexStart: cuint32;
    baseVertex: cint32;
    baseInstance: cuint32;
  end;
type
  MTLDrawIndexedPrimitivesIndirectArgumentsPtr = ^MTLDrawIndexedPrimitivesIndirectArguments;
type
  MTLDrawPatchIndirectArguments = record
    patchCount: cuint32;
    instanceCount: cuint32;
    patchStart: cuint32;
    baseInstance: cuint32;
  end;
type
  MTLDrawPatchIndirectArgumentsPtr = ^MTLDrawPatchIndirectArguments;
type
  MTLQuadTessellationFactorsHalf = record
    edgeTessellationFactor:array[0..3] of cuint16;
    insideTessellationFactor:array[0..1] of cuint16;
  end;
type
  MTLQuadTessellationFactorsHalfPtr = ^MTLQuadTessellationFactorsHalf;
type
  MTLTriangleTessellationFactorsHalf = record
    edgeTessellationFactor:array[0..2] of cuint16;
    insideTessellationFactor: cuint16;
  end;
type
  MTLTriangleTessellationFactorsHalfPtr = ^MTLTriangleTessellationFactorsHalf;

type
  MTLRenderStages = NSUInteger;
  MTLRenderStagesPtr = ^MTLRenderStages;

const
  MTLRenderStageVertex = 1 shl 0;
  MTLRenderStageFragment = 1 shl 1;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLRenderCommandEncoderProtocol = objcprotocol external name 'MTLRenderCommandEncoder' (MTLCommandEncoderProtocol)
    procedure setRenderPipelineState (pipelineState: MTLRenderPipelineStateProtocol); message 'setRenderPipelineState:';
    procedure setVertexBytes_length_atIndex (bytes: pointer; length: NSUInteger; index: NSUInteger); message 'setVertexBytes:length:atIndex:'; { available in 10_11, 8_3 }
    procedure setVertexBuffer_offset_atIndex (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); message 'setVertexBuffer:offset:atIndex:';
    procedure setVertexBufferOffset_atIndex (offset: NSUInteger; index: NSUInteger); message 'setVertexBufferOffset:atIndex:'; { available in 10_11, 8_3 }
    procedure setVertexBuffers_offsets_withRange (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr { variable size array of NSUInteger }; range: NSRange); message 'setVertexBuffers:offsets:withRange:';
    procedure setVertexTexture_atIndex (texture: MTLTextureProtocol; index: NSUInteger); message 'setVertexTexture:atIndex:';
    procedure setVertexTextures_withRange (textures: MTLTextureProtocol; range: NSRange); message 'setVertexTextures:withRange:';
    procedure setVertexSamplerState_atIndex (sampler: MTLSamplerStateProtocol; index: NSUInteger); message 'setVertexSamplerState:atIndex:';
    procedure setVertexSamplerStates_withRange (samplers: MTLSamplerStateProtocol; range: NSRange); message 'setVertexSamplerStates:withRange:';
    procedure setVertexSamplerState_lodMinClamp_lodMaxClamp_atIndex (sampler: MTLSamplerStateProtocol; lodMinClamp: single; lodMaxClamp: single; index: NSUInteger); message 'setVertexSamplerState:lodMinClamp:lodMaxClamp:atIndex:';
    procedure setVertexSamplerStates_lodMinClamps_lodMaxClamps_withRange (samplers: MTLSamplerStateProtocol; lodMinClamps: psingle { variable size array of single }; lodMaxClamps: psingle { variable size array of single }; range: NSRange); message 'setVertexSamplerStates:lodMinClamps:lodMaxClamps:withRange:';
    procedure setViewport (viewport: MTLViewport); message 'setViewport:';
    procedure setViewports_count (viewports: MTLViewportPtr { variable size array of MTLViewport }; count: NSUInteger); message 'setViewports:count:'; { available in 10_13 }
    procedure setFrontFacingWinding (frontFacingWinding: MTLWinding); message 'setFrontFacingWinding:';
    procedure setCullMode (cullMode: MTLCullMode); message 'setCullMode:';
    procedure setDepthClipMode (depthClipMode: MTLDepthClipMode); message 'setDepthClipMode:'; { available in 10_11, 11_0 }
    procedure setDepthBias_slopeScale_clamp (depthBias: single; slopeScale: single; clamp: single); message 'setDepthBias:slopeScale:clamp:';
    procedure setScissorRect (rect: MTLScissorRect); message 'setScissorRect:';
    procedure setScissorRects_count (scissorRects: MTLScissorRectPtr { variable size array of MTLScissorRect }; count: NSUInteger); message 'setScissorRects:count:'; { available in 10_13 }
    procedure setTriangleFillMode (fillMode: MTLTriangleFillMode); message 'setTriangleFillMode:';
    procedure setFragmentBytes_length_atIndex (bytes: pointer; length: NSUInteger; index: NSUInteger); message 'setFragmentBytes:length:atIndex:'; { available in 10_11, 8_3 }
    procedure setFragmentBuffer_offset_atIndex (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); message 'setFragmentBuffer:offset:atIndex:';
    procedure setFragmentBufferOffset_atIndex (offset: NSUInteger; index: NSUInteger); message 'setFragmentBufferOffset:atIndex:'; { available in 10_11, 8_3 }
    procedure setFragmentBuffers_offsets_withRange (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr { variable size array of NSUInteger }; range: NSRange); message 'setFragmentBuffers:offsets:withRange:';
    procedure setFragmentTexture_atIndex (texture: MTLTextureProtocol; index: NSUInteger); message 'setFragmentTexture:atIndex:';
    procedure setFragmentTextures_withRange (textures: MTLTextureProtocol; range: NSRange); message 'setFragmentTextures:withRange:';
    procedure setFragmentSamplerState_atIndex (sampler: MTLSamplerStateProtocol; index: NSUInteger); message 'setFragmentSamplerState:atIndex:';
    procedure setFragmentSamplerStates_withRange (samplers: MTLSamplerStateProtocol; range: NSRange); message 'setFragmentSamplerStates:withRange:';
    procedure setFragmentSamplerState_lodMinClamp_lodMaxClamp_atIndex (sampler: MTLSamplerStateProtocol; lodMinClamp: single; lodMaxClamp: single; index: NSUInteger); message 'setFragmentSamplerState:lodMinClamp:lodMaxClamp:atIndex:';
    procedure setFragmentSamplerStates_lodMinClamps_lodMaxClamps_withRange (samplers: MTLSamplerStateProtocol; lodMinClamps: psingle { variable size array of single }; lodMaxClamps: psingle { variable size array of single }; range: NSRange); message 'setFragmentSamplerStates:lodMinClamps:lodMaxClamps:withRange:';
    procedure setBlendColorRed_green_blue_alpha (red: single; green: single; blue: single; alpha: single); message 'setBlendColorRed:green:blue:alpha:';
    procedure setDepthStencilState (depthStencilState: MTLDepthStencilStateProtocol); message 'setDepthStencilState:';
    procedure setStencilReferenceValue (referenceValue: cuint32); message 'setStencilReferenceValue:';
    procedure setStencilFrontReferenceValue_backReferenceValue (frontReferenceValue: cuint32; backReferenceValue: cuint32); message 'setStencilFrontReferenceValue:backReferenceValue:'; { available in 10_11, 9_0 }
    procedure setVisibilityResultMode_offset (mode: MTLVisibilityResultMode; offset: NSUInteger); message 'setVisibilityResultMode:offset:';
    procedure setColorStoreAction_atIndex (storeAction: MTLStoreAction; colorAttachmentIndex: NSUInteger); message 'setColorStoreAction:atIndex:'; { available in 10_12, 10_0 }
    procedure setDepthStoreAction (storeAction: MTLStoreAction); message 'setDepthStoreAction:'; { available in 10_12, 10_0 }
    procedure setStencilStoreAction (storeAction: MTLStoreAction); message 'setStencilStoreAction:'; { available in 10_12, 10_0 }
    procedure setColorStoreActionOptions_atIndex (storeActionOptions: MTLStoreActionOptions; colorAttachmentIndex: NSUInteger); message 'setColorStoreActionOptions:atIndex:'; { available in 10_13, 11_0 }
    procedure setDepthStoreActionOptions (storeActionOptions: MTLStoreActionOptions); message 'setDepthStoreActionOptions:'; { available in 10_13, 11_0 }
    procedure setStencilStoreActionOptions (storeActionOptions: MTLStoreActionOptions); message 'setStencilStoreActionOptions:'; { available in 10_13, 11_0 }
    procedure drawPrimitives_vertexStart_vertexCount_instanceCount (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger; instanceCount: NSUInteger); message 'drawPrimitives:vertexStart:vertexCount:instanceCount:';
    procedure drawPrimitives_vertexStart_vertexCount (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger); message 'drawPrimitives:vertexStart:vertexCount:';
    procedure drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset_instanceCount (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger; instanceCount: NSUInteger); message 'drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:';
    procedure drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger); message 'drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:';
    procedure drawPrimitives_vertexStart_vertexCount_instanceCount_baseInstance (primitiveType: MTLPrimitiveType; vertexStart: NSUInteger; vertexCount: NSUInteger; instanceCount: NSUInteger; baseInstance: NSUInteger); message 'drawPrimitives:vertexStart:vertexCount:instanceCount:baseInstance:'; { available in 10_11, 9_0 }
    procedure drawIndexedPrimitives_indexCount_indexType_indexBuffer_indexBufferOffset_instanceCount_baseVertex_baseInstance (primitiveType: MTLPrimitiveType; indexCount: NSUInteger; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger; instanceCount: NSUInteger; baseVertex: NSInteger; baseInstance: NSUInteger); message 'drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:baseVertex:baseInstance:'; { available in 10_11, 9_0 }
    procedure drawPrimitives_indirectBuffer_indirectBufferOffset (primitiveType: MTLPrimitiveType; indirectBuffer: MTLBufferProtocol; indirectBufferOffset: NSUInteger); message 'drawPrimitives:indirectBuffer:indirectBufferOffset:'; { available in 10_11, 9_0 }
    procedure drawIndexedPrimitives_indexType_indexBuffer_indexBufferOffset_indirectBuffer_indirectBufferOffset (primitiveType: MTLPrimitiveType; indexType: MTLIndexType; indexBuffer: MTLBufferProtocol; indexBufferOffset: NSUInteger; indirectBuffer: MTLBufferProtocol; indirectBufferOffset: NSUInteger); message 'drawIndexedPrimitives:indexType:indexBuffer:indexBufferOffset:indirectBuffer:indirectBufferOffset:'; { available in 10_11, 9_0 }
    procedure textureBarrier; message 'textureBarrier'; { available in 10_11 }
    procedure updateFence_afterStages (fence: MTLFenceProtocol; stages: MTLRenderStages); message 'updateFence:afterStages:'; { available in 10_13, 10_0 }
    procedure waitForFence_beforeStages (fence: MTLFenceProtocol; stages: MTLRenderStages); message 'waitForFence:beforeStages:'; { available in 10_13, 10_0 }
    procedure setTessellationFactorBuffer_offset_instanceStride (buffer: MTLBufferProtocol; offset: NSUInteger; instanceStride: NSUInteger); message 'setTessellationFactorBuffer:offset:instanceStride:'; { available in 10_12, 10_0 }
    procedure setTessellationFactorScale (scale: single); message 'setTessellationFactorScale:'; { available in 10_12, 10_0 }
    procedure drawPatches_patchStart_patchCount_patchIndexBuffer_patchIndexBufferOffset_instanceCount_baseInstance (numberOfPatchControlPoints: NSUInteger; patchStart: NSUInteger; patchCount: NSUInteger; patchIndexBuffer: MTLBufferProtocol; patchIndexBufferOffset: NSUInteger; instanceCount: NSUInteger; baseInstance: NSUInteger); message 'drawPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:instanceCount:baseInstance:'; { available in 10_12, 10_0 }
    procedure drawPatches_patchIndexBuffer_patchIndexBufferOffset_indirectBuffer_indirectBufferOffset (numberOfPatchControlPoints: NSUInteger; patchIndexBuffer: MTLBufferProtocol; patchIndexBufferOffset: NSUInteger; indirectBuffer: MTLBufferProtocol; indirectBufferOffset: NSUInteger); message 'drawPatches:patchIndexBuffer:patchIndexBufferOffset:indirectBuffer:indirectBufferOffset:'; { available in 10_12, NA }
    procedure drawIndexedPatches_patchStart_patchCount_patchIndexBuffer_patchIndexBufferOffset_controlPointIndexBuffer_controlPointIndexBufferOffset_instanceCount_baseInstance (numberOfPatchControlPoints: NSUInteger; patchStart: NSUInteger; patchCount: NSUInteger; patchIndexBuffer: MTLBufferProtocol; patchIndexBufferOffset: NSUInteger; controlPointIndexBuffer: MTLBufferProtocol; controlPointIndexBufferOffset: NSUInteger; instanceCount: NSUInteger; baseInstance: NSUInteger); message 'drawIndexedPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:instanceCount:baseInstance:'; { available in 10_12, 10_0 }
    procedure drawIndexedPatches_patchIndexBuffer_patchIndexBufferOffset_controlPointIndexBuffer_controlPointIndexBufferOffset_indirectBuffer_indirectBufferOffset (numberOfPatchControlPoints: NSUInteger; patchIndexBuffer: MTLBufferProtocol; patchIndexBufferOffset: NSUInteger; controlPointIndexBuffer: MTLBufferProtocol; controlPointIndexBufferOffset: NSUInteger; indirectBuffer: MTLBufferProtocol; indirectBufferOffset: NSUInteger); message 'drawIndexedPatches:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:indirectBuffer:indirectBufferOffset:'; { available in 10_12, NA }
    procedure useResource_usage (resource: MTLResourceProtocol; usage: MTLResourceUsage); message 'useResource:usage:'; { available in 10_13, 11_0 }
    procedure useResources_count_usage (resources: MTLResourceProtocol; count: NSUInteger; usage: MTLResourceUsage); message 'useResources:count:usage:'; { available in 10_13, 11_0 }
    procedure useHeap (heap: MTLHeapProtocol); message 'useHeap:'; { available in 10_13, 11_0 }
    procedure useHeaps_count (heaps: MTLHeapProtocol; count: NSUInteger); message 'useHeaps:count:'; { available in 10_13, 11_0 }
  end;
{$endif}

