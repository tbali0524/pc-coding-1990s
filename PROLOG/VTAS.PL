%(* Programozasi Paradigmak Hazi Feladat                               *)
%(* VTAS: Vessel Traffic Advisory Service (ACM94FIN/G)                 *)
%(* T¢th B lint                                                        *)
%(* BME Informatika Szak, 3. evfolyam, 1. felev (1994-95), 3.tankor    *)
%(* E-mail: s4078tot@sun10.vsz.bme.hu                                  *)
%(* 1994. november-december                                            *)
%(* Programozasi kornyezet: SWI Prolog 1.9.0 (MS Windows valtozat)     *)
%(* ================================================================== *)

% beolvas egy sztringet az input-folyambol a sor vegeig

  getString(Str, Result) :-
      get0(C),
      C \= 13, !,
      getString([C|Str], Result).
  getString(Str, Result) :-
      reverse(Str, Result).

readString(Result) :-
    get(C),
    getString([C], Result),
    get0(_).

% =======================================================================
% beolvas egy egesz szamot az input-folyambol

  getLetter(C, Value) :-
    C >= 0'0,
    C =< 0'9,
    Value is C - 0'0.

  getInt(Int, Result) :-
      get0(C),
      getLetter(C, Value), !,
      NewInt is Int * 10 + Value,
      getInt(NewInt, Result).
  getInt(Int, Int).

readInt(Result) :-
    get(C),
    getLetter(C, Value),
    getInt(Value, Result).

% =======================================================================
% beolvas egy Size * Size meretu valos szamokbol allo matrixot

  getRow(Row, Result, 0) :-
      reverse(Row, Result).
  getRow(Row, Result, I) :-
      readInt(Next),
      I1 is I - 1,
      getRow([Next|Row], Result, I1).

  getMatrix(Matrix, Result, _Size, 0) :-
      reverse(Matrix, Result).
  getMatrix(Matrix, Result, Size, J) :-
      getRow([], Next, Size),
      J1 is J - 1,
      getMatrix([Next|Matrix], Result, Size, J1).

readMatrix(Size, Result) :-
    SizeR is Size,
    getMatrix([], Result, SizeR, Size).

% =======================================================================
% konvertalja az (ora * 100 + perc) formatumu idot percben mert idove

intTime(From, To) :-
    To is ((From mod 10000) // 1000) * 600 +
          ((From mod 1000) // 100) * 60 + From mod 100.

% =======================================================================
% Route-ban levo azonositokat konvertalja
%   sorszamok listajava (WayPointIDs-beli elofordulas)

  searchID(_, [], _, 0).
  searchID(X, [X|_], I, I).
  searchID(X, [Y|IDList], I, N) :-
      X \= Y,
      I1 is I + 1,
      searchID(X, IDList, I1, N).

  convRoute([], _WayPointIDs, Route_out, Result) :-
      reverse(Route_out, Result).
  convRoute([X|Route_in], WayPointIDs, Route_out, Result) :-
      searchID(X, WayPointIDs, 1, Next),
      convRoute(Route_in, WayPointIDs, [Next|Route_out], Result).

routeIDtoN(Route_in, WayPointIDs, Result) :-
    convRoute(Route_in, WayPointIDs, [], Result).

% =======================================================================
% beolvassa a hajok adatait
%  eredmeny: (VesselNames, EntryTimes, Speeds, Routes)
%  (Routes-ban 0 lesz, ahol nem letezo pont van az utban.)

  getVessels(_WayPointIDs, _I, VesselNames_out, EntryTimes_out,
            Speeds_out, Routes_out, [0'* |_VesselName], _First,
            VesselNames, EntryTimes, Speeds, Routes) :-
      reverse(VesselNames_out, VesselNames),
      reverse(EntryTimes_out, EntryTimes),
      reverse(Speeds_out, Speeds),
      reverse(Routes_out, Routes).
  getVessels(WayPointIDs, I, VesselNames_out, EntryTimes_out,
            Speeds_out, Routes_out, VesselName, First,
            VesselNames, EntryTimes, Speeds, Routes) :-
      readInt(ET_in),
      intTime(ET_in, ET),
      ( I == 0 -> FirstEntry is ET
      ; I \= 0 -> FirstEntry is First
      ),
      ( ET >= FirstEntry -> EntryTime is ET
      ; ET <  FirstEntry -> EntryTime is ET + 1440
      ),
      readInt(Speed),
      readString(Route_in),
      routeIDtoN(Route_in, WayPointIDs, Route),
      readString(NextVN),
      I1 is I + 1,
      getVessels(WayPointIDs, I1, [VesselName|VesselNames_out],
        [EntryTime|EntryTimes_out], [Speed|Speeds_out],
        [Route|Routes_out], NextVN, FirstEntry,
        VesselNames, EntryTimes, Speeds, Routes).

readVessels(WayPointIDs, VesselNames, EntryTimes, Speeds, Routes) :-
    readString(VesselName),
    getVessels(WayPointIDs, 0, [], [], [], [], VesselName, 0,
      VesselNames, EntryTimes, Speeds, Routes).

% =======================================================================
% bemenet olvasasa InpName nevu filebol
%  eredmeny:
%    (WayPoints, WayPointIDs, Conn, VesselNames, EntryTimes, Speeds, Routes)

readInput(InpName, WayPoints, WayPointIDs, Conn,
          VesselNames, EntryTimes, Speeds, Routes) :-
    see(InpName),
    readInt(WayPoints),
    readString(WayPointIDs),
    readMatrix(WayPoints, Conn),
    readVessels(WayPointIDs, VesselNames, EntryTimes, Speeds, Routes),
    seen.

% =======================================================================
% lista N. eleme

nth([X|_List], 1, X).
nth([_X|List], N, Result) :-
   N1 is N - 1,
   nth(List, N1, Result).

% =======================================================================
% Hajok utjanak kovetese:
%   eredmeny: (InvalidRoute, ArriveTimes) *)

  nextWP(_Conn, _Speed, Arriv, _, [_ROfr], 0, Arriv).
  nextWP(_Conn, _Speed, Arriv, _, [_ROfr,0|_RoutRemain], 1, Arriv).
  nextWP(Conn, Speed, Arriv, Tim, [ROfr,ROto|RoutRemain], InvRoute, ATResult) :-
      nth(Conn, ROfr, ConnRow),
      nth(ConnRow, ROto, Dist),
      ( Dist == 0 -> InvRoute is 1,
                     ATResult = Arriv
      ; Dist \= 0 -> NewTim is Tim + (Dist * 60) // Speed,
                     nextWP(Conn, Speed, [NewTim|Arriv], NewTim,
                            [ROto|RoutRemain], InvRoute, ATResult)
      ).

  traceVessel(_Conn, [], _, _, InvalidRoute_out, ArriveTimes_out,
              InvalidRoute, ArriveTimes) :-
      reverse(InvalidRoute_out, InvalidRoute),
      reverse(ArriveTimes_out, ArriveTimes).
  traceVessel(Conn, [ET|EntryTimes], [SP|Speeds], [RO|Routes],
              InvalidRoute_out, ArriveTimes_out, InvalidRoute, ArriveTimes) :-
      nth(RO, 1, H),
      ( H == 0 -> traceVessel(Conn, EntryTimes, Speeds, Routes,
                              [1|InvalidRoute_out], [[]|ArriveTimes_out],
                              InvalidRoute, ArriveTimes)
      ; H \= 0 -> nextWP(Conn, SP, [ET], ET, RO, InvRoute, Arr),
                  reverse(Arr, Arr1),
                  traceVessel(Conn, EntryTimes, Speeds, Routes,
                           [InvRoute|InvalidRoute_out], [Arr1|ArriveTimes_out],
                           InvalidRoute, ArriveTimes)
      ).

traceRoutes(Conn, EntryTimes, Speeds, Routes, InvalidRoute, ArriveTimes) :-
    traceVessel(Conn, EntryTimes, Speeds, Routes, [], [],
                InvalidRoute, ArriveTimes).

% =======================================================================
% sztring (ASCII kodok listaja) kiirasa

writeString([]).
writeString([X|Str]) :-
    put(X),
    writeString(Str).

% =======================================================================
% Talalkozasok vizsgalata es kiirasa
%   Csak a V. hajoval kapcsolatosakat vizsgalja
%   (akinek utvonala ROv-ban, erkezesi idejei ATv-ban vannak

  etracevj(_, _, _, _, _, [_ROvi], _, _, _).
  etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [_ROvi1|ROvi2], [_ROjk1], [_ATvi1|ATvi2], _) :-
      etracevj(WayPointIDs, VesselNames, ROj, ATj, J, ROvi2, ROj, ATvi2, ATj).
  etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [ROvi1,ROvi2|ROvi3], [ROjk1,ROjk2|ROjk3],
          [ATvi1,ATvi2|ATvi3], [ATjk1,ATjk2|ATjk3]) :-
      ( ROvi1 == ROjk1, ROvi2 == ROjk2
      ; ROvi1 == ROjk2, ROvi2 == ROjk1
      ),
      ( ATvi1 =< ATjk1, ATvi2 >= ATjk1
      ; ATjk1 =< ATvi1, ATjk2 >= ATvi1
      ),
      !,
      write('Projected encounter with '),
      nth(VesselNames, J, VN),
      writeString(VN),
      write(' on leg between Waypoints '),
      nth(WayPointIDs, ROvi1, WP1),
      nth(WayPointIDs, ROvi2, WP2),
      put(WP1), write(' & '), put(WP2), nl,
      etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
        [ROvi1,ROvi2|ROvi3], [ROjk2|ROjk3],
        [ATvi1,ATvi2|ATvi3], [ATjk2|ATjk3]).
  etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [ROvi1,ROvi2|ROvi3], [_ROjk1,ROjk2|ROjk3],
          [ATvi1,ATvi2|ATvi3], [_ATjk1,ATjk2|ATjk3]) :-
      etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
        [ROvi1,ROvi2|ROvi3], [ROjk2|ROjk3],
        [ATvi1,ATvi2|ATvi3], [ATjk2|ATjk3]).

  verifyEnc(WayPointIDs, VesselNames, ROv, ATv, V, J,
            [ROj|Routej], [IRj|InvRoutej], [ATj|ArriveTimej]) :-
      V1 is V - 1,
      ( J > V1  -> true
      ; J =< V1 ->
          J1 is J + 1,
          ( IRj == 1 -> true
          ; IRj \= 1 -> etracevj(WayPointIDs, VesselNames, ROj, ATj, J,
                                ROv, ROj, ATv, ATj)
          ),
          verifyEnc(WayPointIDs, VesselNames, ROv, ATv, V, J1,
                      Routej, InvRoutej, ArriveTimej)
      ).

encounters(ROv, ATv, WayPointIDs, VesselNames, Routes,
              InvalidRoute, ArriveTimes, V) :-
    verifyEnc(WayPointIDs, VesselNames, ROv, ATv, V, 1,
      Routes, InvalidRoute, ArriveTimes).

% =======================================================================
% kozeli elhaladasok vizsgalata es kiirasa
%   Csak a V. hajoval kapcsolatosakat vizsgalja
%   (akinek utvonala ROv-ban, erkezesi idejei ATv-ban vannak *)

  ctracevj(_, _, _, _, _, [], _, _, _).
  ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [_ROvi1|ROvi2], [], [_ATvi1|ATvi2], _) :-
      ctracevj(WayPointIDs, VesselNames, ROj, ATj, J, ROvi2, ROj, ATvi2, ATj).
  ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [ROvi1|ROvi2], [ROjk1|ROjk2], [ATvi1|ATvi2], [ATjk1|ATjk2]) :-
      A1 is ATvi1 - ATjk1,
      ROvi1 == ROjk1,
      A1 =< 3,
      A1 >= -3, !,
      write('** Warning ** Close passing with '),
      nth(VesselNames, J, VN),
      writeString(VN),
      write(' at Waypoint '),
      nth(WayPointIDs, ROvi1, WP),
      put(WP), nl,
      ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
        [ROvi1|ROvi2], ROjk2, [ATvi1|ATvi2], ATjk2).
  ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
          [ROvi1|ROvi2], [_ROjk1|ROjk2], [ATvi1|ATvi2], [_ATjk1|ATjk2]) :-
      ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
        [ROvi1|ROvi2], ROjk2, [ATvi1|ATvi2], ATjk2).

  verifyClose(WayPointIDs, VesselNames, ROv, ATv, V, J,
              [ROj|Routej], [IRj|InvRoutej], [ATj|ArriveTimej]) :-
      V1 is V - 1,
      ( J > V1  -> true
      ; J =< V1 ->
          J1 is J + 1,
          ( IRj == 1 -> true
          ; IRj \= 1 -> ctracevj(WayPointIDs, VesselNames, ROj, ATj, J,
                                ROv, ROj, ATv, ATj)
          ),
          verifyClose(WayPointIDs, VesselNames, ROv, ATv, V, J1,
                      Routej, InvRoutej, ArriveTimej)
      ).

closePassings(ROv, ATv, WayPointIDs, VesselNames, Routes,
              InvalidRoute, ArriveTimes, V) :-
    verifyClose(WayPointIDs, VesselNames, ROv, ATv, V, 1,
      Routes, InvalidRoute, ArriveTimes).

% =======================================================================
% percben mert ido kiirasa ora + perc alakban

  leadZero(K) :-
      K < 10, !,
      put(0'0),
      K1 is 0'0 + K,
      put(K1).
  leadZero(K) :-
      K >= 10,
      K1 is 0'0 + (K // 10),
      K2 is 0'0 + (K mod 10),
      put(K1),
      put(K2).

strTime(From) :-
    leadZero((From mod 1440) // 60),
    leadZero(From mod 60).

% =======================================================================
% kimenet irasa a kepernyore

  getWayPointIDs([], _WayPointIDs).
  getWayPointIDs([ActRO|Rout], WayPointIDs) :-
      write('    '),
      nth(WayPointIDs, ActRO, C),
      put(C),
      getWayPointIDs(Rout, WayPointIDs).

  getArriveTimes([]).
  getArriveTimes([ActAT|Arriv]) :-
      write(' '),
      strTime(ActAT),
      getArriveTimes(Arriv).

  writeVessel(_, _, _, _, _, _, _, [], _, _, _, _, _, _).
  writeVessel(WayPoints, WayPointIDs, Conn,
              VesselNames, Routes, InvalidRoute, ArriveTimes,
            [VN|NextVesselNames], [ET|NextEntryTimes], [SP|NextSpeeds],
            [RO|NextRoutes], [IR|NextInvalidRoute], [AT|NextArriveTimes], I) :-
      writeString(VN),
      write(' entering system at '),
      strTime(ET),
      write(' with a planned speed of '),
      write(SP),
      write(' knots'), nl,
      ( IR == 1 -> write('**> Invalid Route Plan for Vessel: '),
                   writeString(VN), nl
      ; IR \= 1 -> write('          Waypoint:'),
                   getWayPointIDs(RO, WayPointIDs), nl,
                   write('          Arrival:  '),
                   getArriveTimes(AT), nl,
                   encounters(RO, AT, WayPointIDs, VesselNames, Routes,
                     InvalidRoute, ArriveTimes, I),
                   closePassings(RO, AT, WayPointIDs, VesselNames, Routes,
                     InvalidRoute, ArriveTimes, I)
      ),
      nl,
      I1 is I + 1,
      writeVessel(WayPoints, WayPointIDs, Conn,
        VesselNames, Routes, InvalidRoute, ArriveTimes,
        NextVesselNames, NextEntryTimes, NextSpeeds, NextRoutes,
        NextInvalidRoute, NextArriveTimes, I1).

writeOutput(WayPoints, WayPointIDs, Conn,
            VesselNames, EntryTimes, Speeds, Routes,
            InvalidRoute, ArriveTimes) :-
    writeVessel(WayPoints, WayPointIDs, Conn,
      VesselNames, Routes, InvalidRoute, ArriveTimes,
      VesselNames, EntryTimes, Speeds, Routes,
      InvalidRoute, ArriveTimes, 1).

% =======================================================================
% foprogram

vtas :-
    write('VTAS: Vessel Traffic Advisory Service  (c) 1994 by Toth Balint'),nl,
    nl, write('Reading input from file: VTAS.INP'), nl,
    readInput('VTAS.INP', WayPoints, WayPointIDs, Conn,
              VesselNames, EntryTimes, Speeds, Routes),
    write('Writing output to screen:'), nl, nl,
    traceRoutes(Conn, EntryTimes, Speeds, Routes, InvalidRoute, ArriveTimes),
    writeOutput(WayPoints, WayPointIDs, Conn,
                VesselNames, EntryTimes, Speeds, Routes,
                InvalidRoute, ArriveTimes),
% Valtozok kepernyore valo kirasahoz:
%    write(WayPoints), nl,
%    writeString(WayPointIDs), nl,
%    write(Conn), nl,
%    write(VesselNames), nl,
%    write(EntryTimes), nl,
%    write(Speeds), nl,
%    write(Routes), nl,
%    write(InvalidRoute), nl,
%    write(ArriveTimes), nl,
    nl.
