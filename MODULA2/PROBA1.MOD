MODULE Proba1;

FROM SYSTEM IMPORT PROCESS, NEWPROCESS, TRANSFER;
FROM IO IMPORT RdChar, WrChar;
FROM Str IMPORT Length;

CONST
  Max = 4096;

TYPE
  BufferT = ARRAY[0..Max] OF CARDINAL;

VAR
  WorkProd, WorkCons: BufferT;
  M, P, C: PROCESS;
  Ch: CHAR;
  S: ARRAY[1..255] OF CHAR;

PROCEDURE Producer;
VAR
  i: INTEGER;
BEGIN
  FOR i := 1 TO Length(S) DO
    Ch := S[i];
    TRANSFER(P, C);
  END;
  TRANSFER(P, M);
END Producer;

PROCEDURE Consumer;
BEGIN
  LOOP
    WrChar(Ch);
    TRANSFER(C, P);
  END;
END Consumer;

BEGIN
  S := "Hello World!";
  NEWPROCESS(Consumer, ADR(WorkCons), SIZE(WorkCons), C);
  NEWPROCESS(Producer, ADR(WorkProd), SIZE(WorkCons), P);
  TRANSFER(M, P);
END Proba1.
