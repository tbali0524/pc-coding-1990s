{******************************************}
{                                          }
{        S T E F I   - gr fprogram         }
{                                          }
{   Copyright (c) 1995,96 by T¢th B lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0   }
{                                          }
{******************************************}

{ Turbo Vision kornyezet }
unit StefiTV;

{$B-,X+}

interface

uses Dos, Objects, Drivers, Views;

const
 { Eroforrasba nem teheto sztringek }
  ResReadErrorStr = 'Unable to read resources.'#13#10;
  ShellMsgStr = 'Type EXIT to return to STEFI...'#13#10;

{ ========================================================================== }
{ Text Viewer }

type
  PLineCollection = ^TLineCollection;
  TLineCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  PFileViewer = ^TFileViewer;
  TFileViewer = object(TScroller)
    FileName: PString;
    FileLines: PCollection;
    IsValid: Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      const AFileName: PathStr);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure ReadFile(const FName: PathStr);
    procedure Print;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end; { TFileViewer }

  PTextWindow = ^TTextWindow;
  TTextWindow = object(TWindow)
    constructor Init(R: TRect; const FileName: PathStr);
  end;

{ ========================================================================== }
{ Grafnev kijelzo }

  PShowGrf = ^TShowGrf;
  TShowGrf = object(TView)
    Grf: PString;
    constructor Init(var Bounds: TRect);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

{ ========================================================================== }
{ Turbo Vision <--> BGI grafika valtas }

function GraphAppInit: Boolean;
procedure GraphAppDone;
function GraphicsStart: Boolean;
procedure GraphicsStop;

{ ========================================================================== }

{ Eroforrasbol olvasott MessageBox }
function RMessageBox(StrNum: Word; Param: Pointer; Flags: Word): Word;

{ ========================================================================== }
implementation
{ ========================================================================== }

uses Graph, Memory, MsgBox, App, StefiHC, StTVGlob;

{ Eroforrasbol olvasott MessageBox }
function RMessageBox(StrNum: Word; Param: Pointer; Flags: Word): Word;
begin
  RMessageBox := MessageBox(RezStrings^.Get(StrNum), Param, Flags);
end;

{ ========================================================================== }
{ Text Viewer }
{ ========================================================================== }

{ TLineCollection }
procedure TLineCollection.FreeItem(P: Pointer);
begin
  DisposeStr(P);
end; { FreeItem }

{ ========================================================================== }
{ TFileViewer }

constructor TFileViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; const AFileName: PathStr);
begin
  inherited Init(Bounds, AHScrollbar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  FileName := Nil;
  ReadFile(AFileName);
end; { Init }

{ ========================================================================== }

destructor TFileViewer.Done;
begin
  Dispose(FileLines, Done);
  DisposeStr(FileName);
  inherited Done;
end; { Done }

{ ========================================================================== }

{ Kirajzolas }
procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  C := GetColor(1);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < FileLines^.Count then
    begin
      P := FileLines^.At(Delta.Y + I);
      if P <> Nil then
        S := Copy(P^, Delta.X + 1, Size.X)
      else
        S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end; { for }
end; { Draw }

{ ========================================================================== }

{ Textfile betoltese }
procedure TFileViewer.ReadFile(const FName: PathStr);
var
  FileToView: Text;
  Line: String;
  MaxWidth: Integer;
  E: TEvent;
begin
  IsValid := True;
  if FileName <> Nil then
    DisposeStr(FileName);
  FileName := NewStr(FName);
  FileLines := New(PLineCollection, Init(5,5));
  {$I-}
  Assign(FileToView, FName);
  Reset(FileToView);
  if IOResult <> 0 then
  begin
    Line := FName;
    RMessageBox(sErrorReading, Nil, mfError + mfOkButton);
    IsValid := False;
  end
  else
  begin
    MaxWidth := 0;
    while not Eof(FileToView) and not LowMemory do
    begin
      Readln(FileToView, Line);
      if Length(Line) > MaxWidth then MaxWidth := Length(Line);
      FileLines^.Insert(NewStr(Line));
    end;
    Close(FileToView);
  end;
  {$I+}
  Limit.X := MaxWidth;
  Limit.Y := FileLines^.Count;
end; { ReadFile }

{ ========================================================================== }

{ File kinyomtatasa }
procedure TFileViewer.Print;
var
  F: Text;
  P: PString;
  I: Integer;
begin
  Assign(F, 'PRN');
  DoneSysError;
  {$I-}
  Rewrite(F);
  for I := 0 to FileLines^.Count - 1 do
  begin
    P := FileLines^.At(I);
    if P <> Nil then
      Writeln(F, P^)
    else
      Writeln(F)
  end;
  Close(F);
  if IOResult <> 0 then
    RMessageBox(sErrorPrinting,  Nil, mfError + mfOkButton);
  {$I+}
  InitSysError;
end; { Print }

{ ========================================================================== }

{ Esemeny kezeles }
procedure TFileViewer.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmPrintSelf) then
  begin
    if (State and sfActive) <> 0 then
      Print;
    ClearEvent(Event);
  end;
end; { HandleEvent }

{ ========================================================================== }

procedure TFileViewer.SetState(AState: Word; Enable: Boolean);
begin
  TScroller.SetState(AState, Enable);
  if Enable and (AState and sfExposed <> 0) then
     SetLimit(Limit.X, Limit.Y);
end; { SetState }

{ ========================================================================== }

function TFileViewer.Valid(Command: Word): Boolean;
begin
  Valid := IsValid;
end; { Valid }

{ ========================================================================== }

{ TTextWindow }
constructor TTextWindow.Init(R: TRect; const FileName: PathStr);
begin
  inherited Init(R, Filename, wnNoNumber);
  Options := Options or ofTileable;
  HelpCtx := hcViewWindow;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), Filename)));
end; { Init }

{ ========================================================================== }
{ Grafnev kijelzo }
{ ========================================================================== }

constructor TShowGrf.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Grf := Nil;
end; { Init }

{ ========================================================================== }

destructor TShowGrf.Done;
begin
  if Grf <> Nil then
    DisposeStr(Grf);
  inherited Done;
end; { Done }

{ ========================================================================== }

{ Grafnev kiirasa }
procedure TShowGrf.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  S: String;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  S := RezStrings^.Get(sGrfNameHeader);
  if Grf <> Nil then
    S := S + Grf^
  else
    S := S + RezStrings^.Get(sUntitledGraf);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end; { Draw }

{ ========================================================================== }

{ Esemeny kezeles }
procedure TShowGrf.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmGrfChanged) then
  begin
    if Grf <> Nil then
      DisposeStr(Grf);
    if Event.InfoPtr <> Nil then
      Grf := NewStr(PString(Event.InfoPtr)^)
    else
      Grf := Nil;
    Draw;
    ClearEvent(Event);
  end;
end; { HandleEvent }

{ ========================================================================== }
{ Turbo Vision <--> BGI grafika valtas }
{ ========================================================================== }

const
  GraphActive: Boolean = False;         { Grafika aktiv }

procedure EgaVgaDriverProc; external;   { Grafikus meghajto }
{$L EGAVGA.OBJ}

{ ========================================================================== }

{ Grafika kezdeti inicializalasa }
function GraphAppInit: Boolean;
begin
  GraphAppInit := RegisterBGIDriver(@EgaVgaDriverProc) >= 0;
end; { GraphAppInit }

{ ========================================================================== }

{ Grafika vegleges lezarasa }
procedure GraphAppDone;
begin
  if GraphActive then
    CloseGraph;
end; { GraphAppDone }

{ ========================================================================== }

{ Grafikus resz kezdete }
function GraphicsStart: Boolean;
var
  Driver, Mode: Integer;
begin
  GraphicsStart := True;
  if GraphActive then
    Exit;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
  Driver := VGA;
  Mode := VGAHi;
  InitGraph(Driver, Mode, '');
  if Driver < 0 then
  begin
    GraphicsStart := False;
    GraphicsStop;
  end
  else
    GraphActive := True;
end; { GraphicsStart }

{ ========================================================================== }

{ Grafikus resz vege }
procedure GraphicsStop;
begin
  if GraphActive then
    CloseGraph;
  GraphActive := False;
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  Application^.Redraw;
end; { GraphicsStop }

{ ========================================================================== }

end.
