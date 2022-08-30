{ T¢th B lint, 1992 }
program P1; { Let's Go To The Movies! }

var
  F1, F2: Text;
  S: String;
  C, { H ny ”tvenes van a p‚nzt rban }
  M, 
  N: Integer;
  I: Longint;

procedure Rekurziv;

begin
  Inc(M);
  if M = N + 1 then
    Inc(I)
  else
  begin
    if C > 0 then
    begin
      Dec(C);
      Rekurziv;
      Inc(C);
    end;
    Inc(C);
    Rekurziv;
    Dec(C);
  end;
  Dec(M);
end;

begin { f“program }
  WriteLn('Mozi (c) T¢th B lint, 1992.');
  Assign(F1, 'P1.INP');
  Reset(F1);
  {$I-}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(1);
  end;
  Assign(F2, 'P1.OUT');
  Rewrite(F2);
  while not Eof(F1) do
  begin
    ReadLn(F1, S);
    Val(S, N, M);
    if M > 0 then
    begin
      WriteLn('HIBA');
      Halt(1);
    end;
    C := 0;
    I := 0;
    M := 0;
    Rekurziv;
    Str(I, S);
    WriteLn(F2, S);
  end;
  Close(F1);
  Close(F2);
  WriteLn('Ok');
end.

