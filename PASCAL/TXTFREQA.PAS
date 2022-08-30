{ Text letter frequency analyser }
{ (c) T¢th B lint, 2004 }

program TxtFreqA;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  C, Prev: Char;
  I, J, K: Integer;
  TotalLetter, TotalWord, TotalDG: LongInt;
  Freq: Array[1..26] of LongInt;
  StartFreq: Array[1..26] of LongInt;
  EndFreq: Array[1..26] of LongInt;
  DFreq: Array[1..26, 1..26] of LongInt;
  DFreqIndex: Array[1.. 26 * 26] of Integer;

const
  EngFreq: Array[1..26] of Real =
   (8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4,
    6.7, 7.5, 1.9, 0.1,  6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1);
  EngStartFreq: Array[1..26] of Real =
   (12.1, 3.5, 2.9, 2.2, 4.7, 4.5, 0.9, 4.7, 5.0, 0.4, 0.2, 1.4, 1.6,
    2.1, 8.5, 4.1, 0.0, 4.9, 4.8, 12.9, 1.1, 0.2, 2.9, 0.0, 0.0, 0.0);
  EngEndFreq: Array[1..26] of Real =
   (1.0, 0.0, 0.6, 9.1, 16.8, 5.0, 1.7, 1.9, 0.0, 0.0, 0.4, 6.1, 1.1,
    8.7, 4.9, 0.2, 0.0, 4.3, 10.9, 6.1, 0.0, 0.0, 0.5, 0.1, 6.4, 0.0);
  EngLen: Real = 4.5;
  EngTopDG: String = 'th on an he er nd in ti al re io en ri of or at it to ed nt';

begin
  WriteLn('TXTFREQA - Text Letter Frequency Analyser');
  WriteLn('(c) 2004 Balint Toth');
  WriteLn;
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: TXTFREQA inputfile outputfile');
    WriteLn;
    WriteLn('Use DOS filenames (8+3 chars)');
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

  WriteLn('Analysing letter frequencies in ', InFName, ', results in ', OutFName);

  WriteLn(OutF, 'TXTFREQA - Text Letter Frequency Analyser');
  WriteLn(OutF, '(c) 2004 Balint Toth');
  WriteLn(OutF);
  WriteLn(OutF, 'Analysing letter frequencies in ', InFName);
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

  for I := 1 to 26 do
  begin
    Freq[I] := 0;
    StartFreq[I] := 0;
    EndFreq[I] := 0;
    for J := 1 to 26 do
    begin
      DFreq[I, J] := 0;
      DFreqIndex[(I - 1) * 26 + J] := (I - 1) * 26 + (J - 1);
    end;
  end;
  TotalLetter := 0;
  TotalWord := 0;
  TotalDG := 0;
  Prev := ' ';

  while not Eof(InF) do
  begin
    Read(InF, C);
    if Upcase(C) in ['A'..'Z'] then
    begin
      Inc(TotalLetter);
      Inc(Freq[Ord(C) and 31]);
      if Prev in ['A'..'Z'] then
      begin
        Inc(DFreq[Ord(Prev) and 31, Ord(C) and 31]);
        Inc(TotalDG);
      end
      else
      begin
        Inc(TotalWord);
        Inc(StartFreq[Ord(C) and 31]);
      end;
    end { if UpCase }
    else if Prev in ['A'..'Z'] then
      Inc(EndFreq[Ord(Prev) and 31]);
    Prev := UpCase(C);
  end; { while }
  Close(InF);

  for I := 26 * 26 - 1 downto 1 do
    for J := I to 26 * 26 - 1 do
      if DFreq[DFreqIndex[J] div 26 + 1, DFreqIndex[J] mod 26 + 1]
        < DFreq[DFreqIndex[J + 1] div 26 + 1, DFreqIndex[J + 1] mod 26 + 1] then
      begin
        K := DFreqIndex[J];
        DFreqIndex[J] := DFreqIndex[J + 1];
        DFreqIndex[J + 1] := K;
      end;

  WriteLn(OutF, 'Frequency analysis of the text:');
  WriteLn(OutF, '===============================');
  WriteLn(OutF);
  WriteLn(OutF, 'Total number of alphabetic letters: ', TotalLetter);
  WriteLn(OutF, 'Total number of words: ', TotalWord);
  if TotalWord <> 0 then
  begin
    WriteLn(OutF, 'Average word length: ', TotalLetter / TotalWord :6:3, ' letters');
    WriteLn(OutF, 'Average English word length: ', EngLen :4:1, ' letters');
  end;
  if TotalLetter <> 0 then
  begin
    WriteLn(OutF);
    WriteLn(OutF, 'Single letters:');
    WriteLn(OutF, '---------------');
    WriteLn(OutF);
    WriteLn(OutF, 'Letter: Frequency : Average English');
    WriteLn(OutF, '      : [%]       : frequency [%]');
    WriteLn(OutF, '------------------------------------');
    for I := 1 to 26 do
      WriteLn(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
        Freq[I] / TotalLetter * 100 :6:3, '    : ', EngFreq[I] :4:1);
    WriteLn(OutF);

    WriteLn(OutF, 'Starting letters of words:');
    WriteLn(OutF, '--------------------------');
    WriteLn(OutF);
    WriteLn(OutF, 'Letter: Frequency : Average English');
    WriteLn(OutF, '      : [%]       : frequency [%]');
    WriteLn(OutF, '------------------------------------');
    for I := 1 to 26 do
      WriteLn(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
        StartFreq[I] / TotalWord * 100 :6:3, '    : ', EngStartFreq[I] :4:1);
    WriteLn(OutF);

    WriteLn(OutF, 'Ending letters of words:');
    WriteLn(OutF, '--------------------------');
    WriteLn(OutF);
    WriteLn(OutF, 'Letter: Frequency : Average English');
    WriteLn(OutF, '      : [%]       : frequency [%]');
    WriteLn(OutF, '------------------------------------');
    for I := 1 to 26 do
      WriteLn(OutF, '   ', Chr(Ord('A') + I - 1), '  : ',
        EndFreq[I] / TotalWord * 100 :6:3, '    : ', EngEndFreq[I] :4:1);
    WriteLn(OutF);

    WriteLn(OutF, 'Digraphs (Letter pairs):');
    WriteLn(OutF, '------------------------');
    WriteLn(OutF, '  (number of occurences, where digraphs are in row-column order)');
    WriteLn(OutF);
    WriteLn(OutF, 'Total number of digraphs: ', TotalDG);
    WriteLn(OutF);
    Write(OutF, '   ');
    for I := 1 to 26 do
      Write(OutF, ':    ', Chr(Ord('A') + I - 1));
    WriteLn(OutF);
    for I := 1 to 6 * 26 + 3 do
      Write(OutF, '-');
    WriteLn(OutF);
    for I := 1 to 26 do
    begin
      Write(OutF, ' ', Chr(Ord('A') + I - 1), ':');
      for J := 1 to 26 do
        Write(OutF, ' ', DFreq[I, J] :5);
      WriteLn(OutF);
    end;
    WriteLn(OutF);
    WriteLn(OutF, '  (Note: same letter 3 or more times count as several pairs.)');
    WriteLn(OutF);
    WriteLn(OutF, '20 most common digraphs: (in decreasing order)');
    WriteLn(OutF, '------------------------');
    for I := 1 to 20 do
      Write(OutF, ' ', Chr(Ord('a') + DFreqIndex[I] div 26),
        Chr(Ord('a') + DFreqIndex[I] mod 26));
    WriteLn(OutF);
    WriteLn(OutF);
    WriteLn(OutF, '20 most common digraphs in English:');
    WriteLn(OutF, ' ', EngTopDG);
  end;
  Close(OutF);
  WriteLn('Done.');
end.
