program TikTak;

uses
  Crt;

type
  IdoTipus = record
               Ora, Perc, Mperc : integer;
             end;

var
  Ido : IdoTipus;

procedure Beolvasas;
begin
  ClrScr;
  WriteLn('Kerem a pontos idot!');
  with Ido do
  begin
    WriteLn('Ora ?');
    Read(Ora);
    WriteLn('Perc ?');
    Read(Perc);
    WriteLn('Masodperc ?');
    Read(Mperc);
  end;
end;

begin
  Beolvasas;
  with Ido do
  begin
    repeat
      Mperc := Mperc + 1;
      Delay(1000);
      if Mperc = 60 then
      begin
        Mperc := 0;
        Inc(Perc);
        if Perc = 60 then
        begin
          Perc := 0;
          Ora := Ora + 1;
        end;
      end;
      Clrscr;
      GoToXY(10,10);
      WriteLn (Ora:2,':',Perc:2,':',Mperc:2);
    until KeyPressed;
  end;
end.


