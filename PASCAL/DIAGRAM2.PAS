program Diagram2;

uses Crt, Graph;

const
  MaxOszlop = 100;

type
  TDiagramm = Object
    Diag: Array[0..MaxOszlop - 1] of Integer;
    Oszlop, Csokkenes, Lepeskoz, Szin, HatterSzin,
    Tav, Szel, Oszto, T: Integer;
    V: Record
         X1, Y1, X2, Y2: Integer;
       end;
    constructor Init(IX1, IY1, IX2, IY2, Oszl, Csok, LKoz, Col, Bk: Integer);
    destructor Done;
    procedure Torol;
    function Esemeny(Ti: Integer): Integer; virtual;
    procedure RajzolOszlop(E: Integer);
    procedure Kepernyo;
    procedure Kezel(E: Integer);
    procedure Lepes;
  end;
  TDiagramm2 = Object(TDiagramm)
    function Esemeny(Ti: Integer): Integer; virtual;
  end;

var
  grDriver, grMode, GX, GY: Integer;
  D1, D3: TDiagramm;
  D2: TDiagramm2;

constructor TDiagramm.Init(IX1, IY1, IX2, IY2, Oszl, Csok, LKoz, Col, Bk: Integer);
begin
  V.X1 := IX1;
  V.Y1 := IY1;
  V.X2 := IX2;
  V.Y2 := IY2;
  Oszlop := Oszl;
  Csokkenes := Csok;
  Lepeskoz := LKoz;
  Szin := Col;
  HatterSzin := Bk;
  Tav := (V.X2 - V.X1) div Oszlop;
  if Tav = 0 then
    Tav := 1;
  if Tav > 2 then
    Szel := Tav -  2
  else
    Szel := 1;
  Torol;
  Kepernyo;
end;

destructor TDiagramm.Done;
begin
end;

procedure TDiagramm.Torol;
var
  I: Integer;
begin
  for I := 0 to Oszlop - 1 do
    Diag[I] := 0;
  T := 0;
  Oszto := 1;
end;

function TDiagramm.Esemeny(Ti: Integer): Integer;
begin
  if Odd(Oszlop) then
    Esemeny := Random(Oszlop div 2 + 1) + Random(Oszlop div 2 + 1)
  else
    Esemeny := Random(Oszlop div 2 + 1) + Random(Oszlop div 2);
end;

procedure TDiagramm.RajzolOszlop(E: Integer);
begin
  SetColor(Szin);
  SetFillStyle(SolidFill, Szin);
  if Diag[E] div Oszto > 0 then
    Bar(V.X1 + E * Tav, V.Y2 - Diag[E] div Oszto, V.X1 + E * Tav + Szel, V.Y2);
end;

procedure TDiagramm.Kepernyo;
var
  I: Integer;
begin
  SetColor(HatterSzin);
  SetFillStyle(SolidFill, HatterSzin);
  Bar(V.X1, V.Y1, V.X2, V.Y2);
  SetFillStyle(SolidFill, Szin);
  SetColor(Szin);
  for I := 0 to Oszlop - 1 do
    RajzolOszlop(I);
end;

procedure TDiagramm.Kezel(E: Integer);
begin
  if Diag[E] < 32767 then
    Inc(Diag[E]);
  if Diag[E] div Oszto > V.Y2 - V.Y1 then
  begin
    Oszto := Oszto * Csokkenes;
    if Oszto > 16383 then
      Torol;
    Kepernyo;
  end
  else
    RajzolOszlop(E);
end;

procedure TDiagramm.Lepes;
begin
  Kezel(Esemeny(T));
  Inc(T, Lepeskoz);
  if T > 30000 then
    T := 0;
end;

function TDiagramm2.Esemeny(Ti: Integer): Integer;
begin
  Esemeny := Random(Oszlop)
end;

begin
  grDriver := Detect;
  InitGraph(grDriver, grMode, 'C:\BP\BGI');
  if GraphResult = grOk then
  begin
    Randomize;
    GX := GetMaxX;
    GY := GetMaxY;
    D1.Init(0, 0, GX div 2, GY div 2, 20, 2, 1, White, Black);
    D2.Init(0, GY div 2 + 1, GX div 4, GY, 5, 4, 1, Yellow, Red);
    D3.Init(GX div 2 + 1, 0, GX, GY, 100, 2, 1, Blue, Green);
    repeat
      D1.Lepes;
      D2.Lepes;
      D3.Lepes;
    until KeyPressed;
    D1.Done;
    D2.Done;
    D3.Done;
  end;
end.
