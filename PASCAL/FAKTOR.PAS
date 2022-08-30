program FaktorSzam;

{$N+,E+}
{$M 65520,0,655360}

var K: Integer;

function Faktor1(N: Integer): Extended;
begin
  if N > 1 then
    Faktor1 := Faktor1(N - 1) * N
  else
    Faktor1 := 1;
end;

function Faktor2(N: Integer): Extended;
var
  I: Integer;
  S: Extended;
begin
  S:= 1;
  for I := 2 to N do
    S := S * I;
  Faktor2 := S;
end;

begin
  repeat
    Write('Kerem a szamot (0 = vege): ');
    ReadLn(K);
    if K > 0 then
      WriteLn('Faktorialisa: ', Faktor1(K), '  ', Faktor2(K));
   until K = 0;
end.
