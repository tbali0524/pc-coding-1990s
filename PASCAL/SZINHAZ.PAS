program Szinhaz;

uses
  Crt;

const
  SorokSzama  = 5;
  UlesekSzama = 10;

type
  SzekTipus = array [ 1..SorokSzama, 1..UlesekSzama ] of boolean;

var
  N, M       : integer;
  Bal, Jobb  : SzekTipus;
  Talalt     : boolean;

procedure Feltoltes ( var Tomb : SzekTipus );
begin
  for N := 1 to SorokSzama do
    for M := 1 to UlesekSzama do
      Tomb [ N, M ] := Random ( 99 ) > 60;
end;

procedure Kereses ( Tomb : SzekTipus; Oldal : string );
begin
  N := 0;
  while ( N < Sorokszama ) and ( not Talalt ) do
  begin
    N := N + 1;
    M := 0;
    while ( M < UlesekSzama - 1 ) and ( not Talalt ) do
    begin
      M := M + 1;
      if Tomb [ N, M ] and Tomb [ N, M + 1 ] then
      begin
        Talalt := true;
        WriteLn ( Oldal, ' oldal, ', N, ',', M );
        WriteLn ( Oldal, ' oldal, ', N, ',', M + 1 );
      end;
    end;
  end;
end;

procedure HatarKereses;
begin
  N := 0;
  while ( N < SorokSzama ) and ( not Talalt ) do
  begin
    N := N + 1;
    if Bal [ N, UlesekSzama ] and Jobb [ N, UlesekSzama ] then
    begin
      Talalt := true;
      WriteLn ( 'Bal oldal, ', N, ',', Ulesekszama );
      WriteLn ( 'Jobb oldal, ', N, ',', Ulesekszama );
    end;
  end;
end;

begin { program }
  Feltoltes ( Bal );
  Feltoltes ( Jobb );
  ClrScr;
  Talalt := false;
  Kereses ( Bal,  'Bal' );
  Kereses ( Jobb, 'Jobb' );
  HatarKereses;
end.