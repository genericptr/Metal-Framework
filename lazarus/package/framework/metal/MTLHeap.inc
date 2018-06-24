{ Parsed from Metal.framework MTLHeap.h }

{$ifdef TYPES}
type
  MTLHeapDescriptorPtr = ^MTLHeapDescriptor;
  MTLHeapProtocolPtr = ^MTLHeapProtocol;
{$endif}

{$ifdef CLASSES}

type
  MTLHeapDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    procedure setSize(newValue: NSUInteger); message 'setSize:';
    function size: NSUInteger; message 'size';
    procedure setStorageMode(newValue: MTLStorageMode); message 'setStorageMode:';
    function storageMode: MTLStorageMode; message 'storageMode';
    procedure setCpuCacheMode(newValue: MTLCPUCacheMode); message 'setCpuCacheMode:';
    function cpuCacheMode: MTLCPUCacheMode; message 'cpuCacheMode';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLHeapProtocol = objcprotocol external name 'MTLHeap' (NSObjectProtocol)
    procedure setLabel(newValue: NSString); message 'setLabel:';
    function label_: NSString; message 'label';
    function device: MTLDeviceProtocol; message 'device';
    function storageMode: MTLStorageMode; message 'storageMode';
    function cpuCacheMode: MTLCPUCacheMode; message 'cpuCacheMode';
    function size: NSUInteger; message 'size';
    function usedSize: NSUInteger; message 'usedSize';
    function currentAllocatedSize: NSUInteger; message 'currentAllocatedSize';
    function maxAvailableSizeWithAlignment (alignment: NSUInteger): NSUInteger; message 'maxAvailableSizeWithAlignment:';
    function newBufferWithLength_options (length: NSUInteger; options: MTLResourceOptions): MTLBufferProtocol; message 'newBufferWithLength:options:';
    function newTextureWithDescriptor (desc: MTLTextureDescriptor): MTLTextureProtocol; message 'newTextureWithDescriptor:';
    function setPurgeableState (state: MTLPurgeableState): MTLPurgeableState; message 'setPurgeableState:';
  end;
{$endif}

