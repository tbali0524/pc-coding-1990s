{ Fortran forrasfile -> normal szovegfile konverzio }
{ (c) T¢th B lint, 1994 }

{ Minden sorbol levagja a 73-80. karaktereket es az ezt megelozo }
{ sorvegi szokozoket }
program For2F;
{$I+}

var
  InF: Text;
  OutF: Text;
  InFName: String;
  OutFName: String;
  InS: String;
  OutS: String;
  I: Integer;

begin
  WriteLn('FOR2F');
  WriteLn;
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: FOR2F infile outfile');
    Halt(1);
  end;
  InFName := ParamStr(1);
  OutFName := ParamStr(2);
  Assign(InF, InFName);
  Reset(InF);
  Assign(OutF, OutFName);
  Rewrite(OutF);
  WriteLn('Converting ', InFName, ' to ', OutFName, '...');
  while not Eof(InF) do
  begin
    ReadLn(InF, InS);
    I := 72;
    if I > Length(InS) then
      I := Length(InS);
    while (InS[I] = ' ') do
      Dec(I);
    OutS := Copy(InS, 1, I);
    WriteLn(OutF, OutS);
  end;
  WriteLn('Ok.');
  Close(OutF);
  Close(InF);
end.
