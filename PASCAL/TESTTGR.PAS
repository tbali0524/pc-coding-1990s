{ TurtleGr unit tesztje }
program TestTGr; 

uses Crt, Graph, TurtleGr;

var
  T : PTurtle;
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;

procedure SokSzog(OSZ, Meret : integer);
var I : byte;
begin
  for I := 1 to OSZ do
  begin
    T^.Forwd(Meret);
    T^.TurnRight(360 / OSZ);
  end;
end;

procedure Spiral(Meret : integer);
begin
  T^.Forwd(Meret);
  T^.TurnRight(90);
  if Meret > 0 then
    Spiral(Meret - 5)
end;

begin
  grDriver := Detect;
  InitGraph(grDriver, grMode, 'C:\BP\BGI');
  ErrCode := GraphResult;
  if ErrCode = grOk then
  begin
    New(T);
    with T^ do
    begin
      Home;
      Spiral(50);
      SetPosition(50, 50);
      SetHeading(30);
      SokSzog(5, 20);
      SetHeading(0);
      SetPosition(400, 180);
      Forwd(400);
      TurnLeft(90);
      Forwd(20);
    end;
  end;
  repeat until KeyPressed;
  Dispose(T);
  CloseGraph;
end.