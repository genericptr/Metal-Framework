{$mode objfpc}

unit Scanner;
interface
uses
	SysUtils;

type
	TScanner = class
		private type TToken = (kTokenID, kTokenComment, kTokenNumber, kTokenSymbol, kTokenEOF);
		public
			procedure LoadFile (path: string);
			procedure Parse; virtual; abstract;
			destructor Destroy; override;
		protected
			contents: pchar;
			c: char;
			pattern: string;
			token: TToken;
		protected
			function ReadTokenTo (inToken: TToken; inPattern: string = ''): boolean;
			function ReadToken: TToken;
			procedure ParserError (messageString: string = '');
		private
			procedure SkipLine;
			procedure SkipSpace;
			function ReadWord: string;
			function ReadChar: char;
			function ReadNumber: string;
			function Peek (advance: integer = 1): char;
		private
			currentIndex: integer;
			readNextPass: boolean;
			fileLength: integer;
	end;

type
	TCLangScanner = class (TScanner)
		public
		protected
	end;

implementation

{=============================================}
{@! ___CLANG SCANNER___ } 
{=============================================}

{=============================================}
{@! ___SCANNER___ } 
{=============================================}

{$macro on}
{$define TCharSetWhiteSpace:=' ', '	', #10, #12}
{$define TCharSetLineEnding:=#10, #12}
{$define TCharSetWord:='a'..'z','A'..'Z','_'}
{$define TCharSetInteger:='0'..'9'}

procedure TScanner.SkipLine;
begin
	repeat
		ReadChar;
	until c in [TCharSetLineEnding];
end;

procedure TScanner.SkipSpace;
begin
	while c in [TCharSetWhiteSpace] do
		ReadChar;
end;

function TScanner.Peek (advance: integer = 1): char;
begin
	if currentIndex + advance < fileLength then
		result := contents[currentIndex + advance]
	else
		result := #0;
end;

function TScanner.ReadChar: char;
begin
	currentIndex += 1;
	c := contents[currentIndex];
	result := c;
end;

function TScanner.ReadWord: string;
begin
	pattern := '';
	while c in [TCharSetWord, TCharSetInteger] do
		begin
			pattern += c;
			ReadChar;
		end;
	result := pattern;
end;

function TScanner.ReadNumber: string;
var
	negative: boolean = false;
begin
	pattern := '';

	if (c = '-') and (Peek in [TCharSetInteger]) then
		begin
			negative := true;
			pattern += c;
			ReadChar;
		end
	else if c in [TCharSetInteger] then
		begin
			pattern += c;
			ReadChar;
		end
	else
		exit;

	while c in [TCharSetInteger, '.'] do
		begin
			pattern += c;
			ReadChar;
		end;

	result := pattern;
end;

procedure TScanner.ParserError (messageString: string = '');
begin
	writeln(messageString);
	halt;
end;

function TScanner.ReadTokenTo (inToken: TToken; inPattern: string = ''): boolean;
begin
	if ReadToken = inToken then
		begin
			if inPattern <> '' then
				begin
					if token in [kTokenSymbol] then
						result := c = inPattern
					else
						result := pattern = inPattern
				end
			else
				result := true;
		end
	else
		ParserError('ReadTokenTo failed');
end;

function TScanner.ReadToken: TToken;
label
	TokenRead;
begin
	while currentIndex < fileLength do 
		begin
			//writeln(currentIndex, ':', c);
			if readNextPass then
				begin
					ReadChar;
					readNextPass := false;
				end;
			case c of
				'-':
					if Peek in [TCharSetInteger] then
						begin
							token := kTokenNumber;
							ReadNumber;
							goto TokenRead;
						end;
				TCharSetInteger:
					begin
						token := kTokenNumber;
						ReadNumber;
						goto TokenRead;
					end;
				TCharSetWord:
					begin
						token := kTokenID;
						ReadWord;
						goto TokenRead;
					end;
				'[', ']', '(', ')', '{', '}', '=', ':', ',', ';':
					begin
						token := kTokenSymbol;
						readNextPass := true;
						goto TokenRead;
					end;
				// NOTE: C comments! pull out into CLangScanner
				'/':
					begin
						if Peek = '/' then
							begin
								token := kTokenComment;
								SkipLine;
							end
						else if Peek = '*' then
							begin
								while true do
									begin
										ReadChar;
										if (c = '*') and (Peek = '/') then
											begin
												token := kTokenComment;
												ReadChar; // *
												ReadChar; // /
												break;
											end;
									end;
							end;
					end;
				'#':
					begin
						token := kTokenComment;
						SkipLine;
					end;
				TCharSetWhiteSpace:
					begin
						SkipSpace;
					end;
			end;
		end;

	token := kTokenEOF;

	TokenRead:
	result := token;
end;

procedure TScanner.LoadFile (path: string);
var
	f: file;
begin
	try
		AssignFile(f, path);
		FileMode := fmOpenRead;
	  Reset(f, 1);
	  contents := GetMem(FileSize(f) + 1);
	  BlockRead(f, contents^, FileSize(f));

	  contents[FileSize(f) + 1] := #0;
	  
	  // set first position
	  c := contents[currentIndex];
	  fileLength := length(contents);

	  CloseFile(f);
  except
    writeln('failed to load ', path);
    halt;
  end;
end;

destructor TScanner.Destroy;
begin
	FreeMem(contents);
	inherited;
end;

end.