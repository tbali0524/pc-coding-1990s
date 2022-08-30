{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B†lint       }
{                                                }
{************************************************}

unit CMemTool; { Mem¢riakezelì segÇdelj†r†sok }

{$B-}
interface

uses Dos, CGlobals;

const
 { elj†r†sok hibak¢djai }
  teNone    = 0; { nincs hiba }
  teInvPRG  = 1; { hib†s PRG f†jl }
  teInvT64  = 2; { hib†s T64 f†jl }
  teInvT64Entry = 3; { hib†s vagy nemlÇtezì †llom†ny a T64 f†jlban }
  teInvP00  = 4; { hib†s P00 f†jl }
  teLoadPRG = 5; { hiba a PRG,T64 vagy P00 f†jl megnyit†sakor }

 { DOS hibak¢dok }
  erParams  = 21;       { hib†s parancssor-paramÇter vagy /? }
  erNoMem   = 22;       { t£l kevÇs mem¢ria }
  erOpenInp = 23;       { bemeneti f†jlt nem sikerÅlt megnyitni }
 { erOpenAsm = 23      CKIF.ASM-ben defini†lt }
  erOutFile = 24;       { kimeneti f†jlt nem sikerÅlt lÇtrehozni }

 { memory map bejegyzÇsek }
   meEmpty = 0;
   meCode  = 1;
   meByte  = 2;
   meByteD = 3;
   meByteB = 4;
   meWord  = 5;
   meWordD = 6;
   meText  = 7;
   meAsc   = 8;
   meScrL  = 9;
   meScrU  = 10;
   meLongName: Array[meEmpty..meScrU] of String[25] = (
     'Empty',
     'Code',
     'Byte',
     'Decimal byte',
     'Binary byte',
     'Word',
     'Decimal word',
     'Text',
     'Ascii',
     'Lowercase screencode',
     'Uppercase screencode');
   meShortName: String[22] = 'E C B BDBBW WDT A SLSU';

 { Mnemonikok}
  InstrSet: String[224] =
        'ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRK BVC BVS CLC CLD CLI ' +
    'CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY JMP JSR LDA LDX LDY LSR ' +
    'NOP ORA PHA PHP PLA PLP ROL ROR RTI RTS SBC SEC SED SEI STA STX STY ' +
    'TAX TAY TSX TXA TXS TYA ';

  PRGExt = '.PRG';
  T64Ext = '.T64';
  P00Ext = '.P00';
  MAPExt = '.MAP';
  InvInstr = '???';
  HexJegy: String[16] = '0123456789ABCDEF';

function HBS(B: Byte): String;
function HWS(W: Word): String;
function HSW(S: String; var W: Word): Boolean;
function PC2CBMAscii(B: Byte): Byte;
function PC2SCRL(B: Byte): Byte;
function PC2SCRU(B: Byte): Byte;
function CBM2PCAscii(B: Byte; ForDisplay: Boolean): Byte;

procedure BalraHuz(var S: String);

procedure FNameExt(var FName: PathStr; DefaultExt: PathStr);
function FullFileName(FName: PathStr; DefaultExt: PathStr): PathStr;
function LoadPRG(M: PMem; var FName: PathStr;
  var StartA, EndA: Word): Byte;
function LoadT64(M: PMem; var FName: PathStr;
  var StartA, EndA: Word; WhichEntry: Word): Byte;
function LoadP00(M: PMem; var FName: PathStr;
  var StartA, EndA: Word): Byte;
function LoadAny(M: PMem; var FName: PathStr;
  var StartA, EndA: Word; WhichEntry: Word): Byte;
function SavePRG(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;
function SaveT64(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;
function SaveP00(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;

function CopyMem(M: PMem; StartA, EndA, ToA: Word): Boolean;
function FillMem(M: PMem; StartA, EndA: Word; Value: Byte): Boolean;
function DumpSor(M: PMem; StartA, Len: Word): String;
function AsciiSor(M: PMem; StartA, Len: Word): String;
function DisAsmSor(M: PMem; PC: Word; var Hossz: Byte): String;
function ResourceSor(M: PMem; PC: Word; var Hossz: Byte): String;

implementation

const
  CBM2PCTable: String[255] =
     '...............' + '................' +
    ' !"#$%&''()*+,-./' + '0123456789:;<=>?' +
    #0'ABCDEFGHIJKLMNO' + 'PQRSTUVWXYZ[ú]^Æ' +
    'ƒ˛≥ƒƒƒƒ≥≥ø¿Ÿ¿\/⁄' + 'ø˛ƒ˛≥⁄XO˛≥˛≈±≥„\' +
    '................' + '................' +
    ' ›‹ƒ_≥±≥±/≥√‹¿øƒ' + '⁄¡¬¥≥≥≥ƒƒƒŸ‹ﬂŸﬂ≤' +
    'ƒ˛≥ƒƒƒƒ≥≥ø¿Ÿ¿\/⁄' + 'ø˛ƒ˛≥⁄XO˛≥˛≈±≥„\' +
    ' ›‹ƒ_≥±≥±/≥√‹¿øƒ' + '⁄¡¬¥≥≥≥ƒƒƒŸ‹ﬂŸﬂ≤';

  PC2CBMTable: String[255] =
     '...............' + '................' +
    ' !"#$%&''()*+,-./' + '0123456789:;<=>?' +
    '@ABCDEFGHIJKLMNO' + 'PQRSTUVWXYZ[j]^§' +
    '''ABCDEFGHIJKLMNO' + 'PQRSTUVWXYZ[b]c'#20 +
    'CUEAAAACEEEIIIAA' + 'EAAOOOUUYOUC\YPS' +
    'AIOUNNAO?∞Æ24!_>' + '¶¶¶b≥≥≥ÆÆ≥bÆΩΩΩÆ' +
    '≠±≤´cõ´´≠∞±≤´cõ±' + '±≤≤≠≠∞∞õõΩ∞.¢°∂∏' +
    'ABo~SOMTwwODwwEñ' + 'c{><uk:=wqqnN2z ';

  PC2SCRLTable: String[255] =
     '...............' + '................' +
    ' !"#$%&''()*+,-./' + '0123456789:;<=>?' +
    #0'ABCDEFGHIJKLMNO' + 'PQRSTUVWXYZ'#27#77#29#30#100 +
    #39#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15 +
     #16#17#18#19#20#21#22#23#24#25#26#27#93#29#64#127 +
    #67#21#5#1#1#1#1#3#5#5#5#9#9#9#65#65 +
     #69#1#65#15#15#15#21#21#25#79#85#3#28#89#80#83 +
    #1#9#15#21#14#78#1#15#63#112#110#50#52#33#31#62 +
     #102#102#102#93#115#115#115#110#110#115#93#110#125#125#125#110 +
    #109#113#114#107#64#91#107#107#109#112#113#114#107#64#91#113 +
     #113#114#114#109#109#112#112#91#91#125#112#160#98#97#118#120 +
    #1#66#71#80#83#15#13#20#79#79#79#4#79#79#69#38 +
     #64#91#62#60#112#125#58#61#79#46#46#82#14#50#123#32;

  PC2SCRUTable: String[255] =
     '...............' + '................' +
    ' !"#$%&''()*+,-./' + '0123456789:;<=>?' +
    #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15 +
     #16#17#18#19#20#21#22#23#24#25#26#27#77#29#30#100 +
    #39#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15 +
     #16#17#18#19#20#21#22#23#24#25#26#27#93#29#64#127 +
    #3#21#5#1#1#1#1#3#5#5#5#9#9#9#1#1 +
     #5#1#1#15#15#15#21#21#25#15#21#3#28#25#16#19 +
    #1#9#15#21#14#14#1#15#63#112#110#50#52#33#31#62 +
     #102#102#102#93#115#115#115#110#110#115#93#110#125#125#125#110 +
    #109#113#114#107#64#91#107#107#109#112#113#114#107#64#91#113 +
     #113#114#114#109#109#112#112#91#91#125#112#160#98#97#118#120 +
    #1#2#79#94#19#15#13#20#15#15#15#4#15#15#5#38 +
     #64#91#62#60#85#75#58#61#15#46#46#78#14#50#123#32;

  T64Header: Array[0..95] of Byte = (
    $43, $36, $34, $53, $20, $74, $61, $70,
    $65, $20, $66, $69, $6C, $65, $0D, $0A,
    $44, $65, $6D, $6F, $20, $74, $61, $70,
    $65, $1A, $2E, $2E, $2E, $2E, $2E, $2E,
    $01, $01, $1E, $00, $01, $00, $00, $00,
    $41, $53, $53, $45, $4D, $42, $4C, $45,
    $44, $20, $20, $20, $20, $20, $20, $20,
    $20, $20, $20, $20, $20, $20, $20, $20,
    $01, $01, $01, $08, $01, $08, $00, $00,
    $00, $04, $00, $00, $00, $00, $00, $00,
    $20, $20, $20, $20, $20, $20, $20, $20,
    $20, $20, $20, $20, $20, $20, $20, $20);

  P00Header: Array[0..27] of Byte = (
    $43, $36, $34, $46, $69, $6C, $65, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00);

{ Byte -> String konverzi¢ }
function HBS(B: Byte): String;
begin
  HBS := HexJegy[B shr 4 + 1] + HexJegy[B and $0F + 1];
end;

{ Word -> String konverzi¢ }
function HWS(W: Word): String;
begin
  HWS := HBS(Hi(W)) + HBS(Lo(W));
end;

{ ================================================================== }
{ String -> Word konverzi¢, eredmÇny: sikerÅlt-e }
function HSW(S: String; var W: Word): Boolean;
var
  B: Byte;
  I: Word;
begin
  if (Length(S) < 1) or (Length(S) > 4) then
    HSW := False
  else
  begin
    W := 0;
    I := 1;
    repeat
      B := Pos(UpCase(S[I]), HexJegy);
      if B > 0 then
        W := W shl 4 or (B - 1);
      Inc(I);
    until (I > Length(S)) or (B = 0);
    HSW := B <> 0;
  end; { else }
end; { HSW }

{ ================================================================== }
{ PC ASCII karakterek konvert†l†sa CBM ASCII-v† }
function PC2CBMAscii(B: Byte): Byte;
var
  C: Char;
begin
  if B > 0 then
    C := PC2CBMTable[B]
  else
    C := '.';
  if C <> '.' then
    PC2CBMAscii := Ord(C)
  else
    PC2CBMAscii := B;
end; { PC2CBMAscii }

function PC2SCRL(B: Byte): Byte;
var
  C: Char;
begin
  if B > 0 then
    C := PC2SCRLTable[B]
  else
    C := '.';
  if C <> '.' then
    PC2SCRL := Ord(C)
  else
    PC2SCRL := B;
end; { PC2SCRL }

function PC2SCRU(B: Byte): Byte;
var
  C: Char;
begin
  if B > 0 then
    C := PC2SCRUTable[B]
  else
    C := '.';
  if C <> '.' then
    PC2SCRU := Ord(C)
  else
    PC2SCRU := B;
end; { PC2SCRU }

{ ================================================================== }
{ CBM ASCII karakterek konvert†l†sa PC ASCII-v† }
function CBM2PCAscii(B: Byte; ForDisplay: Boolean): Byte;
var
  C: Char;
begin
  if B > 0 then
    C := CBM2PCTable[B]
  else
    C := '.';
  if ForDisplay or (C <> '.') then
    CBM2PCAscii := Ord(C)
  else
    CBM2PCAscii := B;
end; { CBM2PCAscii }

{ ================================================================== }
{ Sztring elejÇn lÇvì sz¢kîzîk Çs TAB-ok kivÇtele }
procedure BalraHuz(var S: String);
var
  I: Integer;
begin
  I := 1;
  while (I <= Length(S)) and (S[I] in [' ', #9]) do
    Inc(I);
  if I > 1 then
    Delete(S, 1, I - 1);
end; { BalraHuz }

{ ================================================================== }
procedure FNameExt(var FName: PathStr; DefaultExt: PathStr);
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  I: Integer;
begin
  FSplit(FName, D, N, E);
  if E = '' then
    FName := D + N + DefaultExt;
  for I := 1 to Length(FName) do
    FName[I] := UpCase(FName[I]);
end; { FNameExt }

{ ================================================================== }
function FullFileName(FName: PathStr; DefaultExt: PathStr): PathStr;
var
  S: PathStr;
begin
  S := FName;
  FNameExt(S, DefaultExt);
  FullFileName := FExpand(S);
end; { FullFileName }

{ ================================================================== }
{ PRG f†jl betîltÇse (eredmÇny: hibak¢d) }
function LoadPRG(M: PMem; var FName: PathStr;
  var StartA, EndA: Word): Byte;
var
  MFile: File of Byte;
  W: Word;
  B1, B2: Byte;
begin
  FNameExt(FName, PRGExt);
  {$I-}
  Assign(MFile, FName);
  Reset(MFile);
  {$I+}
  if IOResult <> 0 then
    LoadPRG := teLoadPRG
  else
  begin
    if (FileSize(MFile) < 3) then
      LoadPRG := teInvPRG
    else
    begin
      Read(MFile, B1, B2);
      StartA := B1 or (B2 shl 8);
      if ($FFFF - StartA) < (FileSize(MFile) - 3) then
        LoadPRG := teInvPRG
      else
      begin
        EndA := FileSize(MFile) - 3 + StartA;
        for W := StartA to EndA do
          Read(MFile, M^[W]);
        LoadPRG := teNone;
      end; { if $FFFF else }
    end; { if FileSize else }
    Close(MFile);
  end; { if IOResult else }
end; { LoadPRG }

{ ================================================================== }
{ T64 f†jl betîltÇse (eredmÇny: hibak¢d) }
{   WhichEntry: h†nyadik †lom†nyb¢l tîltsîn a T64 f†jlon belÅl }
function LoadT64(M: PMem; var FName: PathStr;
  var StartA, EndA: Word; WhichEntry: Word): Byte;
var
  MFile: File of Byte;
  W: Word;
  B1, B2, B3, B4, B5: Byte;
  L: LongInt;
  DirEntries: Word;
begin
  FNameExt(FName, T64Ext);
  {$I-}
  Assign(MFile, FName);
  Reset(MFile);
  {$I+}
  if IOResult <> 0 then
    LoadT64 := teLoadPRG
  else
  begin
    if (FileSize(MFile) <= 96) then
      LoadT64 := teInvT64
    else
    begin
      Seek(MFile, 34);
      Read(MFile, B1, B2);
      DirEntries := B1 or (B2 shl 8);
      Read(MFile, B1, B2);
      if (DirEntries < 1) or (FileSize(MFile) <=
          (64 + 32 * DirEntries)) then
        LoadT64 := teInvT64
      else if (WhichEntry < 1) or (WhichEntry > DirEntries) then
        LoadT64 := teInvT64Entry
      else
      begin
        Seek(MFile, 32 + WhichEntry * 32);
        Read(MFile, B5, B3, B1, B2);
        StartA := B1 or (B2 shl 8);
        Read(MFile, B1, B2, B3, B4);
        EndA := B1 or (B2 shl 8) - 1;
        Read(MFile, B1, B2, B3, B4);
        L := LongInt(B1) or (LongInt(B2) shl 8) or (LongInt(B3) shl 16) or
          (LongInt(B3) shl 24);
        if (B5 <> 1) or (EndA < StartA) or ((L - StartA + Enda) >
            FileSize(MFile)) then
          LoadT64 := teInvT64Entry
        else
        begin
          Seek(MFile, L);
          for W := StartA to EndA do
            Read(MFile, M^[W]);
          LoadT64 := teNone;
        end;
      end; { if B1 else }
    end; { if FileSize else }
    Close(MFile);
  end; { if IOResult else }
end; { LoadT64 }

{ ================================================================== }
{ P00 f†jl betîltÇse (eredmÇny: hibak¢d) }
function LoadP00(M: PMem; var FName: PathStr;
  var StartA, EndA: Word): Byte;
var
  MFile: File of Byte;
  W: Word;
  B1, B2: Byte;
begin
  FNameExt(FName, P00Ext);
  {$I-}
  Assign(MFile, FName);
  Reset(MFile);
  {$I+}
  if IOResult <> 0 then
    LoadP00 := teLoadPRG
  else
  begin
    if (FileSize(MFile) <= 28) then
      LoadP00 := teInvP00
    else
    begin
      Seek(MFile, 26);
      Read(MFile, B1, B2);
      StartA := B1 or (B2 shl 8);
      if (FileSize(MFile) - 29 + StartA) > $FFFF then
        LoadP00 := teInvP00
      else
      begin
        EndA := FileSize(MFile) - 29 + StartA;
        for W := StartA to EndA do
          Read(MFile, M^[W]);
        LoadP00 := teNone;
      end;
    end; { if FileSize else }
    Close(MFile);
  end; { if IOResult else }
end; { LoadP00 }

{ ================================================================== }
{ Tetszãleges bin†ris form†tum£ bin†risf†jl betîltÇse }
function LoadAny(M: PMem; var FName: PathStr;
  var StartA, EndA: Word; WhichEntry: Word): Byte;
var
  B: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FNameExt(FName, PRGExt);
  FSplit(FName, D, N, E);
  if E = T64Ext then
    LoadAny := LoadT64(M, FName, StartA, EndA, WhichEntry)
  else if E = P00Ext then
    LoadAny := LoadP00(M, FName, StartA, EndA)
  else
    LoadAny := LoadPRG(M, FName, StartA, EndA);
end; { LoadAny }

{ ================================================================== }
{ Mem¢riarÇsz kimentÇse PRG f†jlba (eredmÇny: sikerÅlt-e) }
function SavePRG(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;
var
  MFile: File of Byte;
  W: Word;
  B1, B2: Byte;
begin
  FNameExt(FName, PRGExt);
  {$I-}
  Assign(MFile, FName);
  Rewrite(MFile);
  {$I+}
  if IOResult <> 0 then
    SavePRG := False
  else
  begin
    B1 := Lo(StartA);
    B2 := Hi(StartA);
    Write(MFile, B1, B2);
    for W := StartA to EndA do
      Write(MFile, M^[W]);
    Close(MFile);
    SavePRG := True;
  end; { else }
end; { SavePRG }

{ ================================================================== }
{ Mem¢riarÇsz kimentÇse T64 f†jlba (eredmÇny: sikerÅlt-e) }
function SaveT64(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;
var
  MFile: File of Byte;
  W: Word;
  B1, B2, B3, B4: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FNameExt(FName, T64Ext);
  FSplit(FName, D, N, E);
  {$I-}
  Assign(MFile, FName);
  Rewrite(MFile);
  {$I+}
  if IOResult <> 0 then
    SaveT64 := False
  else
  begin
    T64Header[66] := Lo(StartA);
    T64Header[67] := Hi(StartA);
    T64Header[68] := Lo(EndA + 1);
    T64Header[69] := Hi(EndA + 1);
    for W := 0 to 7 do
    begin
      T64Header[50 + W] := $20;
      T64Header[80 + W] := $20;
    end;
    for W := 1 to Length(N) do
    begin
      T64Header[49 + W] := Ord(UpCase(N[W]));
      T64Header[79 + W] := Ord(UpCase(N[W]));
    end;
    for W := 0 to 95 do
      Write(MFile, T64Header[W]);
    B1 := 0;
    for W := 1 to 32 * 29 do
      Write(MFile, B1);
    for W := StartA to EndA do
      Write(MFile, M^[W]);
    Close(MFile);
    SaveT64 := True;
  end; { else }
end; { SaveT64 }

{ ================================================================== }
{ Mem¢riarÇsz kimentÇse P00 f†jlba (eredmÇny: sikerÅlt-e) }
function SaveP00(M: PMem; var FName: PathStr;
  StartA, EndA: Word): Boolean;
var
  MFile: File of Byte;
  W: Word;
  B1, B2, B3, B4: Byte;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FNameExt(FName, P00Ext);
  FSplit(FName, D, N, E);
  {$I-}
  Assign(MFile, FName);
  Rewrite(MFile);
  {$I+}
  if IOResult <> 0 then
    SaveP00 := False
  else
  begin
    P00Header[26] := Lo(StartA);
    P00Header[27] := Hi(StartA);
    for W := 0 to 15 do
      P00Header[8 + W] := $00;
    for W := 1 to Length(N) do
      P00Header[7 + W] := Ord(UpCase(N[W]));
    for W := 0 to 27 do
      Write(MFile, P00Header[W]);
    for W := StartA to EndA do
      Write(MFile, M^[W]);
    Close(MFile);
    SaveP00 := True;
  end; { else }
end; { SaveP00 }

{ ================================================================== }
{ Mem¢riarÇsz m†sol†sa (a kÇt blokk egybel¢ghat) (eredmÇny: sikerÅlt-e) }
function CopyMem(M: PMem; StartA, EndA, ToA: Word): Boolean;
var
  W: Word;
begin
  if (StartA > EndA) or (ToA + EndA - StartA > $FFFF) then
    CopyMem := False
  else
  begin
    if ToA < StartA then
      for W := 0 to EndA - StartA do
        M^[ToA + W] := M^[StartA + W]
    else
      for W := EndA - StartA downto 0 do
        M^[ToA + W] := M^[StartA + W];
    CopyMem := True;
  end;
end; { CopyMem }

{ ================================================================== }
{ Mem¢riarÇsz feltîltÇse egy byte-tal (eredmÇny: sikerÅlt-e) }
function FillMem(M: PMem; StartA, EndA: Word; Value: Byte): Boolean;
var
  W: Word;
begin
  if StartA > EndA then
    FillMem := False
  else
  begin
    for W := StartA to EndA do
      M^[W] := Value;
    FillMem := True;
  end;
end; { FillMem }

{ ================================================================== }
{ Hex Dump egy sora (StartA-t¢l Len + 1 darab byte-ot) }
function DumpSor(M: PMem; StartA, Len: Word): String;
var
  S: String;
  I: Word;
begin
  S := HWS(StartA) + ' ≥';
  for I := StartA to StartA + Len do
    S := S + ' ' + HBS(M^[I]);
  for I := 1 to ($F - Len) * 3 do
    S := S + ' ';
  S := S + ' ≥ ';
  for I := StartA to StartA + Len do
    S := S + Chr(CBM2PCAscii(M^[I], True));
  DumpSor := S;
end; { DumpSor }

{ ================================================================== }
{ Ascii View egy sora (StartA-t¢l Len + 1 darab byte-ot) }
function AsciiSor(M: PMem; StartA, Len: Word): String;
var
  S: String;
  I: Word;
begin
  S := HWS(StartA) + ' ≥ ';
  for I := StartA to StartA + Len do
    S := S + Chr(CBM2PCAscii(M^[I], True));
  AsciiSor := S;
end; { AsciiSor }

{ ================================================================== }
{ Disassemble egy sora - egy utas°t†s visszafejtÇse }
{ Hossz a val¢di hossz byte-ban }
function DisAsmSor(M: PMem; PC: Word; var Hossz: Byte): String;
var
  UKod: Word;           { utas°t†sk¢d }
  CMod: Byte;           { c°mzÇsm¢d }
  S: String;
  I: Integer;
begin
  S := HWS(PC) + '  ' + HBS(M^[PC]) + ' ';
  UKod := UK[M^[PC]] and $FFF0;
  CMod := UK[M^[PC]] and $0F;
  Hossz := CMH[CMod];
  case Hossz of
    1: S := S + '     ';
    2: S := S + HBS(M^[PC + 1]) + '   ';
    3: S := S + HBS(M^[PC + 1]) + ' ' + HBS(M^[PC + 2]);
  end;
  if UKod <> FE then
    S := S + '  ' + Copy(InstrSet, UKod shr 2 - 3, 3)
  else
    S := S + '  ' + InvInstr;
  case CMod of
  { Spec : ; }
    Acc  : S := S + ' A';
    Imm  : S := S + ' #$' + HBS(M^[PC + 1]);
    ZP   : S := S + ' $' + HBS(M^[PC + 1]);
    ZPX  : S := S + ' $' + HBS(M^[PC + 1]) + ',X';
    ZPY  : S := S + ' $' + HBS(M^[PC + 1]) + ',Y';
    AbsM : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]);
    AbsX : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ',X';
    AbsY : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ',Y';
    Rel  : begin
             if M^[PC + 1] < $80 then
               I := M^[PC + 1]
             else
               I := M^[PC + 1] - $100;
             S := S + ' $' + HWS((PC + 2 + I));
           end;
    IndX : S := S + ' ($' + HBS(M^[PC + 1]) + ',X)';
    IndY : S := S + ' ($' + HBS(M^[PC + 1]) + '),Y';
    AbsI : S := S + ' ($' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ')';
  end; { case }
  DisAsmSor := S;
end; { DisAsmSor }

{ ================================================================== }
{ Resource egy sora - egy utas°t†s visszafejtÇse assembly forr†ss† }
{ Hossz a val¢di hossz byte-ban }
function ResourceSor(M: PMem; PC: Word; var Hossz: Byte): String;
var
  UKod: Word;           { utas°t†sk¢d }
  CMod: Byte;           { c°mzÇsm¢d }
  S: String;
  I: Integer;
begin
  UKod := UK[M^[PC]] and $FFF0;
  CMod := UK[M^[PC]] and $0F;
  Hossz := CMH[CMod];
  if UKod <> FE then
    S := Copy(InstrSet, UKod shr 2 - 3, 3)
  else
    S := InvInstr;
  case CMod of
  { Spec : ; }
    Acc  : S := S + ' A';
    Imm  : S := S + ' #$' + HBS(M^[PC + 1]);
    ZP   : S := S + ' $' + HBS(M^[PC + 1]);
    ZPX  : S := S + ' $' + HBS(M^[PC + 1]) + ',X';
    ZPY  : S := S + ' $' + HBS(M^[PC + 1]) + ',Y';
    AbsM : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]);
    AbsX : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ',X';
    AbsY : S := S + ' $' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ',Y';
    Rel  : begin
             if M^[PC + 1] < $80 then
               I := M^[PC + 1]
             else
               I := M^[PC + 1] - $100;
             S := S + ' $' + HWS((PC + 2 + I));
           end;
    IndX : S := S + ' ($' + HBS(M^[PC + 1]) + ',X)';
    IndY : S := S + ' ($' + HBS(M^[PC + 1]) + '),Y';
    AbsI : S := S + ' ($' + HBS(M^[PC + 2]) + HBS(M^[PC + 1]) + ')';
  end; { case }
  ResourceSor := S;
end; { ResourceSor }

end.