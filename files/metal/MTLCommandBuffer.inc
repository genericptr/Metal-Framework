{ Parsed from Metal.framework MTLCommandBuffer.h }

{$ifdef TYPES}
type
  MTLCommandBufferProtocolPtr = ^MTLCommandBufferProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLCommandBufferStatus = NSUInteger;
  MTLCommandBufferStatusPtr = ^MTLCommandBufferStatus;

const
  MTLCommandBufferStatusNotEnqueued = 0;
  MTLCommandBufferStatusEnqueued = 1;
  MTLCommandBufferStatusCommitted = 2;
  MTLCommandBufferStatusScheduled = 3;
  MTLCommandBufferStatusCompleted = 4;
  MTLCommandBufferStatusError = 5;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTLCommandBufferErrorDomain: NSString; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTLCommandBufferError = NSUInteger;
  MTLCommandBufferErrorPtr = ^MTLCommandBufferError;

const
  MTLCommandBufferErrorNone = 0;
  MTLCommandBufferErrorInternal = 1;
  MTLCommandBufferErrorTimeout = 2;
  MTLCommandBufferErrorPageFault = 3;
  MTLCommandBufferErrorBlacklisted = 4;
  MTLCommandBufferErrorNotPermitted = 7;
  MTLCommandBufferErrorOutOfMemory = 8;
  MTLCommandBufferErrorInvalidResource = 9;
  MTLCommandBufferErrorMemoryless = 10 { available in 10_0 };
  MTLCommandBufferErrorDeviceRemoved = 11 { available in 10_13 };

type
  MTLCommandBufferHandler = OpaqueCBlock { available in 10_11, 8_0 };
{$endif}

{$ifdef PROTOCOLS}

type
  MTLCommandBufferProtocol = objcprotocol external name 'MTLCommandBuffer' (NSObjectProtocol)
    function device: MTLDeviceProtocol; message 'device';
    function commandQueue: MTLCommandQueueProtocol; message 'commandQueue';
    function retainedReferences: boolean; message 'retainedReferences';
    procedure setLabel(newValue: NSString); message 'setLabel:';
    function label_: NSString; message 'label';
    function kernelStartTime: CFTimeInterval; message 'kernelStartTime';
    function kernelEndTime: CFTimeInterval; message 'kernelEndTime';
    function GPUStartTime: CFTimeInterval; message 'GPUStartTime';
    function GPUEndTime: CFTimeInterval; message 'GPUEndTime';
    procedure enqueue; message 'enqueue';
    procedure commit; message 'commit';
    procedure addScheduledHandler (block: MTLCommandBufferHandler); message 'addScheduledHandler:';
    procedure presentDrawable (drawable: MTLDrawableProtocol); message 'presentDrawable:';
    procedure presentDrawable_atTime (drawable: MTLDrawableProtocol; presentationTime: CFTimeInterval); message 'presentDrawable:atTime:';
    procedure waitUntilScheduled; message 'waitUntilScheduled';
    procedure addCompletedHandler (block: MTLCommandBufferHandler); message 'addCompletedHandler:';
    procedure waitUntilCompleted; message 'waitUntilCompleted';
    function status: MTLCommandBufferStatus; message 'status';
    function error: NSError; message 'error';
    function blitCommandEncoder: MTLBlitCommandEncoderProtocol; message 'blitCommandEncoder';
    function renderCommandEncoderWithDescriptor (renderPassDescriptor: MTLRenderPassDescriptor): MTLRenderCommandEncoderProtocol; message 'renderCommandEncoderWithDescriptor:';
    function computeCommandEncoder: MTLComputeCommandEncoderProtocol; message 'computeCommandEncoder';
    function parallelRenderCommandEncoderWithDescriptor (renderPassDescriptor: MTLRenderPassDescriptor): MTLParallelRenderCommandEncoderProtocol; message 'parallelRenderCommandEncoderWithDescriptor:';
    procedure pushDebugGroup (string_: NSString); message 'pushDebugGroup:'; { available in 10_13, 11_0 }
    procedure popDebugGroup; message 'popDebugGroup'; { available in 10_13, 11_0 }
  end;
{$endif}

