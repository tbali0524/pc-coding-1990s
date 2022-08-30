{ DDA2DA.PAS
{ 0D 0D 0A lecserelese 0D 0A -ra szovegfajlban }
{ (c) T¢th B lint, 1995 }

program DDA2DA;
{$I+}
uses Dos;

const
  In1: Byte = $0D;
  In2: Byte = $0D;
  In3: Byte = $0A;
  Out1: Byte = $0D;
  Out2: Byte = $0A;
var
  InF: File of Byte;
  OutF: File of Byte;
  InFName: String;
  OutFName: String;
  B1, B2, B3: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  S: PathStr;

begin
  WriteLn('DDA2DA');
  WriteLn;
  if ParamCount = 1 then
  begin
    OutFName := ParamStr(1);
    FSplit(OutFName, D, N, E);
    E := '.BAK';
    InFName := D + N + E;
    Assign(InF, OutFName);
    Rename(InF, InFName);
  end
  else if ParamCount = 2 then
  begin
    InFName := ParamStr(1);
    OutFName := ParamStr(2);
  end
  else
  begin
    WriteLn('Usage: DDA2DA infile [outfile]');
    Halt(1);
  end;
  Assign(InF, InFName);
  Reset(InF);
  if (FileSize(InF) < 3) then
  begin
    WriteLn('Too short inputfile');
    Close(InF);
    Halt(1);
  end;
  Assign(OutF, OutFName);
  Rewrite(OutF);

  Read(InF, B1);
  Read(InF, B2);
  while not Eof(InF) do
  begin
    Read(InF, B3);
    if (B1 = In1) and (B2 = In2) and (B3 = In3) then
    begin
      B2 := Out1;
      B3 := Out2;
    end
    else
      Write(OutF, B1);
    B1 := B2;
    B2 := B3;
  end;
  Write(OutF, B1, B2);
  Close(OutF);
  Close(InF);
  WriteLn('Ok.');
end.
