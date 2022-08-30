{ Reverse decipher }
{ (c) T¢th B lint, 2004 }

program Reverse;

const
  MaxLen = 30000;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  C: Char;
  L, I: Integer;
  Len: Integer;
  S: Array[1..MaxLen] of Char;

begin
  WriteLn('REVERSE decipher  (c) 2004 Balint Toth');
  WriteLn('======================================');
  WriteLn;
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: REVERSE inputfile outputfile');
    Halt(1);
  end;
  InFName := ParamStr(1);
  OutFName := ParamStr(2);
  {$I-}
  Assign(InF, InFName);
  Reset(InF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', InFName);
    Halt(2);
  end;
  {$I-}
  Assign(OutF, OutFName);
  Rewrite(OutF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error writing file ', OutFName);
    Halt(3);
  end;
  WriteLn('Decrypting ', InFName, ' to ', OutFName, ' ...');


  WriteLn(OutF, 'REVERSE decipher  (c) 2004 Balint Toth');
  WriteLn(OutF, '======================================');
  WriteLn(OutF);
  WriteLn(OutF, 'Deciphering ', InFName, ' to ', OutFName, ' ...');
  WriteLn(OutF);
  WriteLn(OutF, 'Original text:');
  WriteLn(OutF);
  L := 0;
  while not Eof(InF) do
  begin
    Read(InF, C);
    Write(OutF, C);
    if L < MaxLen then
    begin
      Inc(L);
      S[L] := C;
    end;
  end;
  Len := L;
  Close(InF);
  WriteLn(OutF);
  WriteLn(OutF);
  WriteLn(OutF, 'Reversed text:');
  if Len = MaxLen then
    WriteLn(OutF, ' (only the first ', MaxLen, ' characters)');
  WriteLn(OutF);
  for L := Len downto 1 do
  begin
    case S[L] of
      'a'..'z', 'A'..'Z', ' ':
           Write(OutF, S[L]);
      #13 : WriteLn(OutF);
      #10 : ;
      else
          Write(OutF, S[L]);
    end;
  end; { for }
  WriteLn(OutF);
  Close(OutF);
  WriteLn('Done.');
end.
