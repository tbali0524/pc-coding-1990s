MODULE PrCo;

FROM RTS IMPORT SEMAPHORE, InitSemaphore, P, V,
                 CreateProcess, StartScheduler, StopScheduler;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM Str IMPORT Length;
FROM IO IMPORT WrChar,WrStr, WrLn, RdCard, KeyPressed;

CONST
  MaxBufferSize = 64000;
  WorkSize = 2048;
TYPE
  BufferType = ARRAY [1..MaxBufferSize] OF CHAR;
VAR
  BufferSize: CARDINAL;
  Buffer: POINTER TO BufferType;
  Full, Empty, Access: SEMAPHORE;
  InPos, OutPos: CARDINAL;

PROCEDURE Put(X: CHAR);
BEGIN
  P(Empty);
  P(Access);
  Buffer^[InPos] := X;
  InPos := InPos MOD BufferSize + 1;
  V(Access);
  V(Full);
END Put;

PROCEDURE Get(): CHAR;
VAR
  C: CHAR;
BEGIN
  P(Full);
  P(Access);
  C := Buffer^[OutPos];
  OutPos := OutPos MOD BufferSize + 1;
  V(Access);
  V(Empty);
  RETURN(C);
END Get;

PROCEDURE Producer;
CONST
  msg = 'HELLO WORLD! ';
VAR
  C: CHAR;
  I: CARDINAL;
BEGIN
  I := 0;
  LOOP
    C := msg[I];
    I := (I + 1) MOD Length(msg);
    Put(C);
    IF KeyPressed() THEN
      StopScheduler;
    END;
  END;
END Producer;

PROCEDURE Consumer;
VAR
  C: CHAR;
BEGIN
  LOOP
    C := Get();
    WrChar(C);
    IF KeyPressed() THEN
      StopScheduler;
    END;
  END;
END Consumer;

BEGIN (* ProdCons *)
  InPos := 1;
  OutPos := 1;
  REPEAT
    WrStr('Buffersize: ');
    BufferSize := RdCard();
    WrLn;
  UNTIL (BufferSize > 0) AND (BufferSize < MaxBufferSize);
  ALLOCATE(Buffer, BufferSize);
  InitSemaphore(Empty, BufferSize);
  InitSemaphore(Full, 0);
  InitSemaphore(Access, 1);
  CreateProcess(Producer, WorkSize);
  CreateProcess(Consumer, WorkSize);
  StartScheduler;
  DEALLOCATE(Buffer, BufferSize);
END PrCo.
