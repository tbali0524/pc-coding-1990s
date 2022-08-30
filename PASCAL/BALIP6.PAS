{   Szamitastechnika palyazat  VI. fordulo
 Toth Balint, Berzsenyi Daniel Gimnazium, 1991.
}

program BaliP6;

uses
  Crt;

const
  MJelSorHossz = 13;
  VJelSorHossz = 200;
  MinJel       = 0;
  MaxJel       = 99;
  MinIsmetles  = 3;
  MinPeriodus  = 2;

type
  JelTipus         = MinJel..MaxJel;
  JelSorIndexTipus = 1..VJelSorHossz;
  JelSorTipus      = array[JelSorIndexTipus] of JelTipus;

var
  JelSor      : JelSorTipus;
  JelSorHossz,
  N, M, L, K  : integer;
  Tures       : 0..MaxJel;
  Valasz      : char;
  Jo          : boolean;

procedure Megadas;
begin
  JelSorHossz := MJelSorHossz;
  WriteLn('A jelsorozat hossza: ', JelSorHossz);
  WriteLn('Kerem a jelsorozatot! (', MinJel, '-', MaxJel, ')');
  for N := 1 to JelSorHossz do
    repeat
      Write(N : 3, '. elem: ');
      Read(JelSor[N]);
    until JelSor[N] in [MinJel..MaxJel];
end; { Megadas }

procedure Veletlen;
begin
  JelSorHossz := VJelSorHossz;
  Randomize;
  WriteLn('A jelsorozat hossza: ', JelSorHossz);
  WriteLn('A jelsorozat:');
  for N := 1 to JelSorHossz do
  begin
    JelSor[N] := Random(MaxJel - MinJel + 1) + MinJel;
    Write(JelSor[N] : 3);
    Write(',');
  end; { for }
  WriteLn;
end; { Veletlen }

procedure Bevitel;
begin
  ClrScr;
  WriteLn('RADIOJEL - SZURO PROGRAM   (c) Toth Balint, 1991.');
  WriteLn;
  Write('Veletlen vagy megadott jelsorozat? (v/m) ');
  repeat
    Valasz := ReadKey;
  until Valasz in ['v', 'm', 'V', 'M'];
  WriteLn(Valasz);
  WriteLn;
  WriteLn('Ismetlodesek minimalisan szukseges szama: ', MinIsmetles);
  WriteLn('Minimalis periodushossz: ', MinPeriodus);
  case Valasz of
    'v', 'V' : Veletlen;
    'm', 'M' : Megadas;
  end; { case }
  WriteLn;
  repeat
    Write('Kerem a tureshatart! (0-', MaxJel - MinJel, ')  ');
    Read(Tures);
  until (Tures in [0..MaxJel - MinJel]);
end; { Bevitel }

function Kulonbseg : JelTipus;
begin
  Kulonbseg := abs(JelSor[M + K - 1] - JelSor[M + L * N + K - 1]);
end; { Kulonbseg }

procedure Kereses;
begin
  N := (JelSorHossz div MinIsmetles) + 1;
  repeat                                             { N }
    Dec(N); { N := N - 1 }
    M := 0;
    repeat                                             { M }
      Inc (M); { M := M + 1 }
      Jo := true;
      L := 0;
      repeat                                             { L }
        Inc (L);
        K := 0;
        repeat                                             { K }
          Inc (K);
          Jo := Kulonbseg <= Tures;
        until (not Jo) or (K = N);                         { K }
      until (not Jo) or (L = MinIsmetles - 1);           { L }
    until Jo or (M + N * MinIsmetles > JelSorHossz);   { M }
  until Jo or (N = MinPeriodus );                    { N }
end; { Kereses }

procedure Kiiras;
begin
  WriteLn;
  if Jo then
  begin
    WriteLn('Periodikussagot talaltam.');
    WriteLn(' Kezdo jel: ', M);
    WriteLn(' Periodushossz: ', N);
  end { then }
  else
    WriteLn('Nem talaltam periodikussagot.');
  WriteLn;
  Write('Nyomjon meg egy billentyut! ');
  repeat
  until KeyPressed;
  WriteLn;
end; { Kiiras }

begin { Program }
  Bevitel;
  Kereses;
  Kiiras;
end. { Program }
