{ Caesar shift decipher }
{ (c) T¢th B lint, 2002 }

program Caesar;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  C: Char;
  L, I: Integer;

begin
  WriteLn('CAESAR shift decipher  (c) 2002 Balint Toth');
  WriteLn('===========================================');
  WriteLn;
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: CAESAR inputfile outputfile');
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


  WriteLn(OutF, 'CAESAR shift decipher  (c) 2002 Balint Toth');
  WriteLn(OutF, '===========================================');
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
    Inc(L);
  end;
  Close(InF);
  WriteLn(OutF);
  WriteLn(OutF);
  WriteLn(OutF, 'Now deciphering as Caesar shift cipher with keys 1 through 25:');
  WriteLn(OutF);
  for I := 1 to 25 do
  begin
    {$I-}
    Assign(InF, InFName);
    Reset(InF);
    {$I+}
    if IOResult <> 0 then
    begin
      WriteLn('Error reading file ', InFName);
      Halt(2);
    end;
    WriteLn(OutF, 'Code ', I, ':');
    while not Eof(InF) do
    begin
      Read(InF, C);
      case C of
        'a'..'z', 'A'..'Z':
           if (Ord(C) and 31) > I then
             Write(OutF, Chr(Ord(C) - I))
           else
             Write(OutF, Chr(Ord(C) - I + 26));
        ' ' : Write(OutF, ' ');
        #13 : WriteLn(OutF);
        #10 : ;
        else
          Write(OutF, '*');
      end;
    end;
    WriteLn(OutF);
    WriteLn(OutF);
    Close(InF);
  end; { for }
  Close(OutF);
  WriteLn('Done.');
end.
