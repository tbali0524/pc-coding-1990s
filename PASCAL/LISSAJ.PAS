program Lissajous;

uses
  Crt, Graph;

var
  GraphDriver, GraphMode: Integer;
  Vege: Boolean;
  Ch: Char;
  I, K: Integer;
  C: Integer;           { sz¡n }
  T1, T2: Real;         { id“ }

  D1, D2: Real;         { id“ v ltoz sa }
  A1, A2: Integer;      { amplit£d¢ }
  O1, O2: Real;         { k”rfrekvencia }
  F1, F2: Real;         { kezd“f zis }
  B1, B2: Real;         { csillapod si t‚nyez“ }

begin
  D1 := 0.2;
  D2 := 1;
  O1 := 0.01;
  O2 := 0.08;
  F1 := 0;
  F2 := Pi / 8;
  B1 := 0.0008;
  B2 := 0.0001;
  Randomize;
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, 'C:\BP\BGI');
  if GraphResult <> grOk then
    Halt;
  A1 := GetMaxX div 2;
  A2 := GetMaxY div 2;
  T1 := 0;
  T2 := 0;
  K := Round(2 * Pi / O1 / D1);
  I := K;
  Vege := False;
  repeat
    if I = K then
    begin
      I := 0;
      C := Random(GetMaxColor) + 1;
    end
    else
      Inc(I);
    PutPixel(Round(GetMaxX / 2 + A1 * Exp(-B1 * T1) * Sin(O1 * T1 + F1)),
             Round(GetMaxY / 2 - A2 * Exp(-B2 * T2) * Sin(O2 * T2 + F2)), C);
    T1 := T1 + D1;
    T2 := T2 + D2;
    if KeyPressed then
    begin
      Ch := ReadKey;
      case Ch of
        #13: ClearDevice;
        ' ': repeat
             until KeyPressed;
        #27: Vege := True;
      end;
    end; { if }
  until Vege;
  CloseGraph;
end.
