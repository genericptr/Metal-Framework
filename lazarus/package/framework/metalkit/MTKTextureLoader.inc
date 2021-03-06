{ Parsed from MetalKit.framework MTKTextureLoader.h }

{$ifdef TYPES}
type
  MTKTextureLoaderPtr = ^MTKTextureLoader;
{$endif}

{$ifdef TYPES}
type
  MTKTextureLoaderError = ^NSString;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTKTextureLoaderErrorDomain: MTKTextureLoaderError { available in 10_11, 9_0 }; cvar; external;
  MTKTextureLoaderErrorKey: MTKTextureLoaderError { available in 10_11, 9_0 }; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTKTextureLoaderOption = ^NSString;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTKTextureLoaderOptionAllocateMipmaps: MTKTextureLoaderOption { available in 10_11, 9_0 }; cvar; external;
  MTKTextureLoaderOptionGenerateMipmaps: MTKTextureLoaderOption { available in 10_12, 10_0 }; cvar; external;
  MTKTextureLoaderOptionSRGB: MTKTextureLoaderOption { available in 10_11, 9_0 }; cvar; external;
  MTKTextureLoaderOptionTextureUsage: MTKTextureLoaderOption { available in 10_11, 9_0 }; cvar; external;
  MTKTextureLoaderOptionTextureCPUCacheMode: MTKTextureLoaderOption { available in 10_11, 9_0 }; cvar; external;
  MTKTextureLoaderOptionTextureStorageMode: MTKTextureLoaderOption { available in 10_12, 10_0 }; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTKTextureLoaderCubeLayout = ^NSString;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTKTextureLoaderOptionCubeLayout: MTKTextureLoaderOption { available in 10_12, 10_0 }; cvar; external;
  MTKTextureLoaderCubeLayoutVertical: MTKTextureLoaderCubeLayout { available in 10_12, 10_0 }; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTKTextureLoaderOrigin = ^NSString;
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
var
  MTKTextureLoaderOptionOrigin: MTKTextureLoaderOption { available in 10_12, 10_0 }; cvar; external;
  MTKTextureLoaderOriginTopLeft: MTKTextureLoaderOrigin { available in 10_12, 10_0 }; cvar; external;
  MTKTextureLoaderOriginBottomLeft: MTKTextureLoaderOrigin { available in 10_12, 10_0 }; cvar; external;
  MTKTextureLoaderOriginFlippedVertically: MTKTextureLoaderOrigin { available in 10_12, 10_0 }; cvar; external;
{$endif}

{$ifdef TYPES}
type
  MTKTextureLoaderCallback = OpaqueCBlock;
  MTKTextureLoaderArrayCallback = OpaqueCBlock;
{$endif}

{$ifdef CLASSES}

type
  MTKTextureLoader = objcclass external (NSObject)
  public
    function device: MTLDeviceProtocol; message 'device';
    function init: instancetype; message 'init';
    function initWithDevice (device_: MTLDeviceProtocol): instancetype; message 'initWithDevice:';
    procedure newTextureWithContentsOfURL_options_completionHandler (URL: NSURL; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithContentsOfURL:options:completionHandler:';
    procedure newTextureWithName_scaleFactor_bundle_options_completionHandler (name: NSString; scaleFactor: CGFloat; bundle: NSBundle; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithName:scaleFactor:bundle:options:completionHandler:'; { available in 10_12, 10_0 }
    procedure newTextureWithName_scaleFactor_displayGamut_bundle_options_completionHandler (name: NSString; scaleFactor: CGFloat; displayGamut: NSDisplayGamut; bundle: NSBundle; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithName:scaleFactor:displayGamut:bundle:options:completionHandler:'; { available in 10_12 }
    procedure newTexturesWithContentsOfURLs_options_completionHandler (URLs: NSArray{NSURL}; options: NSDictionary; completionHandler: MTKTextureLoaderArrayCallback); message 'newTexturesWithContentsOfURLs:options:completionHandler:'; { available in 10_12, 10_0 }
    procedure newTexturesWithNames_scaleFactor_bundle_options_completionHandler (names: NSArray{NSString}; scaleFactor: CGFloat; bundle: NSBundle; options: NSDictionary; completionHandler: MTKTextureLoaderArrayCallback); message 'newTexturesWithNames:scaleFactor:bundle:options:completionHandler:'; { available in 10_12, 10_0 }
    procedure newTexturesWithNames_scaleFactor_displayGamut_bundle_options_completionHandler (names: NSArray{NSString}; scaleFactor: CGFloat; displayGamut: NSDisplayGamut; bundle: NSBundle; options: NSDictionary; completionHandler: MTKTextureLoaderArrayCallback); message 'newTexturesWithNames:scaleFactor:displayGamut:bundle:options:completionHandler:'; { available in 10_12 }
    procedure newTextureWithData_options_completionHandler (data: NSData; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithData:options:completionHandler:';
    procedure newTextureWithCGImage_options_completionHandler (cgImage: CGImageRef; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithCGImage:options:completionHandler:';
    procedure newTextureWithMDLTexture_options_completionHandler (texture: MDLTexture; options: NSDictionary; completionHandler: MTKTextureLoaderCallback); message 'newTextureWithMDLTexture:options:completionHandler:'; { available in 10_12, 10_0 }
    function newTextureWithContentsOfURL_options_error (URL: NSURL; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithContentsOfURL:options:error:';
    function newTexturesWithContentsOfURLs_options_error (URLs: NSArray{NSURL}; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTexturesWithContentsOfURLs:options:error:'; { available in 10_12, 10_0 }
    function newTextureWithData_options_error (data: NSData; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithData:options:error:';
    function newTextureWithCGImage_options_error (cgImage: CGImageRef; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithCGImage:options:error:';
    function newTextureWithMDLTexture_options_error (texture: MDLTexture; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithMDLTexture:options:error:'; { available in 10_12, 10_0 }
    function newTextureWithName_scaleFactor_bundle_options_error (name: NSString; scaleFactor: CGFloat; bundle: NSBundle; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithName:scaleFactor:bundle:options:error:'; { available in 10_12, 10_0 }
    function newTextureWithName_scaleFactor_displayGamut_bundle_options_error (name: NSString; scaleFactor: CGFloat; displayGamut: NSDisplayGamut; bundle: NSBundle; options: NSDictionary; error: NSErrorPtr): MTLTextureProtocol; message 'newTextureWithName:scaleFactor:displayGamut:bundle:options:error:'; { available in 10_12 }
  end;
{$endif}

