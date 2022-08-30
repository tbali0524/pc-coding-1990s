program Lekotes;
{ Havi fix osszeg lekotese 50 honapon keresztul }
const
  Havi = 10000.0;
  Kamat: Array[1..4] of Real =
    (1.18, 1.15, 1.15, 1.12);
var
  I, Ev, Ho: Integer;
  Ertek, K1, K2: Real;
begin
  Ertek := 0.0;
  for Ev := 1 to 4 do
  begin
    K1 := 1.0;
    for I := Ev to 3 do
      K1 := K1 * Kamat[I];
    WriteLn('K1 = ', K1:5:2);
    for Ho := 1 to 12 do
    begin
      K2 := Havi * K1 * (1 + (Ho + 2) / 12 * (Kamat[4] - 1));
      Ertek := Ertek + K2;
    end;
  end;
  Ertek := Ertek + Havi + Havi * (1 + (Kamat[4] - 1) / 12);
  WriteLn;
  WriteLn(Ertek:8:0);
end.
