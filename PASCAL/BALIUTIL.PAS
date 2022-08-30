{ Bali's Utility   (c) 1991  Toth Balint }

program BaliUtil;

{$M 4000, 0, 0 }

uses Crt, Dos;

const
  MFSz = 100;

var
  I, FSz,
  Pos, KepPos : word;
  Bill        : char;
  Maszk, A    : string;
  SR          : SearchRec;
  Nev         : array[1..MFSz] of string[12];

procedure KiIr;
begin
  ClrScr;
  TextBackGround(Blue);
  TextColor(Yellow);
  WriteLn('BU - Bali''s Utility    Files:', FExpand(Maszk) : 50);
  TextBackGround(Black);
  TextColor(White);
  I := Pos - 1;
  repeat
    Inc(I);
    WriteLn('   ', Nev[I]);
  until (I - Pos = 22) or (I = Fsz);
  GotoXY(2, KepPos + 1);
end; { KiIr }

procedure Fel;
begin
  if Pos + KepPos > 2 then
  begin
    Dec(KepPos);
    if KepPos = 0 then
    begin
      KepPos := 1;
      Dec(Pos);
      KiIr;
    end; { if KepPos }
  end; { if Pos }
end; { Fel }

procedure Le;
begin
  if Pos + KepPos - 1 < FSz then
  begin
    Inc(KepPos);
    if KepPos = 24 then
    begin
      KepPos := 23;
      Inc(Pos);
      KiIr;
    end; { if KepPos }
  end; { if Pos }
end; { Le }

procedure Elejere;
begin
  Pos := 1;
  KepPos := 1;
  KiIr;
end; { Elejere }

procedure VegreHajt;
begin
  A := Copy(Nev[Pos + KepPos + 1], Length(Nev[Pos + KepPos + 1]), 4);
  if (A = '.exe') or (A = '.com') or (A = '.bat') then
  begin
    ClrScr;
    SwapVectors;
    Exec(Nev[Pos + KepPos + 1], '');
    SwapVectors;
    if DosError <> 0 then
    begin
      WriteLn;
      WriteLn('I/O hiba');
      Halt(1);
    end; { if DosError }
    WriteLn;
    WriteLn('Executing ended - press any key');
    repeat
    until KeyPressed;
    KiIr;
  end; { if }
end; { VegreHajt }

procedure Valasztas;
begin
  Elejere;
  repeat
    repeat
      Bill := UpCase(ReadKey);
    until Bill in ['A', 'Z', 'H', 'E', 'Q'];
    case Bill of
      'A' : Fel;
      'Z' : Le;
      'H' : Elejere;
      'E' : VegreHajt;
    end; { case }
    GotoXY(2, KepPos + 1);
  until Bill = 'Q';
end; { Valasztas }

begin { program }
  if ParamCount = 0 then
    Maszk := '*.*'
  else
    Maszk := ParamStr(1);
  FindFirst(Maszk, AnyFile, SR);
  FSz := 0;
  while (DosError = 0) and (Fsz < MFSz) do
  begin
    if SR.Attr in [Archive, AnyFile] then
    begin
      Inc(FSz);
      Nev[FSz] := SR.Name;
    end;
    FindNext(SR);
  end;
  if FSz = 0 then
  begin
    WriteLn;
    WriteLn('Ures a konyvtar');
    Halt(1);
  end;
  Valasztas;
  ClrScr;
end. { program }