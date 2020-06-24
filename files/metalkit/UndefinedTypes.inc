

// ModelIO.framework
type
	MDLMeshBufferAllocatorProtocol = objcprotocol end;
	MDLMeshBufferProtocol = objcprotocol end;
	MDLNamedProtocol = objcprotocol end;
	MDLMeshBufferZoneProtocol = objcprotocol end;

type
	MDLVertexDescriptor = NSObject;
	MDLVertexDescriptorPtr = ^MDLVertexDescriptor;

type
	MDLVertexFormat = NSUInteger;
	MDLMeshBufferType = NSUInteger;

// NSGraphics.
type
	NSDisplayGamut = NSUInteger; // NS_ENUM_AVAILABLE_MAC(10_12)

const
	NSDisplayGamutSRGB = 1;
	NSDisplayGamutP3 = 2;