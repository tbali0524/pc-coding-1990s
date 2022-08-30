program Kereso;
uses Dos;
const
  N = 10000;

var
  I, Z: Integer;
  A, B: Array[0..N] of Integer;
  A1, A2, A3, A4: Word;

begin
  Randomize;
  ReadLn(Z);
  for I := 0 to N do
    B[I] := 0;
  for I := 1 to N do
  begin
    A[I] := Random(10000);
    B[A[I]] := I;
{    Write(A[I]: 7, ',');
}  end;
  SetTime(0,0,0,0);
  I := 1;
  while (I <= N) and (A[I] <> Z) do
    Inc(I);
  GetTime(A1, A2, A3, A4);
  if { B[Z] > 0 } I <= N then
    WriteLn('TALALT ' , B[Z])
  else
    WriteLn('NEM TALALT');
  WriteLn(A1: 5, A2: 5, A3: 5, A4: 5);
end.