{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1991,95 by T¢th B lint       }
{                                                }
{************************************************}

unit CVWin; { Hex Dump, Ascii Dump es Registers ablakok }
{$B-}
interface

uses Drivers, Objects, Views, CGlobals;

type
  PHexViewer = ^THexViewer;
  THexViewer = Object(TScroller)
    Mem: PMem;
    constructor Init(var Bounds:TRect; AVScrollBar: PScrollBar;
      const M: PMem);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PHexWindow = ^THexWindow;
  THexWindow = object(TWindow)
    constructor Init(var Bounds: TRect; M: PMem);
  end;

  PAsciiViewer = ^TAsciiViewer;
  TAsciiViewer = Object(TScroller)
    Mem: PMem;
    constructor Init(var Bounds:TRect; AVScrollBar: PScrollBar;
      const M: PMem);
    procedure Draw; virtual;
  end;

  PAsciiWindow = ^TAsciiWindow;
  TAsciiWindow = object(TWindow)
    constructor Init(var Bounds: TRect; M: PMem);
  end;

  PRegsViewer = ^TRegsViewer;
  TRegsViewer = object(TScroller)
    procedure Draw; virtual;
  end;

  PRegsWindow = ^TRegsWindow;
  TRegsWindow = object(TWindow)
    constructor Init;
  end;

implementation

uses CMemTool, CVHelp;

{ THexViewer }

constructor THexViewer.Init(var Bounds:TRect; AVScrollBar: PScrollBar;
  const M: PMem);
begin
  inherited Init(Bounds, Nil, AVScrollBar);
  Mem := M;
  GrowMode := gfGrowHiX or gfGrowHiY;
  SetLimit(0, $1000);
end;

procedure THexViewer.Draw;
var
  B: TDrawBuffer;
  S: String;
  C: Word;
  Y : Byte;
begin
  C := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    S := DumpSor(Mem, (Word(Delta.Y) + Y) shl 4, 15);
    MoveStr(B, S, C);
    WriteLine(0, Y, Size.X, 1, B);
  end;
end; { Draw }

procedure THexViewer.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
end;

{ THexWindow objektum }

constructor THexWindow.Init(var Bounds: TRect; M: PMem);
var
  R: TRect;
begin
  inherited Init(Bounds, 'Hex Dump', wnNoNumber);
  HelpCtx := hcDumpWindow;
  Options := Options or ofTileable;
  GetExtent(R);
  R.Grow(-1,-1);
  Insert(New(PHexViewer, Init(R, StandardScrollBar(sbVertical or
    sbHandleKeyboard), M)));
end; { Init }

{ TAsciiViewer }

constructor TAsciiViewer.Init(var Bounds:TRect; AVScrollBar: PScrollBar;
  const M: PMem);
begin
  inherited Init(Bounds, Nil, AVScrollBar);
  Mem := M;
  GrowMode := gfGrowHiX or gfGrowHiY;
  SetLimit(0, $400);
end;

procedure TAsciiViewer.Draw;
var
  B: TDrawBuffer;
  S: String;
  C: Word;
  Y : Byte;
begin
  C := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    S := AsciiSor(Mem, (Word(Delta.Y) + Y) shl 6, 63);
    MoveStr(B, S, C);
    WriteLine(0, Y, Size.X, 1, B);
  end;
end; { Draw }

{ TAsciiWindow objektum }

constructor TAsciiWindow.Init(var Bounds: TRect; M: PMem);
var
  R: TRect;
  SB: PScrollBar;
begin
  inherited Init(Bounds, 'Ascii Viewer', wnNoNumber);
  HelpCtx := hcAsciiWindow;
  Options := Options or ofTileable;
  GetExtent(R);
  R.Grow(-1,-1);
  Insert(New(PAsciiViewer, Init(R, StandardScrollBar(sbVertical or
    sbHandleKeyboard), M)));
end; { Init }

{ TRegsViewer }

procedure TRegsViewer.Draw;
var
  B: TDrawBuffer;
  C: Word;
begin
  C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, 'A=' + HBS(Regs.A), C);
  WriteLine(0, 0, Size.X, 1, B);
  MoveStr(B, 'X=' + HBS(Regs.X), C);
  WriteLine(0, 1, Size.X, 1, B);
  MoveStr(B, 'Y=' + HBS(Regs.Y), C);
  WriteLine(0, 2, Size.X, 1, B);
  MoveStr(B, 'PC=' + HWS(Regs.PC), C);
  WriteLine(6, 0, Size.X, 1, B);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, 'SP=' + HBS(Regs.SP), C);
  WriteLine(6, 1, Size.X, 1, B);
  MoveStr(B, 'SR=' + HBS(Regs.SR), C);
  WriteLine(6, 2, Size.X, 1, B);
  MoveStr(B, 'NV-IBDZC', C);
  WriteLine(0, 3, Size.X, 1, B);
  MoveStr(B, '00 00000', C);
  WriteLine(0, 4, Size.X, 1, B);
end; { Draw }

{ TRegsWindow objektum }

constructor TRegsWindow.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 16, 7);
  inherited Init(R, 'Regs', wnNoNumber);
  HelpCtx := hcRegsWindow;
  GrowMode := 0;
  Flags := wfMove or wfClose;
  R.Grow(-1, -1);
  Insert(New(PRegsViewer, Init(R, Nil, Nil)));
end; { Init }

end.