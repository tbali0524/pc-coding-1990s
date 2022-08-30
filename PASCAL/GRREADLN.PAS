program GrReadLn; { String beolvasas grafikus uzemmodban }

uses Crt, Graph;

var
  grDriver, grMode: Integer;
  Sz: String;

function GrReadStr(KX, KY, MaxHossz: Integer): String;
const
  Enter = #13;
  BackSpace = #8;
var
  RegiTS: TextSettingsType;
  RegiFS: FillSettingsType;
  S: String;
  Bill: Char;

procedure KiirKar(Kar: Char; Poz: Byte);
begin
  if Poz > 0 then
  begin
    Bar(KX + (Poz - 1) * TextWidth('M'), KY, KX + Poz * TextWidth('M'),
      KY + TextHeight('M'));
    OutTextXY(KX + (Poz - 1) * TextWidth('M'), KY, Kar);
  end;
end; { KiirKar }

begin { GrReadStr }
  S := '';
  GetTextSettings(RegiTS);
  GetFillSettings(RegiFS);
  SetTextJustify(LeftText, TopText);
  SetFillStyle(EmptyFill, GetColor);
  repeat
    KiirKar('_', Length(S) + 1); { Kurzor }
    Bill := ReadKey;
    KiirKar(' ', Length(S) + 1);
    if Bill = #0 then
      Bill := ReadKey
    else if Bill = BackSpace then
    begin
      Delete(S, Length(S), 1);
      KiirKar(' ', Length(S) + 1);
    end
    else if (Bill in [' '..'þ']) and (Length(S) < MaxHossz) then
    begin
      S := S + Bill;
      KiirKar(Bill, Length(S));
    end;
  until Bill = Enter;
  SetTextJustify(RegiTS.Horiz, RegiTS.Vert);
  SetFillStyle(RegiFS.Pattern, RegiFS.Color);
  GrReadStr := S;
end; { GrReadStr }

begin
  DetectGraph(GrDriver, GrMode);
  InitGraph(GrDriver, GrMode, 'C:\BP\BGI');
  if GraphResult = 0 then
  begin
    Sz := GrReadStr(10, 10, 10);
    CloseGraph;
    ClrScr;
    WriteLn(Sz);
    ReadLn;
  end;
end.
