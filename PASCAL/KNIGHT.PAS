{ T¢th B lint, 1992 }
program Knight;

{$B-}
const
  N = 6; { a t bla m‚rete }
  LepVarSzam = 8; { h nyf‚le l‚p‚s van }
  Lepes: Array[1..LepVarSzam, 1..2] of Integer = (
    ( 2,  1), ( 2, -1), (-2,  1), (-2, -1),
    ( 1,  2), ( 1, -2), (-1,  2), (-1, -2)); { a lehets‚ges l‚p‚sek }
type
  MezoT = (Ures, MarVolt, Fekete);
  LepSorT = Array[1..N * N, 1..2] of Integer;
var
  A: Array[1..N, 1..N] of MezoT; { a sakkt bla }
  JoSor, { az eddigi legjobb l‚p‚ssorozat }
  LepSor: LepSorT; { a l‚p‚ssorozat }
  M, { az eddigi legkisebb l‚p‚ssz m }
  H, { a jelenlegi l‚p‚ssz m, a rekurzi¢ m‚lys‚ge }
  KX, KY, { Kezd“poz¡ci¢ }
  B: Integer; { marad‚k feket‚k sz ma }

procedure OlvasInp;
var
  X, Y: Integer;
  S: String;
  F: Text;
begin
  Assign(F, 'KNIGHT.INP');
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(1);
  end;
  for X := 1 to N do
    for Y := 1 to N do
      A[X, Y] := Ures;
  B := -1;
  while not Eof(F) do
  begin
    ReadLn(F, S);
    if Length(S) <> 2 then
    begin
      WriteLn('Nem megfelel“ file-form tum!');
      Halt(2);
    end;
    X := Ord(UpCase(S[1])) - Ord('A') + 1;
    Y := Ord(UpCase(S[2])) - Ord('1') + 1;
    if (X < 1) or (X > N) or (Y < 1) or (Y > N) then
    begin
      WriteLn('Nem megfelel“ file-form tum!');
      Halt(2);
    end;
    if B = -1 then
    begin
      KX := X;
      KY := Y;
    end
    else
      A[X, Y] := Fekete;
    Inc(B);
  end; { while }
  Close(F);
end; { OlvasInp }

procedure Rekurziv(X, Y: Integer);
var
  Mezo: MezoT;
  I, Z, W: Integer;
begin
  Inc(H);
  if (H + B) <= M then
  begin
    Mezo := A[X, Y];
    LepSor[H, 1] := X;
    LepSor[H, 2] := Y;
    A[X, Y] := MarVolt;
    if Mezo = Fekete then
      Dec(B);
    if B = 0 then
    begin
      JoSor := LepSor;
      M := H;
    end
    else
      for I := 1 to LepVarSzam do
      begin
        Z := X + Lepes[I, 1];
        W := Y + Lepes[I, 2];
        if (Z > 0) and (Z <= N) and (W > 0) and (W <= N)
          and (A[Z, W] <> MarVolt) then
            Rekurziv(Z, W);
      end; { for }
    A[X, Y] := Mezo;
    if Mezo = Fekete then
      Inc(B);
  end; { if H }
  Dec(H);
end; { Rekurziv }

procedure KiirOut;
var
  I: Integer;
  F: Text;
begin
  Assign(F, 'KNIGHT.OUT');
  Rewrite(F);
  for I := 1 to M do
    WriteLn(F, Chr(JoSor[I, 1] + Ord('A') - 1) +
      Chr(JoSor[I, 2] + Ord('1') - 1));
  Close(F);
end; { KiirOut }

begin
  WriteLn('Knight   (c) T¢th B lint, 1992');
  OlvasInp;
  M := N * N;
  H := 0;
  Rekurziv(KX, KY);
  KiirOut;
  WriteLn('Ok');
end.
