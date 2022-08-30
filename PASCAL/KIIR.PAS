program Kiir;
uses Dos;
const
  N = 10000;
  K = 5000;
var
  I, C: Integer;
  A: Array[0..N] of Boolean;
  A1, A2, A3, A4: Word;

begin
  Randomize;
  for I := 0 to N do
    A[I] := False;
  I := 0;
  SetTime(0,0,0,0);
  while (I < K) do
  begin
    C := Random(N);
    if not A[C] then
    begin
      Inc(I);
      A[C] := True;
    end;
  end;
  GetTime(A1, A2, A3, A4);
{  for I := 0 to N do
    if A[I] then
      Write(I: 7, ',');
}  WriteLn;
  WriteLn(A1: 5, A2: 5, A3: 5, A4: 5);
end.