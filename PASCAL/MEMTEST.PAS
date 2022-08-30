program MemTest;

{$IFDEF WINDOWS}
uses WinCrt;
{$ENDIF}

const
  Max = 500;

type
  P = ^T;
  T = Array[0..$FFFE] of Byte;

var
  N: Integer;
  I: Integer;
  J: Word;
  A: Array[0..Max] of P;

begin
  N := 0;
  Writeln;
  Writeln('MEMORY TEST');
  Writeln('-----------');
  Writeln('Free memory at start: ', MemAvail, ' bytes.');
  Write('Allocating 64K blocks...  ');
  while (N <= Max) and (MaxAvail >= SizeOf(T)) do
  begin
    New(A[N]);
    Inc(N);
  end;
  Writeln('Done.');
  Write(N, ' blocks successfully allocated.');
  Writeln(' (Total size: ', N * SizeOf(T), ' bytes.)');
  Writeln('Free memory left: ', MemAvail, ' bytes.');
{$IFDEF FILL}
  Write('Filling all blocks with zero...  ');
  for I := 0 to N - 1 do
    for J := 0 to $FFFE do
      A[I]^[J] := 0;
  Writeln('Done.');
{$ENDIF}
  Write('De-allocating memory...  ');
  while (N > 0) do
  begin
    Dec(N);
    Dispose(A[N]);
  end;
  Writeln('Done.');
  Writeln('Free memory: ', MemAvail);
end.
