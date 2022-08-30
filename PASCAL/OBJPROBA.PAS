program ObjProba; { Toth Balint }

uses Crt, Graph, Graph3;

type
  ObjTipus1 = object
      Szin : byte;
      procedure Muvelet(KezdoX, KezdoY, VegX, VegY : word);
    end;
  ObjTipus2 = object(ObjTipus1)
    procedure Muvelet(KezdoX, KezdoY, VegX, VegY : word);
  end;

var
  Obj1 : ObjTipus1;
  Obj2 : ObjTipus2;
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;

procedure ObjTipus1.Muvelet; { Vonalhuzas }
begin
  SetColor(Szin);
  Line(KezdoX, KezdoY, VegX, VegY);
end;

procedure ObjTipus2.Muvelet;
begin
  SetColor(Szin);
  Bar(KezdoX, KezdoY, VegX, VegY);
end;

begin { program }
  grDriver := Detect;
  InitGraph(grDriver,grMode,'c:\bp\bgi');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    RestoreCrtMode;
    WriteLn('Grafikus hiba!');
    Halt;
  end;
  Obj1.Szin := White;
  with Obj1 do
    Muvelet(10, 10, 100, 100);
  with Obj2 do
    Muvelet(45, 45, 150, 110);
  repeat
  until Keypressed;
  CloseGraph;
end.
