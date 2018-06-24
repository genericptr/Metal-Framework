{ Parsed from Metal.framework MTLRenderPass.h }

{$ifdef TYPES}
type
  MTLRenderPassAttachmentDescriptorPtr = ^MTLRenderPassAttachmentDescriptor;
  MTLRenderPassColorAttachmentDescriptorPtr = ^MTLRenderPassColorAttachmentDescriptor;
  MTLRenderPassDepthAttachmentDescriptorPtr = ^MTLRenderPassDepthAttachmentDescriptor;
  MTLRenderPassStencilAttachmentDescriptorPtr = ^MTLRenderPassStencilAttachmentDescriptor;
  MTLRenderPassColorAttachmentDescriptorArrayPtr = ^MTLRenderPassColorAttachmentDescriptorArray;
  MTLRenderPassDescriptorPtr = ^MTLRenderPassDescriptor;
{$endif}

{$ifdef TYPES}
type
  MTLLoadAction = NSUInteger;
  MTLLoadActionPtr = ^MTLLoadAction;

const
  MTLLoadActionDontCare = 0;
  MTLLoadActionLoad = 1;
  MTLLoadActionClear = 2;

type
  MTLStoreAction = NSUInteger;
  MTLStoreActionPtr = ^MTLStoreAction;

const
  MTLStoreActionDontCare = 0;
  MTLStoreActionStore = 1;
  MTLStoreActionMultisampleResolve = 2;
  MTLStoreActionStoreAndMultisampleResolve = 3 { available in 10_12, 10_0 };
  MTLStoreActionUnknown = 4 { available in 10_12, 10_0 };
  MTLStoreActionCustomSampleDepthStore = 5 { available in 10_13, 11_0 };

type
  MTLStoreActionOptions = NSUInteger;
  MTLStoreActionOptionsPtr = ^MTLStoreActionOptions;

const
  MTLStoreActionOptionNone = 0;
  MTLStoreActionOptionCustomSamplePositions = 1 shl 0;

type
  MTLClearColor = record
    red: double;
    green: double;
    blue: double;
    alpha: double;
  end;
type
  MTLClearColorPtr = ^MTLClearColor;
{$endif}

{$ifdef CLASSES}

type
  MTLRenderPassAttachmentDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    procedure setTexture(newValue: MTLTextureProtocol); message 'setTexture:';
    function texture: MTLTextureProtocol; message 'texture';
    procedure setLevel(newValue: NSUInteger); message 'setLevel:';
    function level: NSUInteger; message 'level';
    procedure setSlice(newValue: NSUInteger); message 'setSlice:';
    function slice: NSUInteger; message 'slice';
    procedure setDepthPlane(newValue: NSUInteger); message 'setDepthPlane:';
    function depthPlane: NSUInteger; message 'depthPlane';
    procedure setResolveTexture(newValue: MTLTextureProtocol); message 'setResolveTexture:';
    function resolveTexture: MTLTextureProtocol; message 'resolveTexture';
    procedure setResolveLevel(newValue: NSUInteger); message 'setResolveLevel:';
    function resolveLevel: NSUInteger; message 'resolveLevel';
    procedure setResolveSlice(newValue: NSUInteger); message 'setResolveSlice:';
    function resolveSlice: NSUInteger; message 'resolveSlice';
    procedure setResolveDepthPlane(newValue: NSUInteger); message 'setResolveDepthPlane:';
    function resolveDepthPlane: NSUInteger; message 'resolveDepthPlane';
    procedure setLoadAction(newValue: MTLLoadAction); message 'setLoadAction:';
    function loadAction: MTLLoadAction; message 'loadAction';
    procedure setStoreAction(newValue: MTLStoreAction); message 'setStoreAction:';
    function storeAction: MTLStoreAction; message 'storeAction';
    procedure setStoreActionOptions(newValue: MTLStoreActionOptions); message 'setStoreActionOptions:';
    function storeActionOptions: MTLStoreActionOptions; message 'storeActionOptions';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;

type
  MTLRenderPassColorAttachmentDescriptor = objcclass external (MTLRenderPassAttachmentDescriptor)
  public
    procedure setClearColor(newValue: MTLClearColor); message 'setClearColor:';
    function clearColor: MTLClearColor; message 'clearColor';
  end;
{$endif}

{$ifdef TYPES}
type
  MTLMultisampleDepthResolveFilter = NSUInteger;
  MTLMultisampleDepthResolveFilterPtr = ^MTLMultisampleDepthResolveFilter;

const
  MTLMultisampleDepthResolveFilterSample0 = 0;
  MTLMultisampleDepthResolveFilterMin = 1;
  MTLMultisampleDepthResolveFilterMax = 2;
{$endif}

{$ifdef CLASSES}

type
  MTLRenderPassDepthAttachmentDescriptor = objcclass external (MTLRenderPassAttachmentDescriptor)
  public
    procedure setClearDepth(newValue: double); message 'setClearDepth:';
    function clearDepth: double; message 'clearDepth';
    procedure setDepthResolveFilter(newValue: MTLMultisampleDepthResolveFilter); message 'setDepthResolveFilter:';
    function depthResolveFilter: MTLMultisampleDepthResolveFilter; message 'depthResolveFilter';
  end;

type
  MTLRenderPassStencilAttachmentDescriptor = objcclass external (MTLRenderPassAttachmentDescriptor)
  public
    procedure setClearStencil(newValue: cuint32); message 'setClearStencil:';
    function clearStencil: cuint32; message 'clearStencil';
  end;

type
  MTLRenderPassColorAttachmentDescriptorArray = objcclass external (NSObject)
  public
    function objectAtIndexedSubscript (attachmentIndex: NSUInteger): MTLRenderPassColorAttachmentDescriptor; message 'objectAtIndexedSubscript:';
    procedure setObject_atIndexedSubscript (attachment: MTLRenderPassColorAttachmentDescriptor; attachmentIndex: NSUInteger); message 'setObject:atIndexedSubscript:';
  end;

type
  MTLRenderPassDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    class function renderPassDescriptor: MTLRenderPassDescriptor; message 'renderPassDescriptor';
    function colorAttachments: MTLRenderPassColorAttachmentDescriptorArray; message 'colorAttachments';
    procedure setDepthAttachment(newValue: MTLRenderPassDepthAttachmentDescriptor); message 'setDepthAttachment:';
    function depthAttachment: MTLRenderPassDepthAttachmentDescriptor; message 'depthAttachment';
    procedure setStencilAttachment(newValue: MTLRenderPassStencilAttachmentDescriptor); message 'setStencilAttachment:';
    function stencilAttachment: MTLRenderPassStencilAttachmentDescriptor; message 'stencilAttachment';
    procedure setVisibilityResultBuffer(newValue: MTLBufferProtocol); message 'setVisibilityResultBuffer:';
    function visibilityResultBuffer: MTLBufferProtocol; message 'visibilityResultBuffer';
    procedure setRenderTargetArrayLength(newValue: NSUInteger); message 'setRenderTargetArrayLength:';
    function renderTargetArrayLength: NSUInteger; message 'renderTargetArrayLength';
    procedure setSamplePositions_count (positions: MTLSamplePositionPtr; count: NSUInteger); message 'setSamplePositions:count:'; { available in 10_13, 11_0 }
    function getSamplePositions_count (positions: MTLSamplePositionPtr; count: NSUInteger): NSUInteger; message 'getSamplePositions:count:'; { available in 10_13, 11_0 }

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;
{$endif}

