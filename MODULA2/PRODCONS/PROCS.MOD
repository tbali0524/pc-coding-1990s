(* MODULA-2 Hazi feladat                                            *)
(* (Termelo-fogyaszto problema n meretu pufferrel)                  *)
(* T¢th B lint                                                      *)
(* BME Informatika Szak, 3. evfolyam, 1. felev (1994-95), 3.tankor  *)
(* E-mail: s4078tot@sun10.vsz.bme.hu                                *)
(* 1994. november                                                   *)
(* ================================================================ *)

(* Termelo es fogyaszto folyamatot tartalmazo modul torzse *)
IMPLEMENTATION MODULE Procs;

FROM RTS IMPORT StopScheduler;
FROM Str IMPORT Length, Copy, Delete, Append;
FROM IO IMPORT WrChar, WrStr, WrCard, RdKey;
FROM Window IMPORT WinDef, WinType, Color, SingleFrame, CenterUpperTitle,
  Open, SetTitle, Use, Clear, GotoXY, DelLine, TextColor, Close;
FROM Buffer IMPORT Put, Get;

CONST
(* Termelo statusz ablak definicioja *)
  ProdWinDef = WinDef(10, 0, 69, 5, White, Black, FALSE,  FALSE, FALSE,
    TRUE, SingleFrame, Yellow, Black);
(* Fogyaszto statusz ablak definicioja *)
  ConsWinDef = WinDef(10, 16, 69, 24, White, Black, FALSE,  TRUE, FALSE,
    TRUE, SingleFrame, Yellow, Black);

VAR
(* TRUE eseten kepernyos megjelenites is, es statusz kijelzes *)
  DemoMode: BOOLEAN;
  ProdWin: WinType;             (* Termelo statusz ablak leiroja *)
  ConsWin: WinType;             (* Fogyaszto statusz ablak leiroja *)
  TotalSent: CARDINAL;          (* Osszes elkuldott karakter *)
  TotalReceived: CARDINAL;      (* Osszes vett karakter *)
(* Fogyaszto statusz ablakaban kiirando sztring *)
  ReceivedMsg: ARRAY [1..128] OF CHAR;

(* ====================================================================== *)
(* Termelo statusz ablak kirajzolasa, Msg statusz sztringgel.
 Gombnyomasig megall. Ha AtInit = TRUE, akkor nem lehet ESC-re kilepni *)
PROCEDURE DrawProducer(Msg: ARRAY OF CHAR; AtInit: BOOLEAN);
VAR
  C: CHAR;
BEGIN
  IF DemoMode THEN
    Use(ProdWin);
    Clear;
    GotoXY(2, 1);
    WrStr('Total number of characters sent: ');
    WrCard(TotalSent, 5);
    GotoXY(2, 2);
    WrStr('Status: ');
    WrStr(Msg);
    GotoXY(2, 4);
    TextColor(Yellow);
    IF AtInit THEN
      WrStr('Press any key to go on!');
    ELSE
      WrStr('Press any key to go on, ESC to quit!');
    END;
    TextColor(White);
    C := RdKey();
    DelLine;
    IF (NOT AtInit) AND (C = CHAR(27)) THEN
      StopScheduler;
    END;
  END;
END DrawProducer;

(* ====================================================================== *)
(* Fogyaszto statusz ablak kirajzolasa, Msg statusz sztringgel.
 Gombnyomasig megall. Ha AtInit = TRUE, akkor nem lehet ESC-re kilepni *)
PROCEDURE DrawConsumer(Msg: ARRAY OF CHAR; AtInit: BOOLEAN);
VAR
  C: CHAR;
BEGIN
  IF DemoMode THEN
    Use(ConsWin);
    Clear;
    GotoXY(2, 1);
    WrStr('Received message: ');
    GotoXY(2, 2);
    TextColor(Cyan);
    WrStr(ReceivedMsg);
    TextColor(White);
    GotoXY(2, 4);
    WrStr('Total number of characters received: ');
    WrCard(TotalReceived, 5);
    GotoXY(2, 5);
    WrStr('Status: ');
    WrStr(Msg);
    GotoXY(2, 7);
    TextColor(Yellow);
    IF AtInit THEN
      WrStr('Press any key to go on!');
    ELSE
      WrStr('Press any key to go on, ESC to quit!');
    END;
    TextColor(White);
    C := RdKey();
    DelLine;
    IF (NOT AtInit) AND (C = CHAR(27)) THEN
      StopScheduler;
    END;
  END;
END DrawConsumer;

(* ====================================================================== *)
(* Termelo folyamat *)
PROCEDURE Producer;
CONST
  Message = 'Hello World! This is a demo of the producer-consumer problem '
    + 'with a dynamic buffer, written in MODULA2 '
    + 'by T¢th B lint in 1994.  Huh, what a long sentence... '
    + 'Now I start it again:   ';
  S1 = 'Sending character   to buffer...';
VAR
  C: CHAR;
  I: CARDINAL;
  S: ARRAY [1..128] OF CHAR;
BEGIN
  I := 0;
  LOOP
    C := Message[I];
    Copy(S, S1);
    S[19] := C;
    DrawProducer(S, FALSE);
    Put(C);
    TotalSent := TotalSent + 1;
    I := (I + 1) MOD Length(Message);
    DrawProducer('Character sent.', FALSE);
  END;
END Producer;

(* ====================================================================== *)
(* Fogyaszto folyamat *)
PROCEDURE Consumer;
CONST
  S1 = 'Character received:   ';
VAR
  C: CHAR;
  S: ARRAY [1..128] OF CHAR;
BEGIN
  LOOP
    DrawConsumer('Waiting for character...', FALSE);
    C := Get();
    TotalReceived := TotalReceived + 1;
    IF Length(ReceivedMsg) = 55 THEN
      Delete(ReceivedMsg, 0, 1);
    END;
    Append(ReceivedMsg, C);
    Copy(S, S1);
    S[21] := C;
    DrawConsumer(S, FALSE);
  END;
END Consumer;

(* ====================================================================== *)
(* Folyamatok inicializalasa
  IsDemoMode = TRUE eseten kepernyos megjelenites es statusz kijelzes is *)
PROCEDURE InitProcs(IsDemoMode: BOOLEAN);
BEGIN
  DemoMode := IsDemoMode;
  IF IsDemoMode THEN
    ProdWin := Open(ProdWinDef);
    SetTitle(ProdWin, 'PRODUCER', CenterUpperTitle);
    DrawProducer('INIT completed.', TRUE);
    ConsWin := Open(ConsWinDef);
    SetTitle(ConsWin, 'CONSUMER', CenterUpperTitle);
    DrawConsumer('INIT completed.', TRUE);
  END;
END InitProcs;

(* ====================================================================== *)
(* Folyamatok lezarasa: statusz ablakok becsukasa *)
PROCEDURE DoneProcs;
BEGIN
  ReceivedMsg := '';
  IF DemoMode THEN
    Close(ProdWin);
    Close(ConsWin);
  END;
END DoneProcs;

(* ====================================================================== *)
(* Modul inicializalas *)
BEGIN
  DemoMode := FALSE;
  TotalSent := 0;
  TotalReceived := 0;
  ReceivedMsg := '';
END Procs.
