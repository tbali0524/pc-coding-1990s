program Mondat;

uses Crt;

var
  Szo : string;
  Elval : char;

procedure BetuOlvas(var Betu : char);
begin
  repeat
    Betu := ReadKey;
  until Betu <> ' '
end;

procedure SzoOlvas(var S : string; var E : char);

var B : char;

begin
  S := '';
  BetuOlvas(B);
  while not (B in [',', '.']) do
  begin
    S := S + B;
    BetuOlvas(B);
  end;
  Elval := B;
end;

begin
  repeat
    SzoOlvas(Szo, Elval);
    WriteLn(Szo);
  until Elval = '.';
end.
