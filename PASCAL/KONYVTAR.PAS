{ èlmos Attila & T¢th B†lint }
program KonyvtarFa;

uses Crt, Dos;

var
  D: PathStr;
  Utolso: Array[1..128] of Boolean;

procedure Konyvtar(P: PathStr; M: Integer);
const
  KezdoDir = #13#13;
var
  SR: SearchRec;
  Elozo: NameStr;
  I: Integer;
begin
  Elozo := KezdoDir;
  FindFirst(P + '*.*', AnyFile, SR);
  while DosError = 0 do
  begin
    if ((SR.Attr and Directory) <> 0) and (SR.Name[1] <> '.') then
    begin
      if Elozo <> KezdoDir then
      begin
        Write('  ');
        for I := 1 to M - 1 do
          if Utolso[I] then
            Write('    ')
          else
            Write('≥   ');
        WriteLn('√ƒƒƒ', Elozo);
        Utolso[M] := False;
        Konyvtar(P + Elozo + '\', M + 1);
      end;
      Elozo := SR.Name;
    end;
    FindNext(SR);
  end;
  if Elozo <> KezdoDir then
  begin
    Write('  ');
    for I := 1 to M - 1 do
      if Utolso[I] then
        Write('    ')
      else
        Write('≥   ');
    WriteLn('¿ƒƒƒ', Elozo);
    Utolso[M] := True;
    Konyvtar(P + Elozo + '\', M + 1);
  end;
end; { Konyvtar }

begin
  if ParamCount > 0 then
    D := ParamStr(1)
  else
    GetDir(0, D);
  D := D[1] + ':\';
  WriteLn('Kînyvt†r-fastrukt£ra kirajzol¢ program');
  WriteLn(D);
  Konyvtar(D, 1)
end.
