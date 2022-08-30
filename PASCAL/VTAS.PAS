{ VTAS: Vessel Traffic Advisory Service }
{ (c) 1994 by Toth Balint }
{===========================================================================}

program VTAS;

const
  InpFName = 'VTAS.INP';
  OutFName = 'VTAS.OUT';

const
  MaxVesselNameLength = 20;
  MaxWaypoints = 20;
  MaxVessels = 20;
  ClosePassingLimit = 3;

var
 { Input: }
  Waypoints: Integer;
  WaypointIDs: String[MaxWaypoints];
  Conn: Array[1..MaxWaypoints, 1..MaxWaypoints] of Real;
  Vessels: Integer;
  VesselNames: Array[1..MaxVessels] of String[MaxVesselNameLength];
  EntryTimes: Array[1..MaxVessels] of Integer;
  Speeds: Array[1..MaxVessels] of Real;
  RouteLengths: Array[1..MaxVessels] of Integer;
  Routes: Array[1..MaxVessels, 1..MaxWayPoints] of Integer;
 { Output: }
  ArriveTimes: Array[1..Maxvessels, 1..MaxWaypoints] of Integer;
  InvalidRoute: Array[1..MaxVessels] of Boolean;

{===========================================================================}

{ Szamjegy karakter konvertalasa szamma }
function C2N(C: Char): Integer;
begin
  C2N := Ord(C) - Ord('0');
end; { C2N }

{===========================================================================}

{ Idopont sztring (ora + perc) konvertalasa percben mert idove }
function IntTime(TimeStr: String): Integer;
var
  S: String;
  I: Integer;
begin
  S := Copy('0000', 1, 4 - Length(TimeStr)) + TimeStr;
  IntTime := C2N(S[1]) * 600 + C2N(S[2]) * 60 + C2N(S[3]) * 10 + C2N(S[4]);
end; { IntTime }

{===========================================================================}

{ Waypoint ID -> sorszam konverzio; 0 ha nincs ilyen }
function ID2N(IDChar: Char): Integer;
var
  I: Integer;
begin
  I := 1;
  while (I <= WayPoints) and (WayPointIDs[I] <> IDChar) do
    Inc(I);
  if I <= WayPoints then
    ID2N := I
  else
    ID2N := 0;
end; { ID2N }

{===========================================================================}

{ Bemenet olvasasa }
procedure ReadInput;
var
  F: Text;
  S: String;
  I, J, K1, K2, Code: Integer;
  FirstEntry: Integer;
begin
  Assign(F, InpFName);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O error: Cannot read inputfile!');
    Halt;
  end; { if IOResult }
  ReadLn(F, S);
  Val(S, Waypoints, Code);
  ReadLn(F, S);
  WaypointIDs := S;
  for I := 1 to Waypoints do
  begin
    ReadLn(F, S);
    K1 := 1;
    for J := 1 to Waypoints do
    begin
      while (K1 <= Length(S)) and (S[K1] = ' ') do
        Inc(K1);
      K2 := K1;
      while (K2 <= Length(S)) and (S[K2] <> ' ') do
        Inc(K2);
      Val(Copy(S, K1, K2 - K1), Conn[I, J], Code);
      K1 := K2;
    end; { for J }
  end; { for I }
  Vessels := 0;
  ReadLn(F, S);
  while S[1] <> '*' do
  begin
    Inc(Vessels);
    VesselNames[Vessels] := S;
    ReadLn(F, S);
    K1 := 1;
    while (K1 <= Length(S)) and (S[K1] = ' ') do
      Inc(K1);
    K2 := K1;
    while (K2 <= Length(S)) and (S[K2] <> ' ') do
      Inc(K2);
    EntryTimes[Vessels] := IntTime(Copy(S, K1, K2 - K1));
    if Vessels = 1 then
      FirstEntry := EntryTimes[Vessels]
    else if EntryTimes[Vessels] < FirstEntry then
      EntryTimes[Vessels] := EntryTimes[Vessels] + 1440;
    while (K2 <= Length(S)) and (S[K2] = ' ') do
      Inc(K2);
    Val(Copy(S, K2, Length(S) - K2 + 1), Speeds[Vessels], Code);
    ReadLn(F, S);
    RouteLengths[Vessels] := Length(S);
    for I := 1 to RouteLengths[Vessels] do
      Routes[Vessels, I] := ID2N(S[I]);
    ReadLn(F, S);                       { kovetkezo nev }
  end; { while }
  Close(F);
end; { ReadInput }

{===========================================================================}

{ Hajoutvonal kovetese: ArriveTimes kiszamolasa, InvalidRoutes beallitasa }
procedure TraceRoutes;
var
  I, J: Integer;
  Tim: Real;
begin
  for I := 1 to Vessels do
  begin
    InvalidRoute[I] := Routes[I, 1] = 0;
    ArriveTimes[I, 1] := EntryTimes[I];
    Tim := EntryTimes[I];
    J := 2;
    while not InvalidRoute[I] and (J <= RouteLengths[I]) do
    begin
      if (Routes[I, J] = 0) or (Conn[Routes[I, J - 1], Routes[I, J]] = 0.0) then
        InvalidRoute[I] := True
      else
      begin
        Tim := Tim + Conn[Routes[I, J - 1], Routes[I, J]] / (Speeds[I] / 60);
        ArriveTimes[I, J] := Round(Tim);
        Inc(J);
      end; { else }
    end; { while }
  end; { for I }
end; { TraceRoutes }

{===========================================================================}

{ Utkozbeni talalkozasok vizsgalata }
procedure Encounters(Ves: Integer; var F: Text);
var
  I, J, K: Integer;
begin
  for J := 1 to Ves - 1 do
    if (Ves <> J) and not InvalidRoute[J] then
      for I := 1 to RouteLengths[Ves] - 1 do
        for K := 1 to RouteLengths[J] - 1 do
          if     (    (     (Routes[Ves, I] = Routes[J, K])
                        and (Routes[Ves, I + 1] = Routes[J, K + 1]))
                   or (     (Routes[Ves, I] = Routes[J, K + 1])
                        and (Routes[Ves, I + 1] = Routes[J, K])
                      )
                 )
             and (    (     (ArriveTimes[Ves, I] <= ArriveTimes[J, K])
                        and (ArriveTimes[Ves, I + 1] >= ArriveTimes[J, K])
                      )
                   or (     (ArriveTimes[J, K] <= ArriveTimes[Ves, I])
                        and (ArriveTimes[J, K + 1] >= ArriveTimes[Ves, I])
                      )
                 ) then
                   WriteLn(F, 'Projected encounter with ',  VesselNames[J],
                     ' on leg between Waypoints ', WayPointIDs[Routes[Ves, I]],
                     ' & ', WayPointIDs[Routes[Ves, I + 1]])
end; { Encounters }

{===========================================================================}

{ Kozeli elhaladasok vizsgalata csomopontoknal }
procedure ClosePassings(Ves: Integer; var F: Text);
var
  I, J, K: Integer;
begin
  for J := 1 to Ves - 1 do
    if (Ves <> J) and not InvalidRoute[J] then
      for I := 1 to RouteLengths[Ves] do
        for K := 1 to RouteLengths[J] do
          if     (Routes[Ves, I] = Routes[J, K])
             and (   Abs(ArriveTimes[Ves, I] - ArriveTimes[J, K])
                  <= ClosePassingLimit
                 ) then
            WriteLn(F, '** Warning ** Close passing with ', VesselNames[J],
              ' at Waypoint ', WaypointIDs[Routes[Ves, I]]);
end; { ClosePassings }

{===========================================================================}

{ Percben mert ido konvertalasa sztringge (ora + perc) }
function StrTime(TimeInt: Integer): String;
var
  S1, S2: String;
  I: Integer;
begin
  I := TimeInt mod 1440;
  Str(I div 60, S1);
  Str(I mod 60, S2);
  StrTime := Copy('00', 1, 2 - Length(S1)) + S1 +
             Copy('00', 1, 2 - Length(S2)) + S2;
end; { StrTime }

{===========================================================================}

{ Kimenet irasa }
procedure WriteOutput;
var
  F: Text;
  I, J: Integer;
begin
  Assign(F, OutFName );
  {$I-}
  Rewrite(F);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O error: Cannot create outputfile!');
    Halt;
  end; { if IOResult }
  for I := 1 to Vessels do
  begin
    WriteLn(F, VesselNames[I], ' entering system at ', StrTime(EntryTimes[I]),
               ' with a planned speed of ', Speeds[I] :4:1, ' knots');
    if InvalidRoute[I] then
      WriteLn(F, '**> Invalid Route Plan for Vessel: ', VesselNames[I])
    else
    begin
      Write(F, '          Waypoint:');
      for J := 1 to RouteLengths[I] do
        Write(F, '    ', WayPointIDs[Routes[I, J]]);
      WriteLn(F);
      Write(F, '          Arrival:  ');
      for J := 1 to RouteLengths[I] do
        Write(F, ' ', StrTime(ArriveTimes[I, J]));
      WriteLn(F);
      Encounters(I, F);
      ClosePassings(I, F);
    end; { else }
    WriteLn(F);
  end; { for }
  Close(F);
end; { WriteOutput }

{===========================================================================}

begin { VTAS }
  WriteLn('VTAS: Vessel Traffic Advisory Service  (c) 1994 by T¢th B lint');
  WriteLn;
  ReadInput;
  TraceRoutes;
  WriteOutput;
  WriteLn('Ok.');
end. { VTAS }

{===========================================================================}
