{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,96 by T¢th B lint       }
{                                                }
{************************************************}

program C64Asm; { Assembler f“program }

{$B-}
uses Dos, CGlobals, CMemTool, CKif, CAsm;

var
  AFileName: PathStr;   { assembly forr sf jln‚v }
  AOpt: TOpt;           { opci¢k }
  T64Format: Boolean;   { kimeneti f jl T64 form tum£ }
  P00Format: Boolean;   { kimeneti f jl P00 form tum£ }
  Mem: PMem;            { 64K mem¢ria blokk }
  A: PAsm;              { ford¡t¢ }
  W: Word;
  SaveOk: Boolean;      { Sikerlt-e kimenteni a leford¡tott eredm‚nyt }
  ErrorCode: Integer;   { Kil‚p‚si k¢d ideiglenes t rol sa }

{ ================================================================== }
{ Seg¡ts‚g }
procedure Help;
begin
  WriteLn('Usage:  C64ASM sourcefilename[.ASM] [outputfilename[.PRG]] ' +
    '[options]');
  WriteLn;
  WriteLn('Options:');
  WriteLn(' /S                        write symbol table to reportfile');
  WriteLn(' /L                        write compiling list to reportfile');
  WriteLn(' /T                        write summary to reportfile');
  WriteLn(' /R                        create detailed report: same as /SLMT');
  WriteLn(' /R=reportfilename[.REP]   define other name for reportfile');
  WriteLn(' /M                        write memory map to map file');
  WriteLn(' /M=mapfilename[.MAP]      define other name for mapfile');
  WriteLn(' /6                        enforce T64 file format for outputfile');
  WriteLn(' /0                        enforce P00 file format for outputfile');
  WriteLn;
  WriteLn('Use the /6 option or .T64 as extension of output filename to save',
    ' in T64 tape');
  WriteLn('file format. Or use the /0 option or .P00 as extension to save in',
    ' P00 format.');
  WriteLn('Otherwise PRG file format will be used.');
  Halt(erParams);
end; { Help }

{ ================================================================== }
{ Parancssor param‚terek feldolgoz sa }
procedure GetParams;

var
  B: Byte;
  S: String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  EnforceT64: Boolean;
  EnforceP00: Boolean;

procedure ParString;
var
  B2: Byte;
begin
  for B2 := 2 to Length(S) do
    case UpCase(S[B2]) of
      'S': AOpt.S := True;
      'L': AOpt.L := True;
      'M': AOpt.M := True;
      'T': AOpt.T := True;
      '6': EnforceT64 := True;
      '0': EnforceP00 := True;
      'R': begin
             AOpt.S := True;
             AOpt.L := True;
             AOpt.M := True;
             AOpt.T := True;
           end;
      else
        Help;
    end; { case }
end; { ParString }

begin { GetParams }
  AFileName := '';
  AOpt := DefaultOpt;
  EnforceT64 := False;
  EnforceP00 := False;
  for B := 1 to ParamCount do
  begin
    S := ParamStr(B);
    if S[1] in ['/', '-'] then
      if Length(S) > 1 then
        case (UpCase(S[2])) of
          'R': if (Length(S) > 3) and (S[3] = '=') then
                 AOpt.RFileName := Copy(S, 4, 255)
               else
                 ParString;
          'M': if (Length(S) > 3) and (S[3] = '=') then
                 AOpt.MFileName := Copy(S, 4, 255)
               else
                 ParString;
          else
            ParString;
        end { case }
      else
        Help
    else if AFileName = '' then
      AFileName := S
    else if AOpt.OFileName = '' then
      AOpt.OFileName := S
    else
      Help;
  end; { for }
  if AFileName = '' then
    Help;
  FNameExt(AFileName, ASMExt);
  if AOpt.OFileName = '' then
  begin
    FSplit(AFileName, D, N, E);
    AOpt.OFileName := D + N;
  end;
  if EnforceT64 then
  begin
    FNameExt(AOpt.OFileName, T64Ext);
    EnforceP00 := False;
  end
  else if EnforceP00 then
    FNameExt(AOpt.OFileName, P00Ext)
  else
    FNameExt(AOpt.OFileName, PRGExt);
  FSplit(AOpt.OFileName, D, N, E);
  T64Format := EnforceT64 or (E = T64Ext);
  P00Format := EnforceP00 or (E = P00Ext);
  if (AOpt.RFileName <> '') and not (AOpt.S or AOpt.L) then
    AOpt.T := True;
  if (AOpt.MFileName <> '') then
    AOpt.M := True;
  if AOpt.T or AOpt.S or AOpt.L then
  begin
    if AOpt.RFileName = '' then
    begin
      FSplit(AFileName, D, N, E);
      AOpt.RFileName := D + N + REPExt;
    end
    else
      FNameExt(AOpt.RFileName, REPExt);
  end; { if AOpt.T }
  if AOpt.M then
  begin
    if AOpt.MFileName = '' then
    begin
      FSplit(AFileName, D, N, E);
      AOpt.MFileName := D + N + MAPExt;
    end
    else
      FNameExt(AOpt.MFileName, MAPExt);
  end; { if AOpt.M }
end; { GetParams }

{ ================================================================== }
begin { f“program }
  WriteLn(AsmInfo);
  WriteLn;
  ErrorCode := 0;
  GetParams;
  if MaxAvail >= $11000 then
    New(Mem)
  else
  begin
    WriteLn(HibaJel(erNoMem, 0, ''));
    Halt(erNoMem);
  end;
  for W := 0 to $FFFF do
    Mem^[W] := 0;
  New(A, Init(AFileName, Mem, Nil, AOpt));
  A^.Fordit;
  WriteLn('Assembling ', AFileName);
  with A^ do
  begin
    if State <> erNone then
    begin
      WriteLn;
      if State = erIncl then
      begin
        WriteLn(HibaJel(InclHibaState, InclHibaLineNum, InclHibaFName));
        if InclHibaLineNum <> 0 then
          WriteLn('  ', InclHibaEredSor);
      end;
      WriteLn(HibaJel(State, LineNum, ForrasFName));
      if LineNum <> 0 then
        WriteLn('  ', EredSor);
      WriteLn;
      ErrorCode := State;
    end { if State }
    else
    if PCMin <= PCMax then
    begin
      if T64Format then
        SaveOk := SaveT64(Mem, Opt.OFileName, PCMin, PCMax)
      else if P00Format then
        SaveOk := SaveP00(Mem, Opt.OFileName, PCMin, PCMax)
      else
        SaveOk := SavePRG(Mem, Opt.OFileName, PCMin, PCMax);
      if SaveOk then
        WriteLn(Opt.OFileName, ' created from $', HWS(PCMin), ' to $',
          HWS(PCMax))
      else
      begin
        WriteLn('Error #', erOutFile, ' :  Cannot create ', Opt.OFileName);
        ErrorCode := erOutFile;
      end
    end { if PCMin }
    else
      WriteLn('No code generated');
    if VoltRep then
      WriteLn('Report generated in ', Opt.RFileName);
    if VoltMap then
      WriteLn('Memory map generated in ', Opt.MFileName);
  end; { with }
  Dispose(A, Done);
  Dispose(Mem);
  Halt(ErrorCode);
end.

{ Sz”veg nem v‚gleges kiad shoz: (ez most nem az!)
THIS IS AN ALPHA-TEST VERSION, NOT AN OFFICIAL RELEASE.
USE ONLY AT YOUR OWN RISK!
PLEASE DO NOT DISTRIBUTE!
PLEASE REPORT ANY BUGS TO THE AUTHOR.
}