{ Shuffle decipher }
{ (c) T¢th B lint, 2004 }

program Shuffle;

const
  MaxKeyLen = 100;

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
  B: Boolean;
  KeyLen: Integer;
  Key: Array[1..MaxKeyLen] of Integer;

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

{ Sztring elej‚n l‚v“ max 2 jegyu poz egesz sz m kiv‚tele }
function GetSzam(var S: String): Integer;
var
  I, K, W: Integer;
begin
  I := 1;
  while (I <= Length(S)) and (I <= 2) and (S[I] in ['0'..'9']) do
    Inc(I);
  Val(Copy(S, 1, I - 1), W, K);
  if (K = 0) and (W < 100) then
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
  while Length(S) < 2 do
    S := '0' + S;
  TagSzam := S;
end; { GetSzam }

begin { Main }
  WriteLn('SHUFFLE - letter order shuffle decipher');
  WriteLn('(c) 2004 Balint Toth');
  WriteLn;
  if ParamCount <> 3 then
  begin
    WriteLn('Usage: SHUFFLE keyfile inputfile outputfile');
    WriteLn;
    WriteLn('Format of keyfile:');
    WriteLn(' 1st line  cleartext letter position ''01 02 03...''');
    WriteLn(' 2nd line  letter position in ciphertext, e.g .''03 01 02...''');
    WriteLn;
    WriteLn(' ( * is also possible for unshuffled letter)');
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
  for I := 1 to MaxKeyLen do
  begin
    Key[I] := I;
  end;
  KeyLen := 0;
  ReadLn(KeyF, S);
  ReadLn(KeyF, S);
  BalraHuz(S);
  while (Length(S) <> 0) and (S[1] <> ';') do
  begin
    if S[1] = '*' then 
      J := KeyLen + 1
    else
      J := GetSzam(S);
    if (J >= 1) and (J <= MaxKeyLen) then
    begin
      Inc(KeyLen);
      Key[KeyLen] := J;
    end
    else if (J = -1) or (J > MaxKeyLen) or
        ((Length(S) <> 0) and not (S[1] in [' ', ',', #9])) then
    begin
      WriteLn('Wrong keyfile format.');
      Halt(3);
    end;
    BalraHuz(S);
  end;
  Close(KeyF);

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

  WriteLn(OutF, 'SHUFFLE - letter order shuffle decipher');
  WriteLn(OutF, '(c) 2004 Balint Toth');
  WriteLn(OutF);
  WriteLn(OutF, 'Deciphering ', InFName, ' to ', OutFName,
    ' using key from ', KeyFName, ' ...');
  WriteLn(OutF);

  WriteLn(OutF, 'Using key:');
  WriteLn(OutF, '==========');
  for I := 1 to KeyLen do
    Write(OutF, '  ', TagSzam(I));
  WriteLn(OutF);
  for I := 1 to KeyLen do
  begin
    Write(OutF, '  ', TagSzam(Key[I]))
  end;
  WriteLn(OutF);
  WriteLn(OutF);

  WriteLn(OutF, 'Ciphertext (input):');
  WriteLn(OutF, '===================');
  WriteLn(OutF);
  while not Eof(InF) do
  begin
    Read(InF, C);
    Write(OutF, C);
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
  N := 0;
  S := '';
  while not Eof(InF) do
  begin
    Read(InF, C);
    case Upcase(C) of
      '0'..'9', 'A'..'Z' :
        begin 
          S := S + C;
          Inc(N);
          if N = KeyLen then
          begin
            for I := 1 to KeyLen do
              Write(OutF, S[Key[I]]);
            S := '';
            N := 0;
          end;
        end; 
      ' ', #9, #13, #10:
              Write(OutF, C);
      else
        Write(OutF, C);
    end;
  end; { while }
  if S <> '' then
    for I := 1 to KeyLen do
      if Key[I] <= Length(S) then
        Write(OutF, S[Key[I]])
      else
        Write(OutF, ' ');
  Close(InF);
  WriteLn(OutF);
  Close(OutF);
  WriteLn('Done.');
end.
