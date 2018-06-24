{ Parsed from Metal.framework MTLParallelRenderCommandEncoder.h }

{$ifdef TYPES}
type
  MTLParallelRenderCommandEncoderProtocolPtr = ^MTLParallelRenderCommandEncoderProtocol;
{$endif}

{$ifdef PROTOCOLS}

type
  MTLParallelRenderCommandEncoderProtocol = objcprotocol external name 'MTLParallelRenderCommandEncoder' (MTLCommandEncoderProtocol)
    function renderCommandEncoder: MTLRenderCommandEncoderProtocol; message 'renderCommandEncoder';
    procedure setColorStoreAction_atIndex (storeAction: MTLStoreAction; colorAttachmentIndex: NSUInteger); message 'setColorStoreAction:atIndex:'; { available in 10_12, 10_0 }
    procedure setDepthStoreAction (storeAction: MTLStoreAction); message 'setDepthStoreAction:'; { available in 10_12, 10_0 }
    procedure setStencilStoreAction (storeAction: MTLStoreAction); message 'setStencilStoreAction:'; { available in 10_12, 10_0 }
    procedure setColorStoreActionOptions_atIndex (storeActionOptions: MTLStoreActionOptions; colorAttachmentIndex: NSUInteger); message 'setColorStoreActionOptions:atIndex:'; { available in 10_13, 11_0 }
    procedure setDepthStoreActionOptions (storeActionOptions: MTLStoreActionOptions); message 'setDepthStoreActionOptions:'; { available in 10_13, 11_0 }
    procedure setStencilStoreActionOptions (storeActionOptions: MTLStoreActionOptions); message 'setStencilStoreActionOptions:'; { available in 10_13, 11_0 }
  end;
{$endif}

