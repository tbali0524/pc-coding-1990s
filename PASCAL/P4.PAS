{ T¢th B†lint, 1992 }
program P4; { Minimal Difference }
{ A program megvizsg†lja az îsszes elì†ll°that¢ sz†mp†rt. Lehetett volna mÇg
  optimaliz†lni, hiszen ha egy sz†mjegy tîbbszîr szerepel, akkor ugyanazt a
  sz†mp†rt tîbbszîr vizsg†lja, m†srÇszt pl. 6398 6400 illetve 6400 6398
  ugyanaz.  °gy viszont az algoritmus viszonylag egyszerñ, Çs a fut†si idì
  sem tragikus. (Egy 8 jegyñ sz†m vizsg†lata 13 mp a gÇpemen.)
}
const
  Max = 8; { Sz†m maxim†lis hossza }
var
  Inp, Out: Text; { bemenet Çs kimenet }
  S,  { Inp aktu†lis sora }
  MinS, { Az eddigi legjobb sorrend }
  S2: String; { S †trendezve }
  A: Array[1..Max] of Boolean; { volt-e m†r az I. sz†mjegy }
  N, { a sz†m hossza }
  H, { rekurzi¢ mÇlysÇge: h†nyadik jegynÇl tartunk }
  MinKul, { eddigi minim†lis kÅlînbsÇg }
  I: Integer;

procedure Feldolgoz; { Kisebb-e a kÅlînbsÇg, mint az eddigi minimum? }
var
  N1, N2, Kod: Integer;
begin
  Val(Copy(S2, 1, N div 2), N1, Kod);
  Val(Copy(S2, N div 2 + 1, N div 2), N2, Kod);
  if (MinS = '') or (MinKul > (Abs(N1 - N2))) then
  begin
    MinS := S2;
    MinKul := Abs(N1 - N2);
  end;
end; { Feldolgoz }

procedure Rekurziv;
{ minden lehetsÇges sorrend elì†ll°t†sa (Backtrack), vizsg†lat Feldolgoz-zal }
var
  I: Integer;
begin
  Inc(H);
  if H > N then
    Feldolgoz
  else
    for I := 1 to N do
    begin
      if not A[I] then
      begin
        S2 := S2 + S[I];
        A[I] := True;
        Rekurziv;
        A[I] := False;
        Delete(S2, H, 1);
      end; { if }
    end; { for }
  Dec(H);
end; { Rekurziv }

{ fìprogram: sz†mok beolvas†sa Inp-bìl, feldolgoz†s Rekurziv-val }
begin
  WriteLn('Legkisebb kÅlînbsÇg   (c) T¢th B†lint, 1992.');
  Assign(Inp, 'P4.INP');
  Assign(Out, 'P4.OUT');
  {$I-}
  Reset(Inp);
  Rewrite(Out);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(1);
  end;
  while not Eof(Inp) do
  begin
    ReadLn(Inp, S);
    N := Length(S);
    for I := 1 to N do
      A[I] := False;
    MinS := '';
    S2 := '';
    H := 0;
    Rekurziv;
    WriteLn(Out, Copy(MinS, 1, N div 2), ' ', Copy(MinS, N div 2 + 1,
      N div 2), ' ', MinKul);
  end;
  Close(Inp);
  Close(Out);
  WriteLn('Ok');
end.

{ MegjegyzÇsek:
      A program nem ellenìrzi Inp-et, de csak akkor mñkîdik, ha az j¢.
    ( Minden sorban csak p†ros sok sz†mjegy lehet, m†s nem. )
      A bemenì sz†mok legfeljebb nyolc jegyñek lehetnek, mert kÇt Integer-rÇ
    bontom ìket szÇt.
}