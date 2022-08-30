{ BMP2IMG.PAS
  Kulso filenezovel (VPIC) kirak a kepernyore egy BMP kepet,
  majd belso formatumban (PutImage) kirakja fileba.
}
program BMP2IMG;

{$M 8000, 98304, 98304 }
uses Dos, Graph;

const
  BMPViewer = 'C:\UTIL\VPIC.EXE';
  BMPName = 'PICTURE.BMP';
  BMPViewerParam = '/e /r /o /v /z /m11 ' + BMPName;
  BGIPath = 'C:\BP\BGI';
  ImageName = 'PICTURE.IMG';

var
  GraphDriver, GraphMode: Integer;
  X1, Y1, x2, Y2: Word;
  Size, Result: Word;
  Image: Array[0..32100] of Byte;
  ImageFile: File;

begin
  GraphDriver := EGA;
  GraphMode := EGAHi;
  InitGraph(GraphDriver, GraphMode, BGIPath);
  if GraphResult <> grOk then
  begin
    WriteLn('Hiba a grafikus kepernyo inicializalasakor!');
    Halt(1);
  end;
  SwapVectors;
  Exec(BMPViewer, BMPViewerParam);
  SwapVectors;
  if DosError <> 0 then
  begin
    CloseGraph;
    WriteLn('Hiba a BMP nezo program meghivasakor!');
    Halt(2);
  end;
  X1 := GetMaxX div 2 - 160;
  Y1 := GetMaxY div 2 - 100;
  X2 := GetMaxX div 2 + 160 - 1;
  Y2 := GetMaxY div 2 + 100 - 1;
  Size := ImageSize(X1, Y1, X2, Y2);
  GetImage(X1, Y1, X2, Y2, Image);
  CloseGraph;
  Assign(ImageFile, ImageName);
  ReWrite(ImageFile, 1);
  BlockWrite(ImageFile, Image, Size, Result);
  if Size <> Result then
  begin
    WriteLn('Hiba az IMG file irasakor!');
    Halt(3);
  end;
  Close(ImageFile);
  WriteLn(BMPName, ' ==> ', ImageName, '   - Rendben.');
end.
