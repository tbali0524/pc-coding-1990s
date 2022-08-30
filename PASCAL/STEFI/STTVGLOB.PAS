{******************************************}
{                                          }
{        S T E F I   - gr fprogram         }
{                                          }
{   Copyright (c) 1995,96 by T¢th B lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0   }
{                                          }
{******************************************}

{ Eroforras deklaraciok }
unit StTVGlob;

interface

uses Objects, Drivers, Views, Dialogs, Menus;

const
  ResFName = 'STEFI.TVR';               { Eroforras filenev }

 { HandleEvent parancsok }
  cmNoCommand   = 1000;
  cmOpenText    = 1101;
  cmPrint       = 101;
  cmView        = 1201;
  cmEdit        = 1202;
  cmReport      = 1203;
  cmShow        = 1204;
  cmMouse       = 1301;
  cmColors      = 1302;
  cmContents    = 1501;
  cmUsingHelp   = 1502;
  cmAbout       = 1503;

 { Broadcast uzenetek }
  cmGrfChanged  = 1601;         { Grafnev valtozott }
  cmPrintSelf   = 1602;         { Aktualis View window nyomtassa ki magat }

 { Eroforras sztringek }
  sNoMem            = 3001;
  sErrorReading     = 3002;
  sErrorWriting     = 3003;
  sErrorPrinting    = 3004;
  sErrorHelp        = 3006;
  sNoGraphics       = 3007;
  sErrorShow        = 3008;
  sSaveGraf         = 3101;
  sGrfNameHeader    = 3201;
  sUntitledGraf     = 3202;

 { Help sz”veggel nem rendelkez“ (StatusLine) help context-ek }
  hcPleaseWait = 101;

{ ========================================================================== }
{ Context sensitive StatusLine }

type
  PHCStatusLine = ^THCStatusLine;
  THCStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;

{ ========================================================================== }
{ Mouse settings dialog }

  PClickTester = ^TClickTester;
  TClickTester = object(TStaticText)
    Clicked: Boolean;
    constructor Init(var Bounds: TRect; AText: String);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
  end; { TClickTester }

  PMouseDialog = ^TMouseDialog;
  TMouseDialog = object(TDialog)
    MouseScrollBar: PScrollBar;
    OldDelay: Word;
    procedure HandleEvent(var Event: TEvent); virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
  end; { TMouseDialog }

{ ========================================================================== }
{ Eroforras }

var
  RezFile: TResourceFile;
  RezStream: PStream;
  RezStrings: PStringList;

procedure RegisterGlobals;

{ ========================================================================== }
implementation
{ ========================================================================== }

{ Eroforrasba rakando object-ek regisztralasa }
const
  RHCStatusLine : TStreamRec = (
    ObjType : 1001;
    VmtLink : Ofs(TypeOf(THCStatusLine)^);
    Load    : @THCStatusLine.Load;
    Store   : @THCStatusLine.Store
  );

  RClickTester : TStreamRec = (
    ObjType : 1002;
    VmtLink : Ofs(TypeOf(TClickTester)^);
    Load    : @TClickTester.Load;
    Store   : @TClickTester.Store
  );

  RMouseDialog : TStreamRec = (
    ObjType : 1003;
    VmtLink : Ofs(TypeOf(TMouseDialog)^);
    Load    : @TMouseDialog.Load;
    Store   : @TMouseDialog.Store
  );

procedure RegisterGlobals;
begin
  RegisterType(RHCStatusLine);
  RegisterType(RClickTester);
  RegisterType(RMouseDialog);
end; { RegisterGlobals }

{ ========================================================================== }
{ Context sensitive StatusLine }
{ ========================================================================== }

function THCStatusLine.Hint(AHelpCtx: Word) :String;
begin
  Hint := RezStrings^.Get(AHelpCtx);
end; { Hint }

{ ========================================================================== }
{ Mouse settings dialog }
{ ========================================================================== }

const
  CClickTester = #7#8;

{ TClickTester }
constructor TClickTester.Init(var Bounds: TRect; AText: String);
begin
  inherited Init(Bounds, AText);
  Clicked := False;
end; { Init }

{ ========================================================================== }

function TClickTester.GetPalette: PPalette;
const
  P: String[Length(CClickTester)] = CClickTester;
begin
  GetPalette := @P;
end; { GetPalette }

{ ========================================================================== }

procedure TClickTester.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evMouseDown) then
  begin
    if Event.Double then
    begin
      Clicked := not Clicked;
      DrawView;
    end;
    ClearEvent(Event);
  end;
end; { HandleEvent }

{ ========================================================================== }

procedure TClickTester.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  if Clicked then
    C := GetColor(2)
  else
    C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, Text^, C);
  WriteLine(0, 0, Size.X, 1, B);
end; { Draw }

{ ========================================================================== }

constructor TClickTester.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Clicked, SizeOf(Clicked));
end; { Load }

{ ========================================================================== }

procedure TClickTester.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Clicked, SizeOf(Clicked));
end; { Store }

{ ========================================================================== }
{ TMouseDialog }

procedure TMouseDialog.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evCommand) and (Event.Command = cmCancel) then
    DoubleDelay := OldDelay;
  inherited HandleEvent(Event);
  case Event.What of
    evBroadcast:
      if Event.Command = cmScrollBarChanged then
      begin
        DoubleDelay := MouseScrollBar^.Value;
        ClearEvent(Event);
      end;
  end;
end; { HandleEvent }

{ ========================================================================== }

constructor TMouseDialog.Load(var S: TStream);
begin
  inherited Load(S);
  OldDelay := DoubleDelay;
  GetSubViewPtr(S, MouseScrollBar);
  MouseScrollBar^.SetValue(DoubleDelay);
end; { Load }

{ ========================================================================== }

procedure TMouseDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, MouseScrollBar);
end; { Store }

{ ========================================================================== }

end.
