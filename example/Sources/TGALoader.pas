{$mode objfpc}
{$modeswitch advancedrecords}

unit TGALoader;
interface
uses
	CocoaUtils, CTypes, SysUtils;

type
	uint8_t = cuint8;
	int16_t = cint16;
	uint16_t = cuint16;

{$packrecords c}
type
	TGAHeader = packed record
		IDSize: uint8_t;         // Size of ID info following header
		colorMapType: uint8_t;   // Whether this is a paletted image
		imageType: uint8_t;      // type of image 0=none, 1=indexed, 2=rgb, 3=grey, +8=rle packed

		colorMapStart: int16_t;  // Offset to color map in palette
		colorMapLength: int16_t; // Number of colors in palette
		colorMapBpp: uint8_t;    // number of bits per palette entry

		xOffset: uint16_t;        // Number of pixels to the right to start of image
		yOffset: uint16_t;        // Number of pixels down to start of image
		width: uint16_t;          // Width in pixels
		height: uint16_t;         // Height in pixels
		bitsPerPixel: uint8_t;   // Bits per pixel 8,16,24,32
		descriptor: uint8_t;     // Descriptor bits (flipping, etc)
	end;
	TGAHeaderPtr = ^TGAHeader;

type
	TGAImage = record
		bytes: pointer;
		width, height: integer;
		class operator Finalize(var a: TGAImage);
	end;

function LoadTGAFile (path: string): TGAImage;

implementation

class operator TGAImage.Finalize(var a: TGAImage);
begin
	FreeMem(a.bytes);
	a.bytes := nil;
end;

function ReadFile (path: string): pointer;
var
	f: file;
	bytes: pointer;
	i: integer;
begin
	try
		AssignFile(f, path);
		FileMode := fmOpenRead;
	  Reset(f, 1);
	  bytes := GetMem(FileSize(f));
	  BlockRead(f, bytes^, FileSize(f));
	  CloseFile(f);
		
		result := bytes;
  except
		Fatal('can''t load file '+path);
  end;
end;

function LoadTGAFile (path: string): TGAImage;
type
	BytePtr = ^byte;
var
	header: TGAHeaderPtr;
	fileBytes: pointer;
	width, height, dataSize: integer;
	srcImageData: BytePtr;
	destImageData: BytePtr;
	x, y: integer;
	srcPixelIndex, dstPixelIndex: integer;
begin
	fileBytes := ReadFile(path);
	header := TGAHeaderPtr(fileBytes);

	width := header^.width;
	height := header^.height;
	dataSize := width * height * 4;

	//writeln('LoadTGAFile: width: ', result.width, ' height: ', result.height);

	Fatal(header^.imageType <> 2, 'This image loader only supports non-compressed BGR(A) TGA files');
	Fatal(header^.colorMapType <> 0, 'This image loader doesn''t support TGA files with a colormap');
	Fatal((header^.xOffset <> 0) or (header^.yOffset <> 0), 'This image loader doesn''t support TGA files with offsets');
	Fatal((header^.bitsPerPixel <> 32) and (header^.bitsPerPixel <> 24), 'This image loader only supports 24-bit and 32-bit TGA files');
	Fatal((header^.bitsPerPixel = 32) and ((header^.descriptor and $f) <> 8), 'Image loader only supports 32-bit TGA files with 8 bits of alpha');
	Fatal(header^.descriptor <> 0, 'Image loader only supports 24-bit TGA files with the default descriptor');

	// copy image data after header
	srcImageData := CopyMem(fileBytes, sizeof(TGAHeader) + header^.IDSize, dataSize);
	
	FreeMem(fileBytes);

	if header^.bitsPerPixel = 24 then
		begin
			// Metal will not understand an image with 24-bpp format so we must convert our
			//   TGA data from the 24-bit BGR format to a 32-bit BGRA format that Metal does
			//   understand (as MTLPixelFormatBGRA8Unorm)
			destImageData := BytePtr(GetMem(dataSize));
			//BlockMove(destImageData, srcImageData, dataSize);

			for y := 0 to height - 1 do
			for x := 0 to width - 1 do
				begin
					// Calculate the index for the first byte of the pixel you're
					// converting in both the source and destination images
					srcPixelIndex := 3 * (y * width + x);
					dstPixelIndex := 4 * (y * width + x);

					// Copy BGR channels from the source to the destination
					// Set the alpha channel of the destination pixel to 255
					destImageData[dstPixelIndex + 0] := srcImageData[srcPixelIndex + 0];
					destImageData[dstPixelIndex + 1] := srcImageData[srcPixelIndex + 1];
					destImageData[dstPixelIndex + 2] := srcImageData[srcPixelIndex + 2];
					destImageData[dstPixelIndex + 3] := 255;
				end;

			FreeMem(srcImageData);
			result.bytes := destImageData;
		end
	else
		begin
			// Metal will understand an image with 32-bpp format
			result.bytes := srcImageData;
		end;

	result.width := width;
	result.height := height;
end;

end.