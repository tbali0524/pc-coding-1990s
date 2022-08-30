program DJ2Proba; { Szerk es DJSzerk unitok tesztje }

{B-,D+,I+,L+,R+,S+,V+,X-}
uses Crt, kbConst, Szerk, DJSzerk;
var
  Sz: Array[1..4] of PSzerk;
  R, T, I: Byte;
  Bi, SB: Char;
begin
  Sz[1] := New(PFejlec, Init);
  Sz[2] := New(PTores, Init);
  Sz[3] := New(PTetel, Init);
  Sz[4] := New(PSzabvany, Init);
  R := 1;
  T := 1;
  DJSzerkKep(Sz[1], Sz[2], Sz[3]);
  repeat
    Sz[T]^.EBelepTabla;
    repeat
      with Sz[T]^ do begin
        EKurzor(GS, GO, GP);
        GBill(Bi, SB);
        EKezelBill(Bi, SB);
      end;
      if UjTabla then
        if T < 4 then
          if Bi = #0 then
            if SB = kbF6 then begin
              R := T;
              T := 4;
              SzSzerkKep(Sz[4]);
            end
            else { ShiftTab }
              T := (T + 4) mod 3 + 1
          else { Tab }
            T := T mod 3 + 1
        else { SzabvanySzerk }
          if (Bi = #0) and (SB = kbF6) then begin
            T := R;
            DJSzerkKep(Sz[1], Sz[2], Sz[3]);
          end;
    until Kilepes or UjTabla;
  until Kilepes;
  for I := 1 to 4 do
    Dispose(Sz[I], Done);
  ClrScr;
end.
