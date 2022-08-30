program BaliZip; { Toth Balint }

{$M 4000, 0, 4000 }

uses Crt, Dos;

const
  MFSz = 50;

var
  I, FSz,
  Pos, KepPos : word;
  Bill        : char;
  Param       : string;
  SR          : SearchRec;
  Kell        : array[1..MFSz] of boolean;
  Nev         : array[1..MFSz] of string[12];

procedure KiIr;
begin
  ClrScr;
  WriteLn(FExpand('*.*'), ' :');
  I := Pos - 1;
  repeat
    Inc(I);
    if Kell[I] then
      Write(' + ')
    else
      Write('   ');
    WriteLn(Nev[I]);
  until (I - Pos = 22) or (I = Fsz);
  GotoXY(2, KepPos + 1);
end; { KiIr }

procedure Valasztas;
begin
  for I := 1 to Fsz do
    Kell[I] := false;
  Pos := 1;
  KepPos := 1;
  KiIr;
  repeat
    repeat
      Bill := ReadKey;
    until Bill in [' ', 'q', 'a', 'z'];
    case Bill of
      ' ' : begin
              Kell[Pos + KepPos - 1] := not Kell[Pos + KepPos - 1];
              if Kell[Pos + KepPos - 1] then
                Write('+')
              else
                Write(' ');
              GotoXY(2, KepPos + 1);
            end;
      'a' : if Pos + KepPos > 2 then
            begin
              Dec(KepPos);
              if KepPos = 0 then
              begin
                KepPos := 1;
                Dec(Pos);
                KiIr;
              end;
            end;
      'z' : if Pos + KepPos - 1 < FSz then
            begin
              Inc(KepPos);
              if KepPos = 24 then
              begin
                KepPos := 23;
                Inc(Pos);
                KiIr;
              end;
            end;
    end; { case }
    GotoXY(2, KepPos + 1);
  until Bill = 'q';
  ClrScr;
end; { Valasztas }

procedure Hivas;
begin
  SwapVectors;
  Exec('c:pkzip.exe', Param);
  SwapVectors;
  if DosError <> 0 then
  begin
    WriteLn('I/O hiba');
    Halt(1);
  end; { if }
end; { Hivas }

begin { program }
  WriteLn;
  WriteLn('BALIZIP   segitseg a PKZIP - hez   (c) 1991  Toth Balint');
  WriteLn;
  FindFirst('*.*', AnyFile, SR);
  FSz := 0;
  repeat
    FindNext(SR);
    if SR.Attr in [Archive, AnyFile] then
    begin
      Inc(FSz);
      Nev[FSz] := SR.Name;
    end;
  until DosError > 0;
  if FSz = 0 then
  begin
    WriteLn('Ures a konyvtar');
    Halt(1);
  end;
  Dec(FSz);
  if ParamCount = 0 then
  begin
    Write('Kerem a letrehozando archiv file nevet: ');
    Read(Param);
  end
  else
  begin
    Param := '';
    for I := 1 to ParamCount do
      Param := Param + ' ' + ParamStr(I);
  end; { else }
  Valasztas;
  for I := 1 to FSz do
  if Kell[I] then
    Param := Param + ' ' + Nev[I];
  Hivas;
end. { program }
