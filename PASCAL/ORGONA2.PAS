program OrgonasipRendezes2;

uses Crt;

const
  N          = 20;
  MaxErtek   = 99;

type
  TTipus = array [1..N] of Integer;

var
  A, B : TTipus;
  L, X, I, J : Integer;

procedure TombMegadas;
begin
  Randomize;
  for i := 1 to N do
    A[i] := Random(MaxErtek) - MaxErtek DIV 2;
end;

procedure TombKiiras(T : TTipus);
begin
  WriteLn('A t”mb:');
  for i := 1 to N - 1 do
    Write(T[i] :3, ',' );
  Writeln(T[N] :3 );
end;

procedure Csere(var Szam1, Szam2 : Integer);

var
  Verem : Integer;

begin
  Verem := Szam1;
  Szam1 := Szam2;
  Szam2 := Verem;
end; { Csere }

procedure Rendezes;
begin
  X := (N + 1) div 2;
  for I := 1 to N do
  begin
    L := I;
    for J := 1 to N do
      if A[J] > A[L] then
        L := J;
    B[X] := A[L];
    A[L] := - MaxErtek;
    if not Odd(I) then
      X := X - I
    else
      X := X + I;
  end;
end;

begin
  TombMegadas;
  TombKiiras(A);
  Rendezes;
  TombKiiras(B);
  repeat until KeyPressed;
end.
