{$mode objfpc}
{$fpc -vbr -Fu"/../framework" $(source)}
{$shell lazbuild lazmetalcontrol.lpk}

program Tests;
uses
	MetalPipeline, MetalTypes, SysUtils;

function SystemTime: double;
begin
	result := TimeStampToMSecs(DateTimeToTimeStamp(Now)) / 1000;
end;	

procedure Test_Noz;
var
	v: TVec3;
	t: double;
	i: integer;
begin
	t := SystemTime;
	for i := 0 to 100000 do
		v := v3(10, 20, 30).Normalize;
	writeln(FloatToStr(SystemTime - t));
end;

procedure Test_Constref_Operators;
var
	v: TVec3;
	t: double;
	i: integer;
begin
	t := SystemTime;
	for i := 0 to 100000 do
		v := v3(i, i, i) * v3(0.5, 0.5, 0.5);
	writeln(FloatToStr(SystemTime - t));
end;

var
	a, b: TVec3;
begin
	a := V3(10, 10, 10);
	b := V3(20, 20, 20);
	if a = b then
		writeln('equals');
	if a <> b then
		writeln('not equals');
	//Test_Noz;
	Test_Constref_Operators;
end.