{$mode objfpc}
{$modeswitch advancedrecords}

unit SIMDTypes;
interface
uses
	CTypes, SysUtils;

{$packrecords c}
// #include <simd/simd.h>
// https://www.freepascal.org/docs-html/rtl/ctypes/index-8.html

type
	simd_float = cfloat;

{*! @abstract A vector of two 32-bit floating-point numbers.
 *  @description In C++ and Metal, this type is also available as
 *  simd::float2. The alignment of this type is greater than the alignment
 *  of float; if you need to operate on data buffers that may not be
 *  suitably aligned, you should access them using simd_packed_float2
 *  instead.                                                                  *}
//typedef __attribute__((__ext_vector_type__(2))) float simd_float2;

type
	vector_float2 = record
		x, y: simd_float;

		class operator + (left, right: vector_float2): vector_float2; overload;
	end;

{*! @abstract A vector of four 32-bit floating-point numbers.
 *  @description In C++ and Metal, this type is also available as
 *  simd::float4. The alignment of this type is greater than the alignment
 *  of float; if you need to operate on data buffers that may not be
 *  suitably aligned, you should access them using simd_packed_float4
 *  instead.                                                                  *}
//typedef __attribute__((__ext_vector_type__(4))) float simd_float4;
type
	vector_float4 = record
		x, y, z, w: simd_float;
		//case byte of
		//	0: (r, g, b, a: simd_float);
	end;

{*! @abstract A vector of two 32-bit unsigned integers.
 *  @description This type is deprecated; you should use simd_uint2 or
 *  simd::uint2 instead.                                                      *}
//typedef simd_uint2 vector_uint2;
//typedef __attribute__((__ext_vector_type__(2))) unsigned int simd_uint2;
type
	vector_uint2 = record
		x, y: cuint;
	end;

function V2(x, y: simd_float): vector_float2;
function V4(x, y, z, w: simd_float): vector_float4;

implementation

function V2(x, y: simd_float): vector_float2;
begin
	result.x := x;
	result.y := y;
end;

class operator vector_float2.+ (left, right: vector_float2): vector_float2;
begin
	result := V2(left.x + right.x, left.y + right.y);
end;

function V4(x, y, z, w: simd_float): vector_float4;
begin
	result.x := x;
	result.y := y;
	result.z := z;
	result.w := w;
end;

end.