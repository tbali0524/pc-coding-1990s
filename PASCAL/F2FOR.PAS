{ Normal szovegfile -> Fortran forrasfile konverzio }
{ (c) T¢th B lint, 1994 }

{ Minden sort kiegeszit a 73-80. karaktereken a sorszamaval }
program F2For;
{$I+}

const
  SPC = '                                                                         ';
var
  InF: Text;
  OutF: Text;
  InFName: String;
  OutFName: String;
  InS: String;
  OutS: String;
  S2: String;
  I, J, K: Integer;

begin
  WriteLn('F2FOR');
  WriteLn;
  if (ParamCount <> 2) and (ParamCount <> 3) then
  begin
    WriteLn('Usage: F2FOR infile outfile [startnum]');
    Halt(1);
  end;
  InFName := ParamStr(1);
  OutFName := ParamStr(2);
  K := 0;
  if ParamCount = 3 then
    Val(ParamStr(3), J, K);
  if K <> 0 then
    J := 10;
  Assign(InF, InFName);
  Reset(Inf);
  Assign(OutF, OutFName);
  Rewrite(OutF);
  while not Eof(InF) do
  begin
    ReadLn(InF, InS);
    OutS := Copy(InS + SPC, 1, 72);
    for I := 1 to Length(OutS) do
      OutS[I] := UpCase(OutS[I]);
    Str(J, S2);
    OutS := OutS + 'BAL' + Copy('00000', 1, 5 - Length(S2)) + S2;
    WriteLn(OutF, OutS);
    Inc(J, 10);
  end;
  WriteLn('Ok.');
  Close(OutF);
  Close(InF);
end.
