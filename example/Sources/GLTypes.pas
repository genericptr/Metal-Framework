{$mode objfpc}
{$modeswitch advancedrecords}

unit GLTypes;
interface
uses
	SIMDTypes, Math, SysUtils;

type
	TScalar = simd_float;

type
	TVec2 = record
		public
			x, y: TScalar;
		public
			function Magnitude: TScalar; inline;
			procedure Show;
			function Str: string;
			
			class operator + (p1, p2: TVec2): TVec2; overload;
			class operator - (p1, p2: TVec2): TVec2; overload; 
			class operator * (p1, p2: TVec2): TVec2; overload; 
			class operator / (p1, p2: TVec2): TVec2;  overload;
			class operator = (p1, p2: TVec2): boolean; 
			class operator + (p1: TVec2; p2: TScalar): TVec2; overload; 
			class operator - (p1: TVec2; p2: TScalar): TVec2; overload; 
			class operator * (p1: TVec2; p2: TScalar): TVec2; overload; 
			class operator / (p1: TVec2; p2: TScalar): TVec2; overload;
	end;

type
	TVec3 = record
		public
			class function Make (_x,_y,_z: TScalar): TVec3; static; inline;
			class function Up: TVec3; static; inline;
			
			function Normalize:TVec3;
			function Cross(const b:TVec3):TVec3;
			procedure Show;
			function Str: string;
			function XY: TVec2;

		public
			class operator + (p1, p2: TVec3): TVec3; overload;
			class operator - (p1, p2: TVec3): TVec3; overload; 
			class operator * (p1, p2: TVec3): TVec3; overload; 
			class operator / (p1, p2: TVec3): TVec3; overload;
			class operator = (p1, p2: TVec3): boolean; 
			class operator + (p1: TVec3; p2: TScalar): TVec3; overload; 
			class operator - (p1: TVec3; p2: TScalar): TVec3; overload; 
			class operator * (p1: TVec3; p2: TScalar): TVec3; overload; 
			class operator / (p1: TVec3; p2: TScalar): TVec3; overload;
		public
			case integer of
				0:
					(x, y, z: TScalar);
				1:
					(r, g, b: TScalar);
	end;

type
	TVec4 = record
		private
			function GetComponent(const pIndex:integer):TScalar; inline;
      procedure SetComponent(const pIndex:integer;const pValue:TScalar); inline;
		public
			property Components[const pIndex:integer]:TScalar read GetComponent write SetComponent; default;
		public
			case integer of
				0:(RawComponents:array[0..3] of TScalar);
				1: (x, y, z, w: TScalar);
				2: (r, g, b, a: TScalar);
	end;

type
	TMat4 = record
		public
			function Ptr: pointer;
			class function Identity: TMat4; static; inline;
						
			constructor Translate(const tx,ty,tz:TScalar); overload;
      constructor Translate(const pTranslate:TVec3); overload;
      constructor Translate(const tx,ty,tz,tw:TScalar); overload;
      
			constructor Scale (x, y, z: TScalar);
			constructor RotateX(const Angle:TScalar);
      constructor RotateY(const Angle:TScalar);
      constructor RotateZ(const Angle:TScalar);
      constructor Rotate(const Angle:TScalar;const Axis:TVec3); overload;
      constructor Rotate(const pMatrix:TMat4); overload;
			constructor Ortho (const Left,Right,Bottom,Top,zNear,zFar:TScalar);
			constructor Perspective (const fovy,Aspect,zNear,zFar:TScalar);
			constructor LookAt (const Eye,Center,Up:TVec3);
			
			function Inverse:TMat4; inline;
      function Transpose:TMat4; inline;
     
 			procedure Show;

		public
			class operator := (const a:TScalar):TMat4; inline;
      class operator = (const a,b:TMat4):boolean; inline;
      class operator <> (const a,b:TMat4):boolean; inline;
      class operator + (const a,b:TMat4):TMat4; inline;
      class operator + (const a:TMat4;const b:TScalar):TMat4; inline;
      class operator + (const a:TScalar;const b:TMat4):TMat4; inline;
      class operator - (const a,b:TMat4):TMat4; inline;
      class operator - (const a:TMat4;const b:TScalar):TMat4; inline;
      class operator - (const a:TScalar;const b:TMat4): TMat4; inline;
      class operator * (const b,a:TMat4):TMat4; inline;
      class operator * (const a:TMat4;const b:TScalar):TMat4; inline;
      class operator * (const a:TScalar;const b:TMat4):TMat4; inline;
      class operator * (const a:TMat4;const b:TVec3):TVec3; inline;
      class operator * (const a:TVec3;const b:TMat4):TVec3; inline;
      class operator * (const a:TMat4;const b:TVec4):TVec4; inline;
      class operator * (const a:TVec4;const b:TMat4):TVec4; inline;
      class operator / (const a,b:TMat4):TMat4; inline;
      class operator / (const a:TMat4;const b:TScalar):TMat4; inline;
      class operator / (const a:TScalar;const b:TMat4):TMat4; inline;
		public
			case integer of
				0:(RawComponents:array[0..3,0..3] of TScalar);
				1:(v: array[0..3] of TVec4);
				2:(Right,Up,Forwards,Offset:TVec4);
				3:(Tangent,Bitangent,Normal,Translation:TVec4);
	end;
var
	Matrix4x4Identity:TMat4=(RawComponents:((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0,1.0)));

type
	TMat3 = record
		public
			constructor Create (const mat: TMat4);
			
			class operator *(const a:TMat3;const b:TScalar):TMat3; inline;
			class operator *(const a:TMat3;const b:TVec3):TVec3; inline;
		public
			case integer of
				0:(RawComponents:array[0..2,0..2] of TScalar);
				1:(v: array[0..3] of TVec3);
				2:(m00,m01,m02,m10,m11,m12,m20,m21,m22:TScalar);
				3:(Tangent,Bitangent,Normal:TVec3);
				4:(Right,Up,Forwards:TVec3);
	end;


function Vec2 (x, y: TScalar): TVec2;
function V2 (x, y: TScalar): TVec2;

function Vec3 (x, y, z: TScalar): TVec3;
function V3 (x, y, z: TScalar): TVec3;

implementation
	
const
	DEG2RAD=pi/180.0;
  RAD2DEG=180.0/pi;
  HalfPI=pi*0.5;	
	
function Vec2 (x, y: TScalar): TVec2; inline;
begin
	result.x := x;
	result.y := y;
end;

function V2 (x, y: TScalar): TVec2; inline;
begin
	result := Vec2(x, y);
end;

function TVec2.Magnitude: TScalar;
begin
	result := Sqrt(Power(x, 2) + Power(y, 2));
end;

procedure TVec2.Show;
begin
	writeln(Str);
end;

function TVec2.Str: string;
begin
	result := FloatToStr(x)+','+FloatToStr(y);
end;

class operator TVec2.+ (p1, p2: TVec2): TVec2;
begin
	result := Vec2(p1.x+p2.x, p1.y+p2.y);
end;

class operator TVec2.- (p1, p2: TVec2): TVec2;
begin
	result := Vec2(p1.x-p2.x, p1.y-p2.y);
end;

class operator TVec2.* (p1, p2: TVec2): TVec2; 
begin
	result := Vec2(p1.x*p2.x, p1.y*p2.y);
end;

class operator TVec2./ (p1, p2: TVec2): TVec2; 
begin
	result := Vec2(p1.x/p2.x, p1.y/p2.y);
end;

class operator TVec2.= (p1, p2: TVec2): boolean; 
begin
	result := (p1.x = p2.x) and (p1.y = p2.y);
end;

class operator TVec2.+ (p1: TVec2; p2: TScalar): TVec2;
begin
	result := Vec2(p1.x+p2, p1.y+p2);
end;

class operator TVec2.- (p1: TVec2; p2: TScalar): TVec2;
begin
	result := Vec2(p1.x-p2, p1.y-p2);
end;

class operator TVec2.* (p1: TVec2; p2: TScalar): TVec2;
begin
	result := Vec2(p1.x*p2, p1.y*p2);
end;

class operator TVec2./ (p1: TVec2; p2: TScalar): TVec2;
begin
	result := Vec2(p1.x/p2, p1.y/p2);
end;

class function TVec3.Up: TVec3;
begin
	result := Vec3(0,1,0);
end;

class function TVec3.Make (_x,_y,_z: TScalar): TVec3;
begin
	result.x := _x;
	result.y := _y;
	result.z := _z;
end;

function Vec3 (x, y, z: TScalar): TVec3; inline;
begin
	result.x := x;
	result.y := y;
	result.z := z;
end;

function V3 (x, y, z: TScalar): TVec3; inline;
begin
	result := Vec3(x, y, z);
end;

procedure TVec3.Show;
begin
	writeln(Str);
end;

function TVec3.XY: TVec2;
begin
	result := V2(x, y);
end;

function TVec3.Str: string;
begin
	result := FloatToStr(x)+','+FloatToStr(y)+','+FloatToStr(z);
end;

function TVec3.Normalize:TVec3;
var
	Factor:TScalar;
begin
 Factor:=sqrt(sqr(x)+sqr(y)+sqr(z));
 if Factor<>0.0 then begin
  Factor:=1.0/Factor;
  result.x:=x*Factor;
  result.y:=y*Factor;
  result.z:=z*Factor;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function TVec3.Cross(const b:TVec3):TVec3;
begin
 result.x:=(y*b.z)-(z*b.y);
 result.y:=(z*b.x)-(x*b.z);
 result.z:=(x*b.y)-(y*b.x);
end;

class operator TVec3.+ (p1, p2: TVec3): TVec3;
begin
	result := Vec3(p1.x+p2.x, p1.y+p2.y, p1.z+p2.z);
end;

class operator TVec3.- (p1, p2: TVec3): TVec3;
begin
	result := Vec3(p1.x-p2.x, p1.y-p2.y, p1.z-p2.z);
end;

class operator TVec3.* (p1, p2: TVec3): TVec3; 
begin
	result := Vec3(p1.x*p2.x, p1.y*p2.y, p1.z*p2.z);
end;

class operator TVec3./ (p1, p2: TVec3): TVec3; 
begin
	result := Vec3(p1.x/p2.x, p1.y/p2.y, p1.z/p2.z);
end;

class operator TVec3.= (p1, p2: TVec3): boolean; 
begin
	result := (p1.x = p2.x) and (p1.y = p2.y) and (p1.z = p2.z);
end;

class operator TVec3.+ (p1: TVec3; p2: TScalar): TVec3;
begin
	result := Vec3(p1.x+p2, p1.y+p2, p1.z+p2);
end;

class operator TVec3.- (p1: TVec3; p2: TScalar): TVec3;
begin
	result := Vec3(p1.x-p2, p1.y-p2, p1.z-p2);
end;

class operator TVec3.* (p1: TVec3; p2: TScalar): TVec3;
begin
	result := Vec3(p1.x*p2, p1.y*p2, p1.z*p2);
end;

class operator TVec3./ (p1: TVec3; p2: TScalar): TVec3;
begin
	result := Vec3(p1.x/p2, p1.y/p2, p1.z/p2);
end;

constructor TMat3.Create (const mat: TMat4);
begin
	RawComponents[0][0] := mat.RawComponents[0][0];
	RawComponents[1][0] := mat.RawComponents[1][0];
	RawComponents[2][0] := mat.RawComponents[2][0];

	RawComponents[0][1] := mat.RawComponents[0][1];
	RawComponents[1][1] := mat.RawComponents[1][1];
	RawComponents[2][1] := mat.RawComponents[2][1];	
	
	RawComponents[0][2] := mat.RawComponents[0][2];
	RawComponents[1][2] := mat.RawComponents[1][2];
	RawComponents[2][2] := mat.RawComponents[2][2];	
end;

class operator TMat3.*(const a:TMat3;const b:TScalar):TMat3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]*b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]*b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]*b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]*b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]*b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]*b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]*b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]*b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]*b;
end;

class operator TMat3.*(const a:TMat3;const b:TVec3):TVec3;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z);
end;

function TVec4.GetComponent(const pIndex:integer):TScalar;
begin
 result:=RawComponents[pIndex];
end;

procedure TVec4.SetComponent(const pIndex:integer;const pValue:TScalar);
begin
 RawComponents[pIndex]:=pValue;
end;

function SameValue (a, b: TScalar): boolean; inline;
begin
	result := a = b;
end;

function TMat4.Ptr: pointer;
begin
	result := @v[0];
end;

class function TMat4.Identity: TMat4;
begin
	result := Matrix4x4Identity;
end;

constructor TMat4.Translate(const tx,ty,tz:TScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=tx;
 RawComponents[3,1]:=ty;
 RawComponents[3,2]:=tz;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Translate(const pTranslate:TVec3);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=pTranslate.x;
 RawComponents[3,1]:=pTranslate.y;
 RawComponents[3,2]:=pTranslate.z;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Translate(const tx,ty,tz,tw:TScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=tx;
 RawComponents[3,1]:=ty;
 RawComponents[3,2]:=tz;
 RawComponents[3,3]:=tw;
end;

constructor TMat4.Scale (x, y, z: TScalar);
begin	
	v[0].x := x;
	v[0].y := 0;
	v[0].z := 0;
	v[0].w := 0;
          
	v[1].x := 0;
	v[1].y := y;
	v[1].z := 0;
	v[1].w := 0;
 
	v[2].x := 0;
	v[2].y := 0;
	v[2].z := z;
	v[2].w := 0;
	        
	v[3].x := 0;
	v[3].y := 0;
	v[3].z := 0;
	v[3].w := 1;
end;

constructor TMat4.RotateX(const Angle:TScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 SinCos(Angle,RawComponents[1,2],RawComponents[1,1]);
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=-RawComponents[1,2];
 RawComponents[2,2]:=RawComponents[1,1];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.RotateY(const Angle:TScalar);
begin
 SinCos(Angle,RawComponents[2,0],RawComponents[0,0]);
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=-RawComponents[2,0];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=RawComponents[0,0];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.RotateZ(const Angle:TScalar);
begin
 SinCos(Angle,RawComponents[0,1],RawComponents[0,0]);
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=-RawComponents[0,1];
 RawComponents[1,1]:=RawComponents[0,0];
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Rotate(const Angle:TScalar;const Axis:TVec3);
var SinusAngle,CosinusAngle:TScalar;
begin
 SinCos(Angle,SinusAngle,CosinusAngle);
 RawComponents[0,0]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.x));
 RawComponents[1,0]:=((1.0-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 RawComponents[2,0]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 RawComponents[0,3]:=0.0;
 RawComponents[0,1]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 RawComponents[1,1]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.y));
 RawComponents[2,1]:=((1.0-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 RawComponents[1,3]:=0.0;
 RawComponents[0,2]:=((1.0-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 RawComponents[1,2]:=((1.0-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 RawComponents[2,2]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.z));
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Rotate(const pMatrix:TMat4);
begin
 RawComponents[0,0]:=pMatrix.RawComponents[0,0];
 RawComponents[0,1]:=pMatrix.RawComponents[0,1];
 RawComponents[0,2]:=pMatrix.RawComponents[0,2];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=pMatrix.RawComponents[1,0];
 RawComponents[1,1]:=pMatrix.RawComponents[1,1];
 RawComponents[1,2]:=pMatrix.RawComponents[1,2];
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=pMatrix.RawComponents[2,0];
 RawComponents[2,1]:=pMatrix.RawComponents[2,1];
 RawComponents[2,2]:=pMatrix.RawComponents[2,2];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Ortho(const Left,Right,Bottom,Top,zNear,zFar:TScalar);
var rml,tmb,fmn:TScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=(-2.0)/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-(zFar+zNear))/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TMat4.Perspective(const fovy,Aspect,zNear,zFar:TScalar);
var Sine,Cotangent,ZDelta,Radians:TScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=Matrix4x4Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-(zFar+zNear))/ZDelta;
  RawComponents[2,3]:=-1-0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/ZDelta;
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TMat4.LookAt(const Eye,Center,Up:TVec3);
var RightVector,UpVector,ForwardVector:TVec3;
begin
 ForwardVector:=(Eye-Center).Normalize;
 RightVector:=(Up.Cross(ForwardVector)).Normalize;
 UpVector:=(ForwardVector.Cross(RightVector)).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[1,0]:=RightVector.y;
 RawComponents[2,0]:=RightVector.z;
 RawComponents[3,0]:=-((RightVector.x*Eye.x)+(RightVector.y*Eye.y)+(RightVector.z*Eye.z));
 RawComponents[0,1]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[2,1]:=UpVector.z;
 RawComponents[3,1]:=-((UpVector.x*Eye.x)+(UpVector.y*Eye.y)+(UpVector.z*Eye.z));
 RawComponents[0,2]:=ForwardVector.x;
 RawComponents[1,2]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
 RawComponents[3,2]:=-((ForwardVector.x*Eye.x)+(ForwardVector.y*Eye.y)+(ForwardVector.z*Eye.z));
 RawComponents[0,3]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,3]:=1.0;
end;

function TMat4.Inverse:TMat4;
var
	t0,t4,t8,t12,d:TScalar;
begin
 t0:=(((RawComponents[1,1]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[1,1]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,1]*RawComponents[1,2]*RawComponents[3,3])+(RawComponents[2,1]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[1,2]*RawComponents[2,3]))-(RawComponents[3,1]*RawComponents[1,3]*RawComponents[2,2]);
 t4:=((((-(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,2]);
 t8:=((((RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,3])-(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,3]))+(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,1]);
 t12:=((((-(RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,2]))+(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,2]))+(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,1]);
 d:=(RawComponents[0,0]*t0)+(RawComponents[0,1]*t4)+(RawComponents[0,2]*t8)+(RawComponents[0,3]*t12);
 if d<>0.0 then begin
  d:=1.0/d;
  result.RawComponents[0,0]:=t0*d;
  result.RawComponents[0,1]:=(((((-(RawComponents[0,1]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[0,1]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,1]*RawComponents[0,2]*RawComponents[3,3]))-(RawComponents[2,1]*RawComponents[0,3]*RawComponents[3,2]))-(RawComponents[3,1]*RawComponents[0,2]*RawComponents[2,3]))+(RawComponents[3,1]*RawComponents[0,3]*RawComponents[2,2]))*d;
  result.RawComponents[0,2]:=(((((RawComponents[0,1]*RawComponents[1,2]*RawComponents[3,3])-(RawComponents[0,1]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[1,1]*RawComponents[0,2]*RawComponents[3,3]))+(RawComponents[1,1]*RawComponents[0,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[0,2]*RawComponents[1,3]))-(RawComponents[3,1]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[0,3]:=(((((-(RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[0,1]*RawComponents[1,3]*RawComponents[2,2])+(RawComponents[1,1]*RawComponents[0,2]*RawComponents[2,3]))-(RawComponents[1,1]*RawComponents[0,3]*RawComponents[2,2]))-(RawComponents[2,1]*RawComponents[0,2]*RawComponents[1,3]))+(RawComponents[2,1]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[1,0]:=t4*d;
  result.RawComponents[1,1]:=((((RawComponents[0,0]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[0,0]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[0,2]*RawComponents[3,3])+(RawComponents[2,0]*RawComponents[0,3]*RawComponents[3,2])+(RawComponents[3,0]*RawComponents[0,2]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[0,3]*RawComponents[2,2]))*d;
  result.RawComponents[1,2]:=(((((-(RawComponents[0,0]*RawComponents[1,2]*RawComponents[3,3]))+(RawComponents[0,0]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[1,0]*RawComponents[0,2]*RawComponents[3,3]))-(RawComponents[1,0]*RawComponents[0,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[0,2]*RawComponents[1,3]))+(RawComponents[3,0]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[1,3]:=(((((RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,3])-(RawComponents[0,0]*RawComponents[1,3]*RawComponents[2,2]))-(RawComponents[1,0]*RawComponents[0,2]*RawComponents[2,3]))+(RawComponents[1,0]*RawComponents[0,3]*RawComponents[2,2])+(RawComponents[2,0]*RawComponents[0,2]*RawComponents[1,3]))-(RawComponents[2,0]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[2,0]:=t8*d;
  result.RawComponents[2,1]:=(((((-(RawComponents[0,0]*RawComponents[2,1]*RawComponents[3,3]))+(RawComponents[0,0]*RawComponents[2,3]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[0,1]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[0,3]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[0,1]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[0,3]*RawComponents[2,1]))*d;
  result.RawComponents[2,2]:=(((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[3,3])-(RawComponents[0,0]*RawComponents[1,3]*RawComponents[3,1]))-(RawComponents[1,0]*RawComponents[0,1]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[0,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[0,1]*RawComponents[1,3]))-(RawComponents[3,0]*RawComponents[0,3]*RawComponents[1,1]))*d;
  result.RawComponents[2,3]:=(((((-(RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,3]))+(RawComponents[0,0]*RawComponents[1,3]*RawComponents[2,1])+(RawComponents[1,0]*RawComponents[0,1]*RawComponents[2,3]))-(RawComponents[1,0]*RawComponents[0,3]*RawComponents[2,1]))-(RawComponents[2,0]*RawComponents[0,1]*RawComponents[1,3]))+(RawComponents[2,0]*RawComponents[0,3]*RawComponents[1,1]))*d;
  result.RawComponents[3,0]:=t12*d;
  result.RawComponents[3,1]:=(((((RawComponents[0,0]*RawComponents[2,1]*RawComponents[3,2])-(RawComponents[0,0]*RawComponents[2,2]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[0,1]*RawComponents[3,2]))+(RawComponents[2,0]*RawComponents[0,2]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[0,1]*RawComponents[2,2]))-(RawComponents[3,0]*RawComponents[0,2]*RawComponents[2,1]))*d;
  result.RawComponents[3,2]:=(((((-(RawComponents[0,0]*RawComponents[1,1]*RawComponents[3,2]))+(RawComponents[0,0]*RawComponents[1,2]*RawComponents[3,1])+(RawComponents[1,0]*RawComponents[0,1]*RawComponents[3,2]))-(RawComponents[1,0]*RawComponents[0,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[0,1]*RawComponents[1,2]))+(RawComponents[3,0]*RawComponents[0,2]*RawComponents[1,1]))*d;
  result.RawComponents[3,3]:=(((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])-(RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1]))-(RawComponents[1,0]*RawComponents[0,1]*RawComponents[2,2]))+(RawComponents[1,0]*RawComponents[0,2]*RawComponents[2,1])+(RawComponents[2,0]*RawComponents[0,1]*RawComponents[1,2]))-(RawComponents[2,0]*RawComponents[0,2]*RawComponents[1,1]))*d;
 end;
end;

function TMat4.Transpose:TMat4;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[1,0];
 result.RawComponents[0,2]:=RawComponents[2,0];
 result.RawComponents[0,3]:=RawComponents[3,0];
 result.RawComponents[1,0]:=RawComponents[0,1];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[2,1];
 result.RawComponents[1,3]:=RawComponents[3,1];
 result.RawComponents[2,0]:=RawComponents[0,2];
 result.RawComponents[2,1]:=RawComponents[1,2];
 result.RawComponents[2,2]:=RawComponents[2,2];
 result.RawComponents[2,3]:=RawComponents[3,2];
 result.RawComponents[3,0]:=RawComponents[0,3];
 result.RawComponents[3,1]:=RawComponents[1,3];
 result.RawComponents[3,2]:=RawComponents[2,3];
 result.RawComponents[3,3]:=RawComponents[3,3];
end;

procedure TMat4.Show; 
var
	x, y: integer;
begin
	for y := 0 to 3 do
		begin
			write('[');
			for x := 0 to 3 do
				begin
					if x < 3 then
						write(FloatToStr(RawComponents[x, y]),',')
					else
						write(FloatToStr(RawComponents[x, y]));
				end;
			write(']');
		end;
end;

class operator TMat4.:= (const a:TScalar):TMat4;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[0,2]:=a;
 result.RawComponents[0,3]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
 result.RawComponents[1,2]:=a;
 result.RawComponents[1,3]:=a;
 result.RawComponents[2,0]:=a;
 result.RawComponents[2,1]:=a;
 result.RawComponents[2,2]:=a;
 result.RawComponents[2,3]:=a;
 result.RawComponents[3,0]:=a;
 result.RawComponents[3,1]:=a;
 result.RawComponents[3,2]:=a;
 result.RawComponents[3,3]:=a;
end;

class operator TMat4.=(const a,b:TMat4):boolean;
begin
 result:=SameValue(a.RawComponents[0,0],b.RawComponents[0,0]) and
         SameValue(a.RawComponents[0,1],b.RawComponents[0,1]) and
         SameValue(a.RawComponents[0,2],b.RawComponents[0,2]) and
         SameValue(a.RawComponents[0,3],b.RawComponents[0,3]) and
         SameValue(a.RawComponents[1,0],b.RawComponents[1,0]) and
         SameValue(a.RawComponents[1,1],b.RawComponents[1,1]) and
         SameValue(a.RawComponents[1,2],b.RawComponents[1,2]) and
         SameValue(a.RawComponents[1,3],b.RawComponents[1,3]) and
         SameValue(a.RawComponents[2,0],b.RawComponents[2,0]) and
         SameValue(a.RawComponents[2,1],b.RawComponents[2,1]) and
         SameValue(a.RawComponents[2,2],b.RawComponents[2,2]) and
         SameValue(a.RawComponents[2,3],b.RawComponents[2,3]) and
         SameValue(a.RawComponents[3,0],b.RawComponents[3,0]) and
         SameValue(a.RawComponents[3,1],b.RawComponents[3,1]) and
         SameValue(a.RawComponents[3,2],b.RawComponents[3,2]) and
         SameValue(a.RawComponents[3,3],b.RawComponents[3,3]);
end;

class operator TMat4.<>(const a,b:TMat4):boolean;
begin
 result:=(not SameValue(a.RawComponents[0,0],b.RawComponents[0,0])) or
         (not SameValue(a.RawComponents[0,1],b.RawComponents[0,1])) or
         (not SameValue(a.RawComponents[0,2],b.RawComponents[0,2])) or
         (not SameValue(a.RawComponents[0,3],b.RawComponents[0,3])) or
         (not SameValue(a.RawComponents[1,0],b.RawComponents[1,0])) or
         (not SameValue(a.RawComponents[1,1],b.RawComponents[1,1])) or
         (not SameValue(a.RawComponents[1,2],b.RawComponents[1,2])) or
         (not SameValue(a.RawComponents[1,3],b.RawComponents[1,3])) or
         (not SameValue(a.RawComponents[2,0],b.RawComponents[2,0])) or
         (not SameValue(a.RawComponents[2,1],b.RawComponents[2,1])) or
         (not SameValue(a.RawComponents[2,2],b.RawComponents[2,2])) or
         (not SameValue(a.RawComponents[2,3],b.RawComponents[2,3])) or
         (not SameValue(a.RawComponents[3,0],b.RawComponents[3,0])) or
         (not SameValue(a.RawComponents[3,1],b.RawComponents[3,1])) or
         (not SameValue(a.RawComponents[3,2],b.RawComponents[3,2])) or
         (not SameValue(a.RawComponents[3,3],b.RawComponents[3,3]));
end;

class operator TMat4.+(const a,b:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b.RawComponents[0,2];
 result.RawComponents[0,3]:=a.RawComponents[0,3]+b.RawComponents[0,3];
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b.RawComponents[1,2];
 result.RawComponents[1,3]:=a.RawComponents[1,3]+b.RawComponents[1,3];
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b.RawComponents[2,2];
 result.RawComponents[2,3]:=a.RawComponents[2,3]+b.RawComponents[2,3];
 result.RawComponents[3,0]:=a.RawComponents[3,0]+b.RawComponents[3,0];
 result.RawComponents[3,1]:=a.RawComponents[3,1]+b.RawComponents[3,1];
 result.RawComponents[3,2]:=a.RawComponents[3,2]+b.RawComponents[3,2];
 result.RawComponents[3,3]:=a.RawComponents[3,3]+b.RawComponents[3,3];
end;

class operator TMat4.+(const a:TMat4;const b:TScalar):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]+b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]+b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]+b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]+b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]+b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]+b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]+b;
end;

class operator TMat4.+(const a:TScalar;const b:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=a+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a+b.RawComponents[0,2];
 result.RawComponents[0,3]:=a+b.RawComponents[0,3];
 result.RawComponents[1,0]:=a+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a+b.RawComponents[1,2];
 result.RawComponents[1,3]:=a+b.RawComponents[1,3];
 result.RawComponents[2,0]:=a+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a+b.RawComponents[2,2];
 result.RawComponents[2,3]:=a+b.RawComponents[2,3];
 result.RawComponents[3,0]:=a+b.RawComponents[3,0];
 result.RawComponents[3,1]:=a+b.RawComponents[3,1];
 result.RawComponents[3,2]:=a+b.RawComponents[3,2];
 result.RawComponents[3,3]:=a+b.RawComponents[3,3];
end;

class operator TMat4.-(const a,b:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b.RawComponents[0,2];
 result.RawComponents[0,3]:=a.RawComponents[0,3]-b.RawComponents[0,3];
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b.RawComponents[1,2];
 result.RawComponents[1,3]:=a.RawComponents[1,3]-b.RawComponents[1,3];
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b.RawComponents[2,2];
 result.RawComponents[2,3]:=a.RawComponents[2,3]-b.RawComponents[2,3];
 result.RawComponents[3,0]:=a.RawComponents[3,0]-b.RawComponents[3,0];
 result.RawComponents[3,1]:=a.RawComponents[3,1]-b.RawComponents[3,1];
 result.RawComponents[3,2]:=a.RawComponents[3,2]-b.RawComponents[3,2];
 result.RawComponents[3,3]:=a.RawComponents[3,3]-b.RawComponents[3,3];
end;

class operator TMat4.-(const a:TMat4;const b:TScalar):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]-b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]-b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]-b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]-b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]-b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]-b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]-b;
end;

class operator TMat4.-(const a:TScalar;const b:TMat4): TMat4;
begin
 result.RawComponents[0,0]:=a-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a-b.RawComponents[0,2];
 result.RawComponents[0,3]:=a-b.RawComponents[0,3];
 result.RawComponents[1,0]:=a-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a-b.RawComponents[1,2];
 result.RawComponents[1,3]:=a-b.RawComponents[1,3];
 result.RawComponents[2,0]:=a-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a-b.RawComponents[2,2];
 result.RawComponents[2,3]:=a-b.RawComponents[2,3];
 result.RawComponents[3,0]:=a-b.RawComponents[3,0];
 result.RawComponents[3,1]:=a-b.RawComponents[3,1];
 result.RawComponents[3,2]:=a-b.RawComponents[3,2];
 result.RawComponents[3,3]:=a-b.RawComponents[3,3];
end;

class operator TMat4.*(const b,a:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=(a.RawComponents[0,0]*b.RawComponents[0,0])+(a.RawComponents[0,1]*b.RawComponents[1,0])+(a.RawComponents[0,2]*b.RawComponents[2,0])+(a.RawComponents[0,3]*b.RawComponents[3,0]);
 result.RawComponents[0,1]:=(a.RawComponents[0,0]*b.RawComponents[0,1])+(a.RawComponents[0,1]*b.RawComponents[1,1])+(a.RawComponents[0,2]*b.RawComponents[2,1])+(a.RawComponents[0,3]*b.RawComponents[3,1]);
 result.RawComponents[0,2]:=(a.RawComponents[0,0]*b.RawComponents[0,2])+(a.RawComponents[0,1]*b.RawComponents[1,2])+(a.RawComponents[0,2]*b.RawComponents[2,2])+(a.RawComponents[0,3]*b.RawComponents[3,2]);
 result.RawComponents[0,3]:=(a.RawComponents[0,0]*b.RawComponents[0,3])+(a.RawComponents[0,1]*b.RawComponents[1,3])+(a.RawComponents[0,2]*b.RawComponents[2,3])+(a.RawComponents[0,3]*b.RawComponents[3,3]);
 result.RawComponents[1,0]:=(a.RawComponents[1,0]*b.RawComponents[0,0])+(a.RawComponents[1,1]*b.RawComponents[1,0])+(a.RawComponents[1,2]*b.RawComponents[2,0])+(a.RawComponents[1,3]*b.RawComponents[3,0]);
 result.RawComponents[1,1]:=(a.RawComponents[1,0]*b.RawComponents[0,1])+(a.RawComponents[1,1]*b.RawComponents[1,1])+(a.RawComponents[1,2]*b.RawComponents[2,1])+(a.RawComponents[1,3]*b.RawComponents[3,1]);
 result.RawComponents[1,2]:=(a.RawComponents[1,0]*b.RawComponents[0,2])+(a.RawComponents[1,1]*b.RawComponents[1,2])+(a.RawComponents[1,2]*b.RawComponents[2,2])+(a.RawComponents[1,3]*b.RawComponents[3,2]);
 result.RawComponents[1,3]:=(a.RawComponents[1,0]*b.RawComponents[0,3])+(a.RawComponents[1,1]*b.RawComponents[1,3])+(a.RawComponents[1,2]*b.RawComponents[2,3])+(a.RawComponents[1,3]*b.RawComponents[3,3]);
 result.RawComponents[2,0]:=(a.RawComponents[2,0]*b.RawComponents[0,0])+(a.RawComponents[2,1]*b.RawComponents[1,0])+(a.RawComponents[2,2]*b.RawComponents[2,0])+(a.RawComponents[2,3]*b.RawComponents[3,0]);
 result.RawComponents[2,1]:=(a.RawComponents[2,0]*b.RawComponents[0,1])+(a.RawComponents[2,1]*b.RawComponents[1,1])+(a.RawComponents[2,2]*b.RawComponents[2,1])+(a.RawComponents[2,3]*b.RawComponents[3,1]);
 result.RawComponents[2,2]:=(a.RawComponents[2,0]*b.RawComponents[0,2])+(a.RawComponents[2,1]*b.RawComponents[1,2])+(a.RawComponents[2,2]*b.RawComponents[2,2])+(a.RawComponents[2,3]*b.RawComponents[3,2]);
 result.RawComponents[2,3]:=(a.RawComponents[2,0]*b.RawComponents[0,3])+(a.RawComponents[2,1]*b.RawComponents[1,3])+(a.RawComponents[2,2]*b.RawComponents[2,3])+(a.RawComponents[2,3]*b.RawComponents[3,3]);
 result.RawComponents[3,0]:=(a.RawComponents[3,0]*b.RawComponents[0,0])+(a.RawComponents[3,1]*b.RawComponents[1,0])+(a.RawComponents[3,2]*b.RawComponents[2,0])+(a.RawComponents[3,3]*b.RawComponents[3,0]);
 result.RawComponents[3,1]:=(a.RawComponents[3,0]*b.RawComponents[0,1])+(a.RawComponents[3,1]*b.RawComponents[1,1])+(a.RawComponents[3,2]*b.RawComponents[2,1])+(a.RawComponents[3,3]*b.RawComponents[3,1]);
 result.RawComponents[3,2]:=(a.RawComponents[3,0]*b.RawComponents[0,2])+(a.RawComponents[3,1]*b.RawComponents[1,2])+(a.RawComponents[3,2]*b.RawComponents[2,2])+(a.RawComponents[3,3]*b.RawComponents[3,2]);
 result.RawComponents[3,3]:=(a.RawComponents[3,0]*b.RawComponents[0,3])+(a.RawComponents[3,1]*b.RawComponents[1,3])+(a.RawComponents[3,2]*b.RawComponents[2,3])+(a.RawComponents[3,3]*b.RawComponents[3,3]);
end;

class operator TMat4.*(const a:TMat4;const b:TScalar):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]*b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]*b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]*b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]*b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]*b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]*b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]*b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]*b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]*b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]*b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]*b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]*b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]*b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]*b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]*b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]*b;
end;

class operator TMat4.*(const a:TScalar;const b:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=a*b.RawComponents[0,0];
 result.RawComponents[0,1]:=a*b.RawComponents[0,1];
 result.RawComponents[0,2]:=a*b.RawComponents[0,2];
 result.RawComponents[0,3]:=a*b.RawComponents[0,3];
 result.RawComponents[1,0]:=a*b.RawComponents[1,0];
 result.RawComponents[1,1]:=a*b.RawComponents[1,1];
 result.RawComponents[1,2]:=a*b.RawComponents[1,2];
 result.RawComponents[1,3]:=a*b.RawComponents[1,3];
 result.RawComponents[2,0]:=a*b.RawComponents[2,0];
 result.RawComponents[2,1]:=a*b.RawComponents[2,1];
 result.RawComponents[2,2]:=a*b.RawComponents[2,2];
 result.RawComponents[2,3]:=a*b.RawComponents[2,3];
 result.RawComponents[3,0]:=a*b.RawComponents[3,0];
 result.RawComponents[3,1]:=a*b.RawComponents[3,1];
 result.RawComponents[3,2]:=a*b.RawComponents[3,2];
 result.RawComponents[3,3]:=a*b.RawComponents[3,3];
end;

class operator TMat4.*(const a:TMat4;const b:TVec3):TVec3;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+a.RawComponents[3,0];
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+a.RawComponents[3,1];
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+a.RawComponents[3,2];
end;

class operator TMat4.*(const a:TVec3;const b:TMat4):TVec3;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+b.RawComponents[0,3];
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+b.RawComponents[1,3];
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+b.RawComponents[2,3];
end;

class operator TMat4.*(const a:TMat4;const b:TVec4):TVec4;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+(a.RawComponents[3,0]*b.w);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+(a.RawComponents[3,1]*b.w);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+(a.RawComponents[3,2]*b.w);
 result.w:=(a.RawComponents[0,3]*b.x)+(a.RawComponents[1,3]*b.y)+(a.RawComponents[2,3]*b.z)+(a.RawComponents[3,3]*b.w);
end;

class operator TMat4.*(const a:TVec4;const b:TMat4):TVec4;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+(a.w*b.RawComponents[0,3]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+(a.w*b.RawComponents[1,3]);
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+(a.w*b.RawComponents[2,3]);
 result.w:=(a.x*b.RawComponents[3,0])+(a.y*b.RawComponents[3,1])+(a.z*b.RawComponents[3,2])+(a.w*b.RawComponents[3,3]);
end;

class operator TMat4./(const a,b:TMat4):TMat4;
begin
 result:=a*b.Inverse;
end;

class operator TMat4./(const a:TMat4;const b:TScalar):TMat4;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]/b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]/b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]/b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]/b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]/b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]/b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]/b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]/b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]/b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]/b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]/b;
end;

class operator TMat4./(const a:TScalar;const b:TMat4):TMat4;
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[0,2]:=a/b.RawComponents[0,2];
 result.RawComponents[0,3]:=a/b.RawComponents[0,3];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
 result.RawComponents[1,2]:=a/b.RawComponents[1,2];
 result.RawComponents[1,3]:=a/b.RawComponents[1,3];
 result.RawComponents[2,0]:=a/b.RawComponents[2,0];
 result.RawComponents[2,1]:=a/b.RawComponents[2,1];
 result.RawComponents[2,2]:=a/b.RawComponents[2,2];
 result.RawComponents[2,3]:=a/b.RawComponents[2,3];
 result.RawComponents[3,0]:=a/b.RawComponents[3,0];
 result.RawComponents[3,1]:=a/b.RawComponents[3,1];
 result.RawComponents[3,2]:=a/b.RawComponents[3,2];
 result.RawComponents[3,3]:=a/b.RawComponents[3,3];
end;

end.