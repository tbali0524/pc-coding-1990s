program Halmaz;
const
  N = 4;
var
  A: Array[1..N] of Integer;
  B: Array[1..N] of Boolean;
  I, M: Integer;
procedure Rekurziv;
var
  I: Integer;
begin
  Inc(M);
  if M = (N + 1) then
  begin
    Write('{');
    for I := 1 to N do
      if B[I] then
        Write(A[I], ',');
    WriteLn('}');
  end
  else
  begin
    B[M] := True;
    Rekurziv;
    B[M] := False;
    Rekurziv;
  end;
  Dec(M);
end;

begin
  for I := 1 to N do
    A[I] := I;
  M := 0;
  Rekurziv;
end.