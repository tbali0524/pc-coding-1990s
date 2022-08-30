program Diagram3;

uses Crt, Graph;

const
  Oszlop = 3;
  Oszl = 20;
  Stilus: Array[1..Oszlop] of Integer = (SolidFill, SlashFill, XHatchFill);
  Szin: Array[1..Oszlop] of Integer = (White, White, White);

var
  grDriver, grMode,
  Tav, Szel, T: Integer;
  V: ViewPortType;
  Diag: Array[1..Oszlop] of Integer;

procedure BeallitPort;
begin
  GetViewSettings(V);
  Tav := (V.X2 - V.X1) div Oszl;
  if Tav = 0 then
    Tav := 1;
  if Tav > 2 then
    Szel := Tav -  2
  else
    Szel := 1;
end;

function Esemeny(O, Ti: Integer): Integer;
begin
  case O mod 3 of
    0 : Esemeny := 10;
    1 : Esemeny := Random((V.Y2 - V.Y1) div 3);
    2 : Esemeny := Trunc(Sin(Ti) * (V.Y2 - V.Y1) / 3);
  end;
end;

procedure RajzolOszlop(S: Integer);
var
  I, Kezdet, Veg: Integer;
begin
  Kezdet := V.Y2 - V.Y1;
  SetFillStyle(EmptyFill, 0);
  if S = Oszl - 1 then
    Bar(0, 0, Szel, V.Y2 - V.Y1)
  else
    Bar((S + 1) * Tav , 0, (S + 1) * Tav + Szel, V.Y2 - V.Y1);
  for I := 1 to Oszlop do
    if Diag[I] > 0 then
    begin
      SetFillStyle(Stilus[I], Szin[I]);
      Veg := Kezdet - Diag[I];
      if Veg < 0 then
        Veg := 0;
      Bar(S * Tav , Veg, S * Tav + Szel, Kezdet);
      Kezdet := Veg;
    end;
end;

procedure Kezel(Ti: Integer);
var
  I: Integer;
begin
  for I := 1 to Oszlop do
    Diag[I] := Esemeny(I, Ti);
  RajzolOszlop(Ti mod Oszl);
end;

begin
  grDriver := Detect;
  InitGraph(grDriver, grMode, 'C:\BP\BGI');
  if GraphResult = grOk then
  begin
    Randomize;
    T := 0;
    repeat
      SetViewPort(0, 0, GetMaxX div 2, GetMaxY div 2, ClipOn);
      BeallitPort;
      Kezel(T);
      Inc(T);
      if T = 32767 then
        T := 0;
      Delay(100);
    until KeyPressed;
  end;
end.