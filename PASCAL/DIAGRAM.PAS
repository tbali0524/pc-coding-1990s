program Diagram;

uses Crt, Graph;

const
  Oszlop = 20;
  Csokkenes = 2;

var
  grDriver, grMode,
  Tav, Szel, Oszto, T: Integer;
  V: ViewPortType;
  Diag: Array[0..Oszlop - 1] of Integer;

procedure Init;
begin
  for T := 0 to Oszlop - 1 do
    Diag[T] := 0;
  T := 0;
  Oszto := 1;
end;

procedure BeallitPort;
begin
  GetViewSettings(V);
  Tav := (V.X2 - V.X1) div Oszlop;
  if Tav = 0 then
    Tav := 1;
  if Tav > 2 then
    Szel := Tav -  2
  else
    Szel := 1;
end;

function Esemeny(T: Integer): Integer;
begin
  if Odd(Oszlop) then
    Esemeny := Random(Oszlop div 2 + 1) + Random(Oszlop div 2 + 1)
  else
    Esemeny := Random(Oszlop div 2 + 1) + Random(Oszlop div 2);
end;

procedure RajzolOszlop(O: Integer);
begin
  if Diag[O] div Oszto > 0 then
    Bar(O * Tav, V.Y2 - V.Y1 - Diag[O] div Oszto, O * Tav + Szel,
      V.Y2 - V.Y1);
end;

procedure Kepernyo;
var
  I: Integer;
begin
  ClearViewPort;
  for I := 0 to Oszlop - 1 do
    RajzolOszlop(I);
end;

procedure Kezel(E: Integer);
begin
  if Diag[E] < 32767 then
    Inc(Diag[E]);
  if Diag[E] div Oszto > V.Y2 - V.Y1 then
  begin
    Oszto := Oszto * Csokkenes;
    if Oszto = 32768 then
      Init;
    Kepernyo;
  end
  else
    RajzolOszlop(E);
end;

begin
  grDriver := Detect;
  InitGraph(grDriver, grMode, 'C:\BP\BGI');
  if GraphResult = grOk then
  begin
    Randomize;
    Init;
    repeat
      SetViewPort(0, 0, GetMaxX div 2, GetMaxY div 2, ClipOn);
      BeallitPort;
      Kezel(Esemeny(T));
      Inc(T);
      if T = 32767 then
        T := 0;
    until KeyPressed;
  end;
end.