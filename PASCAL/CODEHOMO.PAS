{ monoalphabetic substitution decipher with homophones }
{ (c) T¢th B lint, 2002 }

program CodeHomo;

var
  InF: Text;
  InFName: String;
  OutF: Text;
  OutFName: String;
  KeyF: Text;
  KeyFName: String;
  C: Char;
  S: String;
  I, J, N: Integer;
  Prev: Integer;
  TotalLetter: Integer;
  B: Boolean;
  Key: Array[0..999] of Char;
  Freq: Array[1..26] of Integer;
  DFreq: Array[1..26, 1..26] of Integer;
  CodeFreq: Array[0..999] of Integer;

const
  EngFreq: Array[1..26] of Real =
   (8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4,
    6.7, 7.5, 1.9, 0.1,  6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1);

{ Sztring elej‚n l‚v“ sz¢k”z”k, vessz“k ‚s TAB-ok kiv‚tele }
procedure BalraHuz(var S: String);
var
  I: Integer;
begin
  I := 1;
  while (I <= Length(S)) and (S[I] in [' ', ',', #9]) do
    Inc(I);
  if I > 1 then
    Delete(S, 1, I - 1);
end; { BalraHuz }

{ Sztring elej‚n l‚v“ max 3 jegyu poz egesz sz m kiv‚tele }
function GetSzam(var S: String): Integer;
var
  I, K, W: Integer;
begin
  I := 1;
  while (I <= Length(S)) and (I <= 3) and (S[I] in ['0'..'9']) do
    Inc(I);
  Val(Copy(S, 1, I - 1), W, K);
  if (K = 0) and (W < 1000) then
  begin
    GetSzam := W;
    Delete(S, 1, I - 1);
  end
  else
    GetSzam := -1;
end; { GetSzam }

function TagSzam(I: Integer): String;
var
  S: String;
begin
  Str(I, S);
  while Length(S) < 3 do
    S := '0' + S;
  TagSzam := S;
end; { GetSzam }

begin { Main }
  WriteLn('CODEHOMO - homophonic monoalphabetic substitution decipher');
  WriteLn('(c) 2002 Balint Toth');
  WriteLn;
  if ParamCount <> 3 then
  begin
    WriteLn('Usage: CODEMONO keyfile inputfile outputfile');
    WriteLn;
    WriteLn('Format of keyfile:');
    WriteLn('- separate line for each letter of the cleartext alphabet:');
    WriteLn('    clearletter  code1 code2 ...');
    WriteLn;
    WriteLn('- Valid codes: numbers 0...999 (use * for unknown code)');
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
  for I := 0 to 999 do
  begin
    Key[I] := '*';
    CodeFreq[I] := 0;
  end;
  for I := 1 to 26 do
  begin
    ReadLn(KeyF, S);
    BalraHuz(S);
    if (Length(S) = 0) or not (Upcase(S[1]) in ['A'..'Z']) then
    begin
      WriteLn('Wrong keyfile format.');
      Halt(3);
    end;
    Delete(S, 1, 1);
    BalraHuz(S);
    while (Length(S) <> 0) and (S[1] <> '*') do
    begin
      J := GetSzam(S);
      if J >= 0 then
        Key[J] := Chr(Ord('a') + I - 1)
      else
      if (J = -1) or ((Length(S) <> 0) and not (S[1] in [' ', ',', #9])) then
      begin
        WriteLn('Wrong keyfile format.');
        Halt(3);
      end;
      BalraHuz(S);
    end;
  end; { for }
  Close(KeyF);

  for I := 1 to 26 do
  begin
    Freq[I] := 0;
    for J := 1 to 26 do
      DFreq[I, J] := 0;
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

  WriteLn(OutF, 'CODEHOMO - homophonic monoalphabetic substitution decipher');
  WriteLn(OutF, '(c) 2002 Balint Toth');
  WriteLn(OutF);
  WriteLn(OutF, 'Deciphering ', InFName, ' to ', OutFName,
    ' using key from ', KeyFName, ' ...');
  WriteLn(OutF);

  WriteLn(OutF, 'Using substitution key:');
  WriteLn(OutF, '=======================');
  for I := 1 to 26 do
  begin
    Write(OutF, '  ', Chr(Ord('a') + I - 1),' ->');
    B := False;
    for J := 0 to 999 do
    begin
      if UpCase(Key[J]) = Chr(Ord('A') + I - 1) then
      begin
        Write(OutF, ' ', TagSzam(J));
        B := True;
      end;
    end;
    if not B then
      Write(OutF, ' *');
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
  Prev := -1;
  Write(OutF, '  1 : ');
  N := 1;
  S := '';
  while not Eof(InF) do
  begin
    Read(InF, C);
    case Upcase(C) of
      '0'..'9' :
        S := S + C;
      ' ', ',', #13 :
        begin
          if S <> '' then
          begin
            I := GetSzam(S);
            if (I <> -1) and (S = '') then
            begin
              Write(OutF, Key[I]);
              Inc(TotalLetter);
              if Key[I] <> '*' then
              begin
                Inc(Freq[Ord(Key[I]) and 31]);
                if (Prev >= 0) and (Key[Prev] <> '*') then
                  Inc(DFreq[Ord(Key[Prev]) and 31, Ord(Key[I]) and 31]);
              end;
              Inc(CodeFreq[I]);
              S := '';
              Prev := I;
            end
            else
            begin
              Write(OutF, S);
              Prev := -1;
            end;
          end; { if S }
          if C = #13 then
          begin
            WriteLn(OutF);
            Inc(N);
            Write(OutF, N :3, ' : ');
          end;
        end;
      #10 : ;
      else
        Write(OutF, C);
    end;
  end; { while }
  Close(InF);

  WriteLn(OutF);
  WriteLn(OutF);
  WriteLn(OutF, 'Frequency analysis of the ciphertext: (worthless if real homophones)');
  WriteLn(OutF, '=====================================');
  WriteLn(OutF);
  WriteLn(OutF, ' Code : Occurences');
  WriteLn(OutF, '-------------------');
  if TotalLetter <> 0 then
    for I := 0 to 999 do
      if CodeFreq[I] <> 0 then
        WriteLn(OutF, ' ', TagSzam(I), '  : ', CodeFreq[I] :5);

  WriteLn(OutF);
  WriteLn(OutF, 'Frequency analysis of the assumed cleartext:');
  WriteLn(OutF, '============================================');
  WriteLn(OutF);
  WriteLn(OutF, 'Single letters:');
  WriteLn(OutF);
  WriteLn(OutF, 'Clear  : Frequency in : Average English');
  WriteLn(OutF, 'letter : cleartext [%]: frequency [%]');
  WriteLn(OutF, '----------------------------------------');
  for I := 1 to 26 do
  begin
    if TotalLetter <> 0 then
      Write(OutF, '   ', Chr(Ord('a') + I - 1), '   : ',
        100 * Freq[I] / TotalLetter :5:3)
    else
      Write(OutF, '   ', Chr(Ord('a') + I - 1), '   : ',
        Freq[I] :5);
    WriteLn(OutF, '          ', EngFreq[I] :4:1);
  end;
  WriteLn(OutF, '(Total number of ciphered letters: ', TotalLetter, ')');
  WriteLn(OutF);
  WriteLn(OutF, 'Letter pairs: (total occurences in row-column order)');
  WriteLn(OutF);
  Write(OutF, '   ');
  for I := 1 to 26 do
    Write(OutF, ':  ', Chr(Ord('a') + I - 1));
  WriteLn(OutF);
  for I := 1 to 4 * 26 + 3 do
    Write(OutF, '-');
  WriteLn(OutF);
  for I := 1 to 26 do
  begin
    Write(OutF, ' ', Chr(Ord('a') + I - 1), ':');
    for J := 1 to 26 do
      Write(OutF, ' ', DFreq[I, J] :3);
    WriteLn(OutF);
  end;
  WriteLn(OutF, '(Note: same letter 3 or more times count as several pairs.)');
  Close(OutF);
  WriteLn('Done.');
end.
