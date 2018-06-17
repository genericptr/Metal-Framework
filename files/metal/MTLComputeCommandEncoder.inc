{ Parsed from Metal.framework MTLComputeCommandEncoder.h }

{$ifdef TYPES}
type
  MTLComputeCommandEncoderProtocolPtr = ^MTLComputeCommandEncoderProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLDispatchThreadgroupsIndirectArguments = record
    threadgroupsPerGrid:array[0..2] of cuint32;
  end;
type
  MTLDispatchThreadgroupsIndirectArgumentsPtr = ^MTLDispatchThreadgroupsIndirectArguments;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLComputeCommandEncoderProtocol = objcprotocol external name 'MTLComputeCommandEncoder' (MTLCommandEncoderProtocol)
    procedure setComputePipelineState (state: MTLComputePipelineStateProtocol); message 'setComputePipelineState:';
    procedure setBytes_length_atIndex (bytes: pointer; length: NSUInteger; index: NSUInteger); message 'setBytes:length:atIndex:'; { available in 10_11, 8_3 }
    procedure setBuffer_offset_atIndex (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); message 'setBuffer:offset:atIndex:';
    procedure setBufferOffset_atIndex (offset: NSUInteger; index: NSUInteger); message 'setBufferOffset:atIndex:'; { available in 10_11, 8_3 }
    procedure setBuffers_offsets_withRange (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr { variable size array of NSUInteger }; range: NSRange); message 'setBuffers:offsets:withRange:';
    procedure setTexture_atIndex (texture: MTLTextureProtocol; index: NSUInteger); message 'setTexture:atIndex:';
    procedure setTextures_withRange (textures: MTLTextureProtocol; range: NSRange); message 'setTextures:withRange:';
    procedure setSamplerState_atIndex (sampler: MTLSamplerStateProtocol; index: NSUInteger); message 'setSamplerState:atIndex:';
    procedure setSamplerStates_withRange (samplers: MTLSamplerStateProtocol; range: NSRange); message 'setSamplerStates:withRange:';
    procedure setSamplerState_lodMinClamp_lodMaxClamp_atIndex (sampler: MTLSamplerStateProtocol; lodMinClamp: single; lodMaxClamp: single; index: NSUInteger); message 'setSamplerState:lodMinClamp:lodMaxClamp:atIndex:';
    procedure setSamplerStates_lodMinClamps_lodMaxClamps_withRange (samplers: MTLSamplerStateProtocol; lodMinClamps: psingle { variable size array of single }; lodMaxClamps: psingle { variable size array of single }; range: NSRange); message 'setSamplerStates:lodMinClamps:lodMaxClamps:withRange:';
    procedure setThreadgroupMemoryLength_atIndex (length: NSUInteger; index: NSUInteger); message 'setThreadgroupMemoryLength:atIndex:';
    procedure setStageInRegion (region: MTLRegion); message 'setStageInRegion:'; { available in 10_12, 10_0 }
    procedure dispatchThreadgroups_threadsPerThreadgroup (threadgroupsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize); message 'dispatchThreadgroups:threadsPerThreadgroup:';
    procedure dispatchThreadgroupsWithIndirectBuffer_indirectBufferOffset_threadsPerThreadgroup (indirectBuffer: MTLBufferProtocol; indirectBufferOffset: NSUInteger; threadsPerThreadgroup: MTLSize); message 'dispatchThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerThreadgroup:'; { available in 10_11, 9_0 }
    procedure dispatchThreads_threadsPerThreadgroup (threadsPerGrid: MTLSize; threadsPerThreadgroup: MTLSize); message 'dispatchThreads:threadsPerThreadgroup:'; { available in 10_13, 11_0 }
    procedure updateFence (fence: MTLFenceProtocol); message 'updateFence:'; { available in 10_13, 10_0 }
    procedure waitForFence (fence: MTLFenceProtocol); message 'waitForFence:'; { available in 10_13, 10_0 }
    procedure useResource_usage (resource: MTLResourceProtocol; usage: MTLResourceUsage); message 'useResource:usage:'; { available in 10_13, 11_0 }
    procedure useResources_count_usage (resources: MTLResourceProtocol; count: NSUInteger; usage: MTLResourceUsage); message 'useResources:count:usage:'; { available in 10_13, 11_0 }
    procedure useHeap (heap: MTLHeapProtocol); message 'useHeap:'; { available in 10_13, 11_0 }
    procedure useHeaps_count (heaps: MTLHeapProtocol; count: NSUInteger); message 'useHeaps:count:'; { available in 10_13, 11_0 }
  end;
{$endif}

