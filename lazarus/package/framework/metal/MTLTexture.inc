{ Parsed from Metal.framework MTLTexture.h }

{$ifdef TYPES}
type
  MTLTextureDescriptorPtr = ^MTLTextureDescriptor;
  MTLTextureProtocolPtr = ^MTLTextureProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLTextureType = NSUInteger;
  MTLTextureTypePtr = ^MTLTextureType;

const
  MTLTextureType1D = 0;
  MTLTextureType1DArray = 1;
  MTLTextureType2D = 2;
  MTLTextureType2DArray = 3;
  MTLTextureType2DMultisample = 4;
  MTLTextureTypeCube = 5;
  MTLTextureTypeCubeArray = 6 { available in 10_11 };
  MTLTextureType3D = 7;

type
  MTLTextureUsage = NSUInteger;
  MTLTextureUsagePtr = ^MTLTextureUsage;

const
  MTLTextureUsageUnknown = $0000;
  MTLTextureUsageShaderRead = $0001;
  MTLTextureUsageShaderWrite = $0002;
  MTLTextureUsageRenderTarget = $0004;
  MTLTextureUsagePixelFormatView = $0010;
{$endif}

{$ifdef CLASSES}

type
  MTLTextureDescriptor = objcclass external (NSObject, NSCopyingProtocol)
  public
    class function texture2DDescriptorWithPixelFormat_width_height_mipmapped (pixelFormat: MTLPixelFormat; width: NSUInteger; height: NSUInteger; mipmapped: boolean): MTLTextureDescriptor; message 'texture2DDescriptorWithPixelFormat:width:height:mipmapped:';
    class function textureCubeDescriptorWithPixelFormat_size_mipmapped (pixelFormat: MTLPixelFormat; size: NSUInteger; mipmapped: boolean): MTLTextureDescriptor; message 'textureCubeDescriptorWithPixelFormat:size:mipmapped:';
    procedure setTextureType(newValue: MTLTextureType); message 'setTextureType:';
    function textureType: MTLTextureType; message 'textureType';
    procedure setPixelFormat(newValue: MTLPixelFormat); message 'setPixelFormat:';
    function pixelFormat: MTLPixelFormat; message 'pixelFormat';
    procedure setWidth(newValue: NSUInteger); message 'setWidth:';
    function width: NSUInteger; message 'width';
    procedure setHeight(newValue: NSUInteger); message 'setHeight:';
    function height: NSUInteger; message 'height';
    procedure setDepth(newValue: NSUInteger); message 'setDepth:';
    function depth: NSUInteger; message 'depth';
    procedure setMipmapLevelCount(newValue: NSUInteger); message 'setMipmapLevelCount:';
    function mipmapLevelCount: NSUInteger; message 'mipmapLevelCount';
    procedure setSampleCount(newValue: NSUInteger); message 'setSampleCount:';
    function sampleCount: NSUInteger; message 'sampleCount';
    procedure setArrayLength(newValue: NSUInteger); message 'setArrayLength:';
    function arrayLength: NSUInteger; message 'arrayLength';
    procedure setResourceOptions(newValue: MTLResourceOptions); message 'setResourceOptions:';
    function resourceOptions: MTLResourceOptions; message 'resourceOptions';
    procedure setCpuCacheMode(newValue: MTLCPUCacheMode); message 'setCpuCacheMode:';
    function cpuCacheMode: MTLCPUCacheMode; message 'cpuCacheMode';
    procedure setStorageMode(newValue: MTLStorageMode); message 'setStorageMode:';
    function storageMode: MTLStorageMode; message 'storageMode';
    procedure setUsage(newValue: MTLTextureUsage); message 'setUsage:';
    function usage: MTLTextureUsage; message 'usage';

    { Adopted protocols }
    function copyWithZone (zone: NSZonePtr): id; message 'copyWithZone:';
  end;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLTextureProtocol = objcprotocol external name 'MTLTexture' (MTLResourceProtocol)
    function rootResource: MTLResourceProtocol; message 'rootResource';
    function parentTexture: MTLTextureProtocol; message 'parentTexture';
    function parentRelativeLevel: NSUInteger; message 'parentRelativeLevel';
    function parentRelativeSlice: NSUInteger; message 'parentRelativeSlice';
    function buffer: MTLBufferProtocol; message 'buffer';
    function bufferOffset: NSUInteger; message 'bufferOffset';
    function bufferBytesPerRow: NSUInteger; message 'bufferBytesPerRow';
    function iosurface: IOSurfaceRef; message 'iosurface';
    function iosurfacePlane: NSUInteger; message 'iosurfacePlane';
    function textureType: MTLTextureType; message 'textureType';
    function pixelFormat: MTLPixelFormat; message 'pixelFormat';
    function width: NSUInteger; message 'width';
    function height: NSUInteger; message 'height';
    function depth: NSUInteger; message 'depth';
    function mipmapLevelCount: NSUInteger; message 'mipmapLevelCount';
    function sampleCount: NSUInteger; message 'sampleCount';
    function arrayLength: NSUInteger; message 'arrayLength';
    function usage: MTLTextureUsage; message 'usage';
    function isFramebufferOnly: boolean; message 'isFramebufferOnly';
    procedure getBytes_bytesPerRow_bytesPerImage_fromRegion_mipmapLevel_slice (pixelBytes: pointer; bytesPerRow: NSUInteger; bytesPerImage: NSUInteger; region: MTLRegion; level: NSUInteger; slice: NSUInteger); message 'getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:';
    procedure replaceRegion_mipmapLevel_slice_withBytes_bytesPerRow_bytesPerImage (region: MTLRegion; level: NSUInteger; slice: NSUInteger; pixelBytes: pointer; bytesPerRow: NSUInteger; bytesPerImage: NSUInteger); message 'replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:';
    procedure getBytes_bytesPerRow_fromRegion_mipmapLevel (pixelBytes: pointer; bytesPerRow: NSUInteger; region: MTLRegion; level: NSUInteger); message 'getBytes:bytesPerRow:fromRegion:mipmapLevel:';
    procedure replaceRegion_mipmapLevel_withBytes_bytesPerRow (region: MTLRegion; level: NSUInteger; pixelBytes: pointer; bytesPerRow: NSUInteger); message 'replaceRegion:mipmapLevel:withBytes:bytesPerRow:';
    function newTextureViewWithPixelFormat (pixelFormat_: MTLPixelFormat): MTLTextureProtocol; message 'newTextureViewWithPixelFormat:';
    function newTextureViewWithPixelFormat_textureType_levels_slices (pixelFormat_: MTLPixelFormat; textureType_: MTLTextureType; levelRange: NSRange; sliceRange: NSRange): MTLTextureProtocol; message 'newTextureViewWithPixelFormat:textureType:levels:slices:'; { available in 10_11, 9_0 }
  end;
{$endif}

