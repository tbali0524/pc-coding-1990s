{ ViewIMG.PAS
  Korabban GetImage-vel fileba mentett kep kirakasa a grafikus
  kepernyore.
}
program ViewIMG;

{$M 8000, 98304, 98304 }
uses Graph;

const
  BGIPath = 'C:\BP\BGI';
  ImageName = 'PICTURE.IMG';

var
  GraphDriver, GraphMode: Integer;
  X1, Y1, x2, Y2: Word;
  Size, NumRead: Word;
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
  X1 := GetMaxX div 2 - 160;
  Y1 := GetMaxY div 2 - 100;
  X2 := GetMaxX div 2 + 160 - 1;
  Y2 := GetMaxY div 2 + 100 - 1;
  Size := ImageSize(X1, Y1, X2, Y2);
  Assign(ImageFile, ImageName);
  Reset(ImageFile, 1);
  BlockRead(ImageFile, Image, Size, NumRead);
  if Size <> NumRead then
  begin
    CloseGraph;
    WriteLn('Hiba az IMG file olvasasakor!');
    Halt(2);
  end;
  Close(ImageFile);
  PutImage(X1, Y1, Image, NormalPut);
  ReadLn;
  CloseGraph;
  WriteLn('Rendben.');
end.
