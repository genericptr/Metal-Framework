{ Parsed from Metal.framework MTLRenderPipeline.h }

{$ifdef TYPES}
type
  MTLRenderPipelineColorAttachmentDescriptorPtr = ^MTLRenderPipelineColorAttachmentDescriptor;
  MTLRenderPipelineReflectionPtr = ^MTLRenderPipelineReflection;
  MTLRenderPipelineDescriptorPtr = ^MTLRenderPipelineDescriptor;
  MTLRenderPipelineColorAttachmentDescriptorArrayPtr = ^MTLRenderPipelineColorAttachmentDescriptorArray;
  MTLRenderPipelineStateProtocolPtr = ^MTLRenderPipelineStateProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLBlendFactor = NSUInteger;
  MTLBlendFactorPtr = ^MTLBlendFactor;

const
  MTLBlendFactorZero = 0;
  MTLBlendFactorOne = 1;
  MTLBlendFactorSourceColor = 2;
  MTLBlendFactorOneMinusSourceColor = 3;
  MTLBlendFactorSourceAlpha = 4;
  MTLBlendFactorOneMinusSourceAlpha = 5;
  MTLBlendFactorDestinationColor = 6;
  MTLBlendFactorOneMinusDestinationColor = 7;
  MTLBlendFactorDestinationAlpha = 8;
  MTLBlendFactorOneMinusDestinationAlpha = 9;
  MTLBlendFactorSourceAlphaSaturated = 10;
  MTLBlendFactorBlendColor = 11;
  MTLBlendFactorOneMinusBlendColor = 12;
  MTLBlendFactorBlendAlpha = 13;
  MTLBlendFactorOneMinusBlendAlpha = 14;
  MTLBlendFactorSource1Color = 15 { available in 10_12, 10_11 };
  MTLBlendFactorOneMinusSource1Color = 16 { available in 10_12, 10_11 };
  MTLBlendFactorSource1Alpha = 17 { available in 10_12, 10_11 };
  MTLBlendFactorOneMinusSource1Alpha = 18 { available in 10_12, 10_11 };

type
  MTLBlendOperation = NSUInteger;
  MTLBlendOperationPtr = ^MTLBlendOperation;

const
  MTLBlendOperationAdd = 0;
  MTLBlendOperationSubtract = 1;
  MTLBlendOperationReverseSubtract = 2;
  MTLBlendOperationMin = 3;
  MTLBlendOperationMax = 4;

type
  MTLColorWriteMask = NSUInteger;
  MTLColorWriteMaskPtr = ^MTLColorWriteMask;

const
  MTLColorWriteMaskNone = 0;
  MTLColorWriteMaskRed = $1 shl 3;
  MTLColorWriteMaskGreen = $1 shl 2;
  MTLColorWriteMaskBlue = $1 shl 1;
  MTLColorWriteMaskAlpha = $1 shl 0;
  MTLColorWriteMaskAll = $f;

type
  MTLPrimitiveTopologyClass = NSUInteger;
  MTLPrimitiveTopologyClassPtr = ^MTLPrimitiveTopologyClass;

const
  MTLPrimitiveTopologyClassUnspecified = 0;
  MTLPrimitiveTopologyClassPoint = 1;
  MTLPrimitiveTopologyClassLine = 2;
  MTLPrimitiveTopologyClassTriangle = 3;

type
  MTLTessellationPartitionMode = NSUInteger;
  MTLTessellationPartitionModePtr = ^MTLTessellationPartitionMode;

const
  MTLTessellationPartitionModePow2 = 0;
  MTLTessellationPartitionModeInteger = 1;
  MTLTessellationPartitionModeFractionalOdd = 2;
  MTLTessellationPartitionModeFractionalEven = 3;

type
  MTLTessellationFactorStepFunction = NSUInteger;
  MTLTessellationFactorStepFunctionPtr = ^MTLTessellationFactorStepFunction;

const
  MTLTessellationFactorStepFunctionConstant = 0;
  MTLTessellationFactorStepFunctionPerPatch = 1;
  MTLTessellationFactorStepFunctionPerInstance = 2;
  MTLTessellationFactorStepFunctionPerPatchAndPerInstance = 3;

type
  MTLTessellationFactorFormat = NSUInteger;
  MTLTessellationFactorFormatPtr = ^MTLTessellationFactorFormat;

const
  MTLTessellationFactorFormatHalf = 0;

type
  MTLTessellationControlPointIndexType = NSUInteger;
  MTLTessellationControlPointIndexTypePtr = ^MTLTessellationControlPointIndexType;

const
  MTLTessellationControlPointIndexTypeNone = 0;
  MTLTessellationControlPointIndexTypeUInt16 = 1;
  MTLTessellationControlPointIndexTypeUInt32 = 2;
{$endif}

{$ifdef CLASSES}

type
  MTLRenderPipelineColorAttachmentDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    procedure setPixelFormat(newValue: MTLPixelFormat); message 'setPixelFormat:';
    function pixelFormat: MTLPixelFormat; message 'pixelFormat';
    procedure setBlendingEnabled(newValue: boolean); message 'setBlendingEnabled:';
    function isBlendingEnabled: boolean; message 'isBlendingEnabled';
    procedure setSourceRGBBlendFactor(newValue: MTLBlendFactor); message 'setSourceRGBBlendFactor:';
    function sourceRGBBlendFactor: MTLBlendFactor; message 'sourceRGBBlendFactor';
    procedure setDestinationRGBBlendFactor(newValue: MTLBlendFactor); message 'setDestinationRGBBlendFactor:';
    function destinationRGBBlendFactor: MTLBlendFactor; message 'destinationRGBBlendFactor';
    procedure setRgbBlendOperation(newValue: MTLBlendOperation); message 'setRgbBlendOperation:';
    function rgbBlendOperation: MTLBlendOperation; message 'rgbBlendOperation';
    procedure setSourceAlphaBlendFactor(newValue: MTLBlendFactor); message 'setSourceAlphaBlendFactor:';
    function sourceAlphaBlendFactor: MTLBlendFactor; message 'sourceAlphaBlendFactor';
    procedure setDestinationAlphaBlendFactor(newValue: MTLBlendFactor); message 'setDestinationAlphaBlendFactor:';
    function destinationAlphaBlendFactor: MTLBlendFactor; message 'destinationAlphaBlendFactor';
    procedure setAlphaBlendOperation(newValue: MTLBlendOperation); message 'setAlphaBlendOperation:';
    function alphaBlendOperation: MTLBlendOperation; message 'alphaBlendOperation';
    procedure setWriteMask(newValue: MTLColorWriteMask); message 'setWriteMask:';
    function writeMask: MTLColorWriteMask; message 'writeMask';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;

type
  MTLRenderPipelineReflection = objcclass external (NSObject)
  public
    function vertexArguments: NSArray{MTLArgument}; message 'vertexArguments';
    function fragmentArguments: NSArray{MTLArgument}; message 'fragmentArguments';
  end;

type
  MTLRenderPipelineDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    procedure setLabel(newValue: NSString); message 'setLabel:';
    function label_: NSString; message 'label';
    procedure setVertexFunction(newValue: MTLFunctionProtocol); message 'setVertexFunction:';
    function vertexFunction: MTLFunctionProtocol; message 'vertexFunction';
    procedure setFragmentFunction(newValue: MTLFunctionProtocol); message 'setFragmentFunction:';
    function fragmentFunction: MTLFunctionProtocol; message 'fragmentFunction';
    procedure setVertexDescriptor(newValue: MTLVertexDescriptor); message 'setVertexDescriptor:';
    function vertexDescriptor: MTLVertexDescriptor; message 'vertexDescriptor';
    procedure setSampleCount(newValue: NSUInteger); message 'setSampleCount:';
    function sampleCount: NSUInteger; message 'sampleCount';
    procedure setRasterSampleCount(newValue: NSUInteger); message 'setRasterSampleCount:';
    function rasterSampleCount: NSUInteger; message 'rasterSampleCount';
    procedure setAlphaToCoverageEnabled(newValue: boolean); message 'setAlphaToCoverageEnabled:';
    function isAlphaToCoverageEnabled: boolean; message 'isAlphaToCoverageEnabled';
    procedure setAlphaToOneEnabled(newValue: boolean); message 'setAlphaToOneEnabled:';
    function isAlphaToOneEnabled: boolean; message 'isAlphaToOneEnabled';
    procedure setRasterizationEnabled(newValue: boolean); message 'setRasterizationEnabled:';
    function isRasterizationEnabled: boolean; message 'isRasterizationEnabled';
    function colorAttachments: MTLRenderPipelineColorAttachmentDescriptorArray; message 'colorAttachments';
    procedure setDepthAttachmentPixelFormat(newValue: MTLPixelFormat); message 'setDepthAttachmentPixelFormat:';
    function depthAttachmentPixelFormat: MTLPixelFormat; message 'depthAttachmentPixelFormat';
    procedure setStencilAttachmentPixelFormat(newValue: MTLPixelFormat); message 'setStencilAttachmentPixelFormat:';
    function stencilAttachmentPixelFormat: MTLPixelFormat; message 'stencilAttachmentPixelFormat';
    procedure setInputPrimitiveTopology(newValue: MTLPrimitiveTopologyClass); message 'setInputPrimitiveTopology:';
    function inputPrimitiveTopology: MTLPrimitiveTopologyClass; message 'inputPrimitiveTopology';
    procedure setTessellationPartitionMode(newValue: MTLTessellationPartitionMode); message 'setTessellationPartitionMode:';
    function tessellationPartitionMode: MTLTessellationPartitionMode; message 'tessellationPartitionMode';
    procedure setMaxTessellationFactor(newValue: NSUInteger); message 'setMaxTessellationFactor:';
    function maxTessellationFactor: NSUInteger; message 'maxTessellationFactor';
    procedure setTessellationFactorScaleEnabled(newValue: boolean); message 'setTessellationFactorScaleEnabled:';
    function isTessellationFactorScaleEnabled: boolean; message 'isTessellationFactorScaleEnabled';
    procedure setTessellationFactorFormat(newValue: MTLTessellationFactorFormat); message 'setTessellationFactorFormat:';
    function tessellationFactorFormat: MTLTessellationFactorFormat; message 'tessellationFactorFormat';
    procedure setTessellationControlPointIndexType(newValue: MTLTessellationControlPointIndexType); message 'setTessellationControlPointIndexType:';
    function tessellationControlPointIndexType: MTLTessellationControlPointIndexType; message 'tessellationControlPointIndexType';
    procedure setTessellationFactorStepFunction(newValue: MTLTessellationFactorStepFunction); message 'setTessellationFactorStepFunction:';
    function tessellationFactorStepFunction: MTLTessellationFactorStepFunction; message 'tessellationFactorStepFunction';
    procedure setTessellationOutputWindingOrder(newValue: MTLWinding); message 'setTessellationOutputWindingOrder:';
    function tessellationOutputWindingOrder: MTLWinding; message 'tessellationOutputWindingOrder';
    function vertexBuffers: MTLPipelineBufferDescriptorArray; message 'vertexBuffers';
    function fragmentBuffers: MTLPipelineBufferDescriptorArray; message 'fragmentBuffers';
    procedure reset; message 'reset';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLRenderPipelineStateProtocol = objcprotocol external name 'MTLRenderPipelineState' (NSObjectProtocol)
    function label_: NSString; message 'label';
    function device: MTLDeviceProtocol; message 'device';
  end;
{$endif}

{$ifdef CLASSES}

type
  MTLRenderPipelineColorAttachmentDescriptorArray = objcclass external (NSObject)
  public
    function objectAtIndexedSubscript (attachmentIndex: NSUInteger): MTLRenderPipelineColorAttachmentDescriptor; message 'objectAtIndexedSubscript:';
    procedure setObject_atIndexedSubscript (attachment: MTLRenderPipelineColorAttachmentDescriptor; attachmentIndex: NSUInteger); message 'setObject:atIndexedSubscript:';
  end;
{$endif}

