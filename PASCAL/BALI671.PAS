{     Szamitastechnika verseny, VII. fordulo
  Toth Balint, Berzsenyi Daniel Gimnazium, 1991.
}
program Bali671;

uses
  Crt;

const
  Tabla : array[0..8] of integer = (1, 2, 4, 8, 16, 32, 64, 128, 256);
  SpecialisKar : string[5] = ' ''-,.';

type
  TempTipus = 0..31;

var
  Szoveg          : string;
  Kodok           : array[1..160] of byte;
  Temp            : array[1..255] of TempTipus;
  I, J, Bit, Byte : integer;
  Valasz          : char;

procedure SzovegToTemp;
begin
  I := 1;
  for J := 1 to Length(Szoveg) do
  begin
    case Szoveg[J] of
      'A'..'Z' : Temp[I] := Ord(Szoveg[J]) - 64;
           ' ' : Temp[I] := 27;
          '''' : Temp[I] := 28;
           '-' : Temp[I] := 29;
           ',' : Temp[I] := 30;
           '.' : Temp[I] := 31;
      else
        Dec(I);
    end; { case }
    Inc(I);
  end; { for }
end; { SzovegToTemp }

procedure TempToKod;
begin
  Bit := 7;
  Byte := 1;
  for J := 1 to I - 1 do
    if Bit > 4 then
    begin
      Kodok[Byte] := Kodok[Byte] + Temp[J] * Tabla[Bit - 4];
      Bit := Bit - 5;
    end { if }
    else
    begin
      Kodok[Byte] := Kodok[Byte] + Temp[J] div Tabla[4 - Bit];
      Inc(Byte);
      Kodok[Byte] := (Temp[J] * Tabla[4 + Bit]) mod 256;
      Bit := Bit + 3;
    end; { else }
end; { TempToKod }

procedure Kodolas;
begin
  WriteLn('A nem megengedett karaktereket nem veszem figyelembe.');
  WriteLn('Kerem a kodolando szoveget!');
  repeat
  until not Keypressed;
  repeat
    ReadLn(Szoveg);
  until Length(Szoveg) > 0;
  WriteLn;
  SzovegToTemp;
  for J := 1 to (5 * I) div 8 + 1 do
    Kodok[J] := 0;
  TempToKod;
  WriteLn('A kodok:');
  for J := 1 to Byte do
  begin
    Write(Kodok[J] : 3);
    Write(',');
  end; { for }
  repeat
  until KeyPressed;
end; { Kodolas }

procedure KodToTemp;
begin
  Bit := 7;
  Byte := 1;
  J := 1;
  repeat
    if Bit > 4 then
    begin
      Temp[J] := (Kodok[Byte] div Tabla[Bit - 4]) mod 32;
      Bit := Bit - 5;
    end { if }
    else
    begin
      Temp[J] := (Kodok[Byte] * Tabla[4 - Bit]) mod 32 +
                  Kodok[Byte + 1] div Tabla[4 + Bit];
      Inc(Byte);
      Bit := Bit + 3;
    end; { else }
    Inc(J);
  until ((Byte = I - 1) and (Bit < 4)) or (Byte = I);
end; { KodToTemp }

procedure TempToSzoveg;
begin
  for I := 1 to J - 1 do
    case Temp[I] of
           0 : Write('*');
       1..26 : Write(Chr(Temp[I] + 64));
      27..31 : Write(SpecialisKar[Temp[I] - 26]);
    end; { case }
end; { TempToSzoveg }

procedure DeKodolas;
begin
  WriteLn('Kodsorozat vege = -1');
  WriteLn('Kerem a visszafejtendo kodokat!');
  I := 1;
  repeat
    ReadLn(J);
    case J of
      0..255 : begin
                 Kodok[I] := J;
                 Inc(I);
               end;
          -1 : ;
      else
        WriteLn('Nem megengedett kod, kerem meg egyszer!');
    end; { case }
  until (J = -1) or (I = 160);
  KodToTemp;
  WriteLn;
  WriteLn('A szoveg:');
  TempToSzoveg;
  WriteLn;
  WriteLn;
  WriteLn('( * = Szoveg vege vagy nulla kod, ami nincs ertelmezve)');
  repeat
  until KeyPressed;
end; { DeKodolas }

begin { Program }
  repeat
    ClrScr;
    WriteLn('K O D O L A S   - Toth Balint, 1991.');
    WriteLn;
    WriteLn('A kulcs:');
    WriteLn;
    WriteLn('  Karakter      Dec      Bin (5 bit)');
    WriteLn('--------------------------------------');
    WriteLn('     A - Z  =  1 - 26   00001 - 11010');
    WriteLn('    Szokoz  =      27           11011');
    WriteLn(' Aposztrof  =      28           11100');
    WriteLn('   Kotojel  =      29           11101');
    WriteLn('    Vesszo  =      30           11110');
    WriteLn('      Pont  =      31           11111');
    WriteLn;
    Write('Kodolas, dekodolas vagy vege? (k/d/v) ');
    Valasz := ReadKey;
    WriteLn(Valasz);
    WriteLn;
    case Valasz of
      'k', 'K' : Kodolas;
      'd', 'D' : DeKodolas;
    end;
  until Valasz in ['v', 'V'];
end. { Program }