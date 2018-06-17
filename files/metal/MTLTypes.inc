{ Parsed from Metal.framework MTLTypes.h }
{$ifdef TYPES}
type
  MTLOrigin = record
    x, y, z: NSUInteger;
  end;
type
  MTLOriginPtr = ^MTLOrigin;
type
  MTLSize = record
    width, height, depth: NSUInteger;
  end;
type
  MTLSizePtr = ^MTLSize;
type
  MTLRegion = record
    origin: MTLOrigin;
    size: MTLSize;
  end;
type
  MTLRegionPtr = ^MTLRegion;
type
  MTLSamplePosition = record
    x, y: single;
  end;
type
  MTLSamplePositionPtr = ^MTLSamplePosition;
{$endif}

