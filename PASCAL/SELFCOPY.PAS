{ SELFCOPY.PAS
{ Fajl tartalom atmasolasa uj fajlba }
{ (c) T¢th B lint, 1995 }

program SelfCopy;
{$I+}
uses Dos;

var
  InF: File of Byte;
  OutF: File of Byte;
  InFName: String;
  OutFName: String;
  B: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;

begin
  WriteLn('SelfCopy');
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
    WriteLn('Usage: SelfCopy infile [outfile]');
    Halt(1);
  end;
  Assign(InF, InFName);
  Reset(InF);
  Assign(OutF, OutFName);
  Rewrite(OutF);

  while not Eof(InF) do
  begin
    Read(InF, B);
    Write(OutF, B);
  end;
  Close(OutF);
  Close(InF);
  WriteLn('Ok.');
end.
