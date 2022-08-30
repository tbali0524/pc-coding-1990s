program SorMaxMin;

uses Crt;

const
  N = 22;
  K = 19;
  MaxElem = 100;

var
  A : array[1..N, 1..K] of Integer;

procedure Veletlen;
var I, J : Integer;
begin
  for I := 1 to N do
    for J := 1 to K do
      A[I, J] := Random(MaxElem);
end;

procedure Kiiras;
var I, J : Integer;
begin
  WriteLn('A t”mb:');
  for I := 1 to N do
  begin
    for J := 1 to K do
      Write(A[I, J] : 3, ',');
    WriteLn;
  end;
end;

function SMaxMin : Integer;
var R, S, I, J : Integer;
begin
  R := MaxElem;
  for I := 1 to N do
  begin
    S := A[I, 1];
    for J := 1 to K do
      if S < A[I, J] then
        S := A[I, J];
    if R > S then
      R := S;
  end;
  SMaxMin := R;
end;

begin
  Randomize;
  Veletlen;
  Kiiras;
  WriteLn('A sormaximumok minimuma: ', SMaxMin);
  repeat until KeyPressed;
end.
