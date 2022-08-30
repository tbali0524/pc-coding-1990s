{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B lint       }
{                                                }
{************************************************}

program BAS2TXT; { CBM BASIC -> ASCII TEXT konvert l¢ program }

{$B-}
uses Dos, CGlobals, CMemTool;

const
  Info: String[80] = 'BAS2TXT v1.1a - Copyright (c) 1996-2001 by B lint T¢th';
  TXTExt = '.TXT';

  CommandList: Array[0..126] of String[7] = (
    'END', 'FOR', 'NEXT', 'DATA', 'INPUT#', 'INPUT', 'DIM', 'READ', 'LET',
    'GOTO', 'RUN', 'IF', 'RESTORE', 'GOSUB', 'RETURN', 'REM', 'STOP', 'ON',
    'WAIT', 'LOAD', 'SAVE', 'VERIFY', 'DEF', 'POKE', 'PRINT#', 'PRINT',
    'CONT', 'LIST', 'CLR', 'CMD', 'SYS', 'OPEN', 'CLOSE', 'GET', 'NEW',
    'TAB(', 'TO', 'FN', 'SPC(', 'THEN', 'NOT', 'STEP', '+', '-', '*', '/',
    '^', 'AND', 'OR', '>', '=', '<', 'SGN', 'INT', 'ABS', 'USR', 'FRE',
    'POS', 'SQR', 'RND', 'LOG', 'EXP', 'COS', 'SIN', 'TAN', 'ATN', 'PEEK',
    'LEN', 'STR$', 'VAL', 'ASC', 'CHR$', 'LEFT$', 'RIGHT$', 'MID$', 'GO',
    'Ì', 'FOR', 'NEXT', 'DATA', 'INPUT#', 'INPUT', 'DIM', 'READ', 'LET',
    'GOTO', 'RUN', 'IF', 'RESTORE', 'GOSUB', 'RETURN', 'REM', 'STOP', 'ON',
    'WAIT', 'LOAD', 'SAVE', 'VERIFY', 'DEF', 'POKE', 'PRINT#', 'PRINT',
    'CONT', 'LIST', 'CLR', 'CMD', 'SYS', 'OPEN', 'CLOSE', 'GET', 'NEW',
    'TAB(', 'TO', 'FN', 'SPC(', 'THEN', 'NOT', 'STEP', '+', '-', '*', '/',
    '^', 'AND', 'OR', '>', '=');

{ parancssor param‚terek }
const
  WhichEntry: Word = 1; { h nyadik  llom nyb¢l t”lts”n T64 f jl eset‚n }
  SkipLineNum: Boolean = False; { sorsz mok ne kerljenek a kimenetre }
  LeaveAscii: Boolean  = False; { nem kell CBM->PC ASCII konverzi¢ }
  NoSeparator: Boolean = False; { nem kell sz¢k”z kell token ut n }
  NoColon: Boolean     = False; { kett“spont ut ni parancs kl”n sorba }

var
  T64Format: Boolean;   { bemeneti f jl T64 form tum£ }
  P00Format: Boolean;   { bemeneti f jl P00 form tum£ }
  IFileName: PathStr;   { bemeneti f jln‚v }
  OFileName: PathStr;   { kimeneti k¢dlista f jln‚v }
  OFile: Text;          { lista f jl }
  StartA, EndA: Word;   { bemeneti f jl C64 mem¢riabeli kezd“ ‚s v‚gc¡m }
  M: PMem;              { 64K mem¢ria blokk }

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
  WriteLn('Usage:  BAS2TXT inputfilename[.PRG] [outputfilename[.TXT]] ' +
    '[options]');
  WriteLn;
  WriteLn('Options:');
  WriteLn(' /E=num     use the num-th entry in the T64 file (default: first)');
  WriteLn(' /L         don''t put line numbers in output');
  WriteLn(' /P         don''t convert text in quotes to PC ASCII');
  WriteLn(' /S         don''t put spaces before and after BASIC commands');
  WriteLn(' /:         put commands separated by colon (:) in new lines');
  WriteLn;
  WriteLn('Use .T64 as extension of input filename to load from T64 tape file.');
  WriteLn('Or use .P00 as extension to load from a file in P00 format.');
  WriteLn('Otherwise PRG file format is supposed.');
  WriteLn;
  WriteLn('For C64ASM assembly sourcefiles, use:  BAS2TXT input output.ASM /LPS:');
  Halt(erParams);
end;

{ ================================================================== }
{ Parancssor param‚terek feldolgoz sa }
procedure GetParams;
var
  S: String;
  B, B2: Byte;
  I: Integer;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  IFileName := '';
  OFileName := '';
  for B := 1 to ParamCount do
  begin
    S := ParamStr(B);
    if S[1] = '/' then
      if Length(S) > 1 then
      begin
        if (Length(S) > 3) and (UpCase(S[2]) = 'E') and (S[3] = '=') then
        begin
          Val(Copy(S, 4, 255), WhichEntry, I);
          if (I <> 0) or (WhichEntry < 1) then
            Help;
        end
        else
          for B2 := 2 to Length(S) do
            case UpCase(S[B2]) of
              'L': SkipLineNum := True;
              'P': LeaveAscii := True;
              'S': NoSeparator := True;
              ':': NoColon := True;
              else
                Help;
            end { case }
      end { if Length(S) }
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
    OFileName := D + N + TXTExt
  else
    FNameExt(OFileName, TXTExt);
end; { GetParams }

{ ================================================================== }
{ Bemeneti f jl bet”lt‚se, kimenet f jl megnyit sa }
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
  {$I-}
  Assign(OFile, OFileName);
  Rewrite(OFile);
  {$I+}
  if IOResult <> 0 then
    Hiba('Cannot open ' + OFileName + ' for output', erOutFile);
  Write('Converting ');
  Write(IFileName);
  if T64Format then
    Write(' (Entry: ', WhichEntry, ')');
  WriteLn(' from $', HWS(StartA), ' to $', HWS(EndA));
end; { OpenFiles }

{ ================================================================== }
{ Konvert l s }
procedure Convert;
const
  Done: Boolean = False;
  WasLineNumJam: Boolean = False;
  WasLinePtrJam: Boolean = False;
  InQuote: Boolean = False;
  LastWasSpace: Boolean = True;
  Separator: String[1] = '';
var
  PC: Word;
  NextLine: Word;
  PrevLineNum: Word;
  LineNum: Word;
  B: Byte;
begin
  if not NoSeparator then
    Separator := ' ';
  PC := StartA;
  PrevLineNum := 0;
  repeat
    NextLine := M^[PC] + (M^[PC + 1] shl 8);
    Done := (NextLine = 0) or (PC > EndA - 4);
    if NextLine <> 0 then
    begin
      if (NextLine < StartA) or (NextLine > EndA - 1) then
      begin
        WriteLn('Error in input file: line pointer points out of file at $',
          HWS(PC));
        WasLinePtrJam := True;
        Done := True;
      end
      else if NextLine <= PC + 4 then
      begin
        WriteLn('Error in input file: line pointer points backwards at $',
          HWS(PC));
        WasLinePtrJam := True;
        Done := True;
      end;
    end; { if NextLine <> }
    if not Done then
    begin
      LineNum := M^[PC + 2] + (M^[PC + 3] shl 8);
      if (LineNum <= PrevLineNum) and (LineNum <> 0) then
        WasLineNumJam := True;
      PrevLineNum := LineNum;
      if not SkipLineNum then
        Write(OFile, LineNum, ' ');
      Inc(PC, 4);
      InQuote := False;
      LastWasSpace := True;
      while PC < (NextLine - 1) do
      begin
        B := M^[PC];
        if B = 34 then                  { id‚z“jel " }
          InQuote := not InQuote;
        if InQuote then
          if LeaveAscii then
            Write(OFile, Chr(M^[PC]))
          else
            Write(OFile, Chr(CBM2PCAscii(M^[PC], False)))
        else
        begin
          if (B = 58) and NoColon then   { kett“spont : }
            WriteLn(OFile)
          else if (B < $80) or (B = $FF) then
            Write(OFile, Chr(M^[PC]))
          else
          begin
            if not LastWasSpace then
              Write(OFile, Separator);
            Write(OFile, CommandList[B - $80], Separator);
            B := 32;
          end;
        end; { if InQuote else }
        LastWasSpace := B = 32;
        Inc(PC);
      end; { while }
      Inc(PC);
      WriteLn(OFile);
    end; { if not Done }
  until Done or (PC >= EndA);
  if WasLineNumJam then
    WriteLn('Line numbers were not ascending in input file.');
  if (not WasLinePtrJam) and (PC < (EndA - 1)) then
    WriteLn('BASIC program ended at $', HWS(PC + 1), ', ',
      (EndA - PC - 1), ' bytes before the end of inputfile');
end; { Convert }

{ ================================================================== }
begin { F“program }
  WriteLn(Info);
  WriteLn;
  GetParams;
  if MaxAvail >= $11000 then
    New(M)
  else
    Hiba('Not enough memory', erNoMem);
  OpenFiles;
  if (EndA - StartA) < 7 then
    Hiba('No BASIC program found in inputfile', erOpenInp);
  Convert;
  Close(OFile);
  WriteLn(OFileName, ' created');
  Dispose(M);
  Halt(0);
end.