uses Crt, Dos;
const
  NoCursor = $2000;
var
  OldCursor: Word;

procedure SetCursor(NewCursor : Word);
{ Sets the value of the scan lines of the cursor }
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 1;
    BH := 0;
    CX := NewCursor;
    Intr($10, Reg);
  end; { with }
end; { SetCursor }

function GetCursor : Word;
{ Returns the value of the scan lines of the cursor }
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 3;
    BH := 0;
    Intr($10, Reg);
    GetCursor := CX;
  end; { Reg }
end; { GetCursor }

begin
  ClrScr;
  WriteLn('nincs kurzor');
  OldCursor := GetCursor;
  SetCursor(NoCursor);
  repeat until KeyPressed;
  SetCursor(OldCursor);
  WriteLn('van kurzor');
  ReadLn;
end.
