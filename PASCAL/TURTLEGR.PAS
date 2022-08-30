{ TurtleGr  - teknoc-grafika  Copyright (c) 1991  T¢th B lint }
unit TurtleGr;

interface

type
  PTurtle = ^Turtle;
  Turtle = object
    X, Y : integer;
    Head : real;
    IsPen, IsWrap : boolean;
    procedure Forwd(L : integer);
    procedure Back(L : integer);
    procedure TurnLeft(F : real);
    procedure TurnRight(F : real);
    procedure SetHeading(H : real);
    procedure SetPosition(UX, UY : integer);
    procedure Home;
    procedure ClearScreen;
    procedure PenUp;
    procedure PenDown;
    procedure Wrap;
    procedure NoWrap;
    function Heading : real;
    function XCor : integer;
    function YCor : integer;
    function TestPen : boolean;
    function TestWrap : boolean;
  end;

implementation

uses Graph;

procedure Turtle.Forwd(L : integer);
var
  UX, UY : integer;
begin
  UX := Round(XCor + L * Cos(Heading * 2 * Pi / 360));
  UY := Round(YCor - L * Sin(Heading * 2 * Pi / 360));
  if TestPen then
    Line(X, Y, UX, UY);
  SetPosition(UX, UY);
end;

procedure Turtle.Back(L : integer);
begin
  Forwd(-L);
end;

procedure Turtle.TurnLeft(F : real);
begin
  SetHeading(Heading + F);
end;

procedure Turtle.TurnRight(F : real);
begin
  SetHeading(Heading - F);
end;

procedure Turtle.SetHeading(H : real);
var
  SH : real;
begin
  SH := H;
  while SH < 0 do
    SH := SH + 360;
  Head := Frac(SH / 360) * 360;
end;

procedure Turtle.SetPosition(UX, UY : integer);
begin
  if TestWrap then
  begin

  end
  else
  begin
    if UX < 0 then
      X := 0
    else
      if UX > GetMaxX then
        X := GetMaxX
      else
        X := UX;
    if UY < 0 then
      Y := 0
    else
      if UY > GetMaxY then
        Y := GetMaxY
      else
        Y := UY;
  end;
end;

procedure Turtle.Home;
begin
  SetPosition(GetMaxX div 2, GetMaxY div 2);
  SetHeading(0);
  PenDown;
end;

procedure Turtle.ClearScreen;
begin
  ClearDevice;
  Home;
end;

procedure Turtle.PenUp;
begin
  IsPen := false;
end;

procedure Turtle.PenDown;
begin
  IsPen := true;
end;

function Turtle.Heading;
begin
  Heading := Head;
end;

function Turtle.XCor;
begin
  XCor := X;
end;

function Turtle.YCor;
begin
  YCor := Y;
end;

function Turtle.TestPen;
begin
  TestPen := IsPen;
end;

function Turtle.TestWrap;
begin
  TestWrap := IsWrap;
end;

procedure Turtle.Wrap;
begin
  IsWrap := true;
end;

procedure Turtle.NoWrap;
begin
  IsWrap := false;
end;

end.