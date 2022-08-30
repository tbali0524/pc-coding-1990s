program Uldozes;

uses Crt, Graph;

const
  N = 100;

var
  Gr, Gm, I : integer;
  X, Y      : array[1..N] of word;

begin { program }
  DetectGraph(Gr, Gm);
  InitGraph(Gr, Gm, 'c:\bp\bgi');
  for I := 1 to N do
  begin
    X[I] := Random(GetMaxX);
    Y[I] := Random(GetMaxY);
  end; { for }
  repeat
    for I := 1 to N do
    begin
      PutPixel(X[I], Y[I], Black);
      if X[I] > X[(I + 1) mod N]  then
        X[I] := X[I] - 1
      else
        if X[I] < X[(I + 1) mod N] then
          X[I] := X[I] + 1;
      if Y[I] > Y[(I + 1) mod N]  then
        Y[I] := Y[I] - 1
      else
        if Y[I] < Y[(I + 1) mod N] then
          Y[I] := Y[I] + 1;
      X[I] := X[I] mod GetMaxX;
      Y[I] := Y[I] mod GetMaxY;
      PutPixel(X[I], Y[I], White);
    end; { for }
  until KeyPressed;
  CloseGraph;
end.
