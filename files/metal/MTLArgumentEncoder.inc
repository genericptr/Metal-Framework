{ Parsed from Metal.framework MTLArgumentEncoder.h }

{$ifdef TYPES}
type
  MTLArgumentEncoderProtocolPtr = ^MTLArgumentEncoderProtocol;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLArgumentEncoderProtocol = objcprotocol external name 'MTLArgumentEncoder' (NSObjectProtocol)
    function device: MTLDeviceProtocol; message 'device';
    procedure setLabel(newValue: NSString); message 'setLabel:';
    function label_: NSString; message 'label';
    function encodedLength: NSUInteger; message 'encodedLength';
    function alignment: NSUInteger; message 'alignment';
    procedure setArgumentBuffer_offset (argumentBuffer: MTLBufferProtocol; offset: NSUInteger); message 'setArgumentBuffer:offset:';
    procedure setArgumentBuffer_startOffset_arrayElement (argumentBuffer: MTLBufferProtocol; startOffset: NSUInteger; arrayElement: NSUInteger); message 'setArgumentBuffer:startOffset:arrayElement:';
    procedure setBuffer_offset_atIndex (buffer: MTLBufferProtocol; offset: NSUInteger; index: NSUInteger); message 'setBuffer:offset:atIndex:';
    procedure setBuffers_offsets_withRange (buffers: MTLBufferProtocol; offsets: NSUIntegerPtr { variable size array of NSUInteger }; range: NSRange); message 'setBuffers:offsets:withRange:';
    procedure setTexture_atIndex (texture: MTLTextureProtocol; index: NSUInteger); message 'setTexture:atIndex:';
    procedure setTextures_withRange (textures: MTLTextureProtocol; range: NSRange); message 'setTextures:withRange:';
    procedure setSamplerState_atIndex (sampler: MTLSamplerStateProtocol; index: NSUInteger); message 'setSamplerState:atIndex:';
    procedure setSamplerStates_withRange (samplers: MTLSamplerStateProtocol; range: NSRange); message 'setSamplerStates:withRange:';
    function constantDataAtIndex (index: NSUInteger): pointer; message 'constantDataAtIndex:';
    function newArgumentEncoderForBufferAtIndex (index: NSUInteger): MTLArgumentEncoderProtocol; message 'newArgumentEncoderForBufferAtIndex:'; { available in 10_13 }
  end;
{$endif}

