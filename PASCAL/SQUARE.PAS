{ T¢th B lint, 1992 }
program Square;
{$B-}

const
  N = 5; { a m trix m‚rete }
  LepVarSzam = 8; { h nyf‚le l‚p‚s van }
  Lepes: Array[1..LepVarSzam, 1..2] of Integer = (
    ( 3,  0), (-3,  0), ( 0,  3), ( 0, -3),
    ( 2,  2), ( 2, -2), (-2,  2), (-2, -2)); { a lehets‚ges l‚p‚sek }
var
  M: Array [1..N, 1..N] of Integer; { a m trix }
  H, { rekurzi¢ m‚lys‚ge (h nyadik rublik t sz mozza) }
  KX, KY, { kezd“poz¡ci¢ }
  S: Integer;

procedure Torol;
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to N do
      M[I, J] := 0;
end;

procedure Kiir; { M trix ki¡r sa }

procedure KiirSor(Sor: Integer); { Egy sor ki¡r sa }
var
  I: Integer;
begin
  Write(Sor: 2, ' ');
  for I := 1 to N do
    Write('º', M[Sor, I] : 3);
  WriteLn('º');
end; { KiirSor }

var
  I, J: Integer;
begin
  Write('  ');
  for I := 1 to N do
    Write('  ', I : 2);
  WriteLn;
  Write('   É');
  for I := 1 to N - 1 do
    Write('ÍÍÍË');
  WriteLn('ÍÍÍ»');
  for J := 1 to N - 1 do
  begin
    KiirSor(J);
    Write('   Ì');
    for I := 1 to N - 1 do
      Write('ÍÍÍÎ');
    WriteLn('ÍÍÍ¹');
  end;
  KiirSor(N);
  Write('   È');
  for I := 1 to N - 1 do
    Write('ÍÍÍÊ');
  WriteLn('ÍÍÍ¼');
end; { Kiir }

procedure Rekurziv(X, Y: Integer);
{ minden lehets‚ges sz moz s el“ ll¡t sa (Backtrack)
    ha S = -1 , akkor csak ki¡rja az els“ j¢ besz moz st
                 (ut na S -2 lesz ‚s visszafele l‚pked a rekurz¡v h¡v sokban)
    ha S >= 0 , akkor S-ben sz molja a j¢ besz moz sokat
}
var
  I, Z, W: Integer;
begin
  Inc(H);
  M[X, Y] := H;
  if H = N * N then
  begin
    if S >= 0 then
      Inc(S)
    else if S = -1 then
    begin
      Kiir;
      S := -2; { hogy csak az els“t ¡rja ki }
    end
  end
  else
    for I := 1 to LepVarSzam do
    begin
      Z := X + Lepes[I, 1];
      W := Y + Lepes[I, 2];
      if (Z > 0) and (Z <= N) and (W > 0) and (W <= N) and (M[Z, W] = 0) then
      begin
        Rekurziv(Z, W);
        M[Z, W] := 0;
        if S = -2 then { ne keressen tov bb }
        begin
          Dec(H);
          Exit;
        end;
      end; { if }
    end; { for }
  Dec(H);
end; { Rekurziv }

{ f“program }
begin
  WriteLn(N, 'x', N, ' m trix besz moz sa    (c) T¢th B lint, 1992.');
  WriteLn('K‚rem a kezd“poz¡ci¢ koordin t it!');
  repeat
    Write(' X: ');
    ReadLn(KX);
  until KX in [1..N];
  repeat
    Write(' Y: ');
    ReadLn(KY);
  until KY in [1..N];
  Torol;
  H := 0;
  S := -1;
  Rekurziv(KX, KY);
  if S = -1 then
    WriteLn('Nem sz mozhat¢ be.');
  WriteLn('A kl”nb”z“ besz moz sok sz ma:');
  WriteLn;
  WriteLn('Kezd“pont ³ besz moz sok sz ma');
  WriteLn('ÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
  for KY := 1 to N do
    for KX := KY to N do
    begin
      Torol;
      H := 0;
      S := 0;
      Rekurziv(KX, KY);
      WriteLn(' (', KX : 2, ',', KY : 2, ')  ³   ', S);
    end;
end.

{ Megjegyz‚sek:
      A n‚gyzet szimmetri ja miatt felesleges kl”n kisz molni a vari ci¢kat
    minden kezd“pontra. (Pl. (1,4)-n‚l ‚s (2, 5)-n‚l nyilv n ugyanaz.)
      M sr‚szt ugyancsak a szimmetria miatt felesleges a backtrack-ben minden
     gon v‚gigmenni. (Pl. (3,3)-b¢l el‚g egyfel‚ elindulni, ‚s az eredm‚nyt
    n‚ggyel szorozni.) Ez azonban sokkal bonyolultabb  tenn‚ az algoritmust.
}
