{ M†trix mÅveletek - Copyright (c) 1992  T¢th B†lint }
unit Matrix;
{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,655360}

interface

const
  Max = 10;
type
  MatrixT = Array[1..Max, 1..Max] of Real;

procedure Veletlen(var A: MatrixT; N, M: Integer);
procedure Bevitel(var A: MatrixT; var N, M: Integer);
procedure Kiiras(A: MatrixT; N, M: Integer);
procedure Torles(var A: MatrixT; N, M: Integer);
procedure Egyseg(var A: MatrixT; N: Integer);
procedure SkalarSzorzas(var A: MatrixT; N, M: Integer; R: Real);
procedure Osszeadas(A, B: MatrixT; var C:MatrixT; N, M: Integer);
procedure Kivonas(A, B: MatrixT; var C:MatrixT; N, M: Integer);
procedure Szorzas(A, B: MatrixT; var C: MatrixT; N, L, M: Integer);
procedure Hatvanyozas(A: MatrixT; var B: MatrixT; N, Kitevo: Integer);
procedure Gauss(var A: MatrixT; N, M: Integer);
function AlDeterminans(A: MatrixT; N, Sor, Oszlop: Integer): Real;
function Determinans(A: MatrixT; N: Integer): Real;
procedure Inverz(A: MatrixT; var B:MatrixT; N: Integer);

implementation

procedure Veletlen(var A: MatrixT; N, M: Integer);
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to M do
      A[I, J] := Random(10);
end; { Veletlen }

procedure Bevitel(var A: MatrixT; var N, M: Integer);
var
  I, J: Integer;
begin
  Write('Sorok sz†ma: ');
  ReadLn(N);
  Write('Oszlopok sz†ma: ');
  ReadLn(M);
  for I := 1 to N do
  begin
    WriteLn(I, '. sor');
    for J := 1 to M do
    begin
      Write(' ', J, '. oszlop: ');
      ReadLn(A[I, J]);
    end;
  end;
end; { Bevitel }

procedure Kiiras(A: MatrixT; N, M: Integer);
var
  I, J: Integer;
begin
  for I := 1 to N do
  begin
    for J := 1 to M do
    begin
      if Abs(A[I, J]) < 0.05 then
        A[I, J] := 0;
      Write(A[I, J] : 10 : 1, ', ');
    end;
    WriteLn;
  end;
end; { Kiiras }

procedure Torles(var A: MatrixT; N, M: Integer);
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to M do
      A[I, J] := 0.0;
end; { Torles }

procedure Egyseg(var A: MatrixT; N: Integer);
var
  I: Integer;
begin
  Torles(A, N, N);
  for I := 1 to N do
    A[I, I] := 1.0;
end; { Egyseg }

procedure SkalarSzorzas(var A: MatrixT; N, M: Integer; R: Real);
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to M do
      A[I, J] := A[I, J] * R;
end; { SkalarSzorzas }

procedure Osszeadas(A, B: MatrixT; var C:MatrixT; N, M: Integer);
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to M do
      C[I, J] := A[I, J] + B[I, J];
end; { Osszeadas }

procedure Kivonas(A, B: MatrixT; var C:MatrixT; N, M: Integer);
var
  I, J: Integer;
begin
  for I := 1 to N do
    for J := 1 to M do
      C[I, J] := A[I, J] - B[I, J];
end; { Kivonas }

procedure Szorzas(A, B: MatrixT; var C: MatrixT; N, L, M: Integer);
var
  I, J, K: Integer;
  R: Real;
begin
  for I := 1 to N do
    for J := 1 to M do
    begin
      R := 0;
      for K := 1 to L do
        R := R + A[I, K] * B[K, J];
      C[I, J] := R;
    end;
end; { Szorzas }

procedure Hatvanyozas(A: MatrixT; var B: MatrixT; N, Kitevo: Integer);
var
  I: Integer;
  C: MatrixT;
begin
  if Kitevo > 0 then
  begin
    B := A;
    for I := 2 to Kitevo do
    begin
      Szorzas(A, B, C, N, N, N);
      B := C;
    end;
  end
  else if Kitevo = 0 then
    Egyseg(B, N)
  else
  begin
    Hatvanyozas(A, C, N, -Kitevo);
    Inverz(C, B, N);
  end;
end; { Hatvanyozas }

procedure Gauss(var A: MatrixT; N, M: Integer);
var
  I, J, K: Integer;
  R: Real;
begin
  if M < N then
    K := M
  else
    K := N;
  for I := 1 to K do
    for J := 1 to N do
      if A[I, I] <> 0.0 then
        if J = I then
        begin
          R := A[J, J];
          for K := J to M do
            A[J, K] := A[J, K] / R;
        end
        else
        begin
          R := A[J, I] / A[I, I];
          for K := I to M do
            A[J, K] := A[J, K] - R * A[I, K];
        end;
end; { Gauss }

function AlDeterminans(A: MatrixT; N, Sor, Oszlop: Integer): Real;
var
  I, J, E: Integer;
  B: MatrixT;
begin
  for I := 1 to Sor - 1 do
  begin
    for J := 1 to Oszlop - 1 do
      B[I, J] := A[I, J];
    for J := Oszlop to N - 1 do
      B[I, J] := A[I, J + 1];
  end;
  for I := Sor to N - 1 do
  begin
    for J := 1 to Oszlop - 1 do
      B[I, J] := A[I + 1, J];
    for J := Oszlop to N - 1 do
      B[I, J] := A[I + 1, J + 1];
  end;
  if Odd(Oszlop) then
    E := 1
  else
    E := -1;
  AlDeterminans := Determinans(B, N - 1) * E;
end; { AlDeterminans }

function Determinans(A: MatrixT; N: Integer): Real;
var
  I: Integer;
  R: Real;
begin
  if  N = 2 then
    Determinans := A[1, 1] * A[2, 2] - A[1, 2] * A[2, 1]
  else
  begin
    R := 0;
    for I := 1 to N do
      if A[N, I] <> 0.0 then
        R := R + A[N, I] * AlDeterminans(A, N, N, I);
    Determinans := R;
  end;
end; { Determinans }

procedure Inverz(A: MatrixT; var B:MatrixT; N: Integer);
var
  I, J: Integer;
  R: Real;
begin
  R := Determinans(A, N);
  if R <> 0.0 then
    for I := 1 to N do
      for J := 1 to N do
        B[I, J] := AlDeterminans(A, N, I, J) / R;
end; { Inverz }

end. { unit }
