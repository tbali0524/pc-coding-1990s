{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1991,95 by T¢th B lint       }
{                                                }
{************************************************}

unit CVGlob; { Glob lis deklar ci¢k }

interface

uses Dos, Objects, Menus;

const
  BaseName =  'C64IDE';
  EXEExt = '.EXE';
  EXEName = BaseName + EXEExt;
  HLPExt = '.HLP';
  DSKExt = '.DSK';
  CFGExt = '.CFG';
  TVRExt = '.TVR';

 { C64 ROM file-ok }
  BasicROMName: PathStr  = 'BASIC.ROM';
  CharROMName: PathStr   = 'CHAR.ROM';
  KernalROMName: PathStr = 'KERNAL.ROM';

 { Desktop file fejl‚c }
  SignatureLen = 21;
  DSKSignature: String[SignatureLen] = 'C64IDE Desktop File '#26;

 { Resource-ba nem tehet“ sztringek }
  ResReadErrorStr = 'Unable to read resources.'#13#10;
  ShellMsgStr = 'Type EXIT to return to ' + BaseName + '...'#13#10;

const

 { HandleEvent parancsok }
  cmNoCommand   = 1000;
  cmShowClip    = 1201;
  cmAssemble    = 1501;
  cmMakePRG     = 1502;
  cmMakeT64     = 1503;
  cmReport      = 1601;
  cmMouse       = 1602;
  cmColors      = 1603;
  cmToggleVideo = 1604;
  cmOpenDeskTop = 1605;
  cmSaveDeskTop = 1606;
  cmDisAssembler= 1701;
  cmDump        = 1702;
  cmAsciiViewer = 1703;
  cmRegisters   = 1704;
  cmOutput      = 1705;
  cmMemFill     = 1801;
  cmMemFind     = 1802;
  cmMemLoad     = 1803;
  cmMemSave     = 1804;
  cmContents    = 1901;
  cmIndex       = 1902;
  cmUsingHelp   = 1903;
  cmAbout       = 1904;

const

 { Resource sztringek }
  sNoMem            = 3001;
  sErrorReading     = 3002;
  sErrorWriting     = 3003;
  sErrorCreating    = 3004;
  sModified         = 3005;
  sSaveUntitled     = 3006;
  sStrNotFound      = 3007;
  sReplace          = 3008;
  sErrorHelp        = 3009;
  sErrorOpenDesk    = 3010;
  sErrorReadingDesk = 3011;
  sDeskInvalid      = 3012;
  sErrorDeskCreate  = 3013;
  sErrorAssemble    = 3014;
  sErrorOpenSource  = 3015;
  sAssembleOk       = 3016;
  sErrorMemFill     = 3017;
  sErrorMemFind     = 3018;
  sErrorMemSave     = 3019;
  sMemSearchNotFound= 3020;
  sErrorReadROM     = 3021;

 { Help sz”veggel nem rendelkez“ (StatusLine) help context-ek }
  hcPleaseWait = 101;

type
  PHCStatusLine = ^THCStatusLine;
  THCStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;

var
  RezFile: TResourceFile;
  RezStream: PStream;
  RezStrings: PStringList;

procedure RegisterGlobals;

implementation

const
  RHCStatusLine : TStreamRec = (
    ObjType : 100;
    VmtLink : Ofs(TypeOf(THCStatusLine)^);
    Load    : @THCStatusLine.Load;
    Store   : @THCStatusLine.Store
  );

procedure RegisterGlobals;
begin
  RegisterType(RHCStatusLine);
end;

{ THCStatusLine objektum }
function THCStatusLine.Hint(AHelpCtx: Word) :String;
begin
  Hint := RezStrings^.Get(AHelpCtx);
end;

end.