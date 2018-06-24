{ Parsed from MetalKit.framework MTKModel.h }

{$ifdef TYPES}
type
  MTKMeshBufferAllocatorPtr = ^MTKMeshBufferAllocator;
  MTKMeshBufferPtr = ^MTKMeshBuffer;
  MTKSubmeshPtr = ^MTKSubmesh;
  MTKMeshPtr = ^MTKMesh;
{$endif}

{$ifdef TYPES}
type
  MTKModelError = ^NSString;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTKModelErrorDomain: MTKModelError { available in 10_11, 9_0 }; cvar; external;
  MTKModelErrorKey: MTKModelError { available in 10_11, 9_0 }; cvar; external;
{$endif}

{$ifdef CLASSES}

type
  MTKMeshBufferAllocator = objcclass external (NSObject, MDLMeshBufferAllocatorProtocol)
  public
    function init: instancetype; message 'init';
    function initWithDevice (device: MTLDeviceProtocol): instancetype; message 'initWithDevice:';
    function device: MTLDeviceProtocol; message 'device';
  end;

type
  MTKMeshBuffer = objcclass external (NSObject, MDLMeshBufferProtocol, MDLNamedProtocol)
  public
    function init: instancetype; message 'init';
    function length: NSUInteger; message 'length';
    function allocator: MTKMeshBufferAllocator; message 'allocator';
    function zone: MDLMeshBufferZoneProtocol; message 'zone';
    function buffer: MTLBufferProtocol; message 'buffer';
    function offset: NSUInteger; message 'offset';
    function type_: MDLMeshBufferType; message 'type';
  end;

type
  MTKSubmesh = objcclass external (NSObject)
  public
    function init: instancetype; message 'init';
    function primitiveType: MTLPrimitiveType; message 'primitiveType';
    function indexType: MTLIndexType; message 'indexType';
    function indexBuffer: MTKMeshBuffer; message 'indexBuffer';
    function indexCount: NSUInteger; message 'indexCount';
    function mesh: MTKMesh; message 'mesh';
    procedure setName(newValue: NSString); message 'setName:';
    function name: NSString; message 'name';
  end;

type
  MTKMesh = objcclass external (NSObject)
  private
  public
    function vertexBuffers: NSArray{MTKMeshBuffer}; message 'vertexBuffers';
    function vertexDescriptor: MDLVertexDescriptorPtr; message 'vertexDescriptor';
    function submeshes: NSArray{MTKSubmesh}; message 'submeshes';
    function vertexCount: NSUInteger; message 'vertexCount';
    procedure setName(newValue: NSString); message 'setName:';
    function name: NSString; message 'name';
  end;
{$endif}

{$ifdef FUNCTIONS}
function MTKModelIOVertexDescriptorFromMetal(metalDescriptor: MTLVertexDescriptor): MDLVertexDescriptorPtr; cdecl; external; { available in 10_11, 9_0 }
function MTKModelIOVertexDescriptorFromMetalWithError(metalDescriptor: MTLVertexDescriptor; error: NSErrorPtr): MDLVertexDescriptorPtr; cdecl; external; { available in 10_12, 10_0 }
function MTKMetalVertexDescriptorFromModelIO(modelIODescriptor: MDLVertexDescriptorPtr): MTLVertexDescriptor; cdecl; external; { available in 10_11, 9_0 }
function MTKMetalVertexDescriptorFromModelIOWithError(modelIODescriptor: MDLVertexDescriptorPtr; error: NSErrorPtr): MTLVertexDescriptor; cdecl; external; { available in 10_12, 10_0 }
function MTKModelIOVertexFormatFromMetal(vertexFormat: MTLVertexFormat): MDLVertexFormat; cdecl; external; { available in 10_11, 9_0 }
function MTKMetalVertexFormatFromModelIO(vertexFormat: MDLVertexFormat): MTLVertexFormat; cdecl; external; { available in 10_11, 9_0 }
{$endif}

