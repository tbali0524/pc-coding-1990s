program OrgonasipRendezes;

uses Crt;

const
  N          = 20;
  MaxErtek   = 99;

type
  IndexTipus = 1..N;
  SzamTipus  = 1..MaxErtek;
  TombTipus  = array [ IndexTipus ] of SzamTipus;

var
  KovHatulE  : boolean;
  Tomb       : TombTipus;
  i          : IndexTipus;
  Elol,Hatul : SzamTipus;

procedure TombMegadas;
begin
  Randomize;
  for i := 1 to N do
    Tomb [ i ] := Random( MaxErtek ) + 1;
end;

procedure TombKiiras;
begin
  WriteLn('A t”mb:');
  for i := 1 to N - 1 do
    Write( Tomb [ i ] :3, ',' );
  Writeln( Tomb [ N ] :3 );
end;

procedure Csere( var Szam1, Szam2 : SzamTipus );

var
  Verem : SzamTipus;

begin
  Verem := Szam1;
  Szam1 := Szam2;
  Szam2 := Verem;
end; { Csere }

function LegkisebbHely : IndexTipus;

var
  Hely : IndexTipus;

begin
  Hely := Elol;
  for i:= Elol to Hatul do
    if Tomb [ i ] < Tomb [ Hely ] then
      Hely := i;
  LegkisebbHely := Hely;
end;

procedure Rendezes;
begin
  Elol  := 1;
  Hatul := N;
  KovHatulE := Odd( N );
  repeat
    if KovHatulE then
    begin
      Csere( Tomb [ LegkisebbHely ], Tomb [ Hatul ] );
      Hatul := Hatul - 1;
    end
    else
    begin
      Csere( Tomb [ LegkisebbHely ], Tomb [ Elol ] );
      Elol := Elol + 1;
    end;
    KovHatulE := not KovHatulE;
  until Elol = Hatul;
end; { Rendezes }

begin { program }
  TombMegadas;
  ClrScr;
  TombKiiras;
  Rendezes;
  WriteLn('Az orgonas¡pos rendez‚s ut…n:');
  TombKiiras;
  repeat
  until KeyPressed;
end.
