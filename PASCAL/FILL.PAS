program FillRutin;
uses Crt, Graph, Dos;
var
  gd, gm: Integer;
  A1, A2, A3, A4: Word;

procedure Fill(X, Y: Integer);
var
  X1, X2, I: Integer;
begin
  X1 := X;
  while GetPixel(X1, Y) = 0 do
    Dec(X1);
  X2 := X;
  while GetPixel(X2, Y) = 0 do
    Inc(X2);
  Line(X1 + 1, Y, X2 - 1, Y);
  for I := X1 + 1 to X2 - 1 do
  begin
    if GetPixel(I, Y - 1) = 0 then
      Fill(I, Y - 1);
    if GetPixel(I, Y + 1) = 0 then
      Fill(I, Y + 1);
  end;
end;

begin
  DetectGraph(gd, gm);
  InitGraph(gd, gm, 'c:\BP\BGI');
  Rectangle(10, 10, 600, 400);
  Circle(50, 50, 20);
  Circle(150, 150, 120);
  Rectangle(80, 20, 90, 50);
  SetTime(0,0,0,0);
  Fill(15,15);
  GetTime(A1, A2, A3, A4);
  ReadLn;
  CloseGraph;
  ClrScr;
  WriteLn(A1:5, A2:5, A3:5, A4:5);
end.
