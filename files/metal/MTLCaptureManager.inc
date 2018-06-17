{ Parsed from Metal.framework MTLCaptureManager.h }

{$ifdef TYPES}
type
  MTLCaptureManagerPtr = ^MTLCaptureManager;
{$endif}

{$ifdef CLASSES}

type
  MTLCaptureManager = objcclass external (NSObject)
  private
    _isCapturing: boolean;
    _defaultCaptureScope: MTLCaptureScopeProtocol;
  public
    class function sharedCaptureManager: MTLCaptureManager; message 'sharedCaptureManager';
    function init: instancetype; message 'init';
    function newCaptureScopeWithDevice (device: MTLDeviceProtocol): MTLCaptureScopeProtocol; message 'newCaptureScopeWithDevice:';
    function newCaptureScopeWithCommandQueue (commandQueue: MTLCommandQueueProtocol): MTLCaptureScopeProtocol; message 'newCaptureScopeWithCommandQueue:';
    procedure startCaptureWithDevice (device: MTLDeviceProtocol); message 'startCaptureWithDevice:';
    procedure startCaptureWithCommandQueue (commandQueue: MTLCommandQueueProtocol); message 'startCaptureWithCommandQueue:';
    procedure startCaptureWithScope (captureScope: MTLCaptureScopeProtocol); message 'startCaptureWithScope:';
    procedure stopCapture; message 'stopCapture';
    procedure setDefaultCaptureScope(newValue: MTLCaptureScopeProtocol); message 'setDefaultCaptureScope:';
    function defaultCaptureScope: MTLCaptureScopeProtocol; message 'defaultCaptureScope';
    function isCapturing: boolean; message 'isCapturing';
  end;
{$endif}

