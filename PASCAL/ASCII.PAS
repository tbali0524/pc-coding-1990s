program ASCIITable;
var
  F: Text;
  I, J: Integer;
begin
  Assign(F, 'ASCII.TXT');
  Rewrite(F);
  WriteLn(F, '                               ASCII KขDTBLZAT');
  WriteLn(F, '               ษอออออัอออออหอออออัอออออหอออออัอออออหอออออัอออออป');
  for I := 0 to 63 do
  begin
    for J := 0 to 3 do
    begin
      if J = 0 then
        Write(F, '               ');
      Write(F, 'บ', J * 64 + I : 4, ' ณ  ');
      if ((J = 0) and (I < 32)) or ((J = 1) and (I = 63)) then
        Write(F, ' ')
      else
        Write(F, Chr(J * 64 + I));
      Write(F, '  ');
    end;
    WriteLn(F, 'บ');
  end;
  WriteLn(F, '               ศอออออฯอออออสอออออฯอออออสอออออฯอออออสอออออฯอออออผ');
  Close(F);
end.