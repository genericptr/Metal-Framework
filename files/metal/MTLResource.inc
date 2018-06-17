{ Parsed from Metal.framework MTLResource.h }

{$ifdef TYPES}
type
  MTLResourceProtocolPtr = ^MTLResourceProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLPurgeableState = NSUInteger;
  MTLPurgeableStatePtr = ^MTLPurgeableState;

const
  MTLPurgeableStateKeepCurrent = 1;
  MTLPurgeableStateNonVolatile = 2;
  MTLPurgeableStateVolatile = 3;
  MTLPurgeableStateEmpty = 4;

type
  MTLCPUCacheMode = NSUInteger;
  MTLCPUCacheModePtr = ^MTLCPUCacheMode;

const
  MTLCPUCacheModeDefaultCache = 0;
  MTLCPUCacheModeWriteCombined = 1;

type
  MTLStorageMode = NSUInteger;
  MTLStorageModePtr = ^MTLStorageMode;

const
  MTLStorageModeShared = 0;
  MTLStorageModeManaged = 1 { available in 10_11, NA };
  MTLStorageModePrivate = 2;
  MTLStorageModeMemoryless = 3 { available in NA, 10_0 };

const
  MTLResourceCPUCacheModeShift = 0;
  MTLResourceStorageModeShift = 4;
  MTLResourceHazardTrackingModeShift = 8;

type
  MTLResourceOptions = NSUInteger;
  MTLResourceOptionsPtr = ^MTLResourceOptions;

const
  MTLResourceCPUCacheModeDefaultCache = MTLCPUCacheModeDefaultCache shl MTLResourceCPUCacheModeShift;
  MTLResourceCPUCacheModeWriteCombined = MTLCPUCacheModeWriteCombined shl MTLResourceCPUCacheModeShift;
  MTLResourceStorageModeShared = MTLStorageModeShared shl MTLResourceStorageModeShift { available in 10_11, 9_0 };
  MTLResourceStorageModeManaged = MTLStorageModeManaged shl MTLResourceStorageModeShift { available in 10_11, NA };
  MTLResourceStorageModePrivate = MTLStorageModePrivate shl MTLResourceStorageModeShift { available in 10_11, 9_0 };
  MTLResourceStorageModeMemoryless = MTLStorageModeMemoryless shl MTLResourceStorageModeShift { available in NA,    10_0 };
  MTLResourceHazardTrackingModeUntracked = $1 shl MTLResourceHazardTrackingModeShift { available in 10_13, 10_0 };
  MTLResourceOptionCPUCacheModeDefault = MTLResourceCPUCacheModeDefaultCache;
  MTLResourceOptionCPUCacheModeWriteCombined = MTLResourceCPUCacheModeWriteCombined;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLResourceProtocol = objcprotocol external name 'MTLResource' (NSObjectProtocol)
    procedure setLabel(newValue: NSString); message 'setLabel:';
    function label_: NSString; message 'label';
    function device: MTLDeviceProtocol; message 'device';
    function cpuCacheMode: MTLCPUCacheMode; message 'cpuCacheMode';
    function storageMode: MTLStorageMode; message 'storageMode';
    function setPurgeableState (state: MTLPurgeableState): MTLPurgeableState; message 'setPurgeableState:';
    function heap: MTLHeapProtocol; message 'heap';
    function allocatedSize: NSUInteger; message 'allocatedSize';
    procedure makeAliasable; message 'makeAliasable'; { available in 10_13, 10_0 }
    function isAliasable: boolean; message 'isAliasable'; { available in 10_13, 10_0 }
  end;
{$endif}

