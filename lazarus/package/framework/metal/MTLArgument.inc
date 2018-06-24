{ Parsed from Metal.framework MTLArgument.h }

{$ifdef TYPES}
type
  MTLTypePtr = ^MTLType;
  MTLStructMemberPtr = ^MTLStructMember;
  MTLStructTypePtr = ^MTLStructType;
  MTLArrayTypePtr = ^MTLArrayType;
  MTLPointerTypePtr = ^MTLPointerType;
  MTLTextureReferenceTypePtr = ^MTLTextureReferenceType;
  MTLArgumentPtr = ^MTLArgument;
{$endif}

{$ifdef TYPES}
type
  MTLDataType = NSUInteger;
  MTLDataTypePtr = ^MTLDataType;

const
  MTLDataTypeNone = 0;
  MTLDataTypeStruct = 1;
  MTLDataTypeArray = 2;
  MTLDataTypeFloat = 3;
  MTLDataTypeFloat2 = 4;
  MTLDataTypeFloat3 = 5;
  MTLDataTypeFloat4 = 6;
  MTLDataTypeFloat2x2 = 7;
  MTLDataTypeFloat2x3 = 8;
  MTLDataTypeFloat2x4 = 9;
  MTLDataTypeFloat3x2 = 10;
  MTLDataTypeFloat3x3 = 11;
  MTLDataTypeFloat3x4 = 12;
  MTLDataTypeFloat4x2 = 13;
  MTLDataTypeFloat4x3 = 14;
  MTLDataTypeFloat4x4 = 15;
  MTLDataTypeHalf = 16;
  MTLDataTypeHalf2 = 17;
  MTLDataTypeHalf3 = 18;
  MTLDataTypeHalf4 = 19;
  MTLDataTypeHalf2x2 = 20;
  MTLDataTypeHalf2x3 = 21;
  MTLDataTypeHalf2x4 = 22;
  MTLDataTypeHalf3x2 = 23;
  MTLDataTypeHalf3x3 = 24;
  MTLDataTypeHalf3x4 = 25;
  MTLDataTypeHalf4x2 = 26;
  MTLDataTypeHalf4x3 = 27;
  MTLDataTypeHalf4x4 = 28;
  MTLDataTypeInt = 29;
  MTLDataTypeInt2 = 30;
  MTLDataTypeInt3 = 31;
  MTLDataTypeInt4 = 32;
  MTLDataTypeUInt = 33;
  MTLDataTypeUInt2 = 34;
  MTLDataTypeUInt3 = 35;
  MTLDataTypeUInt4 = 36;
  MTLDataTypeShort = 37;
  MTLDataTypeShort2 = 38;
  MTLDataTypeShort3 = 39;
  MTLDataTypeShort4 = 40;
  MTLDataTypeUShort = 41;
  MTLDataTypeUShort2 = 42;
  MTLDataTypeUShort3 = 43;
  MTLDataTypeUShort4 = 44;
  MTLDataTypeChar = 45;
  MTLDataTypeChar2 = 46;
  MTLDataTypeChar3 = 47;
  MTLDataTypeChar4 = 48;
  MTLDataTypeUChar = 49;
  MTLDataTypeUChar2 = 50;
  MTLDataTypeUChar3 = 51;
  MTLDataTypeUChar4 = 52;
  MTLDataTypeBool = 53;
  MTLDataTypeBool2 = 54;
  MTLDataTypeBool3 = 55;
  MTLDataTypeBool4 = 56;
  MTLDataTypeTexture = 58 { available in 10_13, 11_0 };
  MTLDataTypeSampler = 59 { available in 10_13, 11_0 };
  MTLDataTypePointer = 60 { available in 10_13, 11_0 };

type
  MTLArgumentType = NSUInteger;
  MTLArgumentTypePtr = ^MTLArgumentType;

const
  MTLArgumentTypeBuffer = 0;
  MTLArgumentTypeThreadgroupMemory = 1;
  MTLArgumentTypeTexture = 2;
  MTLArgumentTypeSampler = 3;

type
  MTLArgumentAccess = NSUInteger;
  MTLArgumentAccessPtr = ^MTLArgumentAccess;

const
  MTLArgumentAccessReadOnly = 0;
  MTLArgumentAccessReadWrite = 1;
  MTLArgumentAccessWriteOnly = 2;
{$endif}

{$ifdef CLASSES}

type
  MTLType = objcclass external (NSObject)
  public
    function dataType: MTLDataType; message 'dataType';
  end;

type
  MTLStructMember = objcclass external (NSObject)
  public
    function name: NSString; message 'name';
    function offset: NSUInteger; message 'offset';
    function dataType: MTLDataType; message 'dataType';
    function structType: MTLStructType; message 'structType';
    function arrayType: MTLArrayType; message 'arrayType';
    function textureReferenceType: MTLTextureReferenceType; message 'textureReferenceType'; { available in 10_13, 11_0 }
    function pointerType: MTLPointerType; message 'pointerType'; { available in 10_13, 11_0 }
    function argumentIndex: NSUInteger; message 'argumentIndex';
  end;

type
  MTLStructType = objcclass external (MTLType)
  public
    function members: NSArray {MTLStructMember}; message 'members';
    function memberByName (name: NSString): MTLStructMember; message 'memberByName:';
  end;

type
  MTLArrayType = objcclass external (MTLType)
  public
    function elementType: MTLDataType; message 'elementType';
    function arrayLength: NSUInteger; message 'arrayLength';
    function stride: NSUInteger; message 'stride';
    function argumentIndexStride: NSUInteger; message 'argumentIndexStride';
    function elementStructType: MTLStructType; message 'elementStructType';
    function elementArrayType: MTLArrayType; message 'elementArrayType';
    function elementTextureReferenceType: MTLTextureReferenceType; message 'elementTextureReferenceType'; { available in 10_13, 11_0 }
    function elementPointerType: MTLPointerType; message 'elementPointerType'; { available in 10_13, 11_0 }
  end;

type
  MTLPointerType = objcclass external (MTLType)
  public
    function elementType: MTLDataType; message 'elementType';
    function access: MTLArgumentAccess; message 'access';
    function alignment: NSUInteger; message 'alignment';
    function dataSize: NSUInteger; message 'dataSize';
    function elementIsArgumentBuffer: boolean; message 'elementIsArgumentBuffer';
    function elementStructType: MTLStructType; message 'elementStructType'; { available in 10_13, 11_0 }
    function elementArrayType: MTLArrayType; message 'elementArrayType'; { available in 10_13, 11_0 }
  end;

type
  MTLTextureReferenceType = objcclass external (MTLType)
  public
    function textureDataType: MTLDataType; message 'textureDataType';
    function textureType: MTLTextureType; message 'textureType';
    function access: MTLArgumentAccess; message 'access';
    function isDepthTexture: boolean; message 'isDepthTexture';
  end;

type
  MTLArgument = objcclass external (NSObject)
  public
    function name: NSString; message 'name';
    function type_: MTLArgumentType; message 'type';
    function access: MTLArgumentAccess; message 'access';
    function index: NSUInteger; message 'index';
    function isActive: boolean; message 'isActive';
    function bufferAlignment: NSUInteger; message 'bufferAlignment';
    function bufferDataSize: NSUInteger; message 'bufferDataSize';
    function bufferDataType: MTLDataType; message 'bufferDataType';
    function bufferStructType: MTLStructType; message 'bufferStructType';
    function bufferPointerType: MTLPointerType; message 'bufferPointerType';
    function threadgroupMemoryAlignment: NSUInteger; message 'threadgroupMemoryAlignment';
    function threadgroupMemoryDataSize: NSUInteger; message 'threadgroupMemoryDataSize';
    function textureType: MTLTextureType; message 'textureType';
    function textureDataType: MTLDataType; message 'textureDataType';
    function isDepthTexture: boolean; message 'isDepthTexture';
    function arrayLength: NSUInteger; message 'arrayLength';
  end;
{$endif}

