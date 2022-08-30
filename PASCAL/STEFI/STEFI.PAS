{***********************************************}
{                                               }
{        S T E F I   - gr fprogram              }
{               1.0c verzi¢                     }
{                                               }
{   Copyright (c) 1995,96,2001 by T¢th B lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0        }
{                                               }
{***********************************************}

{ Turbo Vision valtozat }

{ Foprogram }
program Stefi;

{$B-,X+}

uses Drivers, Memory, Objects, Views, Menus, Dialogs, HistList, App,
  MsgBox, StdDlg, ColorSel, HelpFile, Dos,
  GrStrukt, GrafAlg, GrSzerk, StefiHC, StefiTV, StTVGlob;

const
  ReportFName = 'REPORT.TXT';
  DefExeFName = 'STEFI.EXE';
  DefHelpFName = 'STEFI.TVH';
  GrfExt = '.GRF';

var
  ExeFName: PathStr;
  HelpFName: PathStr;

type
  TStefiApp = object(TApplication)
    G: PGraf;
    GrafFName: PString;
    Modified: Boolean;
    ShowGrf: PShowGrf;
    constructor Init;
    destructor Done; virtual;
    procedure ChangeGrafFName(const FName: PathStr);
    function ValidDestroy: Boolean;
    procedure SaveGraph;
    procedure OpenGraf(const FName: PathStr);
    procedure OpenText(const FName: PathStr);
    procedure WriteShellMsg; virtual;
    procedure Idle; virtual;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end; { TStefiApp }

{ ========================================================================== }

constructor TStefiApp.Init;
var
  R: TRect;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ExeFName := FExpand(ParamStr(0));
  if ExeFName = '' then
    ExeFName := DefExeFName;
  FSplit(ExeFName, D, N, E);
  HelpFName := D + DefHelpFName;
  RezStream := New(PBufStream, Init(ResFName, stOpenRead, 4096));
  if RezStream^.Status <> stOK then
  begin
    Dispose(RezStream, Done);
    RezStream := New(PBufStream, Init(ExeFName, stOpenRead, 4096));
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
  New(G);
  G^ := UresGraf;
  GrafFName := Nil;
  Modified := False;
  ExecuteDialog(PDialog(RezFile.Get('AboutDialog')), Nil);
  if not GraphAppInit then
    RMessageBox(sNoGraphics, Nil, mfError + mfOkButton);
  if ParamCount > 0 then
    OpenGraf(ParamStr(1));

  GetExtent(R);
  R.A.X := R.B.X - 42;
  R.B.Y := R.A.Y + 1;
  ShowGrf := New(PShowGrf, Init(R));
  Insert(ShowGrf);
  Message(ShowGrf, evBroadcast, cmGrfChanged, GrafFName);
end; { Init }

{ ========================================================================== }

destructor TStefiApp.Done;
begin
  GraphAppDone;
  DisposeGraf(G);
  if GrafFName <> Nil then
  begin
    DisposeStr(GrafFName);
    GrafFName := Nil;
  end;
  RezFile.Done;
  inherited Done;
end; { Done }

{ ========================================================================== }

procedure TStefiApp.ChangeGrafFName(const FName: PathStr);
begin
  if GrafFName <> Nil then
  begin
    DisposeStr(GrafFName);
    GrafFName := Nil;
  end;
  if FName <> '' then
    GrafFName := NewStr(FName);
  Message(ShowGrf, evBroadcast, cmGrfChanged, GrafFName);
end; { ChangeGrafFName }

{ ========================================================================== }

function TStefiApp.ValidDestroy: Boolean;
var
  W: Word;
begin
  ValidDestroy := True;
  if Modified then
  begin
    case RMessageBox(sSaveGraf, Nil, mfInformation + mfYesNoCancel) of
      cmYes:    SaveGraph;
      cmCancel: ValidDestroy := False;
    end;
  end;
end; { ValidDestroy }

{ ========================================================================== }

procedure TStefiApp.SaveGraph;
var
  FileName: PathStr;
begin
  if GrafFName = Nil then
  begin
    FileName := '*' + GrfExt;
    if ExecuteDialog(PDialog(RezFile.Get('SaveAsDialog')), @FileName)
      <> cmCancel then
        ChangeGrafFName(FileName);
  end;
  if GrafFName <> Nil then
    if SaveGraf(G, GrafFName^) then
      Modified := False
    else
      RMessageBox(sErrorWriting, Nil, mfError + mfOkButton);
end; { SaveGraf }

{ ========================================================================== }

procedure TStefiApp.OpenGraf(const FName: PathStr);
begin
  if ValidDestroy then
  begin
    DisposeGraf(G);
    ChangeGrafFName('');
    Modified := False;
    if not LoadGraf(G, FName) then
      RMessageBox(sErrorReading, Nil, mfError + mfOkButton)
    else
      ChangeGrafFName(FName);
  end;
end; { OpenGraf }

{ ========================================================================== }

procedure TStefiApp.OpenText(const FName: PathStr);
var
  P: PView;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := Application^.ValidView(New(PTextWindow, Init(R, FName)));
  Desktop^.Insert(P);
end; { OpenText }

{ ========================================================================== }

procedure TStefiApp.WriteShellMsg;
begin
  PrintStr(ShellMsgStr);
end; { WriteShellMsg }

{ ========================================================================== }

procedure TStefiApp.Idle;

function IsTileable(P: PView): Boolean; far;
begin
  IsTileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

begin
  inherited Idle;
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmPrint, cmCloseAll, cmTile, cmCascade])
  else
    DisableCommands([cmPrint, cmCloseAll, cmTile, cmCascade]);
end; { Idle }

{ ========================================================================== }

procedure TStefiApp.GetEvent(var Event: TEvent);

procedure HandleHelp(Context: Word);

const
  HelpInUse: Boolean = False; { ‚lettartam nem lok lis! }
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;

begin
  if not HelpInUse then
  begin
    HelpInUse := True;
    HelpStrm := New(PDosStream, Init(HelpFName, stOpenRead));
    HFile := New(PHelpFile, Init(HelpStrm));
    if HelpStrm^.Status <> stOk then
    begin
      RMessageBox(sErrorHelp, Nil, mfError + mfOkButton);
      Dispose(HFile, Done);
    end
    else
    begin
      W := New(PHelpWindow, Init(HFile, Context));
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
        cmUsingHelp: HandleHelp(hcHelpUsingHelp);
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end; { GetEvent }

{ ========================================================================== }

function TStefiApp.GetPalette: PPalette;
const
  CNewColor = CAppColor + CHelpColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome;
  P: Array[apColor..apMonochrome] of String[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end; { GetPalette }

{ ========================================================================== }

procedure TStefiApp.HandleEvent(var Event: TEvent);

{ ========================================================================== }

procedure TextOpen;
var
  FileName: PathStr;
begin
  FileName := '*.TXT';
  if ExecuteDialog(PDialog(RezFile.Get('OpenDialog')),
      @FileName) <> cmCancel then
    OpenText(FileName);
end; { TextOpen }

{ ========================================================================== }

procedure Print;
const
  Event: TEvent = (
    What: evBroadcast;
    Command: cmPrintSelf;
    InfoPtr: Nil
  );
begin
  Application^.PutEvent(Event);
end; { Print }

{ ========================================================================== }

procedure NewGraf;
begin
  if ValidDestroy then
  begin
    DisposeGraf(G);
    New(G);
    G^ := UresGraf;
    ChangeGrafFName('');
    Modified := False;
  end;
end; { NewGraf }

{ ========================================================================== }

procedure Open;
var
  FileName: PathStr;
begin
  FileName := '*' + GrfExt;
  if ExecuteDialog(PDialog(RezFile.Get('OpenDialog')),
      @FileName) <> cmCancel then
    OpenGraf(FileName);
end; { Open }

{ ========================================================================== }

procedure SaveAs;
begin
  ChangeGrafFName('');
  SaveGraph;
end; { SaveAs }

{ ========================================================================== }

procedure View;
var
  Event: TEvent;
begin
  if not GraphicsStart then
    RMessageBox(sNoGraphics, Nil, mfError + mfOkButton)
  else
  begin
    if (G^.XPoz = Nil) or (G^.YPoz = Nil) then
      ElhelyezGraf(G);
    RajzolGraf(G, 0, 0, Nil);
    repeat
      GetKeyEvent(Event);
    until Event.What <> evNothing;
    GraphicsStop;
  end;
end; { View }

{ ========================================================================== }

procedure Edit;
begin
  if not GraphicsStart then
    RMessageBox(sNoGraphics, Nil, mfError + mfOkButton)
  else
  begin
    Szerk(G);
    DisposeResults(G);
    Modified := True;
    GraphicsStop;
  end;
end; { Edit }

{ ========================================================================== }

procedure Report;

type
  TReportData = Record
    InpData: Word;
    ResData: Word;
    RepWidth: Word;
    RepLanguage: Word;
  end;
const
  ReportData: TReportData = (
    InpData: InpAll;
    ResData: ResAll;
    RepWidth: RepW250;
    RepLanguage: RepEnglish
  );
var
  FName: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  I: Word;
begin { Report }
  if ExecuteDialog(PDialog(RezFile.Get('ReportDialog')), @ReportData)
    <> cmCancel then
  begin
    HelpCtx := hcPleaseWait;
    StatusLine^.Update;
    DisposeResults(G);
    with ReportData do
    begin
      if (ResData and ResIncM) <> 0 then
        SzamitIncM(G);
      if (ResData and ResKomp) <> 0 then
        SzamitKomp(G);
      if (ResData and ResKorLista) <> 0 then
        SzamitKorM(G);
      if (ResData and ResFokLista) <> 0 then
        SzamitFokLista(G);
      if (ResData and ResEulerUt) <> 0 then
        SzamitEulerUt(G);
      if (ResData and ResPruferKod) <> 0 then
        SzamitPruferKod(G);
      if (ResData and ResMinTav) <> 0 then
        SzamitMinTav(G);
      if (ResData and ResExcentritas) <> 0 then
        SzamitExcentritas(G);
      if (ResData and ResMinFeszitoFa) <> 0 then
        SzamitMinFeszitoFa(G);
      if (ResData and ResTopRendezes) <> 0 then
        SzamitTopRendezes(G);
      if (ResData and ResErosKomp) <> 0 then
        SzamitErosKomp(G);
    end; { with }
    if GrafFName <> Nil then
    begin
      FSplit(GrafFName^, D, N, E);
      FName := D + N + '.TXT';
    end
    else
      FName := ReportFName;
    if Jelentes(G, FName, ReportData.InpData, ReportData.ResData,
        ReportData.RepWidth, ReportData.RepLanguage) then
      OpenText(FName)
    else
      RMessageBox(sErrorWriting, Nil, mfError + mfOkButton);
    HelpCtx := hcNoContext;
  end;
end; { Report }

{ ========================================================================== }

procedure ShowBox;
type
  TShowData = Record
    FromCs: String[1];
    ToCs: String[1];
    What: Word;
  end;
const
  ShowData: TShowData = (
    FromCs: 'A';
    ToCs: 'A';
    What: 0
  );
var
  WAdjM: TAdjMatrix;
  Ind, Veg: Integer;
  I, J: Integer;
  S: String;
  Ok: Boolean;
begin
  if ExecuteDialog(PDialog(RezFile.Get('ShowDialog')), @ShowData)
      <> cmCancel then
    if not GraphicsStart then
      RMessageBox(sNoGraphics, Nil, mfError + mfOkButton)
    else
      with G^ do
      begin
        Ok := True;
        if (G^.XPoz = Nil) or (G^.YPoz = Nil) then
          ElhelyezGraf(G);
        case ShowData.What of
          0: begin
               with ShowData do
               begin
                 if (Length(FromCs) = 0) or (Length(FromCs) = 0) then
                   Ind := 0
                 else
                 begin
                   Ind := Ord(UpCase(FromCs[1])) - Ord('A') + 1;
                   Veg := Ord(UpCase(ToCs[1])) - Ord('A') + 1;
                 end;
               end; { with }
               if (Ind > 0) and (Ind <= Cs) and (Veg > 0) and (Veg <= Cs)
                 and (Ind <> Veg) then
               begin
                 SzamitMinTav(G);
                 if MinUtKozepso <> Nil then
                 begin
                   for I := 1 to Cs do
                     for J := 1 to Cs do
                       WAdjM[I, J] := 0;
                   S := Betu(Ind) + GetMinUt(G, Ind, Veg) + Betu(Veg);
                   for I := 1 to Length(S) - 1 do
                     WAdjM[Ord(S[I]) - Ord('A') + 1, Ord(S[I + 1]) - Ord('A') + 1]
                       := 1;
                   RajzolGraf(G, 0, Ind, @WAdjM);
                 end { if MinUtKozepso }
                 else
                   Ok := False;
               end { if Ind }
               else
                 Ok := False;
             end; { case 0 }
          1: begin
               SzamitMinFeszitoFa(G);
               if MinFeszitoFa <> Nil then
                 RajzolGraf(G, 0, 0, MinFeszitoFa)
               else
                 Ok := False;
             end;
        end; { case }
        if Ok then
        begin
          repeat
            GetKeyEvent(Event);
          until Event.What <> evNothing;
          GraphicsStop;
        end
        else
        begin
          GraphicsStop;
          RMessageBox(sErrorShow, Nil, mfError + mfOkButton);
        end;
      end; { with }
end; { Show }

{ ========================================================================== }

procedure Colors;
begin
  if ExecuteDialog(PDialog(RezFile.Get('ColorSelectDialog')),
    Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;
    ReDraw;
  end;
end; { Colors }

{ ========================================================================== }

procedure CloseAll;

  procedure CloseView(P: PView); far;
  begin
    Message(P, evCommand, cmClose, Nil);
  end;

begin
  if Desktop^.Valid(cmClose) then
    Desktop^.ForEach(@CloseView);
end; { CloseAll }

{ ========================================================================== }

{ HandeEvent }
begin
  if (Event.What = evCommand) and (Event.Command = cmQuit) then
    if not ValidDestroy then
      ClearEvent(Event);
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmOpenText:  TextOpen;
          cmPrint:     Print;
          cmChangeDir: ExecuteDialog(PDialog(RezFile.Get('ChDirDialog')), Nil);
          cmNew:       NewGraf;
          cmOpen:      Open;
          cmSave:      SaveGraph;
          cmSaveAs:    SaveAs;
          cmView:      View;
          cmEdit:      Edit;
          cmReport:    Report;
          cmShow:      ShowBox;
          cmMouse:     ExecuteDialog(PDialog(RezFile.Get('MouseDialog')),
                         @MouseReverse);
          cmColors:    Colors;
          cmTile:      Tile;
          cmCascade:   Cascade;
          cmCloseAll:  CloseAll;
          cmAbout:     ExecuteDialog(PDialog(RezFile.Get('AboutDialog')), Nil);
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end; { case }
end; { HandleEvent }

{ ========================================================================== }

procedure TStefiApp.OutOfMemory;
begin
  RMessageBox(sNoMem, Nil, mfError + mfOkButton);
end;

{ ========================================================================== }

procedure TStefiApp.InitMenuBar;
begin
  MenuBar := PMenuBar(RezFile.Get('MenuBar'));
end;

{ ========================================================================== }

procedure TStefiApp.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PHCStatusLine(RezFile.Get('StatusLine'));
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine^.Locate(R);
end; { InitSatusLine }

{ ========================================================================== }

var
  StefiApp: TStefiApp;

{ Foprogram }
begin
  StefiApp.Init;
  StefiApp.Run;
  StefiApp.Done;
end.

{ ========================================================================== }
