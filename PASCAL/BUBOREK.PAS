program BuborekRendezes;

uses Crt;

const
  Max = 10;

var
  C: Char;
  N, I, J, K: Integer;
  A: Array[1..Max] of Integer;

begin
  Randomize;
  WriteLn('Bubor‚krendez‚s');
  repeat
    Write('A vektor hossza: ');
    ReadLn(N);
  until N in [1..Max];
  Write('Megadott vagy v‚letlen vektor? [M/V] ');
  repeat
    C := UpCase(ReadKey);
  until C in ['M', 'V'];
  WriteLn(C);
  if C = 'M' then
    for I := 1 to N do
    begin
      Write(I :2, '. elem: ');
      ReadLn(A[I]);
    end
  else
    for I := 1 to N do
    begin
      A[I] := Random(100);
      WriteLn(I: 2, '.elem: ', A[I]);
    end;
  for I := N - 1 downto 1 do
    for J := I to N - 1 do
      if A[J] > A[J + 1] then
      begin
        K := A[J];
        A[J] := A[J + 1];
        A[J + 1] := K;
      end;
  WriteLn('Rendezve:');
  for I := 1 to N do
    WriteLn(A[I]);
  Write('Nyomjon meg egy billenty–t!');
  repeat until KeyPressed;
end.
