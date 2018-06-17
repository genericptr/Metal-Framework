{ Parsed from Metal.framework MTLDrawable.h }

{$ifdef TYPES}
type
  MTLDrawableProtocolPtr = ^MTLDrawableProtocol;
{$endif}

{$ifdef TYPES}
type
  MTLDrawablePresentedHandler = OpaqueCBlock { available in 10_11, 8_0 };
{$endif}

{$ifdef PROTOCOLS}

type
  MTLDrawableProtocol = objcprotocol external name 'MTLDrawable' (NSObjectProtocol)
    procedure present; message 'present';
    procedure presentAtTime (presentationTime: CFTimeInterval); message 'presentAtTime:';
  end;
{$endif}

