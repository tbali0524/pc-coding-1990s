{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1991,95 by T¢th B†lint       }
{                                                }
{     Borland Pascal 7.0, Turbo Vision 2.0       }
{                                                }
{************************************************}

program C64IDE; { IDE fìprogram }

{$B-}
uses Drivers, Memory, Objects, Views, Menus, Dialogs, HistList, App,
  Editors, MsgBox, StdDlg, ColorSel, HelpFile,
  Dos, CGlobals, CMemTool, CKif, CAsm, CVHelp, CVGlob, CVWin;

const
  HeapSize = 148 * 1024 div 16;

var
  ExeBaseName: FNameStr; { Program filenÇv kiterjesztÇs nÇlkÅl }

type
  TC64App = object(TApplication)
    Mem: PMem;
    ClipWindow: PEditWindow;
    constructor Init;
    destructor Done; virtual;
    procedure FileOpen(WildCard: PathStr);
    function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
    procedure CloseAll;
    procedure WriteShellMsg; virtual;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OpenDesktop(ShowError: Boolean);
    procedure LoadDesktop(var S: TStream);
    procedure OutOfMemory; virtual;
    procedure StoreDesktop(var S: TStream);
  end;

{ Resource MessageBox wrappers }

function RMessageBox(StrNum: Word; Param: Pointer; Flags: Word): Word;
begin
  RMessageBox := MessageBox(RezStrings^.Get(StrNum), Param, Flags);
end;

function RMessageBoxRect(var Rect: TRect; StrNum: Word; Param: Pointer;
  Flags: Word): Word;
begin
  RMessageBoxRect := MessageBoxRect(Rect, RezStrings^.Get(StrNum), Param,
    Flags);
end;

{ Editor dialog call-back }

function DoEditDialog(Dialog: Integer; Info: Pointer): Word; far;
var
  R: TRect;
  T: TPoint;

  function ExecDialog(const Dialog: String; Param: Pointer): Word;
  begin
    Application^.ExecuteDialog(PDialog(RezFile.Get(Dialog)), Param);
  end;

begin
  case Dialog of
    edOutOfMemory:
      DoEditDialog := RMessageBox(sNoMem, Nil, mfError + mfOkButton);
    edReadError:
      DoEditDialog := RMessageBox(sErrorReading, @Info, mfError + mfOkButton);
    edWriteError:
      DoEditDialog := RMessageBox(sErrorWriting, @Info, mfError + mfOkButton);
    edCreateError:
      DoEditDialog := RMessageBox(sErrorCreating, @Info, mfError + mfOkButton);
    edSaveModify:
      DoEditDialog := RMessageBox(sModified, @Info,
        mfInformation + mfYesNoCancel);
    edSaveUntitled:
      DoEditDialog := RMessageBox(sSaveUntitled, Nil,
        mfInformation + mfYesNoCancel);
    edSaveAs:
      DoEditDialog := ExecDialog('SaveAsDialog', Info);
    edFind:
      DoEditDialog := ExecDialog('FindDialog', Info);
    edSearchFailed:
      DoEditDialog := RMessageBox(sStrNotFound, Nil, mfError + mfOkButton);
    edReplace:
      DoEditDialog := ExecDialog('ReplaceDialog', Info);
    edReplacePrompt:
      begin
        { Avoid placing the dialog on the same line as the cursor }
        R.Assign(0, 1, 40, 8);
        R.Move((Desktop^.Size.X - R.B.X) div 2, 0);
        Desktop^.MakeGlobal(R.B, T);
        Inc(T.Y);
        if TPoint(Info).Y <= T.Y then
          R.Move(0, Desktop^.Size.Y - R.B.Y - 2);
        DoEditDialog := RMessageBoxRect(R, sReplace, Nil,
          mfYesNoCancel + mfInformation);
      end;
  end;
end;

procedure GetExeBaseName; { Program filenÇv meghat†roz†sa (kiterjesztÇs nÇlkÅl) }
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ExeBaseName := ParamStr(0);
  if ExeBaseName = '' then
    ExeBaseName := FSearch(EXEName, GetEnv('PATH'));
  ExeBaseName := FExpand(ExeBaseName);
  FSplit(ExeBaseName, D, N, E);
  ExeBaseName := D + N;
end;

constructor TC64App.Init;
var
  I: Integer;
  W1, W2: Word;
  FileName: String;
begin
  GetExeBaseName;
  MaxHeapSize := HeapSize;
  RezStream := New(PBufStream, Init(ExeBaseName + TVRExt, stOpenRead, 4096));
  if RezStream^.Status <> stOK then
  begin
    Dispose(RezStream, Done);
    RezStream := New(PBufStream, Init(ExeBaseName + EXEExt, stOpenRead, 4096));
    if RezStream^.Status <> stOK then
    begin
      PrintStr(ResReadErrorStr);
      Halt(1);
    end;
  end;
  RezFile.Init(RezStream);
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterStdDlg;
  RegisterEditors;
  RegisterColorSel;
  RegisterType(RStringList);
  RegisterHelpFile;
  RegisterGlobals;
  RezStrings := PStringList(RezFile.Get('Strings'));
  if RezStrings = Nil then
  begin
    PrintStr(ResReadErrorStr);
    Halt(1);
  end;
  inherited Init;
  HelpCtx := hcPleaseWait;
  StatusLine^.Update;
  New(Mem);
  FillMem(Mem, 0, $FFFF, $00);
  if (LoadPRG(Mem, BasicROMName, W1, W2) <> teNone) or
     (LoadPRG(Mem, CharROMName, W1, W2) <> teNone) or
     (LoadPRG(Mem, KernalROMName, W1, W2) <> teNone) then
      RMessageBox(sErrorReadROM, Nil, mfError + mfOkButton);
  OpenDesktop(False);
  EditorDialog := DoEditDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> Nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  for I := 1 to ParamCount do
  begin
    FileName := ParamStr(I);
    if FileName[Length(FileName)] = '\' then
      FileName := FileName + '*.*';
    if (Pos('?', FileName) = 0) and (Pos('*', FileName) = 0) then
      OpenEditor(FExpand(FileName), True)
    else
      FileOpen(FileName);
  end;
  HelpCtx := hcNoContext;
  ExecuteDialog(PDialog(RezFile.Get('AboutDialog')), Nil);
end; { Init }

destructor TC64App.Done;
begin
  Dispose(Mem);
  RezFile.Done;
  inherited Done;
end;

function TC64App.OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PView;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := Application^.ValidView(New(PEditWindow,
    Init(R, FileName, wnNoNumber)));
  if not Visible then P^.Hide;
  Desktop^.Insert(P);
  OpenEditor := PEditWindow(P);
end;

procedure TC64App.FileOpen(WildCard: PathStr);
var
  FileName: PathStr;
begin
  FileName := WildCard;
  if ExecuteDialog(PDialog(RezFile.Get('FileOpenDialog')),
      @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure TC64App.CloseAll;

procedure CloseView(P: PView); far;
begin
  Message(P, evCommand, cmClose, Nil);
end;

begin
  if Desktop^.Valid(cmClose) then
    Desktop^.ForEach(@CloseView);
end;

procedure TC64App.WriteShellMsg;
begin
  PrintStr(ShellMsgStr);
end; { WriteShellMsg }

procedure TC64App.GetEvent(var Event: TEvent);

procedure HandleHelp(Context: Word);

const
  HelpInUse: Boolean = False; { Çlettartam nem lok†lis! }
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;

begin
  if not HelpInUse then
  begin
    HelpInUse := True;
    HelpStrm := New(PDosStream, Init(ExeBaseName + HLPExt, stOpenRead));
    HFile := New(PHelpFile, Init(HelpStrm));
    if HelpStrm^.Status <> stOk then
    begin
      RMessageBox(sErrorHelp, Nil, mfError + mfOkButton);
      Dispose(HFile, Done);
    end
    else
    begin
      W := New(PHelpWindow,Init(HFile, Context));
      if ValidView(W) <> Nil then
      begin
        ExecView(W);
        Dispose(W, Done);
      end;
      ClearEvent(Event);
    end;
    HelpInUse := False;
  end;
end; { HandleHelp }

begin { GetEvent }
  TApplication.GetEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmHelp:      HandleHelp(GetHelpCtx);
        cmContents:  HandleHelp(hcHelpContents);
        cmIndex:     HandleHelp(hcHelpIndex);
        cmUsingHelp: HandleHelp(hcHelpUsingHelp);
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;

function TC64App.GetPalette: PPalette;
const
  CNewColor = CAppColor + CHelpColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome;
  P: Array[apColor..apMonochrome] of String[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TC64App.OpenDesktop(ShowError: Boolean);
var
  S: PStream;
  Signature: String[SignatureLen];
begin
  S := New(PBufStream, Init(ExeBaseName + DSKExt, stOpenRead, 1024));
  if LowMemory then
    OutOfMemory
  else if S^.Status <> stOk then
  begin
    if ShowError then
      RMessageBox(sErrorOpenDesk, Nil, mfOkButton + mfError)
  end
  else
  begin
    Signature[0] := Char(SignatureLen);
    S^.Read(Signature[1], SignatureLen);
    if Signature = DSKSignature then
    begin
      LoadDesktop(S^);
      LoadIndexes(S^);
      LoadHistory(S^);
      if S^.Status <> stOk then
        RMessageBox(sErrorReadingDesk, Nil, mfOkButton + mfError);
    end
    else
      RMessageBox(sDeskInvalid, Nil, mfOkButton + mfError);
  end;
  Dispose(S, Done);
end; { OpenDesktop }

procedure TC64App.HandleEvent(var Event: TEvent);

procedure Colors;
begin
  if ExecuteDialog(PDialog(RezFile.Get('ColorSelectDialog')),
    Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;
    ReDraw;
  end;
end;

procedure Mouse;
var
  D: PDialog;
begin
{  D := New(PMouseDialog, Init);
  D^.HelpCtx := hcOMMouseDBox;
  ExecuteDialog(D, @MouseReverse);
}end;

procedure SaveDesktop;
var
  S: PStream;
  F: File;
begin
  S := New(PBufStream, Init(ExeBaseName + DSKExt, stCreate, 1024));
  if not LowMemory and (S^.Status = stOk) then
  begin
    S^.Write(DSKSignature[1], SignatureLen);
    StoreDesktop(S^);
    StoreIndexes(S^);
    StoreHistory(S^);
    if S^.Status <> stOk then
    begin
      RMessageBox(sErrorDeskCreate, Nil, mfOkButton + mfError);
      {$I-}
      Dispose(S, Done);
      Assign(F, ExeBaseName + DSKExt);
      Erase(F);
      {$I+}
      Exit;
    end;
  end;
  Dispose(S, Done);
end; { SaveDesktop }

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

procedure Dump;
var
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  InsertWindow(New(PHexWindow, Init(R, Mem)));
end;

procedure AsciiViewer;
var
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  InsertWindow(New(PAsciiWindow, Init(R, Mem)));
end;


procedure MemFill;
type
  FillInfoT = Record
    ValueS: String[10];
    FromS, ToS: String[5];
  end;
const
  FillInfo: FillInfoT = (
    ValueS : '';
    FromS  : '';
    ToS    : '');
var
  StartA, EndA: Word;
  Value: Byte;
  K: Integer;
begin
  if ExecuteDialog(PDialog(RezFile.Get('MemFillDialog')), @FillInfo)
    <> cmCancel then
  begin
    Val(FillInfo.FromS, StartA, K);
    if K = 0 then
    begin
      Val(FillInfo.ToS, EndA, K);
      if K = 0 then
      begin
        Val(FillInfo.ValueS, Value, K);
        if K = 0 then
        begin
          if not FillMem(Mem, StartA, EndA, Value) then
            K := 1;
        end;
      end;
    end;
    if K <> 0 then
      RMessageBox(sErrorMemFill, Nil, mfOkButton + mfError);
  end;
end; { MemFill }

procedure MemFind;
type
  FindInfoT = Record
    ValueS: String[19];
    FromS, ToS: String[5];
  end;
const
  FindInfo: FindInfoT = (
    ValueS : '';
    FromS  : '';
    ToS    : '');
var
  StartA, EndA: Word;
  Value: Byte;
  K: Integer;
begin
  if ExecuteDialog(PDialog(RezFile.Get('MemFindDialog')), @FindInfo)
    <> cmCancel then
  begin
    Val(FindInfo.FromS, StartA, K);
    if K = 0 then
    begin
      Val(FindInfo.ToS, EndA, K);
      if K = 0 then
      begin
        Val(FindInfo.ValueS, Value, K);
        if K = 0 then
        begin

        end;
      end;
    end;
    if K <> 0 then
      RMessageBox(sErrorMemFind, Nil, mfOkButton + mfError);
  end;
end; { MemFind }

procedure MemSave;
type
  SaveInfoT = Record
    FromS, ToS: String[5];
  end;
const
  SaveInfo: SaveInfoT = (
    FromS  : '';
    ToS    : '');
var
  StartA, EndA: Word;
  SaveName: PathStr;
  K: Integer;
begin
  if ExecuteDialog(PDialog(RezFile.Get('MemSaveDialog')), @SaveInfo)
    <> cmCancel then
  begin
    Val(SaveInfo.FromS, StartA, K);
    if K = 0 then
    begin
      Val(SaveInfo.ToS, EndA, K);
      if K = 0 then
        if ExecuteDialog(PDialog(RezFile.Get('MemSaveAsDialog')), @SaveName)
          <> cmCancel then
          if not SavePRG(Mem, SaveName, StartA, EndA) then
            RMessageBox(sErrorWriting, Nil, mfOkButton + mfError);
    end;
    if K <> 0 then
      RMessageBox(sErrorMemSave, Nil, mfOkButton + mfError);
  end;
end; { MemSave }

procedure Assemble;
var
  A: PAsm;
  Info: Record
    L: LongInt;
    S: Pointer;
  end;
  P: PView;
  S1: String[255];
  AFileName: PathStr;
begin
  P := Desktop^.Current;
  if (P <> Nil) and (TypeOf(P^) = TypeOf(TEditWindow)) and
    (PEditWindow(P)^.GetTitle(SizeOf(PathStr)) <> 'Clipboard') then
  begin
    if PEditWindow(P)^.Editor^.Modified then
      PEditWindow(P)^.Editor^.Save;
    HelpCtx := hcPleaseWait;
    StatusLine^.Update;
    AFileName := PEditWindow(P)^.GetTitle(SizeOf(PathStr));
    New(A, Init(AFileName, Mem, Nil, DefaultOpt));
    A^.Fordit;
    if A^.State <> erNone then
    begin
      if A^.State = erOpenAsm then
        RMessageBox(sErrorOpenSource, Nil, mfError+ mfOkButton)
      else
      begin
        Info.L := A^.LineNum;
        S1 := HibaJel(A^.State, A^.LineNum, '');
        Info.S := @S1;
        RMessageBox(sErrorAssemble, @Info, mfError+ mfOkButton);
      end
    end
    else
      RMessageBox(sAssembleOk, Nil, mfError+ mfOkButton);
    A^.Done;
    HelpCtx := hcNoContext;
  end;
end; { Assemble }

{ HandeEvent }
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmTile:      Tile;
          cmCascade:   Cascade;
          cmCloseAll:  CloseAll;
          cmNew:       OpenEditor('', True);
          cmOpen:      FileOpen('*.ASM');
          cmChangeDir: ExecuteDialog(PDialog(RezFile.Get('ChDirDialog')), Nil);
          cmAssemble:  Assemble;
          cmShowClip:  ShowClip;
          cmMouse:     Mouse;
          cmColors:    Colors;
          cmToggleVideo: SetScreenMode(ScreenMode xor smFont8x8);
          cmSaveDesktop: SaveDesktop;
          cmOpenDesktop: OpenDesktop(True);
          cmDump:        Dump;
          cmAsciiViewer: AsciiViewer;
          cmRegisters:   InsertWindow(New(PRegsWindow, Init));
          cmMemFill:     MemFill;
          cmMemFind:     MemFind;
          cmMemSave:     MemSave;
          cmAbout:     ExecuteDialog(PDialog(RezFile.Get('AboutDialog')), Nil);
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end; { case }
end; { HandleEvent }

procedure TC64App.OutOfMemory;
begin
  RMessageBox(sNoMem, Nil, mfError + mfOkButton);
end;

{ Since the safety pool is only large enough to guarantee that allocating
  a window will not run out of memory, loading the entire desktop without
  checking LowMemory could cause a heap error.  This means that each
  window should be read individually, instead of using Desktop's Load.
}

procedure TC64App.LoadDesktop(var S: TStream);
var
  P: PView;
begin
  if Desktop^.Valid(cmClose) then
  begin
    CloseAll;
    repeat
      P := PView(S.Get);
      Desktop^.InsertBefore(ValidView(P), Desktop^.Last);
    until P = Nil;
  end;
end;

procedure TC64App.StoreDesktop(var S: TStream);

procedure WriteView(P: PView); far;
begin
  if P <> Desktop^.Last then S.Put(P);
end;

begin
  Desktop^.ForEach(@WriteView);
  S.Put(Nil);
end;

procedure TC64App.InitMenuBar;
begin
  MenuBar := PMenuBar(RezFile.Get('MenuBar'));
end;

procedure TC64App.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PHCStatusLine(RezFile.Get('StatusLine'));
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine^.Locate(R);
end;

var
  C64App: TC64App;

begin
  C64App.Init;
  C64App.Run;
  C64App.Done;
end.