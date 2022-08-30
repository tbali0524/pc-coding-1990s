{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B†lint       }
{                                                }
{************************************************}

unit CKif; { KifejezÇs kiÇrtÇkelÇs }

{$B-}
interface

uses CGlobals, CMemTool, CSzimb;

const
  ECOffset     = 40; { State hibak¢d offset hibaÅzenet tîmbindexhez }
 { Hibak¢dok }
  erNone       =  0; { nincs hiba }
  erOpenAsm    = 23; { forr†sf†jl-t nem sikerÅlt megnyitni }
  erExp        = 41; { szintaktikus hiba a kifejezÇsben }
  erOverflow   = 42; { decim†lis konstans t£l nagy a kifejezÇsben }
  erZJel       = 43; { lez†ratlan z†r¢jel a kifejezÇsben }
  erExpOp      = 44; { hi†nyz¢ operandus a kifejezÇsben }
  erUndef      = 45; { defini†latlan azonos°t¢ a kifejezÇsben }
  erUresExp    = 46; { hi†nyz¢ kifejezÇs }
  erRedef      = 47; { lÇtezì cimke vagy konstans £jradefini†l†sa }
  erSyntax     = 48; { szintaktikus hiba }
  erDivZero    = 49; { null†val val¢ oszt†s }
  erCimzes     = 50; { a c°mzÇsm¢d nem megengedett az utas°t†shoz }
  erOpByte     = 51; { byte operandus helyett word-ot kapott }
  erBranch     = 52; { megengedettnÇl nagyobb ugr†s relat°v c°mzÇsnÇl }
  erDir        = 53; { nemlÇtezì ford°t¢i direkt°va }
  erDirPar     = 54; { hib†s direkt°va paramÇter }
  erIncl       = 55; { hiba az INCLUDE f†jlban }
  erInclLoop   = 56; { hurok az INCLUDE h°v†sokban }
  erOpenIncl   = 57; { INCLUDE f†jlt nem sikerÅlt megnyitni }
  erGotoLoop   = 58; { hurok .GOTO vagy .IF-fel h°v†sokban }
  erSzimb      = 81; { belsì haszn†latra: szimb¢lum a kifejezÇsben }

  { Szimb¢lumnÇvben 1. helyen megengedett karakterek halmaza }
  SzimbElsoKar: Set of Char = ['A'..'Z', '_'];
  { Szimb¢lumnÇvben 2. helytìl megengedett karakterek halmaza }
  SzimbKar: Set of Char = ['A'..'Z', '0'..'9', '_'];

type

 { KifejezÇs kiÇrtÇkelì objektum szimb¢lumt†bl†val }
  PKif = ^TKif;
  TKif = object
    Cimke: PSzimb;      { cimke t†bl†zat }
    Konst: PSzimb;      { konstans t†bl†zat }
    Valt: PValt;        { v†ltoz¢ t†bl†zat }
    HelyiCimke: PHelyi; { helyi cimke t†bl†zat }
    HelyiKonst: PHelyi; { helyi konstans t†bl†zat }
    State: Byte;        { hibak¢d (erXXXX konstansok) }
    constructor Init;
    destructor Done; virtual;
    function Kiertekel(AS: String; PC: Word; LehetSzimb: Boolean;
      LGL: Word): Word;
  end; { TKif }

{ String -> Word konverzi¢ kÅlînbîzì form†tumok esetÇn }
{ Az elsì karakter sz†mjegy, $, % vagy " }
{ Hiba esetÇn State erOverflow vagy erExp lesz, egyÇbkÇnt v†ltozatlan marad }
function DecSzam(var S: String; var State: Byte): Word;
function HexSzam(var S: String; var State: Byte): Word;
function BinSzam(var S: String; var State: Byte): Word;
function AscSzam(var S: String; var State: Byte): Word;

implementation

{ ================================================================== }
{ Decim†lis konstans }
function DecSzam(var S: String; var State: Byte): Word;
var
  I, K: Integer;
  W: LongInt;
begin
  I := 1;
  while (I <= Length(S)) and (I <= 5) and (S[I] in ['0'..'9']) do
    Inc(I);
  Val(Copy(S, 1, I - 1), W, K);
  if (K = 0) and (W < $10000) then
  begin
    DecSzam := W;
    Delete(S, 1, I - 1)
  end
  else
    State := erOverflow;
end; { DecSzam }

{ ================================================================== }
{ Hexadecim†lis konstans }
function HexSzam(var S: String; var State: Byte): Word;
var
  B: Byte;
  W, I: Word;
begin
  if Length(S) = 1 then
    State := erExp
  else
  begin
    W := 0;
    I := 1;
    repeat
      Inc(I);
      B := Pos(S[I], HexJegy);
      if B > 0 then
        W := W shl 4 or (B - 1);
    until (I = Length(S)) or (I = 5) or (B = 0);
    if B = 0 then
      Delete(S, 1, I - 1)
    else
      Delete(S, 1, I);
    HexSzam := W;
    if (I = 2) and (B = 0) then
      State := erExp;
  end; { else }
end; { HexSzam }

{ ================================================================== }
{ Bin†ris konstans }
function BinSzam(var S: String; var State: Byte): Word;
var
  W, I: Word;
  Vege: Boolean;
begin
  if Length(S) = 1 then
    State := erExp
  else
  begin
    Vege := False;
    W := 0;
    I := 1;
    repeat
      Inc(I);
      case S[I] of
        '0': W := W shl 1;
        '1': W := W shl 1 or 1
        else
          Vege := True;
      end;
    until (I = Length(S)) or (I = 17) or Vege;
    if Vege then
      Delete(S, 1, I - 1)
    else
      Delete(S, 1, I);
    BinSzam := W;
    if (I = 2) and Vege then
      State := erExp;
  end; { else }
end; { BinSzam }

{ ================================================================== }
{ PC Ascii karakter konstans }
function AscSzam(var S: String; var State: Byte): Word;
begin
  if (Length(S) < 3) or (S[3] <> '"') then
    State := erExp
  else
  begin
    AscSzam := Ord(S[2]);
    Delete(S, 1, 3);
  end;
end; { AscSzam }

{ ================================================================== }
{ CBM Ascii karakter konstans }
function PetScSzam(var S: String; var State: Byte): Word;
begin
  if (Length(S) < 3) or (S[3] <> '''') then
    State := erExp
  else
  begin
    PetScSzam := PC2CBMAscii(Ord(S[2]));
    Delete(S, 1, 3);
  end;
end; { PetScSzam }

{ ================================================================== }
{ TKif objektum }

constructor TKif.Init;
begin
  New(Cimke, Init);
  New(Konst, Init);
  New(Valt, Init);
  New(HelyiCimke, Init);
  New(HelyiKonst, Init);
  State := erNone;
end; { Init }

destructor TKif.Done;
begin
  Dispose(Cimke, Done);
  Dispose(Konst, Done);
  Dispose(Valt, Done);
  Dispose(HelyiCimke, Done);
  Dispose(HelyiKonst, Done);
end; { Done }

{ ================================================================== }
{ Sztring kifejezÇs kiÇrtÇkelÇse }
{ * = PC ; Ha LehetSzimb = False, akkor szimb¢lum esetÇn State = erSzimb }
{ LGL utols¢ glob†lis azonos°t¢ c°me (helyi cimkÇkhez) }
function TKif.Kiertekel(AS: String; PC: Word; LehetSzimb: Boolean;
  LGL: Word): Word;

{ Azonos°t¢ (szimb¢lumnÇv) }
function KiertAzon(var S: String): Word;
var
  I: Word;
  SzNev: AzonT;
  P: PElem;
begin
  I := 1;
  while (I <= Length(S)) and (I <= AzonHossz) and (S[I] in SzimbKar) do
    Inc(I);
  SzNev := Copy(S, 1, I - 1);
  Delete(S, 1, I - 1);
  if SzNev[1] = '_' then
  begin
    P := HelyiCimke^.Keres(SzNev, LGL);
    if P = Nil then
    begin
      P := HelyiKonst^.Keres(SzNev, LGL);
      if P = Nil then
        State := erUndef;
    end;
  end { if S[1] }
  else
  begin
    P := Cimke^.Keres(SzNev, 0);
    if P = Nil then
    begin
      P := Konst^.Keres(SzNev, 0);
      if P = Nil then
      begin
        P := Valt^.Keres(SzNev, 0);
        if P = Nil then
          State := erUndef;
      end;
    end;
  end; { if S[1] else }
  if State <> erUndef then
    KiertAzon := P^.Tart;
end; { KiertAzon }

{ ================================================================== }
{ Z†r¢jel }
function KiertZJel(var S: String): Word;
var
  I,
  J: Integer;           { egym†sba †gyazott z†r¢jelek sz†ma }
begin
  J := 1;
  I := 2;
  while (I <= Length(S)) and (J > 0) do
  begin
    case S[I] of
      '(': Inc(J);
      ')': Dec(J);
    end;
    Inc(I);
  end; { while }
  if J = 0 then
  begin
    KiertZJel := Kiertekel(Copy(S, 2, I - 3), PC, LehetSzimb, LGL);
    Delete(S, 1, I - 1);
  end
  else
    State := erZJel;
end; { KiertZJel }

{ ================================================================== }
{ Mñveleti jel nÇlkÅli konstans (vagy z†r¢jeles kifejezÇs) }
function KiertKonst(var S: String): Word;
begin
  if S[1] in SzimbElsoKar then
    if LehetSzimb then
      KiertKonst := KiertAzon(S)
    else
      State := erSzimb
  else
    case S[1] of
      '0'..'9': KiertKonst := DecSzam(S, State);
      '$': KiertKonst := HexSzam(S, State);
      '%': KiertKonst := BinSzam(S, State);
      '"': KiertKonst := AscSzam(S, State);
      '''': KiertKonst := PetScSzam(S, State);
      '(': KiertKonst := KiertZJel(S);
      '*': begin
             KiertKonst := PC;
             Delete(S, 1, 1);
           end;
      else
        State := erExp;
    end; { case }
end; { KiertKonst }

{ ================================================================== }
{ Prefixummal (egyoperandus£ mñvelettel) rendelkezì konstans }
function KiertPKonst(var S: String): Word;
var
  C: Char;
begin
  if S = '' then
    State := erExpOp
  else
  begin
    C := S[1];
    if C in ['>', '<', '~', '-'] then
      Delete(S, 1, 1);
    case C of
      '-': KiertPKonst := Word(-KiertPKonst(S));
      '~': KiertPKonst := not KiertPKonst(S);
      '<': KiertPKonst := KiertPKonst(S) and $00FF;
      '>': KiertPKonst := KiertPKonst(S) shr 8;
      else
        KiertPKonst := KiertKonst(S);
    end; { case }
  end; { else }
end; { KiertPKonst }

{ ================================================================== }
{ TKif.Kiertekel }
var
  S: String;
  C1, C2: Char;
  W1, W2: Word;
begin
  S := AS;
  W1 := KiertPKonst(S);
  if State = erExpOp then
    State := erUresExp;
  while (Length(S) > 0) and (State = erNone) do
  begin
    C1 := S[1];
    Delete(S, 1, 1);
    C2 := S[1];
    if ((C1 = '<') and ((C2 = '<') or (C2 = '=') or (C2 = '>'))) or
      ((C1 = '>') and ((C2 = '>') or (C2 = '='))) then
        Delete(S, 1, 1);
    W2 := KiertPKonst(S);
    if (State = erNone) then
      case C1 of
        '+': W1 := W1 + W2;
        '-': W1 := (((LongInt(W1) or $10000)) - LongInt(W2)) and LongInt($0FFFF);
        '*': W1 := W1 * W2;
        '/': if W2 <> 0 then
               W1 := W1 div W2
             else
               State := erDivZero;
        '%': if W2 <> 0 then
               W1 := W1 mod W2
             else
               State := erDivZero;
        '&': W1 := W1 and W2;
        '|': W1 := W1 or W2;
        '^': W1 := W1 xor W2;
        '<': case C2 of
               '<': W1 := W1 shl W2;
               '=': if W1 <= W2 then
                      W1 := 1
                    else
                      W1 := 0;
               '>': if W1 <> W2 then
                      W1 := 1
                    else
                      W1 := 0;
                else
                  if W1 < W2 then
                    W1 := 1
                  else
                    W1 := 0;
              end; { case C2 }
        '>': case C2 of
               '>': W1 := W1 shr W2;
               '=': if W1 >= W2 then
                      W1 := 1
                    else
                      W1 := 0;
                else
                  if W1 > W2 then
                    W1 := 1
                  else
                    W1 := 0;
              end; { case C2 }
        '=': if W1 = W2 then
               W1 := 1
             else
               W1 := 0;
        else
          State := erExp;
      end; { case }
  end; { while }
  Kiertekel := W1;
end; { Kiertekel }

end.