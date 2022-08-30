program Meres;
const
  N = 20;
  K = 5;
var
  A: Array[1..N] of Real;
  I, J, L: Integer;
begin
  WriteLn;
  for I := 1 to N do
    A[I] := Random(N) + 1;
  I := 0;
  repeat
    J := Random(N) + 1;
    if A[J] > 0 then
    begin
      A[J] := 0;
      Inc(I);
    end;
  until I = K;
  for I := 1 to N do
    Write(A[I]: 9, ',');
  I := 1;
  while (I <= N) do
  begin
    if A[I] > 0 then
      Inc(I)
    else
    begin
      L := I;
      while (L <= N) and (A[L] = 0) do
        Inc(L);
      if I = 1 then
      begin
        for J := 1 to L - 1 do
          A[J] := A[L];
        I := L;
      end
      else
        if L = 101 then
        begin
          for J := I to N do
            A[J] := A[I - 1];
          I := 101;
        end
        else
        begin
          for J := I to L - 1 do
            A[J] := A[J - 1] + (A[L] - A[I - 1]) / (L - I + 1);
          I := L;
        end;
    end;
  end;
  WriteLn('----');
  for I := 1 to N do
    Write(A[I]: 9, ',');
end.
