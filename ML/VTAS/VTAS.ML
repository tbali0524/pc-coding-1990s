(* Programozasi Paradigmak Hazi Feladat                                *)
(* VTAS: Vessel Traffic Advisory Service (ACM94FIN/G)                  *)
(* T¢th B lint                                                         *)
(* BME Informatika Szak, 3. evfolyam, 1. felev (1994-95), 3.tankor     *)
(* E-mail: s4078tot@sun10.vsz.bme.hu                                   *)
(* 1994. november                                                      *)
(* Programozasi kornyezet: Micro ML of Umea (UML) 0.22 (DOS valtozat)  *)
(* =================================================================== *)

(* igaz, ha c szamjegy *)
fun isLetter c = ((c >= "0") andalso (c <= "9"));

(* igaz ha c elvalaszto karakter *)
fun isDivider c = (c = " ") orelse (c = "\n") orelse (c = "\t");

(* c sztring erteke ha az szamjegy *)
fun getLetter c = ord(c) - ord("0");

(* ======================================================================= *)
(* "is" input_stream-bol beolvas egy sztringet (sor vegeig) *)

fun readString is =
  let fun getString s =
    if end_of_stream is
    then s
    else case input (is, 1) of "\n" => s
                             | c    => getString (s ^ c)
  in
    getString ""
  end; (* readString *)

(* ======================================================================= *)
(* "is" input_stream-bol beolvas egy egesz szamot *)

fun readInt is =
  let fun getInt i =
    if end_of_stream is
    then i
    else
      let val c = input (is, 1)
      in
        if isDivider c
        then i
        else if isLetter c
        then getInt (i * 10 + (getLetter c))
        else i                          (* hibas input! *)
      end
  in
    getInt 0
  end; (* readInt *)

(* ======================================================================= *)
(* "is" input_stream-bol beolvas egy valos (tizedes tort) szamot *)

fun readReal is =
  let fun getReal (r, he) =
    if end_of_stream is
    then r
    else
      let val c = input (is, 1)
      in
        if isDivider c
        then r
        else if he = 0.0
        then
          if isLetter c
          then getReal (r * 10.0 + real (getLetter c), 0.0)
          else if c = "."
          then getReal (r, 10.0)
          else r                        (* hibas input! *)
        else if isLetter c
        then getReal (r + (real (getLetter c)) / he, he * 10.0)
        else r                          (* hibas input! *)
      end
  in
    getReal (0.0, 0.0)
  end; (* readReal *)

(* ======================================================================= *)
(* "is" input_stream-bol beolvas size * size meretu,
   valos szamokbol allo matrixot *)

fun readMatrix (is, size) =
  let
    fun getRow (is, row, 0) = row
      | getRow (is, row, i) =
          let val next = readReal is
          in getRow (is, next::row, i - 1)
          end;
    fun getMatrix (is, matrix, 0) = matrix
      | getMatrix (is, matrix, j) =
          let val next = rev (getRow (is, [], size))
          in getMatrix (is, next::matrix, j - 1)
          end
  in
    rev (getMatrix (is, [], size))
  end; (* readmatrix *)

(* ======================================================================= *)
(* konvertalja az (ora * 100 + perc) formatumu idot percben mert idove *)

fun intTime i = ((i mod 10000) div 1000) * 600 +
                ((i mod 1000) div 100) * 60 + i mod 100;

(* ======================================================================= *)
(* Route:string-ben levo azonositokat konvertalja
   sorszamok listajava (WayPointIDs-beli elofordulas) *)

fun routeIDtoN (Route, WayPointIDs) =
  let
    fun searchID (_, [], n) = 0
      | searchID (x, y::idlist, i) =
          if x = y
          then i
          else searchID (x, idlist, i + 1);
    fun convRoute ([], route_out) = rev route_out
      | convRoute (x::route_in, route_out) =
          convRoute (route_in, (searchID (x, WayPointIDs, 1))::route_out)
  in
    convRoute (explode Route, [])
  end; (* routeIDtoN *)

(* ======================================================================= *)
(* "is" input_stream-bol beolvassa a hajok adatait
  eredmeny: (VesselNames, EntryTimes, Speeds, Routes)
  (Routes-ban 0 lesz, ahol nem letezo pont van az utban.) *)

fun readVessels (is, WayPointIDs) =
  let
    fun getVessels (i, VesselNames, EntryTimes, Speeds, Routes, name, first) =
      if (chr (ord name)) = "*"
      then (rev VesselNames, rev EntryTimes, rev Speeds, rev Routes)
      else
        let
          val et = intTime (readInt is);
          val firstEntry =
            if i = 0
            then et
            else first;
          val entrytime =
            if et >= firstEntry
            then et
            else et + 1440;             (* masodik nap *)
          val speed = readReal is;
          val route = routeIDtoN (readString is, WayPointIDs);
          val next = readString is
        in
          getVessels (i + 1, name::VesselNames, entrytime::EntryTimes,
            speed::Speeds, route::Routes, next, firstEntry)
        end
  in
    getVessels (0, [], [], [], [], (readString is), 0)
  end; (* readVessels *)

(* ======================================================================= *)
(* bemenet olvasasa inpname nevu filebol
  eredmeny:
    (WayPoints, WayPointIDs, Conn, VesselNames, EntryTimes, Speeds, Routes) *)

fun readInput inpname =
  let
    val is = open_in inpname;
    val WayPoints = readInt is;
    val WayPointIDs = explode (readString is)
    val Conn = readMatrix (is, WayPoints);
    val (VesselNames, EntryTimes, Speeds, Routes) =
           readVessels (is, WayPointIDs)
  in
    close_in is;
    (WayPoints, WayPointIDs, Conn, VesselNames, EntryTimes, Speeds, Routes)
  end; (* readInput *)

(* ======================================================================= *)
(* Hajok utjanak kovetese:
   eredmeny: (InvalidRoute, ArriveTimes) *)

fun traceRoutes (Conn, EntryTimes, Speeds, Routes) =
  let fun traceVessel ([], _, _, InvalidRoute, ArriveTimes) =
            (rev InvalidRoute, rev ArriveTimes)
        | traceVessel (et::EntryTimes, sp::Speeds, ro::Routes,
                       InvalidRoute, ArriveTimes) =
            if hd (ro) = 0
            then traceVessel (EntryTimes, Speeds, Routes,
                              true::InvalidRoute, []::ArriveTimes)
            else
              let fun nextwp (Arriv, _, [rofr]) = (false, Arriv)
                    | nextwp (Arriv, Tim, (rofr::roto::RoutRemain)) =
                if roto = 0
                then (true, Arriv)
                else
                  let
                    val Dist = nth( nth (Conn, rofr), roto);
                    val NewTim = Tim + (Dist / (sp / 60.0))
                  in
                    if Dist = 0.0
                    then (true, Arriv)
                    else
                      nextwp ((floor NewTim)::Arriv, NewTim, roto::RoutRemain)
                  end;
                val (InvRoute, Arr) = nextwp ([et], real (et), ro)
              in
                traceVessel (EntryTimes, Speeds, Routes,
                             InvRoute::InvalidRoute, (rev Arr)::ArriveTimes)
              end
  in
    traceVessel (EntryTimes, Speeds, Routes, [], [])
  end; (* traceRoutes *)

(* ======================================================================= *)
(* Talalkozasok vizsgalata es kiirasa "os" ouput_streambe
   Csak a v. hajoval kapcsolatosakat vizsgalja
   (akinek utvonala rov-ban, erkezesi idejei atv-ban vannak *)

fun encounters (os, rov, atv, WayPointIDs, VesselNames, Routes,
                InvalidRoute, ArriveTimes, v) =
  let
    fun verifyEnc (j, roj::Routej, irj::InvRoutej, atj::ArriveTimej) =
      if j > v - 1
      then ()
      else if irj
      then verifyEnc (j + 1, Routej, InvRoutej, ArriveTimej)
      else
        let
          fun tracevj ([rovi], _, _, _) = ()
            | tracevj (rovi1::rovi2, [rojk1], atvi1::atvi2, _) =
                tracevj (rovi2, roj, atvi2, atj)
            | tracevj (rovi1::rovi2::rovi3, rojk1::rojk2::rojk3,
                       atvi1::atvi2::atvi3, atjk1::atjk2::atjk3) =
                if ((   ((rovi1 = rojk1) andalso (rovi2 = rojk2))
                      orelse
                        ((rovi1 = rojk2) andalso (rovi2 = rojk1)))
                    andalso
                    (   (((atvi1:int) <= atjk1) andalso ((atvi2:int) >= atjk1))
                      orelse
                        ((atjk1 <= atvi1) andalso (atjk2 >= atvi1))))
                then (
                  output (os, "Projected encounter with " ^
                    nth (VesselNames, j) ^ " on leg between Waypoints " ^
                    nth (WayPointIDs, rovi1) ^ " & " ^
                    nth (WayPointIDs, rovi2) ^ "\n");
                  tracevj (rovi1::rovi2::rovi3, rojk2::rojk3,
                           atvi1::atvi2::atvi3, atjk2::atjk3)
                )
                else
                  tracevj (rovi1::rovi2::rovi3, rojk2::rojk3,
                           atvi1::atvi2::atvi3, atjk2::atjk3)
        in
          tracevj (rov, roj, atv, atj);
          verifyEnc (j + 1, Routej, InvRoutej, ArriveTimej)
        end
  in
    verifyEnc (1, Routes, InvalidRoute, ArriveTimes)
  end; (* encounters *)

(* ======================================================================= *)
(* kozeli elhaladasok vizsgalata es kiirasa "os" ouput_streambe
   Csak a v. hajoval kapcsolatosakat vizsgalja
   (akinek utvonala rov-ban, erkezesi idejei atv-ban vannak *)

fun closePassings (os, rov, atv, WayPointIDs, VesselNames, Routes,
                   InvalidRoute, ArriveTimes, v) =
  let
    fun verifyClose (j, roj::Routej, irj::InvRoutej, atj::ArriveTimej) =
      if j > v - 1
      then ()
      else if irj
      then verifyClose (j + 1, Routej, InvRoutej, ArriveTimej)
      else
        let
          fun tracevj ([], _, _, _) = ()
            | tracevj (rovi1::rovi2, [], atvi1::atvi2, _) =
                tracevj (rovi2, roj, atvi2, atj)
            | tracevj (rovi1::rovi2, rojk1::rojk2, atvi1::atvi2, atjk1::atjk2) =
                if (rovi1 = rojk1) andalso (abs(atvi1 - atjk1) <= 3)
                then (
                  output (os, "** Warning ** Close passing with " ^
                    nth (VesselNames, j) ^ " at Waypoint " ^
                    nth (WayPointIDs, rovi1) ^ "\n");
                  tracevj (rovi1::rovi2, rojk2, atvi1::atvi2, atjk2)
                )
                else
                  tracevj (rovi1::rovi2, rojk2, atvi1::atvi2, atjk2)
        in
          tracevj (rov, roj, atv, atj);
          verifyClose (j + 1, Routej, InvRoutej, ArriveTimej)
        end
  in
    verifyClose (1, Routes, InvalidRoute, ArriveTimes)
  end; (* closePassings *)

(* ======================================================================= *)
(* percben mert ido konvertalasa ora ^ perc sztringge *)

fun strTime i =
  let
    fun leadZero k =
      if k < 10
      then "0" ^ chr((ord "0") + k)
      else (chr ((ord "0") + k div 10)) ^ (chr ((ord "0") + k mod 10))
  in
    (leadZero ((i mod 1440) div 60)) ^ (leadZero (i mod 60))
  end; (* strTime *)

(* ======================================================================= *)
(* kimenet irasa outname nevu file-ba *)

fun writeOutput (outname, WayPoints, WayPointIDs, Conn,
                 VesselNames, EntryTimes, Speeds, Routes,
                 InvalidRoute, ArriveTimes) =
  let
    val os = open_out outname;
    fun writeVessel (_, _, _, [], _, _, _, _, _, _) = ()
      | writeVessel (WayPoints, WayPointIDs, Conn,
            vn::nextVesselNames, et::nextEntryTimes, sp::nextSpeeds,
            ro::nextRoutes, ir::nextInvalidRoute, at::nextArriveTimes, i) =
      let fun getWayPointIDs [] = ""
            | getWayPointIDs (actro::rout) =
                "    " ^ nth (WayPointIDs, actro) ^ getWayPointIDs (rout);
          fun getArriveTimes [] = ""
            | getArriveTimes (actat::arriv) =
                " " ^ strTime (actat) ^ getArriveTimes (arriv);
      in
        output (os, vn ^ " entering system at " ^ (strTime et) ^
                " with a planned speed of " ^ (makestring sp) ^ " knots\n");
        if ir
        then output (os, "**> Invalid Route Plan for Vessel: " ^ vn ^"\n")
        else
        (  output (os, "          Waypoint:" ^ getWayPointIDs (ro) ^
                      "\n          Arrival:  " ^ getArriveTimes (at) ^ "\n");
           encounters(os, ro, at, WayPointIDs, VesselNames, Routes,
                      InvalidRoute, ArriveTimes, i);
           closePassings(os, ro, at, WayPointIDs, VesselNames, Routes,
                      InvalidRoute, ArriveTimes, i)
        );
        output (os, "\n");
        writeVessel (WayPoints, WayPointIDs, Conn,
                     nextVesselNames, nextEntryTimes, nextSpeeds, nextRoutes,
                     nextInvalidRoute, nextArriveTimes, i + 1)
      end (* writeVessel *)
  in
    writeVessel (WayPoints, WayPointIDs, Conn,
                 VesselNames, EntryTimes, Speeds, Routes,
                 InvalidRoute, ArriveTimes, 1);
    close_out os
  end; (* writeOutput *)

(* ======================================================================= *)
(* foprogram *)

fun vtas () =
  let
    val inpname = "vtas.inp";
    val outname = "vtas.out";
    val (WayPoints, WayPointIDs, Conn, VesselNames, EntryTimes, Speeds, Routes)
          = readInput inpname;
    val (InvalidRoute, ArriveTimes) =
           traceRoutes (Conn, EntryTimes, Speeds, Routes)
  in
    writeOutput (outname, WayPoints, WayPointIDs, Conn,
                 VesselNames, EntryTimes, Speeds, Routes,
                 InvalidRoute, ArriveTimes);
    print (
      "\nVTAS: Vessel Traffic Advisory Service  (c) 1994 by T¢th B lint\n" ^
      "\nReading input from file: " ^ inpname ^
      "\nWriting output to file: " ^ outname ^ "\n\n")
   (* Valtozok kepernyore valo kirasahoz:
    (WayPoints, WayPointIDs, Conn,
     VesselNames, EntryTimes, Speeds, Routes,
     InvalidRoute, ArriveTimes)
   *)
  end; (* vtas *)

(* ======================================================================= *)
(* use "vtas.ml"; utan kiirando uzenet *)

val msg = print (
      "================================================================\n" ^
      "\nVTAS: Vessel Traffic Advisory Service  (c) 1994 by T¢th B lint\n" ^
      "\nEnter 'vtas();' at the ML toplevel prompt to run the program.\n" ^
      "\nThe input file (vtas.inp) should be in the current directory.\n\n");
