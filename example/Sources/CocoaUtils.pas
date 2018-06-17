{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch typehelpers}
{$modeswitch advancedrecords}

unit CocoaUtils;
interface
uses
	CocoaAll, MacOSAll, SysUtils;

procedure Show (obj: id; msg: string = ''); 
procedure Fatal (condition: boolean; msg: string = ''; error: NSError = nil); overload;
procedure Fatal (msg: string; error: NSError = nil); overload;
procedure BlockMove(dest, src: pointer; size: SizeInt); 
function CopyMem (src: pointer; offset: integer; count: integer): pointer;

function NSSTR(str: string): NSString; overload;

function ResourcePath (name: pchar; ofType: pchar): string;
function ResourceURL (name: pchar; ofType: pchar): NSURL;

implementation

//type
//	CocoaStringUtils = type helper for string
//		function nsstr: NSString;
//	end;

//function CocoaStringUtils.nsstr: NSString;
//begin
//	result := NSSTR(self);
//end;

function ResourceURL (name: pchar; ofType: pchar): NSURL;
var
	url: NSURL;
begin
	result := NSBundle.mainBundle.URLForResource_withExtension(NSSTR(name), NSSTR(ofType));
end;

function ResourcePath (name: pchar; ofType: pchar): string;
var
	url: NSURL;
begin
	url := ResourceURL(name, ofType);
	result := url.relativePath.UTF8String;
end;

function NSSTR(str: string): NSString; overload;
begin
	result := NSString.stringWithCString_length(@str[1], length(str));
end;

function CopyMem (src: pointer; offset: integer; count: integer): pointer;
begin
	result := GetMem(count);
	BlockMove(result, src + offset, count);
end;

procedure BlockMove(dest, src: pointer; size: SizeInt); 
begin 
  Move(src^, dest^, size);
end; 

procedure Fatal (msg: string; error: NSError = nil);
begin
	Fatal(true, msg, error);
end;

procedure Fatal (condition: boolean; msg: string = ''; error: NSError = nil);
begin
	if condition then
		begin
			if error = nil then
				writeln(msg)
			else
				writeln(msg+' -> '+error.localizedDescription.UTF8String);
			raise Exception.Create('fatal');
		end;
end;

procedure Show (obj: id; msg: string = ''); 
begin
	if msg <> '' then
		msg := msg+' ';
	if obj = nil then
		writeln(msg+'nil')
	else
		writeln(msg+obj.description.UTF8String);
end;

end.