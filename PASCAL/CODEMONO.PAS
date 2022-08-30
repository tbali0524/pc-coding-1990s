{ Monoalphabetic substitution decipher }
{ (c) T¢th B lint, 2002 }

program CodeMono;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  KeyF: Text;
  KeyFName: String;
  C, Prev: Char;
  S: String;
  I, J, N: Integer;
  TotalLetter: Integer;
  B: Boolean;
  Key: Array[1..26] of Char;
  Freq: Array[1..26] of Integer;
  DFreq: Array[1..26, 1..26] of Integer;
const
  EngFreq: Array[1..26] of Real =
   (8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4,
    6.7, 7.5, 1.9, 0.1,  6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1);

begin
  WriteLn('CODEMONO - monoalphabetic substitution decipher');
  WriteLn('(c) 2002 Balint Toth');
  WriteLn;
  if ParamCount <> 3 then
  begin
    WriteLn('Usage: CODEMONO keyfile inputfile outputfile');
    WriteLn;
    WriteLn('Format of keyfile:');
    WriteLn('  1st line: cleartext alphabet ''abc...xyz'')');
    WriteLn('  2nd line: cipher alphabet (substitution letter for ''abc...xyz'')');
    WriteLn('            (use * for unknown)');
    WriteLn;
    WriteLn('Use DOS filenames (8+3 chars)');
    Halt(1);
  end;
  KeyFName := ParamStr(1);
  InFName := ParamStr(2);
  OutFName := ParamStr(3);

  {$I-}
  Assign(KeyF, KeyFName);
  Reset(KeyF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', KeyFName);
    Halt(2);
  end;
  ReadLn(KeyF, S);
  ReadLn(KeyF, S);
  if Length(S) <> 26 then
  begin
    WriteLn('Wrong keyfile format.');
    Halt(3);
  end;
  Close(KeyF);
  for I := 1 to 26 do
  begin
    Key[I] := '*';
    Freq[I] := 0;
    for J := 1 to 26 do
      DFreq[I, J] := 0;
  end;
  for I := 1 to 26 do
  begin
    if (Upcase(S[I]) in ['A'..'Z']) and (Key[Ord(S[I]) and 31] = '*') then
      Key[Ord(S[I]) and 31] := Chr(Ord('a') + I - 1)
    else if S[I] <> '*' then
    begin
      WriteLn('Wrong keyfile format.');
      Halt(3);
    end;
  end;
  {$I-}
  Assign(InF, InFName);
  Reset(InF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', InFName);
    Halt(4);
  end;

  {$I-}
  Assign(OutF, OutFName);
  Rewrite(OutF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error writing file ', OutFName);
    Halt(5);
  end;

  WriteLn('Deciphering ', InFName, ' to ', OutFName,
    ' using key from ', KeyFName, ' ...');

  WriteLn(OutF, 'CODEMONO - monoalphabetic substitution decipher');
  WriteLn(OutF, '(c) 2002 Balint Toth');
  WriteLn(OutF);
  WriteLn(OutF, 'Deciphering ', InFName, ' to ', OutFName,
    ' using key from ', KeyFName, ' ...');
  WriteLn(OutF);

  WriteLn(OutF, 'Using substitution key:');
  WriteLn(OutF, '=======================');
  for I := 1 to 26 do
  begin
    Write(OutF, '  ', Chr(Ord('a') + I - 1),' -> ');
    J := 0;
    B := False;
    while (not B) and (J < 26) do
    begin
      Inc(J);
      B := UpCase(Key[J]) = Chr(Ord('A') + I - 1)
    end;
    if B then
      Write(OutF, Chr(Ord('A') + J - 1))
    else
      Write(OutF, '*');
    WriteLn(OutF);
  end;
  WriteLn(OutF, '(* = unknown substitution, leave out from deciphered text)');
  WriteLn(OutF);

  WriteLn(OutF, 'Ciphertext (input):');
  WriteLn(OutF, '===================');
  WriteLn(OutF);
  Write(OutF, '  1 : ');
  N := 1;
  while not Eof(InF) do
  begin
    Read(InF, C);
    case C of
      #13 :
        begin
          WriteLn(OutF);
          Inc(N);
          Write(OutF, N :3, ' : ');
        end;
      #10 : ;
      else
        Write(OutF, C);
    end;
  end; { while }
  Close(InF);
  WriteLn(OutF);
  WriteLn(OutF);

  {$I-}
  Assign(InF, InFName);
  Reset(InF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', InFName);
    Halt(4);
  end;

  WriteLn(OutF, 'Deciphered text (output):');
  WriteLn(OutF, '=========================');
  WriteLn(OutF);
  TotalLetter := 0;
  Prev := ' ';
  Write(OutF, '  1 : ');
  N := 1;
  while not Eof(InF) do
  begin
    Read(InF, C);
    case Upcase(C) of
      'A'..'Z':
        begin
          Write(OutF, Key[Ord(C) and 31]);
          Inc(TotalLetter);
          Inc(Freq[Ord(C) and 31]);
          if Prev in ['A'..'Z'] then
            Inc(DFreq[Ord(Prev) and 31, Ord(C) and 31]);
        end;
      ' ' : Write(OutF, ' ');
      #13 :
        begin
          WriteLn(OutF);
          Inc(N);
          Write(OutF, N :3, ' : ');
        end;
      #10 : ;
      else
        Write(OutF, C);
    end;
    Prev := UpCase(C);
  end; { while }
  Close(InF);
  WriteLn(OutF);
  WriteLn(OutF);
  WriteLn(OutF, 'Frequency analysis of the ciphertext:');
  WriteLn(OutF, '=====================================');
  WriteLn(OutF);
  WriteLn(OutF, 'Single letters:');
  WriteLn(OutF);
  WriteLn(OutF, 'Cipher: Frequency : Assumed      : Average English');
  WriteLn(OutF, 'letter: [%]       : clear letter : frequency [%]');
  WriteLn(OutF, '---------------------------------------------------');
  for I := 1 to 26 do
  begin
    if TotalLetter <> 0 then
      Write(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
        Freq[I] / TotalLetter * 100 :6:3)
    else
      Write(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
        Freq[I] :6);
    if Key[I] <> '*' then
      Write(OutF, '      ', Key[I], '              ',
        EngFreq[Ord(Key[I]) and 31] :4:1);
    WriteLn(OutF);
  end;
  WriteLn(OutF, '(Total number of ciphered letters: ', TotalLetter, ')');
  WriteLn(OutF);
  WriteLn(OutF, 'Letter pairs: (total occurences in row-column order)');
  WriteLn(OutF);
  Write(OutF, '   ');
  for I := 1 to 26 do
    Write(OutF, ':  ', Chr(Ord('A') + I - 1));
  WriteLn(OutF);
  for I := 1 to 4 * 26 + 3 do
    Write(OutF, '-');
  WriteLn(OutF);
  for I := 1 to 26 do
  begin
    Write(OutF, ' ', Chr(Ord('A') + I - 1), ':');
    for J := 1 to 26 do
      Write(OutF, ' ', DFreq[I, J] :3);
    WriteLn(OutF);
  end;
  WriteLn(OutF, '(Note: same letter 3 or more times count as several pairs.)');
  Close(OutF);
  WriteLn('Done.');
end.
