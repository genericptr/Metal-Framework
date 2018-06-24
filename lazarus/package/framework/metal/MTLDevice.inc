{ Parsed from Metal.framework MTLDevice.h }

{$ifdef TYPES}
type
  MTLArgumentDescriptorPtr = ^MTLArgumentDescriptor;
  MTLDeviceProtocolPtr = ^MTLDeviceProtocol;
{$endif}

{$ifdef FUNCTIONS}
function MTLCreateSystemDefaultDevice: MTLDeviceProtocol; cdecl; external; { available in 10_11, 8_0 }
function MTLCopyAllDevices: NSArray; cdecl; external; { available in 10_11 }
{$endif}

{$ifdef TYPES}
type
  MTLDeviceNotificationName = ^NSString { available in 10_13 };
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTLDeviceWasAddedNotification: MTLDeviceNotificationName { available in 10_13 }; cvar; external;
  MTLDeviceRemovalRequestedNotification: MTLDeviceNotificationName { available in 10_13 }; cvar; external;
  MTLDeviceWasRemovedNotification: MTLDeviceNotificationName { available in 10_13 }; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTLDeviceNotificationHandler = OpaqueCBlock { available in 10_13 };
{$endif}

{$ifdef FUNCTIONS}
function MTLCopyAllDevicesWithObserver(observer: NSObjectProtocol; handler: MTLDeviceNotificationHandler): NSArray; cdecl; external; { available in 10_13 }
procedure MTLRemoveDeviceObserver(observer: NSObjectProtocol); cdecl; external; { available in 10_13 }
{$endif}

{$ifdef TYPES}
type
  MTLFeatureSet = NSUInteger;
  MTLFeatureSetPtr = ^MTLFeatureSet;

const
  MTLFeatureSet_iOS_GPUFamily1_v1 = 0 { available in 8_0 };
  MTLFeatureSet_iOS_GPUFamily2_v1 = 1 { available in 8_0 };
  MTLFeatureSet_iOS_GPUFamily1_v2 = 2 { available in 9_0 };
  MTLFeatureSet_iOS_GPUFamily2_v2 = 3 { available in 9_0 };
  MTLFeatureSet_iOS_GPUFamily3_v1 = 4 { available in 9_0 };
  MTLFeatureSet_iOS_GPUFamily1_v3 = 5 { available in 10_0 };
  MTLFeatureSet_iOS_GPUFamily2_v3 = 6 { available in 10_0 };
  MTLFeatureSet_iOS_GPUFamily3_v2 = 7 { available in 10_0 };
  MTLFeatureSet_iOS_GPUFamily1_v4 = 8 { available in 11_0 };
  MTLFeatureSet_iOS_GPUFamily2_v4 = 9 { available in 11_0 };
  MTLFeatureSet_iOS_GPUFamily3_v3 = 10 { available in 11_0 };
  MTLFeatureSet_macOS_GPUFamily1_v1 = 10000 { available in 10_11 };
  MTLFeatureSet_OSX_GPUFamily1_v1 = MTLFeatureSet_macOS_GPUFamily1_v1 { available in 10_11 };
  MTLFeatureSet_macOS_GPUFamily1_v2 = 10001 { available in 10_12 };
  MTLFeatureSet_OSX_GPUFamily1_v2 = MTLFeatureSet_macOS_GPUFamily1_v2 { available in 10_12 };
  MTLFeatureSet_macOS_ReadWriteTextureTier2 = 10002 { available in 10_12 };
  MTLFeatureSet_OSX_ReadWriteTextureTier2 = MTLFeatureSet_macOS_ReadWriteTextureTier2 { available in 10_12 };
  MTLFeatureSet_macOS_GPUFamily1_v3 = 10003 { available in 10_13 };
  MTLFeatureSet_tvOS_GPUFamily1_v1 = 30000;
  //MTLFeatureSet_TVOS_GPUFamily1_v1 = MTLFeatureSet_tvOS_GPUFamily1_v1;
  MTLFeatureSet_tvOS_GPUFamily1_v2 = 30001;
  MTLFeatureSet_tvOS_GPUFamily1_v3 = 30002;

type
  MTLPipelineOption = NSUInteger;
  MTLPipelineOptionPtr = ^MTLPipelineOption;

const
  MTLPipelineOptionNone = 0;
  MTLPipelineOptionArgumentInfo = 1 shl 0;
  MTLPipelineOptionBufferTypeInfo = 1 shl 1;

type
  MTLReadWriteTextureTier = NSUInteger;
  MTLReadWriteTextureTierPtr = ^MTLReadWriteTextureTier;

const
  MTLReadWriteTextureTierNone = 0;
  MTLReadWriteTextureTier1 = 1;
  MTLReadWriteTextureTier2 = 2;

type
  MTLArgumentBuffersTier = NSUInteger;
  MTLArgumentBuffersTierPtr = ^MTLArgumentBuffersTier;

const
  MTLArgumentBuffersTier1 = 0;
  MTLArgumentBuffersTier2 = 1;

type
  MTLSizeAndAlign = record
    size: NSUInteger;
    align: NSUInteger;
  end;
type
  MTLSizeAndAlignPtr = ^MTLSizeAndAlign;

type
  MTLAutoreleasedRenderPipelineReflection = ^MTLRenderPipelineReflection;
  MTLAutoreleasedComputePipelineReflection = ^MTLComputePipelineReflection;
  MTLNewLibraryCompletionHandler = OpaqueCBlock;
  MTLNewRenderPipelineStateCompletionHandler = OpaqueCBlock;
  MTLNewRenderPipelineStateWithReflectionCompletionHandler = OpaqueCBlock;
  MTLNewComputePipelineStateCompletionHandler = OpaqueCBlock;
  MTLNewComputePipelineStateWithReflectionCompletionHandler = OpaqueCBlock;
{$endif}

{$ifdef CLASSES}

type
  MTLArgumentDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    class function argumentDescriptor: MTLArgumentDescriptor; message 'argumentDescriptor';
    procedure setDataType(newValue: MTLDataType); message 'setDataType:';
    function dataType: MTLDataType; message 'dataType';
    procedure setIndex(newValue: NSUInteger); message 'setIndex:';
    function index: NSUInteger; message 'index';
    procedure setArrayLength(newValue: NSUInteger); message 'setArrayLength:';
    function arrayLength: NSUInteger; message 'arrayLength';
    procedure setAccess(newValue: MTLArgumentAccess); message 'setAccess:';
    function access: MTLArgumentAccess; message 'access';
    procedure setTextureType(newValue: MTLTextureType); message 'setTextureType:';
    function textureType: MTLTextureType; message 'textureType';
    procedure setConstantBlockAlignment(newValue: NSUInteger); message 'setConstantBlockAlignment:';
    function constantBlockAlignment: NSUInteger; message 'constantBlockAlignment';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLDeviceProtocol = objcprotocol external name 'MTLDevice' (NSObjectProtocol)
    function name: NSString; message 'name';
    function registryID: cuint64; message 'registryID';
    function maxThreadsPerThreadgroup: MTLSize; message 'maxThreadsPerThreadgroup';
    function isLowPower: boolean; message 'isLowPower';
    function isHeadless: boolean; message 'isHeadless';
    function isRemovable: boolean; message 'isRemovable';
    function recommendedMaxWorkingSetSize: cuint64; message 'recommendedMaxWorkingSetSize';
    function isDepth24Stencil8PixelFormatSupported: boolean; message 'isDepth24Stencil8PixelFormatSupported';
    function readWriteTextureSupport: MTLReadWriteTextureTier; message 'readWriteTextureSupport';
    function argumentBuffersSupport: MTLArgumentBuffersTier; message 'argumentBuffersSupport';
    function areRasterOrderGroupsSupported: boolean; message 'areRasterOrderGroupsSupported';
    function currentAllocatedSize: NSUInteger; message 'currentAllocatedSize';
    function newCommandQueue: MTLCommandQueueProtocol; message 'newCommandQueue';
    function newCommandQueueWithMaxCommandBufferCount (maxCommandBufferCount: NSUInteger): MTLCommandQueueProtocol; message 'newCommandQueueWithMaxCommandBufferCount:';
    function heapTextureSizeAndAlignWithDescriptor (desc: MTLTextureDescriptor): MTLSizeAndAlign; message 'heapTextureSizeAndAlignWithDescriptor:'; { available in 10_13, 10_0 }
    function heapBufferSizeAndAlignWithLength_options (length: NSUInteger; options: MTLResourceOptions): MTLSizeAndAlign; message 'heapBufferSizeAndAlignWithLength:options:'; { available in 10_13, 10_0 }
    function newHeapWithDescriptor (descriptor: MTLHeapDescriptor): MTLHeapProtocol; message 'newHeapWithDescriptor:'; { available in 10_13, 10_0 }
    function newBufferWithLength_options (length: NSUInteger; options: MTLResourceOptions): MTLBufferProtocol; message 'newBufferWithLength:options:';
    function newBufferWithBytes_length_options (pointer_: pointer; length: NSUInteger; options: MTLResourceOptions): MTLBufferProtocol; message 'newBufferWithBytes:length:options:';
    function newBufferWithBytesNoCopy_length_options_deallocator (pointer_: pointer; length: NSUInteger; options: MTLResourceOptions; deallocator: OpaqueCBlock): MTLBufferProtocol; message 'newBufferWithBytesNoCopy:length:options:deallocator:';
    function newDepthStencilStateWithDescriptor (descriptor: MTLDepthStencilDescriptor): MTLDepthStencilStateProtocol; message 'newDepthStencilStateWithDescriptor:';
    function newTextureWithDescriptor (descriptor: MTLTextureDescriptor): MTLTextureProtocol; message 'newTextureWithDescriptor:';
    function newTextureWithDescriptor_iosurface_plane (descriptor: MTLTextureDescriptor; iosurface: IOSurfaceRef; plane: NSUInteger): MTLTextureProtocol; message 'newTextureWithDescriptor:iosurface:plane:'; { available in 10_11, 11_0 }
    function newSamplerStateWithDescriptor (descriptor: MTLSamplerDescriptor): MTLSamplerStateProtocol; message 'newSamplerStateWithDescriptor:';
    function newDefaultLibrary: MTLLibraryProtocol; message 'newDefaultLibrary';
    function newDefaultLibraryWithBundle_error (bundle: NSBundle; error: NSErrorPtr): MTLLibraryProtocol; message 'newDefaultLibraryWithBundle:error:'; { available in 10_12, 10_0 }
    function newLibraryWithFile_error (filepath: NSString; error: NSErrorPtr): MTLLibraryProtocol; message 'newLibraryWithFile:error:';
    function newLibraryWithURL_error (url: NSURL; error: NSErrorPtr): MTLLibraryProtocol; message 'newLibraryWithURL:error:'; { available in 10_13, 11_0 }
    function newLibraryWithData_error (data: dispatch_data_t; error: NSErrorPtr): MTLLibraryProtocol; message 'newLibraryWithData:error:';
    function newLibraryWithSource_options_error (source: NSString; options: MTLCompileOptions; error: NSErrorPtr): MTLLibraryProtocol; message 'newLibraryWithSource:options:error:';
    procedure newLibraryWithSource_options_completionHandler (source: NSString; options: MTLCompileOptions; completionHandler: MTLNewLibraryCompletionHandler); message 'newLibraryWithSource:options:completionHandler:';
    function newRenderPipelineStateWithDescriptor_error (descriptor: MTLRenderPipelineDescriptor; error: NSErrorPtr): MTLRenderPipelineStateProtocol; message 'newRenderPipelineStateWithDescriptor:error:';
    function newRenderPipelineStateWithDescriptor_options_reflection_error (descriptor: MTLRenderPipelineDescriptor; options: MTLPipelineOption; reflection: MTLAutoreleasedRenderPipelineReflection; error: NSErrorPtr): MTLRenderPipelineStateProtocol; message 'newRenderPipelineStateWithDescriptor:options:reflection:error:';
    procedure newRenderPipelineStateWithDescriptor_completionHandler (descriptor: MTLRenderPipelineDescriptor; completionHandler: MTLNewRenderPipelineStateCompletionHandler); message 'newRenderPipelineStateWithDescriptor:completionHandler:';
    procedure newRenderPipelineStateWithDescriptor_options_completionHandler (descriptor: MTLRenderPipelineDescriptor; options: MTLPipelineOption; completionHandler: MTLNewRenderPipelineStateWithReflectionCompletionHandler); message 'newRenderPipelineStateWithDescriptor:options:completionHandler:';
    function newComputePipelineStateWithFunction_error (computeFunction: MTLFunctionProtocol; error: NSErrorPtr): MTLComputePipelineStateProtocol; message 'newComputePipelineStateWithFunction:error:';
    function newComputePipelineStateWithFunction_options_reflection_error (computeFunction: MTLFunctionProtocol; options: MTLPipelineOption; reflection: MTLAutoreleasedComputePipelineReflection; error: NSErrorPtr): MTLComputePipelineStateProtocol; message 'newComputePipelineStateWithFunction:options:reflection:error:';
    procedure newComputePipelineStateWithFunction_completionHandler (computeFunction: MTLFunctionProtocol; completionHandler: MTLNewComputePipelineStateCompletionHandler); message 'newComputePipelineStateWithFunction:completionHandler:';
    procedure newComputePipelineStateWithFunction_options_completionHandler (computeFunction: MTLFunctionProtocol; options: MTLPipelineOption; completionHandler: MTLNewComputePipelineStateWithReflectionCompletionHandler); message 'newComputePipelineStateWithFunction:options:completionHandler:';
    function newComputePipelineStateWithDescriptor_options_reflection_error (descriptor: MTLComputePipelineDescriptor; options: MTLPipelineOption; reflection: MTLAutoreleasedComputePipelineReflection; error: NSErrorPtr): MTLComputePipelineStateProtocol; message 'newComputePipelineStateWithDescriptor:options:reflection:error:'; { available in 10_11, 9_0 }
    procedure newComputePipelineStateWithDescriptor_options_completionHandler (descriptor: MTLComputePipelineDescriptor; options: MTLPipelineOption; completionHandler: MTLNewComputePipelineStateWithReflectionCompletionHandler); message 'newComputePipelineStateWithDescriptor:options:completionHandler:'; { available in 10_11, 9_0 }
    function newFence: MTLFenceProtocol; message 'newFence'; { available in 10_13, 10_0 }
    function supportsFeatureSet (featureSet: MTLFeatureSet): boolean; message 'supportsFeatureSet:';
    function supportsTextureSampleCount (sampleCount: NSUInteger): boolean; message 'supportsTextureSampleCount:'; { available in 10_11, 9_0 }
    function minimumLinearTextureAlignmentForPixelFormat (format: MTLPixelFormat): NSUInteger; message 'minimumLinearTextureAlignmentForPixelFormat:'; { available in 10_13, 11_0 }
    function maxThreadgroupMemoryLength: NSUInteger; message 'maxThreadgroupMemoryLength';
    function areProgrammableSamplePositionsSupported: boolean; message 'areProgrammableSamplePositionsSupported';
    procedure getDefaultSamplePositions_count (positions: MTLSamplePositionPtr; count: NSUInteger); message 'getDefaultSamplePositions:count:'; { available in 10_13, 11_0 }
    function newArgumentEncoderWithArguments (arguments: NSArray{MTLArgumentDescriptor}): MTLArgumentEncoderProtocol; message 'newArgumentEncoderWithArguments:'; { available in 10_13, 11_0 }
  end;
{$endif}

