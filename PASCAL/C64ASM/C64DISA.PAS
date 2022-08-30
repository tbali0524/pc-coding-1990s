{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B lint       }
{                                                }
{************************************************}

program C64DisA; { DisAssembler f“program }

{$B-}
uses Dos, CGlobals, CMemTool, CKif;

const
  Info: String[80] = 'C64DISA v1.1a - C64 (6510) DisAssembler  ' +
    'Copyright (c) 1993-2001 by B lint T¢th';
  DISExt = '.DIS';

{ parancssor param‚terek }
const
  WhichEntry: Word = 1;      { h nyadik  llom nyb¢l t”lts”n T64 f jl eset‚n }
  PRGInfo: Boolean = False;  { csak file info a k‚perny“re }

  Resource: Boolean = False; { assembly source }
  HDump: Boolean = False;    { hex dump }
  ADump: Boolean = False;    { ascii dump }
  UseMap: Boolean = False;   { mapfile haszn lata }
  LFromA: Boolean = False;   { lista a megadott c¡mt“l }
  LToInv: Boolean = False;   { lista az els“ ‚rtelmetlen k¢dig }
  LToBRK: Boolean = False;   { lista az els“ BRK-ig }
  LToA: Boolean = False;     { lista a megadott c¡mig }
  SkipInv: Boolean = False;  { ‚rtelmezhetetlen k¢dok  tugr sa }

var
  T64Format: Boolean;   { bemeneti f jl T64 form tum£ }
  P00Format: Boolean;   { bemeneti f jl P00 form tum£ }
  IFileName: PathStr;   { bemeneti f jln‚v }
  OFileName: PathStr;   { kimeneti k¢dlista f jln‚v }
  MFileName: PathStr;   { map file resource eset‚n }
  OFile: Text;          { lista f jl }
  MFile: Text;          { mapf jl }
  StartA, EndA: Word;   { bemeneti f jl C64 mem¢riabeli kezd“ ‚s v‚gc¡m }
  FromA, ToA: Word;     { lista kezd“ ‚s v‚gc¡m }
  M: PMem;              { 64K mem¢ria blokk }
  Map: PMem;            { mem¢ria t‚rk‚p }
  CommentOut: String;   { komment a kimenetbe resource eset‚n }

procedure Hiba(S: String; HC: Word);
var
  S1: String;
begin
  Str(HC, S1);
  WriteLn('Error #' + S1 + ' : ', S);
  Halt(HC);
end;

{ ================================================================== }
{ Seg¡ts‚g }
procedure Help;
begin
  WriteLn('Usage:  C64DISA inputfilename[.PRG] [outputfilename[.DIS]] ' +
    '[options]');
  WriteLn;
  WriteLn('Options:');
  WriteLn(' /E=num            use the num-th entry in the T64 file (default: first)');
  WriteLn(' /I                write info about inputfile to screen (no disassembling)');
  WriteLn(' /X                create hex dump (no disassembling)');
  WriteLn(' /A                create ascii dump (no disassembling)');
  WriteLn(' /R                create assembly source');
  WriteLn(' /M                use mapfile');
  WriteLn(' /M=filename[.MAP] define other name for mapfile');
  WriteLn(' /$hexnum-hexnum   specify the address range to disassemble/list');
  WriteLn(' /$hexnum          start from given address');
  WriteLn(' /-$hexnum         stop at given address');
  WriteLn(' /B                stop disassembling at first BRK instruction');
  WriteLn(' /L                stop disassembling at first illegal instruction');
  WriteLn(' /S                skip illegal instructions');
  WriteLn;
  WriteLn('Use .T64 as extension of input filename to load from T64 tape file.');
  WriteLn('Or use .P00 as extension to load from a file in P00 format.');
  WriteLn('Otherwise PRG file format is supposed.');
  Halt(erParams);
end;

{ ================================================================== }
{ Parancssor param‚terek feldolgoz sa }
procedure GetParams;
var
  S: String;
  I: Integer;
  B, B2: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  IFileName := '';
  OFileName := '';
  MFileName := '';
  for B := 1 to ParamCount do
  begin
    S := ParamStr(B);
    if S[1] = '/' then
      if Length(S) > 1 then
        if (S[2] = '$') then
        begin
          B2 := 2;
          while (B2 <= Length(S)) and (S[B2] <> '-') do
            Inc(B2);
          if HSW(Copy(S, 3, B2 - 3), FromA) then
          begin
            LFromA := True;
            if B2 < Length(S) then
              if HSW(Copy(S, B2 + 1, 255), ToA) then
                LToA := True
              else
                Help;
          end { if HSW }
          else
            Help;
        end { if S[2] }
        else if (Length(S) > 3) and (S[2] = '-') and (S[3] = '$') then
          if HSW(Copy(S, 4, 255), ToA) then
            LToA := True
          else
            Help
        else if (Length(S) > 3) and (UpCase(S[2]) = 'E') and (S[3] = '=') then
        begin
          Val(Copy(S, 4, 255), WhichEntry, I);
          if (I <> 0) or (WhichEntry < 1) then
            Help;
        end
        else if (Length(S) > 3) and (UpCase(S[2]) = 'M') and (S[3] = '=') then
          MFileName := Copy(S, 4, 255)
        else
          for B2 := 2 to Length(S) do
            case UpCase(S[B2]) of
              'I': PRGInfo := True;
              'S': SkipInv := True;
              'B': LToBRK := True;
              'L': LToInv := True;
              'R': Resource := True;
              'M': UseMap := True;
              'X': HDump := True;
              'A': ADump := True;
              else
                Help;
            end { case }
      else { if Length(S) }
        Help
    else if IFileName = '' then
      IFileName := S
    else if OFileName = '' then
      OFileName := S
    else
      Help;
  end; { for }
  if IFileName = '' then
    Help;
  FNameExt(IFileName, PRGExt);
  FSplit(IFileName, D, N, E);
  T64Format := E = T64Ext;
  P00Format := E = P00Ext;
  if OFileName = '' then
    OFileName := D + N + DISExt
  else
    FNameExt(OFileName, DISExt);
  if MFileName <> '' then
    UseMap := True;
  if UseMap then
  begin
    if MFileName = '' then
    begin
      FSplit(IFileName, D, N, E);
      MFileName := D + N + MAPExt;
    end
    else
      FNameExt(MFileName, MAPExt);
  end; { if UseMap }
  if Resource then
    CommentOut := '; '
  else
    CommentOut := '';
end; { GetParams }

{ ================================================================== }
{ Bemeneti f jl bet”lt‚se, kimeneti f jl megnyit sa }
procedure OpenFiles;
var
  B: Byte;
begin
  B := LoadAny(M, IFileName, StartA, EndA, WhichEntry);
  case B of
    teInvPRG:  Hiba('Invalid PRG file', erOpenInp);
    teInvT64:  Hiba('Invalid T64 file', erOpenInp);
    teInvT64Entry:  Hiba('Invalid or nonexisting entry in T64 file', erOpenInp);
    teInvP00:  Hiba('Invalid P00 file', erOpenInp);
    teLoadPRG: Hiba('Cannot open ' + IFileName, erOpenInp);
  end;
  if PRGInfo or (not LFromA) or (FromA < StartA) or (FromA > EndA) then
    FromA := StartA;
  if PRGInfo or (not LToA) or (ToA < FromA) or (ToA > EndA) then
    ToA := EndA;
  if not PRGInfo then
  begin
    {$I-}
    Assign(OFile, OFileName);
    Rewrite(OFile);
    {$I+}
    if IOResult <> 0 then
      Hiba('Cannot open ' + OFileName, erOutFile);
    WriteLn(OFile, CommentOut, Info);
    WriteLn(OFile);
    if HDump or ADump then
    begin
      Write('Listing ');
      Write(OFile, 'Listing ');
    end
    else
    begin
      Write('Disassembling ');
      Write(OFile, CommentOut, 'Disassembling ');
    end;
    Write(OFile, IFileName);
    if T64Format then
      Write(OFile, ' (Entry: ', WhichEntry, ')');
    Write(OFile, ' from $', HWS(FromA), ' to $', HWS(ToA));
    if (FromA <> StartA) or (ToA <> EndA) then
    begin
      WriteLn(Ofile);
      Write(OFile, CommentOut, '  Total C64 file from $', HWS(StartA),
        ' to $', HWS(EndA));
    end;
    WriteLn(Ofile);
    WriteLn(Ofile);
  end;
  Write(IFileName);
  if T64Format then
    Write(' (Entry: ', WhichEntry, ')');
  if not PRGInfo then
    Write(' from $', HWS(FromA), ' to $', HWS(ToA));
  if PRGInfo or (FromA <> StartA) or (ToA <> EndA) then
  begin
    WriteLn;
    Write('  Total C64 file from $', HWS(StartA), ' to $', HWS(EndA));
  end;
  WriteLn;
end; { OpenFiles }

{ ================================================================== }
{ Mapf jl bet”lt‚se }
procedure ReadMap;
var
  Sor, EredSor: String;
  I: Integer;
  RegionF, RegionT, W: Word;
  RegionC, State: Byte;
begin
  {$I-}
  Assign(MFile, MFileName);
  Reset(MFile);
  {$I+}
  if IOResult <> 0 then
    Hiba('Cannot open ' + MFileName, erOpenInp)
  else
  begin
    if MaxAvail >= $11000 then
      New(Map)
    else
      Hiba('Not enough memory', erNoMem);
    for W := 0 to $FFFF do
      Map^[W] := meCode;
    WriteLn('Using map file: ', MFileName);
    State := erNone;
    while not Eof(MFile) do
    begin
      ReadLn(MFile, EredSor);
      Sor := '';
      I := 1;
      while (I <= Length(EredSor)) and (EredSor[I] <> ';') do
      begin
        Sor := Sor + UpCase(EredSor[I]);
        Inc(I);
      end;
      BalraHuz(Sor);
      if Sor <> '' then
      begin
        if Sor[1] = '-' then
          RegionF := FromA
        else if Sor[1] = '$' then
          RegionF := HexSzam(Sor, State)
        else
          RegionF := DecSzam(Sor, State);
        BalraHuz(Sor);
        if (State <> erNone) or (Sor = '') then
          Hiba('Invalid map file', erOpenInp);
        if Sor[1] <> '-' then
          RegionT := RegionF
        else
        begin
          Delete(Sor, 1, 1);
          BalraHuz(Sor);
          if Sor[1] = '$' then
            RegionT := HexSzam(Sor, State)
          else if Sor[1] in ['0'..'9'] then
            RegionT := DecSzam(Sor, State)
          else
            RegionT := ToA;
        end; { if Sor[1] else }
        BalraHuz(Sor);
        if (State <> erNone) or (Sor = '') then
          Hiba('Invalid map file', erOpenInp);
        case Sor[1] of
          'E': RegionC := meEmpty;
          'C': RegionC := meCode;
          'B': if Length(Sor) > 1 then
               begin
                 if Sor[2] = 'D' then
                 begin
                   RegionC := meByteD;
                   Delete(Sor, 1, 1);
                 end
                 else if Sor[2] = 'B' then
                 begin
                   RegionC := meByteB;
                   Delete(Sor, 1, 1);
                 end;
               end
               else
                 RegionC := meByte;
          'W': if Length(Sor) > 1 then
               begin
                 if Sor[2] = 'D' then
                 begin
                   RegionC := meWordD;
                   Delete(Sor, 1, 1);
                 end;
               end
               else
                 RegionC := meWord;
          'T': RegionC := meText;
          'A': RegionC := meAsc;
          'S': if Length(Sor) > 1 then
               begin
                 if Sor[2] = 'U' then
                 begin
                   RegionC := meScrU;
                   Delete(Sor, 1, 1);
                 end
                 else if Sor[2] = 'L' then
                 begin
                   RegionC := meScrL;
                   Delete(Sor, 1, 1);
                 end;
               end
               else
                 State := erExp;
          else
            State := erExp;
        end; { case }
        Delete(Sor, 1, 1);
        BalraHuz(Sor);
        if (Sor <> '') or (State <> erNone) then
            Hiba('Invalid map file', erOpenInp);
        for W := RegionF to RegionT do
          Map^[W] := RegionC;
      end; { if Sor <> '' }
    end; { while }
    Close(MFile);
  end; { if IOResult else }
end; { ReadMap }

{ ================================================================== }
{ Hex Dump }
procedure WriteHexDump;
var
  I: Word;
begin
  I := FromA;
  while (I < $FFF0) and (I + $F <= ToA) do
  begin
    WriteLn(OFile, DumpSor(M, I, $F));
    Inc(I, $10);
  end;
  if (I - 1) <> ToA then
    WriteLn(OFile, DumpSor(M, I, ToA - I));
end; { WriteHexDump }

{ ================================================================== }
{ Ascii Dump }
procedure WriteAsciiDump;
var
  I: Word;
begin
  I := FromA;
  while (I < $FFC0) and (I + $3F <= ToA) do
  begin
    WriteLn(OFile, AsciiSor(M, I, $3F));
    Inc(I, $40);
  end;
  if (I - 1) <> ToA then
    WriteLn(OFile, AsciiSor(M, I, ToA - I));
end; { WriteAsciiDump }

{ ================================================================== }
{ Resource }
procedure WriteResource;
var
  PC: Word;             { Program Counter }
  H: Byte;              { utas¡t s m‚rete byte-ban }
  S: String;
  LastInv: Boolean;     { az utols¢ utas¡t s ‚rtelmezhetetlen volt (/S-n‚l) }
  Vege: Boolean;
begin
  LastInv := False;
  Vege := False;
  PC := FromA;
  repeat
    S := ResourceSor(M, PC, H);
    if PC - 1 + H <= ToA then
    begin
      if S[Length(S)] = '?' then
      begin
        if LToInv then
        begin
          Vege := True;
          WriteLn('Invalid instruction reached at $', HWS(PC));
        end
        else
        begin
          if not LastInv then
            WriteLn(OFile, '; Invalid instruction follows:');
          WriteLn(OFile, '.BYTE ', M^[PC]);
        end;
        LastInv := True;
      end { if S }
      else
      begin
        if LastInv then
        begin
          WriteLn(OFile);
          LastInv := False;
        end;
        WriteLn(OFile, S);
      end; { if S else }
      if (LToBRK and (Copy(S, Length(S) - 2, 3) = 'BRK')) then
      begin
        Vege := True;
        WriteLn('BRK instruction reached at $', HWS(PC));
      end
      else if PC - 1 + H >= ToA then
          Vege := True;
      PC := PC + H;
    end { if PC + H }
    else
      Vege := True;
  until Vege;
end; { WriteResource }

{ ================================================================== }
{ Disassembl l s }
procedure WriteDisAsm;
var
  PC: Word;             { Program Counter }
  H: Byte;              { utas¡t s m‚rete byte-ban }
  S: String;
  LastInv: Boolean;     { az utols¢ utas¡t s ‚rtelmezhetetlen volt (/S-n‚l) }
  Vege: Boolean;
begin
  LastInv := False;
  Vege := False;
  PC := FromA;
  repeat
    S := DisAsmSor(M, PC, H);
    if PC - 1 + H <= ToA then
    begin
      if S[Length(S)] = '?' then
        if LToInv then
        begin
          Vege := True;
          WriteLn(OFile, 'Invalid instruction reached.');
          WriteLn('Invalid instruction reached at $', HWS(PC));
        end
        else if SkipInv then
          LastInv := True
        else
          WriteLn(OFile, S)
      else
      begin
        if LastInv then
        begin
          WriteLn(OFile);
          LastInv := False;
        end;
        WriteLn(OFile, S);
      end; { if S else }
      if (LToBRK and (Copy(S, Length(S) - 2, 3) = 'BRK')) then
      begin
        Vege := True;
        WriteLn('BRK instruction reached at $', HWS(PC));
      end
      else if PC - 1 + H >= ToA then
          Vege := True;
      PC := PC + H;
    end { if PC + H }
    else
      Vege := True;
  until Vege;
end; { WriteDisAsm }

{ ================================================================== }
begin { f“program }
  WriteLn(Info);
  WriteLn;
  Map := Nil;
  GetParams;
  if MaxAvail >= $11000 then
    New(M)
  else
    Hiba('Not enough memory', erNoMem);
  OpenFiles;
  if not PRGInfo then
  begin
    if UseMap then
      ReadMap;
    if Resource then
      WriteResource
    else if HDump then
      WriteHexDump
    else if ADump then
      WriteAsciiDump
    else
      WriteDisAsm;
    Close(OFile);
    WriteLn(OFileName, ' created');
    if UseMap and (Map <> Nil) then
      Dispose(Map);
  end;
  Dispose(M);
  Halt(0);
end.