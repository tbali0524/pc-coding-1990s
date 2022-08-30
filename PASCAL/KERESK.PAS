program KeresKadik;
uses Dos;
const
  N = 10;

var
  I, J, K, Max: Integer;
  ElozoMax: Real;
  A: Array[1..N] of Real;
  B: Array[1..N] of Boolean;
  A1, A2, A3, A4: Word;

begin
  Randomize;
  ReadLn(K);
  for I := 1 to N do
    A[I] := Random(10000);
  SetTime(0,0,0,0);
  ElozoMax := 30000;
  for I := 1 to N do
    B[I] := False;
  for I := 1 to K do
  begin
    Max := 1;
    while (Max < N) and B[Max] do
      Inc(Max);
    for J := Max to N do
      if (A[J] >= A[Max]) and (not B[J]) then
        Max := J;
    B[Max] := True;
    ElozoMax := A[Max];
  end;
  GetTime(A1, A2, A3, A4);
  for I := 1 to N do
    Write(A[I]: 9, ',');
  WriteLn;
  WriteLn(ElozoMax: 9);
  WriteLn(A1: 5, A2: 5, A3: 5, A4: 5);
end.
