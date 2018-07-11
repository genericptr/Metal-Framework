{ Parsed from Metal.framework MTLBlitCommandEncoder.h }

{$ifdef TYPES}
type
  MTLBlitCommandEncoderProtocolPtr = ^MTLBlitCommandEncoderProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLBlitOption = NSUInteger;
  MTLBlitOptionPtr = ^MTLBlitOption;

const
  MTLBlitOptionNone = 0;
  MTLBlitOptionDepthFromDepthStencil = 1 shl 0;
  MTLBlitOptionStencilFromDepthStencil = 1 shl 1;
  MTLBlitOptionRowLinearPVRTC = 1 shl 2 { available in 9_0 };
{$endif}

{$ifdef PROTOCOLS}

type
  MTLBlitCommandEncoderProtocol = objcprotocol external name 'MTLBlitCommandEncoder' (MTLCommandEncoderProtocol)
    procedure synchronizeResource (resource: MTLResourceProtocol); message 'synchronizeResource:'; { available in 10_11 }
    procedure synchronizeTexture_slice_level (texture: MTLTextureProtocol; slice: NSUInteger; level: NSUInteger); message 'synchronizeTexture:slice:level:'; { available in 10_11 }

    // NOTE: these names are too long

    //procedure copyFromTexture_sourceSlice_sourceLevel_sourceOrigin_sourceSize_toTexture_destinationSlice_destinationLevel_destinationOrigin (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:';
    //procedure copyFromBuffer_sourceOffset_sourceBytesPerRow_sourceBytesPerImage_sourceSize_toTexture_destinationSlice_destinationLevel_destinationOrigin (sourceBuffer: MTLBufferProtocol; sourceOffset: NSUInteger; sourceBytesPerRow: NSUInteger; sourceBytesPerImage: NSUInteger; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin); overload; message 'copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:';
    //procedure copyFromBuffer_sourceOffset_sourceBytesPerRow_sourceBytesPerImage_sourceSize_toTexture_destinationSlice_destinationLevel_destinationOrigin_options (sourceBuffer: MTLBufferProtocol; sourceOffset: NSUInteger; sourceBytesPerRow: NSUInteger; sourceBytesPerImage: NSUInteger; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin; options: MTLBlitOption); overload; message 'copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:options:'; { available in 10_11, 9_0 }
    //procedure copyFromTexture_sourceSlice_sourceLevel_sourceOrigin_sourceSize_toBuffer_destinationOffset_destinationBytesPerRow_destinationBytesPerImage (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationBuffer: MTLBufferProtocol; destinationOffset: NSUInteger; destinationBytesPerRow: NSUInteger; destinationBytesPerImage: NSUInteger); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:';
    //procedure copyFromTexture_sourceSlice_sourceLevel_sourceOrigin_sourceSize_toBuffer_destinationOffset_destinationBytesPerRow_destinationBytesPerImage_options (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationBuffer: MTLBufferProtocol; destinationOffset: NSUInteger; destinationBytesPerRow: NSUInteger; destinationBytesPerImage: NSUInteger; options: MTLBlitOption); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:options:'; { available in 10_11, 9_0 }

    procedure copyFromTexture (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:';
    procedure copyFromBuffer (sourceBuffer: MTLBufferProtocol; sourceOffset: NSUInteger; sourceBytesPerRow: NSUInteger; sourceBytesPerImage: NSUInteger; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin); overload; message 'copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:';
    procedure copyFromBuffer (sourceBuffer: MTLBufferProtocol; sourceOffset: NSUInteger; sourceBytesPerRow: NSUInteger; sourceBytesPerImage: NSUInteger; sourceSize: MTLSize; destinationTexture: MTLTextureProtocol; destinationSlice: NSUInteger; destinationLevel: NSUInteger; destinationOrigin: MTLOrigin; options: MTLBlitOption); overload; message 'copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:options:'; { available in 10_11, 9_0 }
    procedure copyFromTexture (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationBuffer: MTLBufferProtocol; destinationOffset: NSUInteger; destinationBytesPerRow: NSUInteger; destinationBytesPerImage: NSUInteger); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:';
    procedure copyFromTexture (sourceTexture: MTLTextureProtocol; sourceSlice: NSUInteger; sourceLevel: NSUInteger; sourceOrigin: MTLOrigin; sourceSize: MTLSize; destinationBuffer: MTLBufferProtocol; destinationOffset: NSUInteger; destinationBytesPerRow: NSUInteger; destinationBytesPerImage: NSUInteger; options: MTLBlitOption); overload; message 'copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:options:'; { available in 10_11, 9_0 }

    procedure generateMipmapsForTexture (texture: MTLTextureProtocol); message 'generateMipmapsForTexture:';
    procedure fillBuffer_range_value (buffer: MTLBufferProtocol; range: NSRange; value: cuint8); message 'fillBuffer:range:value:';
    procedure copyFromBuffer_sourceOffset_toBuffer_destinationOffset_size (sourceBuffer: MTLBufferProtocol; sourceOffset: NSUInteger; destinationBuffer: MTLBufferProtocol; destinationOffset: NSUInteger; size: NSUInteger); message 'copyFromBuffer:sourceOffset:toBuffer:destinationOffset:size:';
    procedure updateFence (fence: MTLFenceProtocol); message 'updateFence:'; { available in 10_13, 10_0 }
    procedure waitForFence (fence: MTLFenceProtocol); message 'waitForFence:'; { available in 10_13, 10_0 }
  end;
{$endif}

