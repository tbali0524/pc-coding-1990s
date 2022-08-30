program MemTestX;

{$IFNDEF DPMI}
  Set target to Dos protected mode!
{$ENDIF}

{$D DPMI Memory Test}
{$X+}

uses WinApi;

var
  L: LongInt;
  P: Pointer;

begin
  Writeln;
  Writeln('DPMI MEMORY TEST');
  Writeln('----------------');
  Writeln('Total free global memory at start: ', GetFreeSpace(0), ' bytes.');
  L := 3 * GlobalCompact(0) div 4;
  Writeln('Allocating ', L, ' bytes of memory.');
  P := GlobalAllocPtr(GMEM_FIXED, L);
  Writeln('Total free global memory: ', GetFreeSpace(0), ' bytes.');
  Writeln('De-allocating ', L, ' bytes of memory.');
  GlobalFreePtr(P);
  Writeln('Total free global memory: ', GetFreeSpace(0), ' bytes.');
end.
