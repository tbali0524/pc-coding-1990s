program SzetVal;

uses Crt;

const
  N          = 20;
  MaxErtek   = 99;

var
  Tomb : array [1..N] of Integer;
  I, J : Integer;

procedure TombMegadas;
begin
  Randomize;
  for i := 1 to N do
    Tomb [i] := Random(MaxErtek) - MaxErtek DIV 2;
end;

procedure TombKiiras;
begin
  WriteLn('A t”mb:');
  for i := 1 to N - 1 do
    Write( Tomb [i] :3, ',' );
  Writeln( Tomb [N] :3 );
end;

procedure Csere(var Szam1, Szam2 : Integer);

var
  Verem : Integer;

begin
  Verem := Szam1;
  Szam1 := Szam2;
  Szam2 := Verem;
end; { Csere }

procedure Valogatas;
begin
  for I := 1 to N - 1 do
    if Tomb[I] >= 0 then
    begin
      J := I + 1;
      while (J <= N) and (Tomb[J] >= 0) do
        Inc(J);
      if J <= N then
        Csere(Tomb[I], Tomb[J]);
    end;
end;

begin
  WriteLn('Sz‚tv logat¢ program');
  TombMegadas;
  TombKiiras;
  Valogatas;
  WriteLn('Sz‚tv logat s ut n:');
  TombKiiras;
  repeat until KeyPressed;
end.
