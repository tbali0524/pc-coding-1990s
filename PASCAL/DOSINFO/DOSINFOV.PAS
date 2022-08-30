program DosInfoV;

uses Dos, Objects, Drivers, Views, Menus, Dialogs, App;

const
  cmDatum = 100;
  HoNev : array[1..12] of string[10] =
    ('janu†r', 'febru†r', 'm†rcius', '†prilis', 'm†jus', 'j£nius', 'j£lius',
     'augusztus', 'szeptember', 'okt¢ber', 'november', 'december');
  NapNev : array[0..6] of string[8] =
    ('vas†rnap', 'hÇtfî', 'kedd', 'szerda', 'csÅtîrtîk', 'pÇntek',
     'szombat');

type
  PHelloApp = ^THelloApp;
  THelloApp = object(TApplication)
    procedure Datum;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

{ THelloApp }
procedure THelloApp.Datum;
var
  R: TRect;
  D: PDialog;
  C: Word;
  Ev, Ho, Nap, NapN : word;
  S1, S2 : string[4];
  Szov : string;
begin
  GetDate(Ev, Ho, Nap, NapN);
  Str(Ev, S1);
  Str(Nap, S2);
  Szov := 'A mai d†tum: ' + S1 + '. ' + HoNev[Ho] + ' ' + S2 + '.  ' +
    NapNev[NapN];
  R.Assign(15, 7, 65, 15);
  D := New(PDialog, Init(R, 'D†tum'));
  R.Assign(3, 2, 45, 3);
  D^.Insert(New(PStaticText, Init(R, Szov)));
  R.Assign(21, 5, 29, 7);
  D^.Insert(New(PButton, Init(R, 'Ok', cmCancel, bfDefault)));
  C := DeskTop^.ExecView(D);
end;

procedure THelloApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmDatum: Datum;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure THelloApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~~', hcNoContext, NewMenu(
      NewItem('~D~†tum', 'Alt-D', kbAltD, cmDatum, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil)))),
    nil))));
end;

procedure THelloApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-D~ D†tum', kbAltD, cmDatum,
      NewStatusKey('~Alt-X~ VÇge', kbAltX, cmQuit,
      NewStatusKey('~F10~ MenÅ', kbF10, cmMenu,
      nil))),
    nil)));
end;

var
  DInfo: THelloApp;

begin
  DInfo.Init;
  DInfo.Run;
  DInfo.Done;
end.
