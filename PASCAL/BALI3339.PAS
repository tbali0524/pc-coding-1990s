program Bali3339;

uses Crt;

const maxvonathossz = 18;
      celszam       = 26;
      akodja        = 96;

type  hossztipus = 0..maxvonathossz;
      vonattipus = array[ 1..celszam ] of array[ 1..maxvonathossz ] of integer;

var kocsiv,kocsik : vonattipus;
    vonathossz    : array [ 1..celszam ] of hossztipus;
    i,j,k,
    vonatsorszam  : integer;
    vonat         : string;
    billentyu,
    valasz        : char;

procedure torles;
begin
  vonatsorszam := 0;
  for i:=1 to celszam do
   vonathossz [i] := 0
end;

procedure menu;
begin
  ClrScr;
  GotoXY (21, 3);
  Write ('RENDEZOPALYAUDVAR - SZIMULACIOS  PROGRAM');
  GotoXY (10, 5);
  Write ('(c) Copyright: 1990. Toth Balint, Berzsenyi Daniel Gimnazium');
  GotoXY (18, 10);
  Write ('1 - Uj vonat fogadasa');
  GotoXY (18, 12);
  Write ('2 - Osszes varakozo szerelveny megtekintese');
  GotoXY (18, 14);
  Write ('3 - Egy varakozo szerelveny megtekintese');
  GotoXY (18, 16);
  Write ('4 - Vege');
  GotoXY (23, 22);
  Write ('Kerem valasszon! (1-4)     :');
  Readln (valasz);
  ClrScr;
end;

procedure varakozik;
begin
  GotoXY (14, 24);
  Write ('Kerem nyomjon le valamit!');
  Repeat Until Keypressed;
  billentyu := ReadKey;
  Repeat Until Not Keypressed;
end;

procedure kiirjediket;
begin
  ClrScr;
  Write ('Celallomas: ');
  Writeln ( Chr (j + akodja));
  Writeln ('A varakozo kocsik:');
  for i:= 1 to vonathossz [j] do
  begin
    Writeln;
    Write (i);
    Write ('. :  ');
    Write (kocsiv[ j, i ]);
    Write ('. vonat, ');
    Write (kocsik [ j, i ]);
    Write ('. kocsi');
  end;
  varakozik;
end;

procedure elinditvonat;
begin
  ClrScr;
  Write (vonat [k]);
  Writeln ('-ba tarto vonat megtelt, es elindult celja fele.');
  Writeln ('Tartalma:');
  varakozik;
  kiirjediket;
  vonathossz [j] := 0;
end; { elinditvonat }

procedure rendezes;
begin
  for k:=1 to Length (vonat) do
  begin
    j := Ord (vonat [k]) - akodja;
    if (j > 0) and (j < 27) then
    begin
      vonathossz [j] := vonathossz [j] + 1;
      kocsiv [j,vonathossz [j]] := vonatsorszam;
      kocsik [j,vonathossz [j]] := k;
      if vonathossz [j] = maxvonathossz then
        elinditvonat;
    end; { if }
  end; { for }
end; { rendezes }

procedure bevitel;
begin
  vonatsorszam := vonatsorszam + 1;
  Writeln ('Minden kocsit egy karakter jelkepez.');
  Writeln ('A celallomas jelolese betukkel turtenik. (a - z)');
  Writeln ('Kerem a beerkezett szerelvenyt:');
  Readln (vonat);
  rendezes;
end;

procedure kiiras;
begin
  j := 0;
  billentyu := ' ';
  repeat
    j := j + 1;
    if vonathossz [j] > 0
    then kiirjediket;
  until (j = celszam) or (billentyu = 'm')
end;

procedure kiiregyet;
begin
  repeat
    Writeln ('Kerem a celallomast: ');
    Readln (billentyu);
  until (billentyu >= 'a') and (billentyu <= 'z');
  j := Ord (billentyu) - akodja;
  if vonathossz [j] > 0
  then kiirjediket
  else
  begin
    Writeln;
    Write ('Nincs ide meno kocsi.');
    varakozik
  end; { else }
end;

begin { program }
  torles;
  repeat
    menu;
    case valasz of
      '1' : bevitel;
      '2' : kiiras;
      '3' : kiiregyet;
    end;
  until valasz = '4';
  ClrScr;
end.
