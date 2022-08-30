{ T¢th B lint,
  BME, Vill. ‚s Inf. Kar, M. Informatika Szak, I. ‚vfolyam 2. f‚l‚v, 3. tank.
  Sz m¡t¢g‚p labor h zi feladat (1), 1993. janu r 21.

  6: Line ris egyenletrendszer megold sa LU dekompoz¡ci¢val
     Szorz sm–veletek sz m nak ki¡r sa
}
program LU;
{ Megjegyz‚sek:
   - minden r‚szeredm‚ny kl”n t”mbben van a k”z‚rthet“s‚g kedv‚‚rt
   - f jlb¢l val¢ olvas sn l nincs semmif‚le ellen“rz‚s
      (a k¡v nt form tum le¡r sa a Bevitel elj r sn l)
   - az egyenleteket £gy adjuk meg, hogy a f“ tl¢ban ne legyen 0
}
uses Crt;

const
  Max = 10;     { egyenletek max. sz ma }
type
  MatrixT = Array[1..Max, 1..Max] of Real;
  VektorT = Array[1..Max] of Real;
var
  N: Integer;    { az egyenletek sz ma }
  A: MatrixT;    { az egytthat¢k }
  B: VektorT;    { a jobboldal }
  L, U: MatrixT; { L ‚s U m trixok: a dekompoz¡ci¢ eredm‚nyei }
  X: VektorT;    { a megold s }
  M: Integer;    { szorz sm–veletek sz ma }
  I: Integer;

procedure Bevitel; { Bemen“ adatok olvas sa }
var
  I, J, K: Integer;
  C: Char;
  FN: String;
  F: Text;
  S: String;
begin
  Write('F jlb¢l k¡v n bemen“ adatokat t”lteni? [I/N] ');
  repeat
    C := UpCase(ReadKey);
  until C in ['I', 'N'];
  WriteLn(C);
  WriteLn;
  if C = 'N' then
  begin
    Write('Egyenletek sz ma: ');
    repeat
      ReadLn(N);
    until (N >= 1) and (N <= Max);
    for I := 1 to N do
    begin
      WriteLn(I, '. egyenlet');
      for J := 1 to N do
      begin
        Write('  x', J, ' egytthat¢ja: ');
        ReadLn(A[I, J]);
      end;
      Write('  Jobboldal: ');
      ReadLn(B[I]);
    end;
  end { if C }
  else
  begin
    WriteLn('F jlform tum: ASCII sz”vegf jlban val¢s sz mok');
    WriteLn('Az els“ sorban az egyenletek sz ma, ut na sorra az egyenletek');
    WriteLn('egytthat¢k ill. jobboldal sorrendben');
    WriteLn('( N, A11, A12, ... A1N, B1, A21, A22 ...  ANN, BN )');
    WriteLn('Minden sorban csak egy sz m (‚s semmi m s)');
    WriteLn('Ellen“rz‚s nincs.');
    WriteLn;
    Write('F jln‚v? [LU.INP]  ');
    ReadLn(FN);
    if FN = '' then
      FN := 'LU.INP';
    Assign(F, FN);
    {$I-}
    Reset(F);
    {$I+}
    if IOResult <> 0 then
    begin
      WriteLn('Nem tudom megnyitni a f jlt!');
      Halt(1);
    end;
    ReadLn(F, S);
    Val(S, N, K);
    for I := 1 to N do
    begin
      for J := 1 to N do
      begin
        ReadLn(F, S);
        Val(S, A[I, J], K);
      end;
      ReadLn(F, S);
      Val(S, B[I], K);
    end;
    Close(F);
  end; { else }
end; { Bevitel }

procedure Dekomp;                       { L ‚s U meghat roz sa }
var
  I, J, K: Integer;
  S: Real;
begin
  for I := 1 to N do
  begin
    L[I, I] := 1;                      { L f“ tl¢j t v lasztom 1-nek }
    for J := 1 to N do
      if I > J then
      begin
        S := 0;
        for K := 1 to J - 1 do
          S := S + L[I, K] * U[K, J];
        Inc(M, J - 1);
        L[I, J] := (A[I, J] - S) / U[J, J];
      end
      else
      begin
        S := 0;
        for K := 1 to I - 1 do
          S := S + L[I, K] * U[K, J];
        Inc(M, I - 1);
        U[I, J] := A[I, J] - S;        { / L[I, I] elmarad, mert 1 }
      end;
  end;
end; { Dekomp }

procedure Megold;
var
  Y: VektorT;                           { Y = U X }
  I, J: Integer;
  S: Real;
begin
 { Y meghat roz sa }
  for I := 1 to N do
  begin
    S := 0;
    for J := 1 to I - 1 do
      S := S + L[I, J] * Y[J];
    Inc(M, I - 1);
    Y[I] := (B[I] - S);                 { / L[I, I] elmarad, mert 1 }
  end;
 { X meghat roz sa }
  X[N] := Y[N] / U[N, N];
  for I := N - 1 downto 1 do
  begin
    S := 0;
    for J := I + 1 to N do
      S := S + U[I, J] * X[J];
    Inc(M, N - I);
    X[I] := (Y[I] - S) / U[I, I];
  end;
end; { Megold }

begin { f“program }
  WriteLn('Line ris egyenletrendszer megold sa LU dekompoz¡ci¢val');
  WriteLn('T¢th B lint, 1993');
  WriteLn;
  M := 0;
  Bevitel;
  Dekomp;
  Megold;
  WriteLn;
  WriteLn('A megold s:');
  for I := 1 to N do
    WriteLn(' X', I, ' = ', X[I]);
  WriteLn;
  WriteLn('A szorz sm–veletek sz ma: ', M);
end.