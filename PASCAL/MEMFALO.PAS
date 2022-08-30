program MemFalo; { be ll¡tja a szabad mem¢ria mennyis‚g‚t }
{$M 8192,0,655360}

uses Memory, Dos;

var
  Mem: LongInt;
  Kod: Integer;

begin
  Kod := 1;
  if ParamCount > 0 then
    Val(ParamStr(1), Mem, Kod);
  if Kod <> 0 then
  begin
    Write('Fennmarad¢ szabad mem¢ria kilobyte-ban: ');
    ReadLn(Mem);
  end;
  if Mem shl 10 > MaxAvail then
  begin
    WriteLn('Csak ', MaxAvail shr 10, 'k-t tudok szabadon hagyni!');
    Mem := MaxAvail shr 10 - 1;
  end;
  WriteLn('Visszal‚p‚s EXIT-tel.');
  SetMemTop(Ptr(Seg(HeapPtr) + MaxAvail shr 4 - Mem shl 6 + 1, 0));
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  if DosError <> 0 then
    WriteLn('Nem tudom elind¡tani a COMMAND.COM-ot!');
  SetMemTop(HeapEnd);
end.
