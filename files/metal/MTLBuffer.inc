{ Parsed from Metal.framework MTLBuffer.h }

{$ifdef TYPES}
type
  MTLBufferProtocolPtr = ^MTLBufferProtocol;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLBufferProtocol = objcprotocol external name 'MTLBuffer' (MTLResourceProtocol)
    function length: NSUInteger; message 'length';
    function contents: pointer; message 'contents';
    procedure didModifyRange (range: NSRange); message 'didModifyRange:'; { available in 10_11 }
    function newTextureWithDescriptor_offset_bytesPerRow (descriptor: MTLTextureDescriptor; offset: NSUInteger; bytesPerRow: NSUInteger): MTLTextureProtocol; message 'newTextureWithDescriptor:offset:bytesPerRow:'; { available in 10_13, 8_0 }
    procedure addDebugMarker_range (marker: NSString; range: NSRange); message 'addDebugMarker:range:'; { available in 10_12, 10_0 }
    procedure removeAllDebugMarkers; message 'removeAllDebugMarkers'; { available in 10_12, 10_0 }
  end;
{$endif}

