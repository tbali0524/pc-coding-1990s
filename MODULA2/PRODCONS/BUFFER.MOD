(* MODULA-2 Hazi feladat                                            *)
(* (Termelo-fogyaszto problema n meretu pufferrel)                  *)
(* T¢th B lint                                                      *)
(* BME Informatika Szak, 3. evfolyam, 1. felev (1994-95), 3.tankor  *)
(* E-mail: s4078tot@sun10.vsz.bme.hu                                *)
(* 1994. november                                                   *)
(* ================================================================ *)

(* Korkoros puffer kezelo modul torzse *)
IMPLEMENTATION MODULE Buffer;

FROM RTS IMPORT SEMAPHORE, InitSemaphore, P, V, StopScheduler;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM IO IMPORT WrStr, WrChar, WrCard, RdKey;
FROM Window IMPORT WinDef, WinType, Color, DoubleFrame, CenterUpperTitle,
  Open, SetTitle, Use, Clear, GotoXY, DelLine, TextColor, Close;

CONST
(* Puffer statusz ablak definicioja *)
  BufWinDef = WinDef(0, 6, 79, 15, White, Black, FALSE,  FALSE, FALSE,
    TRUE, DoubleFrame, Yellow, Black);

TYPE
(* Tombtipus az elemek eleresehez, valojaban csak annyi helyet allokal,
 amennyi szukseges *)
  BufferType = ARRAY [0..MaxBufferSize - 1] OF CHAR;

VAR
  Inited: BOOLEAN;             (* TRUE, ha a puffer inicializalva van *)
  BufferSize: CARDINAL;        (* A puffer merete (hany karakter fer bele) *)
  ItemNum: CARDINAL;           (* Elemek szama a pufferben *)
(* Szemaforok a szinkronizaciohoz, kolcsonos kizarashoz: *)
  Full: SEMAPHORE;             (* Elemek szama a pufferben *)
  Empty: SEMAPHORE;            (* Ures helyek szama a pufferben *)
  Access: SEMAPHORE;           (* 1 = belephetunk a kritikus szakaszba *)
(* Kovetkezo be- ill. kivivendo karakter helye a Buf tombben: *)
  InPos, OutPos: CARDINAL;
  Buf: POINTER TO BufferType;  (* Puffer elemek tarolasa *)
(* TRUE eseten kepernyos megjelenites is, es statusz kijelzes
 Put-nal es , Get-nel *)
  DemoMode: BOOLEAN;
  BufWin: WinType;             (* Puffer statuszablak leiroja *)

(* ====================================================================== *)
(* Puffer statusz ablak kirajzolasa, Msg statusz sztringgel.
 Gombnyomasig megall. Ha AtInit = TRUE, akkor nem lehet ESC-re kilepni *)
PROCEDURE DrawBuffer(Msg: ARRAY OF CHAR; AtInit: BOOLEAN);
VAR
  I: CARDINAL;
  C: CHAR;
BEGIN
  IF DemoMode THEN
    Use(BufWin);
    Clear;
    GotoXY(2, 2);
    WrStr('Size: ');
    WrCard(BufferSize, 5);
    WrStr('   Items: ');
    WrCard(ItemNum, 5);
    IF IsEmpty() THEN
      WrStr(' (EMPTY)')
    ELSIF IsFull() THEN
      WrStr(' (FULL)');
    END;
    GotoXY(2, 4);
    WrStr('Items in Buffer: ');
    IF NOT IsEmpty() THEN
      TextColor(Cyan);
      IF ItemNum <= 55 THEN
        FOR I := 0 TO ItemNum - 1 DO
          WrChar(Buf^[(OutPos +  I) MOD BufferSize]);
        END;
      ELSE
        FOR I := 0 TO 24 DO
          WrChar(Buf^[(OutPos + I) MOD BufferSize]);
        END;
        TextColor(White);
        WrStr(' ... ');
        TextColor(Cyan);
        FOR I := ItemNum - 25 TO ItemNum - 1 DO
          WrChar(Buf^[(OutPos + I) MOD BufferSize]);
        END;
      END;
      TextColor(White);
    END;
    GotoXY(2, 6);
    WrStr('Status: ');
    WrStr(Msg);
    GotoXY(2, 8);
    TextColor(Yellow);
    IF AtInit THEN
      WrStr('Press any key to go on!');
    ELSE
      WrStr('Press any key to go on, ESC to quit!');
    END;
    TextColor(White);
    C := RdKey();
    DelLine;
    GotoXY(10, 6);
    WrStr('Inactive                           ');
    IF (NOT AtInit) AND (C = CHAR(27)) THEN
      StopScheduler;
    END;
  END;
END DrawBuffer;

(* ====================================================================== *)
(* Inicializalas "Size" darab karakter mereture
  IsDemoMode = TRUE eseten kepernyos megjelenites is,
  es statusz kijelzes Put-nal es Get-nel *)
PROCEDURE InitBuffer(Size: CARDINAL; IsDemoMode: BOOLEAN);
BEGIN
  IF (NOT Inited) AND (Size <= MaxBufferSize) AND (Size > 0) THEN
    BufferSize := Size;
    ItemNum := 0;
    InPos := 0;
    OutPos := 0;
    ALLOCATE(Buf, BufferSize);
    InitSemaphore(Empty, BufferSize);
    InitSemaphore(Full, 0);
    InitSemaphore(Access, 1);
    DemoMode := IsDemoMode;
    IF DemoMode THEN
      BufWin := Open(BufWinDef);
      SetTitle(BufWin, 'BUFFER', CenterUpperTitle);
      DrawBuffer('INIT completed.', TRUE);
    END;
    Inited := TRUE;
  END;
END InitBuffer;

(* ====================================================================== *)
(* Puffer megszuntetese, memoria felszabaditasa, ablak lecsukasa *)
PROCEDURE DoneBuffer;
BEGIN
  IF Inited THEN
    BufferSize := 0;
    ItemNum := 0;
    IF DemoMode THEN
      Close(BufWin);
    END;
    DEALLOCATE(Buf, BufferSize);
    Inited := FALSE;
  END;
END DoneBuffer;

(* ====================================================================== *)
(* TRUE, ha a puffer inicializalva van *)
PROCEDURE IsInited(): BOOLEAN;
BEGIN
  RETURN(Inited);
END IsInited;

(* ====================================================================== *)
(* TRUE, ha a puffer ures *)
PROCEDURE IsEmpty(): BOOLEAN;
BEGIN
  RETURN(ItemNum = 0);
END IsEmpty;

(* ====================================================================== *)
(* TRUE, ha a puffer tele van *)
PROCEDURE IsFull(): BOOLEAN;
BEGIN
  RETURN(ItemNum = BufferSize);
END IsFull;

(* ====================================================================== *)
(* A puffer merete (hany karakter fer bele) *)
PROCEDURE GetSize(): CARDINAL;
BEGIN
  RETURN(BufferSize);
END GetSize;

(* ====================================================================== *)
(* Elemek szama a pufferben a lekerdezes pillanataban *)
PROCEDURE GetItemNum(): CARDINAL;
BEGIN
  RETURN(ItemNum);
END GetItemNum;

(* ====================================================================== *)
(* Elem berakasa a pufferbe; ha tele van, elalszik *)
PROCEDURE Put(Item: CHAR);
BEGIN
  IF Inited THEN
    P(Empty);
    P(Access);
    Buf^[InPos] := Item;
    ItemNum := ItemNum + 1;
    InPos := (InPos + 1) MOD BufferSize;
    DrawBuffer('PUT completed.', FALSE);
    V(Access);
    V(Full);
  END;
END Put;

(* ====================================================================== *)
(* Elem kivetele a pufferbol; ha ures elalszik *)
PROCEDURE Get(): CHAR;
VAR
  C: CHAR;
BEGIN
  IF Inited THEN
    P(Full);
    P(Access);
    C := Buf^[OutPos];
    ItemNum := ItemNum - 1;
    OutPos := (OutPos + 1) MOD BufferSize;
    DrawBuffer('GET completed.', FALSE);
    V(Access);
    V(Empty);
    RETURN(C);
  ELSE
    RETURN(CHAR(0));
  END;
END Get;

(* ====================================================================== *)
(* Modul inicializalas *)
BEGIN
  Inited := FALSE;
  BufferSize := 0;
  ItemNum := 0;
  DemoMode := FALSE;
END Buffer.
