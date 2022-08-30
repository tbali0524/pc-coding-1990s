{ Vigenere decipher }
{ (c) T¢th B lint, 2002 }

program Vigenere;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  C: Char;
  S: String;
  I, J, K, N: Integer;
  B: Boolean;
  MaxJ: Integer;
  R, MaxR: Real;
  TotalLetter: Integer;
  VFreq: Array[1..26, 1..26] of Integer;
  Key: String;
  KeyLen: Integer;

const
  EngFreq: Array[1..26] of Real =
    (8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4,
     6.7, 7.5, 1.9, 0.1,  6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1);

begin
  WriteLn('VIGENERE decipher');
  WriteLn('(c) 2002 Balint Toth');
  WriteLn;
  if ParamCount <> 3 then
  begin
    WriteLn('Usage: VIGENERE key inputfile outputfile');
    WriteLn;
    WriteLn('The length of ''key'' is used as assumed key length in key-generating');
    WriteLn;
    WriteLn('Use DOS filenames (8+3 chars)');
    Halt(1);
  end;
  Key := ParamStr(1);
  InFName := ParamStr(2);
  OutFName := ParamStr(3);

  if Length(Key) > 26 then
  begin
    WriteLn('Key must include only alphabetic letters');
    Halt(4);
  end;
  for I := 1 to Length(Key) do
    if not (UpCase(Key[I]) in ['A'..'Z']) then
    begin
      WriteLn('Key must include only alphabetic letters');
      Halt(4);
    end;

  for I := 1 to 26 do
  begin
    for J := 1 to 26 do
      VFreq[I, J] := 0;
  end;

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

  WriteLn('Deciphering ', InFName, ' to ', OutFName,
    ' using key ''', Key, ''' ...');

  WriteLn(OutF, 'VIGENERE decipher');
  WriteLn(OutF, '(c) 2002 Balint Toth');
  WriteLn(OutF);
  WriteLn(OutF, 'Deciphering ', InFName, ' to ', OutFName,
    ' using key ''', Key, ''' ...');
  WriteLn(OutF);

  WriteLn(OutF, 'Ciphertext (input):');
  WriteLn(OutF, '===================');
  WriteLn(OutF);
  Write(OutF, '  1 : ');
  N := 1;
  while not Eof(InF) do
  begin
    Read(InF, C);
    case UpCase(C) of
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

  KeyLen := Length(Key);

  {$I-}
  Assign(InF, InFName);
  Reset(InF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', InFName);
    Halt(2);
  end;
  WriteLn(OutF, 'Deciphered text (output):');
  WriteLn(OutF, '=========================');
  WriteLn(OutF);
  TotalLetter := 0;
  Write(OutF, '  1 : ');
  N := 1;
  K := 1;
  while not Eof(InF) do
  begin
    Read(InF, C);
    case Upcase(C) of
      'A'..'Z':
        begin
          if Key <> '*' then
          begin
            I := (Ord(Key[K]) and 31) - 1;
            if (Ord(C) and 31) > I then
              Write(OutF, Chr(Ord(C) - I))
            else
              Write(OutF, Chr(Ord(C) - I + 26));
          end
          else
            Write(OutF, '*');
          Inc(TotalLetter);
          Inc(VFreq[K, Ord(C) and 31]);
          if K = KeyLen then
            K := 1
          else
            Inc(K);
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
  end; { while }
  Close(InF);
  WriteLn(OutF);
  WriteLn(OutF);

  WriteLn(OutF, 'Frequency analysis of cyclic slices of the ciphertext:');
  WriteLn(OutF, '======================================================');

  WriteLn(OutF);
  WriteLn(OutF, ' Code : Average English : Frequency in ciphertext segments [%]');
  Write  (OutF, 'letter: frequency [%]');
  for I := 1 to KeyLen do
    Write(OutF, '   : ', I :2);
  WriteLn(OutF);
  for I := 1 to 25 + 7 * KeyLen do
    Write(OutF, '-');
  WriteLn(OutF);

  for I := 1 to 26 do
  begin
    Write(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
      EngFreq[I] :5:1 , '           ');
    if TotalLetter <> 0 then
      for J := 1 to KeyLen do
        Write(OutF, ':', 100 * Length(Key) * VFreq[J, I] / TotalLetter :6:3);
    WriteLn(OutF);
  end;
  WriteLn(OutF, '(Total number of ciphered letters: ', TotalLetter, ')');

  S := '';
  for I := 1 to KeyLen do
  begin
    for J := 0 to 25 do
    begin
      R := 0.0;
      for K := 1 to 26 do
      begin
        if K + J > 26 then
          N := K + J - 26
        else
          N := K + J;
        R := R + (VFreq[I, N] - EngFreq[K]) * (VFreq[I, N] - EngFreq[K]);
      end;
      if (J = 0) or (R < MaxR) then
      begin
        MaxR := R;
        MaxJ := J
      end;
    end; { for J }
    if (Ord('A') and 31) + MaxJ > 26 then
      S := S + Chr(Ord('A') + MaxJ - 26)
    else
      S := S + Chr(Ord('A') + MaxJ);
  end; { for I }
  WriteLn(OutF);
  WriteLn(OutF, 'Recommended key (best fit based on frequencies): ', S);
  WriteLn(OutF);
  Key := S;

  {$I-}
  Assign(InF, InFName);
  Reset(InF);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('Error reading file ', InFName);
    Halt(2);
  end;
  WriteLn(OutF, 'Deciphering with recommended key:');
  WriteLn(OutF, '=================================');
  WriteLn(OutF);
  Write(OutF, '  1 : ');
  N := 1;
  K := 1;
  while not Eof(InF) do
  begin
    Read(InF, C);
    case Upcase(C) of
      'A'..'Z':
        begin
          I := (Ord(Key[K]) and 31) - 1;
          if (Ord(C) and 31) > I then
            Write(OutF, Chr(Ord(C) - I))
          else
            Write(OutF, Chr(Ord(C) - I + 26));
          if K = KeyLen then
            K := 1
          else
            Inc(K);
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
  end; { while }
  Close(InF);
  WriteLn(OutF);

  Close(OutF);
  WriteLn('Done.');
end.
