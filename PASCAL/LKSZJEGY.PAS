var
  A: Array[0..9] of Integer; { h ny darab van az egyes sz mjegyekb“l }

procedure KeresLegkozelebbi(var Je, Ta: Integer; Elso: Boolean);
{ Kikeresi a sz mb¢l a k‚t legk”zelebbi sz mjegyet.
  Ha Elso igaz, akkor a 0-t nem veszi figyelembe.
}
var
  Jegy, Tav: Integer;
  Talalt: Boolean;
begin
  Talalt := False;
  Tav := 0;
  while (not Talalt) and (Tav <= 9) do
  begin
    Jegy := 0;
    while (not Talalt) and (Jegy <= 9) do
    begin
      if ((not Elso) or (Jegy > 0)) and { els“ jegy nem lehet 0 }
         (((Tav = 0) and (A[Jegy] >= 2)) or
         ((Tav > 0) and (A[Jegy] > 0) and (A[Jegy + Tav] > 0))) then
        Talalt := True
      else
        Inc(Jegy);
    end; { while ... Jegy }
    if not Talalt then
      Inc(Tav);
  end; { while ... Tav }
  Je := Jegy;
  Ta := Tav;
end; { KeresLegkozelebbi }
