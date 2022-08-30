(* MODULA-2 Hazi feladat                                            *)
(* (Termelo-fogyaszto problema n meretu pufferrel)                  *)
(* T¢th B lint                                                      *)
(* BME Informatika Szak, 3. evfolyam, 1. felev (1994-95), 3.tankor  *)
(* E-mail: s4078tot@sun10.vsz.bme.hu                                *)
(* 1994. november                                                   *)
(* ================================================================ *)

(* Foprogram *)
MODULE ProdCons;

FROM RTS IMPORT CreateProcess, StartScheduler;
FROM IO IMPORT WrStr, WrLn, RdCard;
FROM Buffer IMPORT MaxBufferSize, InitBuffer, DoneBuffer;
FROM Procs IMPORT InitProcs, DoneProcs, Producer, Consumer;

CONST
  WorkSize = 4096;      (* Munkaterulet merete a folyamatok szamara *)
VAR
  BSize: CARDINAL;      (* Puffermeret *)

BEGIN
  WrStr('PRODUCER-CONSUMER DEMO   (c) 1994 by T¢th B lint');
  WrLn;
  WrLn;
  REPEAT
    WrStr('Enter size of buffer (1 - 64000) : ');
    BSize := RdCard();
    WrLn;
  UNTIL (BSize > 0) AND (BSize <= MaxBufferSize);
  InitBuffer(BSize, TRUE);
  InitProcs(TRUE);
  CreateProcess(Producer, WorkSize);
  CreateProcess(Consumer, WorkSize);
  StartScheduler;
  DoneProcs;
  DoneBuffer;
END ProdCons.
