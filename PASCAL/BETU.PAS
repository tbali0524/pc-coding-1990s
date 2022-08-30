program Betu; { Nem mukodik }

uses Crt;
var
  C: Char;
  S: String;
  I, J, K: Integer;
  Talalt: Boolean;

begin
  WriteLn;
  S := '';
  I := 0;
  Talalt := False;
  repeat
    repeat
      C := UpCase(ReadKey);
    until C in ['A'..'Z'];
    Write(C);
    Inc(I);
    S := S + C;
    J := 1;
    while (not Talalt) and (J <= (I div 3)) do
    begin
      K := 1;
      Talalt := True;
      while Talalt and (K <= J) do
      begin
        if (S[I - J * 3 + K] <> S[I - J - K + 1]) or
          (S[I - J * 3 + K] <> S[I - J + K]) then
            Talalt := False;
        Inc(K);
      end;
      Inc(J);
    end;
  until Talalt;
  WriteLn(' Elfogadtam.');
end.
