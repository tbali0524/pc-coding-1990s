program Rendezo;
{$M 65520,0,655360}
uses Dos;
const
  N = 1000;
var
  A: Array[1..N] of Real;
  I: Integer;
  E, B, C, D: Word;

procedure Rendez(L, R: Integer);
var
  L1, R1: Integer;
  X, V: Real;
begin
  L1 := L;
  R1 := R;
  X := A[(L1 + R1) div 2];
  repeat
    while A[L1] < X do
      Inc(L1);
    while A[R1] > X do
      Dec(R1);
    if L1 <= R1 then
    begin
      V := A[L1];
      A[L1] := A[R1];
      A[R1] := V;
      Inc(L1);
      Dec(R1);
    end;
  until L1 > R1;
  if  L < R1 then
    Rendez(L, R1);
  if R > L1 then
    Rendez(L1, R);
end;

begin
  Randomize;
  for I := 1 to N do
    A[I] := Random(10000);
  SetTime(0,0,0,0);
  Rendez(1, N);
  GetTime(E, B, C, D);
  for I := 1 to N do
    Write(A[I]: 9, ',');
  WriteLn;
  WriteLn(E, ',', B, ',', C, ',', D);
end.

