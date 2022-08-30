{ Elektron szimul ci¢ }
{ Szatm ry Zolt n & T¢th B lint, 1992 }
program Elektron;

uses Crt, Graph;

const
  kbLeft  = #75;
  kbRight = #77;
  kbUp   = #72;
  kbDown = #80;
  kbIns = #82;
  kbDel = #83;
  GMaxX = 40;
  GMaxY = 40;

var
  grDriver, grMode: Integer;
  Bill: Char;

procedure Szerk;
var
  Iras, Toll : Boolean;
  Size, SP, DX, DY, X, Y, S : Integer;
  P: Pointer;
  F: File;
begin
  X := GMaxX div 2;
  Y := GMaxY div 2;
  SP := 1;
  Iras := True;
  Toll := False;
  repeat
    DX := 0;
    DY := 0;
    S := GetPixel(X, Y);
    PutPixel(X, Y, White);
    Bill := UpCase(ReadKey);
    case Bill of
      #0 : case ReadKey of
             kbLeft  : DX := -SP;
             kbRight : DX := SP;
             kbUp   : DY := -SP;
             kbDown : DY := SP;
             kbIns : Toll := not Toll;
             kbDel : Iras := not Iras;
           end;
      ' ' : if S = Blue then S := Black else S := Blue;
      'S' : SP := 6 - SP;
    end;
    if Toll then
    begin
      SP := 1;
      if Iras then
        S := Blue
      else
        S := Black;
    end;
    PutPixel(X, Y, S);
    if (X + DX <= GMaxX) and (X + DX >= 0) then
      X := X + DX;
    if (Y + DY <= GMaxY) and (Y + DY >= 0) then
      Y := Y + DY;
  until Bill = 'Q';
  PutPixel(X, Y, Red);
  if X > 0 then
    PutPixel(X - 1, Y, Yellow)
  else
    PutPixel(X + 1, Y, Yellow);
end;

procedure Terjedes;
const
  Kod: Array[1..4, 1..2] of Integer = ((1, 0), (0, 1), (-1, 0), (0, -1));
var
  X, Y, I: Integer;
begin
  for X := 0 to GMaxX do
    for Y := 0 to GMaxY do
      if GetPixel(X, Y) = Red then
      begin
        for I := 1 to 4 do
          Case GetPixel(X + Kod[I, 1], Y + Kod[I, 2]) of
           Blue : PutPixel(X + Kod[I, 1], Y + Kod[I, 2], Green);
           Green : PutPixel(X + Kod[I, 1], Y + Kod[I, 2], Brown);
           Brown : PutPixel(X + Kod[I, 1], Y + Kod[I, 2], Yellow);
          End;
        PutPixel(X, Y, White);
      end;
  for X := 0 to GMaxX do
    for Y := 0 to GMaxY do
      case GetPixel(X, Y) of
        Green : PutPixel(X, Y, Red);
        Brown : PutPixel(X, Y, Red);
        White : PutPixel(X, Y, Yellow);
        Yellow : PutPixel(X, Y, Blue);
      end;
end;

begin
  grDriver := Detect;
  InitGraph(grDriver, grMode, 'C:\BP\BGI');
  if GraphResult = grOk then
  begin
    Szerk;
    repeat
      Terjedes;
    until KeyPressed;
    CloseGraph;
  end;
end.
