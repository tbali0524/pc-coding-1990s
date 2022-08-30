program ABCRend;
const
  ABC: String = 'a † b c csd dze Ç f g gyh i ° j k l lym n nyo ¢ î ì p q r '+
    's szt tyu £ Å ñ v w x y z ';
var
  S1, S2: String;
  I: Integer;
function Megeloz(S1, S2: String): Boolean;
var
  I, J, K: Integer;

begin
  S1 := S1 +' ';
  S2 := S2 + ' ';
  I := 1;
  Megeloz := False;
  while (I <= Length(S1)) and (I <= Length(S2)) and (S1[I] = S2[I]) do
    Inc(I);
  if (I = Length(S1)) and (I < Length(S2)) then
    Megeloz := True
  else
  begin
    J := Pos(Copy(S1, I - 1, 2), ABC);
    if J = 0 then
    begin
      J := Pos(Copy(S1, I, 2), ABC);
      if J = 0 then
        J := Pos(Copy(S1, I, 1), ABC);
    end;
    K := Pos(Copy(S2, I - 1, 2), ABC);
    if K = 0 then
    begin
      K := Pos(Copy(S2, I, 2), ABC);
      if K = 0 then
        K := Pos(Copy(S2, I - 1, 1), ABC);
    end;
    Megeloz := J < K;
  end;
end;

begin
  ReadLn(S1);
  ReadLn(S2);
  WriteLn(Megeloz(S1, S2));
end.
