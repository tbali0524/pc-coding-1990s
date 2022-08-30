program MemSpeed;

{$IFNDEF DPMI}
  Set target to Dos protected mode!
{$ENDIF}

{$D DPMI Memory Speed Test}
{$X+,R-,Q-}

uses WinApi, Dos;

type
  BP = ^Byte;
var
  N: LongInt;
  L: LongInt;
  P: Array[0..100] of Pointer;
  I, J: LongInt;
  B: Byte;
  A1, A2, A3, A4: Word;
  B1, B2, B3, B4: Word;
  T1, T2: LongInt;

begin
  Writeln;
  Writeln('DPMI MEMORY SPEED TEST');
  Writeln('----------------------');
  Writeln('Total free global memory at start: ', GetFreeSpace(0), ' bytes.');
  L := 1024 * 1024;
  N := (GlobalCompact(0) - 65536) div L;
  Write('Allocating ', N, ' x ', L, ' bytes of memory...');
  for I := 0 to N - 1 do
    P[I] := GlobalAllocPtr(GMEM_FIXED, L);
  Writeln('Done.');
  Writeln('Total free global memory: ', GetFreeSpace(0), ' bytes.');
  WriteLn('Measuring memory access time...');
  GetTime(B1, B2, B3, B4);
  T1 := B4 + 100 * B3 + 6000 * B2 + 360000 + B1;
  for I := 0 to N - 1 do
  begin
    Write(I, '. block: ');
    for J := 0 to L - 1 do
      B := (BP(LongInt(P[I]) + J))^;
    GetTime(B1, B2, B3, B4);
    T2 := B4 + 100 * B3 + 6000 * B2 + 360000 + B1;
    WriteLn((T2 - T1) * 10, ' ms');
    T1 := T2;
  end;
  Writeln('Releasing all allocated memory...');
  for I := 0 to N - 1 do
    GlobalFreePtr(P[I]);
  Writeln('Done.');
  Writeln('Total free global memory: ', GetFreeSpace(0), ' bytes.');
end.
