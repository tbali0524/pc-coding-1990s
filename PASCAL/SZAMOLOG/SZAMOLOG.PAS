{ Sz?m?t?g?p labor - h?zi feladat
  T?th B?lint
  B M E Villamosm?rn?ki ?s Inform. Kar, M?szaki Informatika Szak, 3. tank?r
  I. ?vfolyam, 1. f?l?v
  1992

  SZ?MOL?G?P

  ENGLISH LANGUAGE EXTENSION by T?th B?lint, 1995
  Compile with -dENGLISH to get all messages in english.
}
program SzamoloGep;

{$B-}              { r?vid logikai ki?rt?kel?s (csak ?gy m?k?dik j?l) }
{$N-,E-}           { mat.koproc. kikapcsolva }

uses Crt, Dos;
{ Dos unitb?l: Registers t?pus ?s Intr elj?r?s (eg?rkezel?shez) }

const

 { ReadKey billenty?k?dok }
  kbLeft  = #75;        { #0 ut?n }
  kbRight = #77;
  kbUp    = #72;
  kbDown  = #80;
  kbPgUp  = #73;
  kbPgDn  = #81;
  kbHome  = #71;
  kbEnd   = #79;
  kbAltQ  = #16;
  kbAltX  = #45;
  kbBackSpace = #8;     { els? ReadKey-re }
  kbEnter = #13;
  kbEsc   = #27;

  Beep    = #7;         { hangjelz?s }

  SzamSzel = 21;        { sz?mkijelz? sz?less?ge }
  MaxBill = 48;         { gombok sz?ma }
  RajzSor = 8;          { h?ny sor gomb van }
  RajzOszlop = 6;       { h?ny gomb van egy sorban }

 { sz?mol?g?p gombk?dok }
  biEsc  = 1;  biNyit = 2;  biCsuk = 3;  biBS   = 4;  biClr  = 5;  biAC   = 6;
  biASin = 7;  biACos = 8;  biATan = 9;  biExp10= 10; biExpE = 11; biRad  = 12;
  biSin  = 13; biCos  = 14; biTan  = 15; biLg   = 16; biLn   = 17; biDeg  = 18;
  bi7    = 19; bi8    = 20; bi9    = 21; biGyok = 22; biNGyok= 23; biFakt = 24;
  bi4    = 25; bi5    = 26; bi6    = 27; biNegyz= 28; biHatv = 29; biReci = 30;
  bi1    = 31; bi2    = 32; bi3    = 33; biSzor = 34; biPer  = 35; biMem  = 36;
  bi0    = 37; biPont = 38; biExp  = 39; biMeg  = 40; biBol  = 41; biMPlu = 42;
  biRan  = 43; biPi   = 44; biDisp = 45; biPlMi = 46; biEgye = 47; biRM   = 48;

 { "forr? billenty?k/kulcsok" }
  HotKey: String[MaxBill] = ' () CA     R  TGLD789? !456^? 123*/ 0.E+- #PS\=M';

 { Gombtipusok elemei }
  { sz?mbevitel ?s szerkeszt?s }
  SzamBevBill: Set of Byte = [biBS, biClr, bi0, bi1, bi2, bi3, bi4, bi5, bi6,
    bi7, bi8, bi9, biPont, biExp, biRan, biPi, biRM];
  { m?veleti jelek }
  MuvBill: Set of Byte = [biMeg, biBol, biSzor, biPer, biHatv, biNGyok];
  { be?p?tett f?ggv?nyek }
  FuggvBill: Set of Byte = [biReci, biFakt, biASin..biDeg, biNegyz, biGyok];

  SPC = '                     ';       { seg?dsztring }

type
 { A precedenciaszab?lyok helyes alkalmaz?s?hoz az eddig bevitt sz?mokat ?s
   m?veleteket egy l?ncolt list?ban t?roljuk. Ha az ?j m?velet priorit?sa
   kisebb, minta az el?z??, akkor elv?gezz?k a lista tetej?n l?v? m?veleteket,
   ha nagyobb, akkor csak felvessz?k az ?j elemet a list?ra.
 }
 { a l?ncolt lista egy eleme }
  PElemT = ^ElemT;
  ElemT = Record
    ZJel: Byte;         { nyit? z?r?jelek }
    Szam: Real;         { operandus (a m?velet el?tti) }
    Muv: Byte;          { m?velet k?dja ( 1=+, 2=-, 3=*, 4=/, 5=^, 6=?? ) }
    Prev: PElemT;       { el?z? elemre mutat }
  end;

var
  KS: String[SzamSzel]; { kijelz? }
  Mem: Real;            { mem?ria }
  VanMem,               { van-e a mem?ri?ban valami }
  VanEger,              { haszn?lhat?-e az eg?r }
  NormKMod,             { norm?l kijelz? m?dban vagyunk-e (False = fixpontos) }
  TorolKep, { t?r?lni kell-e a kijelz?t a k?vetkez? sz?mszerkeszt? bill.-re }
  VoltMuv,              { el?z? billenty? m?velet volt-e }
  VoltHiba,             { aritmetikai hiba ki?rt?kel?s k?zben }
  RendesBef: Boolean;   { ha kil?p?skor False, akkor Runtime error }
  OldExitProc: Pointer; { eredeti kil?p?si elj?r?s }
  Regs: Registers;      { regiszterek az eg?rkezel? megszak?t?sok h?v?s?hoz }
  P: PElemT;            { legfels? elem a l?ncolt list?ban }

procedure BillRajz;     { Sz?mol?g?p kirajzol?sa }
const
  VonalKTeto = '???????????????????????ͻ'; { seg?dsztringek }
  VonalKep   = '?                       ?';
  VonalTeto  = '???????????????????????͹';
  VonalKozep = '???????????????????????͹';
  VonalAlj   = '???????????????????????ͼ';

begin
  TextBackGround(Black);
  ClrScr;
  Window(27, 1, 80, 25);
  TextColor(Cyan);
{$IFDEF ENGLISH}
  WriteLn('                     BALI''S CALC');
  WriteLn;
  WriteLn('         Simple Scientific Calculator Program');
  WriteLn;
  TextColor(LightGray);
  WriteLn('                  HELP IN NUTSHELL:');
  WriteLn('CURSOR MOVEMENT: Arrows, Home, End, PgUp/Dn & MOUSE');
  WriteLn('PRESSING BUTTON: Enter or left click with mouse');
  WriteLn(' (Many buttons have a hotkey (E.g. T = Tan) )');
  WriteLn('ENTERING A NUMBER: digits, decimal point, EXP, +/-');
  WriteLn(' < (BackSpace): erase last digit, C: clear display');
  WriteLn(' Ran: random number 0.000-0.999, RM (memory), Pi');
  WriteLn('OPERATOR PRECEDENCE: parentheses ( ), function call,');
  WriteLn(' n-th power and root (x? ?s ??x) (on positive base!),');
  WriteLn(' multiply & divide (* /), add & subtract (+ -)');
  WriteLn('FUNCTIONS:  x?, ?x (square, sqruare root), 1/x,');
  WriteLn(' Sin, Cos, Tan, -1 (inverses) (EVERYTHING IN RADIAN!)');
  WriteLn(' Rad, Deg (conversions), x! (factorial)');
  WriteLn(' Lg, -1, Ln, e^x (base 10 & natural log. & expon.fn)');
  WriteLn('MEMORY:  Mem: store, M+ adding, RM: read');
  WriteLn('SCI: normal/scientific display');
  WriteLn('AC:  reset everything,  ESC:  Quit program');
  TextColor(Cyan);
  WriteLn('          (See BALICALC.DOC for more information.)');
  Window(1, 1, 80, 25);
  GoToXY(1, 24);
  WriteLn('Copyright (c) 1992,95 by B?lint T?th  - This program is freeware');
{$ELSE}
  WriteLn('                     SZ?MOL?G?P');
  WriteLn;
  WriteLn('          Tudom?nyos sz?mol?g?p szimul?ci?');
  WriteLn;
  TextColor(LightGray);
  WriteLn('                 SEG?TS?G DI?H?JBAN:');
  WriteLn('KURZORMOZGAT?S:  Nyilak, Home, End, PgUp/Dn, eg?rrel');
  WriteLn('GOMB LENYOM?SA:  Enter vagy bal eg?rgomb');
  WriteLn(' (Sok gomb k?zvetlen?l is el?rhet?. (Pl. T = Tan) )');
  WriteLn('SZ?M BEVITELE:  sz?mjegyek, tizedespont, EXP, +/-');
  WriteLn(' < (BackSpace): utols? jegy t?rl?se, C: sz?m t?rl?se');
  WriteLn(' Ran: v?letlensz?m 0.000-0.999, RM (mem?ria), Pi');
  WriteLn('M?VELETI SORREND:  z?r?jelek ( ), f?ggv?nyh?v?s,');
  WriteLn(' hatv?nyoz?s ?s n. gy?k (x? ?s ??x) (poz. alapra!),');
  WriteLn(' szorz?s ?s oszt?s (* /), ?sszead?s ?s kivon?s (+ -)');
  WriteLn('F?GGV?NYEK:  x?, ?x (n?gyzet, n?gyzetgy?k), 1/x,');
  WriteLn(' Sin, Cos, Tan, -1 (inverzek) (minden radi?nban!)');
  WriteLn(' Rad, Deg (fok <=> rad v?lt?s), x! (faktori?lis)');
  WriteLn(' Lg, -1, Ln, e^x (10 ?s e alap? logaritmus ?s exp.fv)');
  WriteLn('MEM?RIA:  Mem: bevitel, M+ hozz?ad?s, RM: ki?r?s');
  WriteLn('SCI: norm?l/tudom?nyos kijelz?');
  WriteLn('AC:  Vissza?ll?s alaphelyzetbe,  ESC:  Kil?p?s');
  TextColor(Cyan);
  WriteLn('              (B?vebb le?r?s a SZAMOLOG.DOC f?jlban.)');
  Window(1, 1, 80, 25);
  GoToXY(1, 24);
  WriteLn('Copyright (c) 1992  T?th B?lint');
{$ENDIF}
  TextBackGround(Cyan);
  TextColor(Black);
  GoToXY(1, 2);
  WriteLn(VonalKTeto);
  WriteLn(VonalKep);
  WriteLn(VonalKep);
  WriteLn(VonalTeto);
  WriteLn('?ESC? ( ? ) ? < ? C ? AC?');
  WriteLn(VonalKozep);
  WriteLn('? -1? -1? -1? -1?e^x?Rad?');
  WriteLn(VonalKozep);
  WriteLn('?Sin?Cos?Tan?Lg ?Ln ?Deg?');
  WriteLn(VonalKozep);
  WriteLn('? 7 ? 8 ? 9 ? ?x???x? x!?');
  WriteLn(VonalKozep);
  WriteLn('? 4 ? 5 ? 6 ? x?? x??1/x?');
  WriteLn(VonalKozep);
  WriteLn('? 1 ? 2 ? 3 ? * ? / ?Mem?');
  WriteLn(VonalKozep);
  WriteLn('? 0 ? . ?EXP? + ? - ?M+ ?');
  WriteLn(VonalKozep);
  WriteLn('?Ran?Pi ?SCI?+/-? = ?RM ?');
  WriteLn(VonalAlj);
  TextBackGround(LightGray);
  GoToXY(3, 3);
  Write(SPC);
end; { BillRajz }

procedure SzamKep(R: Real);         { Sz?m berak?sa KS sztringbe (form?z?s) }
var
  I,
  K: Integer;           { kitev? hossza (seg?dv?ltoz?) }
begin
  Str(R, KS);
  if NormKMod then
  begin
    Val(Copy(KS, Length(KS) - 2, 3), I, K);
    if (I >= -2) and (I <= 9) then
    begin
      Delete(KS, Length(KS) - 3, 4);   { kitev? kiv?tele }
      Delete(KS, 3, 1);                { tizedespont kiv?tele }
      if I = -2 then
        KS := KS[1] + '0.0' + Copy(KS, 2, 255)
      else if I = -1 then
        KS := KS[1] + '0.' + Copy(KS, 2, 255)
      else
        Insert('.', KS, 3 + I);        { tizedespont berak?sa ?j helyre }
      K := 0;
    end
    else
      if KS[Length(KS) - 1] = '0' then { egyjegy? kitev? }
      begin
        Delete(KS, Length(KS) - 1, 1);
        K := 3;
      end
      else
        K := 4;
    while KS[Length(KS) - K] = '0' do  { f?l?s null?k kiv?tele }
      Delete(KS, Length(KS) - K, 1);
    if KS[Length(KS) - K] = '.' then   { tizedespont kiv?tele, ha nem kell }
      Delete(KS, Length(KS) - K, 1);
  end; { if NormKMod }
  if KS[1] = ' ' then                  { kezd? sz?k?z kiv?tele poz. sz?mokn?l }
    Delete(KS, 1, 1);
end; { SzamKep }

procedure Kijelzo;      { Kijelz? friss?t?se }
begin
  GotoXY(3, 3);
  if VanMem then
    Write(' M   ')
  else
    Write('     ');
  if NormKMod then
    Write('   ')
  else
    Write('SCI');
  GotoXY(3, 4);
  Write(Copy(SPC, 1, SzamSzel - Length(KS)), KS);
end; { Kijelzo }

procedure UjElem;       { ?j elem felv?tele a l?ncolt lista v?g?re }
var
  P1: PElemT;
begin
  New(P1);
  P1^.ZJel := 0;
  P1^.Szam := 0;
  P1^.Muv := 0;
  P1^.Prev := P;
  P := P1;
end; { UjElem }

procedure Felszab;      { A l?ncolt lista felszabad?t?sa a heap-b?l }
var
  P1: PElemT;
begin
  while P <> Nil do
  begin
    P1 := P^.Prev;
    Dispose(P);
    P := P1;
  end;
end; { Felszab }

procedure Done; far;    { Programlez?r?s: automatikusan h?v?dik }
begin
  ExitProc := OldExitProc;             { eredeti kil?p?si elj?r?s }
  FelSzab;
  if VanEger then
  begin
    Regs.AX := 2;                      { eg?rkurzor kikapcsol?sa }
    Intr($33, Regs);
  end;
  TextBackGround(Black);
  TextColor(LightGray);
  ClrScr;
  if not RendesBef then                { Runtime error }
  begin
{$IFDEF ENGLISH}
    WriteLn('Arithmetical overflow occured!');
    WriteLn('Please restart program!');
{$ELSE}
    WriteLn('Aritmetikai t?lcsordul?s l?pett fel!');
    WriteLn('Ind?tsa ?jra a programot!');
{$ENDIF}
  end;
end; { Done }

procedure Init;         { Inicializ?l?s }
begin
  OldExitProc := ExitProc;             { eredeti kil?p?si elj?r?s elment?se }
  ExitProc := @Done;                   { ?j kil?p?si elj?r?s }
  RendesBef := False;                  { rendes befejez?skor True lesz }
  TextMode(Co80);       { 80x25 sz?veges ?zemm?d }
  Randomize;
  Mem := 0.0;
  VanMem := False;
  KS := '0';
  BillRajz;
  Regs.AX := 0;         { eg?r inicializ?l?sa }
  Intr($33, Regs);
  VanEger := Regs.AX <> 0;
  if VanEger then
  begin
    Regs.AX := 4;       { eg?rkurzor pozicion?l?sa }
    Regs.CX := 12 * 8;
    Regs.DX := 11 * 8;
    Intr($33, Regs);
    Regs.AX := 7;       { eg?rkurzor mozg?ster?let kijel?l?se }
    Regs.CX := 1 * 8;
    Regs.DX := 23 * 8;
    Intr($33, Regs);
    Regs.AX := 8;
    Regs.CX := 5 * 8;
    Regs.DX := 19 * 8;
    Intr($33, Regs);
    Regs.AX := 1;       { eg?rkurzor bekapcsol?sa }
    Intr($33, Regs);
  end { if }
  else
  begin
    Write(Beep);
    TextBackGround(Black);
    TextColor(LightGray);
    GoToXY(1, 22);
{$IFDEF ENGLISH}
    Write('No mouse detected!');
{$ELSE}
    Write('Nincs eg?r!');
{$ENDIF}
    TextBackGround(LightGray);
    TextColor(Black);
  end; { if VanEger else }
  NormKMod := True;
  TorolKep := True;
  VoltMuv := False;
  VoltHiba := False;
  P := Nil;
  UjElem;
end; { Init }

procedure Reset;        { AC billenty?: vissza?ll?s alaphelyzetbe }
begin
  Felszab;
  UjElem;
  KS := '0';
  TorolKep := True;
  VoltMuv := False;
  VoltHiba := False;
end; { Reset }

procedure Hiba;         { Aritmetikai hiba }
begin
{$IFDEF ENGLISH}
  KS := 'Arithmetic error!';
{$ELSE}
  KS := 'Aritmetikai hiba!';
{$ENDIF}
  VoltHiba := True;
  Write(Beep);
end; { Hiba }

function VegreHajtOp(R1, R2: Real; Muv: Byte): Real;
{ "Muv" k?d? m?velet elv?gz?se R1 ?s R2 operandusok k?z?tt }
begin
  case Muv of
    1 : VegreHajtOp := R1 + R2;
    2 : VegreHajtOp := R1 - R2;
    3 : if (R1 = 0) or (R2 = 0) then
          VegreHajtOp := 0
        else if Ln(Abs(R1)) + Ln(Abs(R2)) <= Ln(1.0E+38) then
          VegreHajtOp := R1 * R2
        else            { t?lcsordul?s }
          Hiba;
    4 : if R2 = 0 then
          Hiba
        else if R1 = 0 then
          VegreHajtOp := 0
        else if Ln(Abs(R1)) - Ln(Abs(R2)) <= Ln(1.0E+38) then
          VegreHajtOp := R1 / R2
        else            { t?lcsordul?s }
          Hiba;
    5 : if (R1 > 0) and (Abs(R2 * Ln(R1)) <= 88) then
          VegreHajtOp := Exp(R2 * Ln(R1))
        else            { t?lcsordul?s vagy nem pozit?v alap }
          Hiba;
    6 : if (R1 > 0) and (R2 <> 0) and (Abs(1 / R2 * Ln(R1)) <= 88) then
          VegreHajtOp := Exp(1 / R2 * Ln(R1))
        else            { t?lcsordul?s vagy nem pozit?v alap }
          Hiba;
  end; { case }
end; { VegreHajtOp }

function NagyobbPrec(M1, M2: Byte): Boolean;
{ True ha az M1 k?d? m?veletet el?bb kell elv?gezni, mint az M2 k?d?t }
begin
  NagyobbPrec := (M1 - 1) div 2 >= (M2 - 1) div 2;
end; { NagyobbPrec }

procedure VegreHajtB(B: Byte);         { gomb v?grehajt?sa }
{ B a gomb k?dja ( biXXXX konstansok ) }
var
  R: Real;              { kijelz?n l?v? sz?m }

procedure SzamBev;      { Sz?mszerkeszt? billenty?k kezel?se }
begin
  { sz?mjegyek }
  if (HotKey[B] in ['0'..'9']) then
  begin
    if (Length(KS) < SzamSzel) then
      if KS = '0' then
        KS := HotKey[B]
      else if (KS[Length(KS)] = 'E') and (Length(KS) < (SzamSzel - 1)) then
        KS := KS + '+' + HotKey[B]
      else
        KS := KS + HotKey[B]
  end
  else
    case B of
      biBS:                            { BackSpace }
        begin
          Delete(KS, Length(KS), 1);
          if KS = '' then
            KS := '0';
        end;
      biClr: KS := '0'; { C }
      biPont:                          { tizedes pont }
        if (Pos('E', KS) = 0) and (Pos('.', KS) = 0) and
          (Length(KS) < SzamSzel) then
            KS := KS + '.';
      biExp:                           { Exp }
        if (Pos('E', KS) = 0) and (Length(KS) < SzamSzel) then
        begin
          if KS[Length(KS)] = '.' then
            Delete(KS, Length(KS), 1);
          if (KS <> '0') and (KS <> '-0') then
            KS := KS + 'E'
          else
            KS := '0';
        end;
      else
      begin
        TorolKep := True;
        case B of
          biRM:                        { RM : mem?ria kiolvas?sa }
            if VanMem then
              SzamKep(Mem);
          biRan: SzamKep(Random(1000) / 1000); { Ran: v?letlensz?m 0.000-0.999 }
          biPi: SzamKep(Pi);           { Pi }
        end; { bels? case }
      end; { case else }
    end; { case }
end; { SzamBev }

procedure FuggvBev;
{ Be?p?tett (egyv?ltoz?s) f?ggv?nyek kezel?se.
  Param?ter a kijelz?, ide ker?l az eredm?ny is }
var
  I: Integer;
  R1: Real;
begin
  case B of
    biReci:                            { reciprok }
      if R <> 0 then
        R := 1 / R
      else
        Hiba;
    biFakt:                            { faktori?lis }
      if (R = Int(R)) and (R >= 0) and (R <= 33) then
      begin
        R1 := 1;
        for I := 2 to Trunc(R) do
          R1 := R1 * I;
        R := R1;
      end
      else
        Hiba;
 { logaritmus ?s exponenci?lis f?ggv?nyek }
    biLn:
      if R > 0 then
        R := Ln(R)
      else
        Hiba;
    biExpE:
      if Abs(R) <= 88 then
        R := Exp(R)
      else
        Hiba;
    biLg:
      if R > 0 then
        R := Ln(R) / Ln(10)
      else
        Hiba;
    biExp10:
      if Abs(R) <= 38 then
        R := Exp(R * Ln(10))
      else
        Hiba;
 { trigonometrikus f?ggv?nyek ?s inverzeik }
    biSin: R := Sin(R);
    biCos: R := Cos(R);
    biTan:
      if Cos(R) <> 0 then
        R := Sin(R) / Cos(R)
      else
        Hiba;
    biASin:
      if Abs(R) < 1 then
        R := ArcTan(R / Sqrt(1 - R * R))
      else if Abs(R) = 1 then
        R := Pi / 2 * R
      else
        Hiba;
    biACos:
      if Abs(R) < 1 then
        R := Pi / 2 - ArcTan(R / Sqrt(1 - R * R))
      else if Abs(R) = 1 then
        R := Pi * (1 - R) / 2
      else
        Hiba;
    biATan: R := ArcTan(R);
 { ?tv?lt?s fokb?l radi?nba ?s vissza }
    biRad: R := Pi * R / 180;
    biDeg: R := 180 * R / Pi;
 { n?gyzet ?s n?gyzetgy?k }
    biNegyz:
      if Abs(R) <= 1E19 then
        R := R * R
      else
        Hiba;
    biGyok:
      if R >= 0 then
        R := Sqrt(R)
      else
        Hiba;
  end; { case };
  if not VoltHiba then
    SzamKep(R);
end; { FuggvBev }

procedure MuvBev;       { (K?toperandus?) m?veletek kezel?se }
var
  P1: PElemT;
begin
  P^.Szam := R;
 if VoltMuv then        { az el?z? m?velet helyesb?t?se }
 begin                  { az el?z? m?velet ki?rt?kel?sekor l?trehozott (?res) }
   P1 := P;             { elemet t?r?lj?k a lista tetej?r?l }
   P := P^.Prev;
   Dispose(P1);
 end;
 { az ?j m?veletet csak elt?roljuk }
  case B of
    biMeg:   P^.Muv := 1;
    biBol:   P^.Muv := 2;
    biSzor:  P^.Muv := 3;
    biPer:   P^.Muv := 4;
    biHatv:  P^.Muv := 5;
    biNGyok: P^.Muv := 6;
  end; { case }
 { kor?bbi magasabb precedenci?j? m?veletek v?grehajt?sa visszafel? haladva
    (csak az el?z? nyit? z?r?jelig) }
  while (not VoltHiba) and (P^.Prev <> Nil) and (P^.ZJel = 0) and
    NagyobbPrec(P^.Prev^.Muv, P^.Muv) do
  begin
    P1 := P^.Prev;
    P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
    P1^.Muv := P^.Muv;
    Dispose(P);
    P := P1;
  end; { while }
  if not VoltHiba then
  begin
    SzamKep(P^.Szam);
    UjElem;             { ?j elem a lista tetej?n (most m?g ?res) }
    VoltMuv := True;
  end; { if }
end; { MuvBev }

procedure CsZaroJel;    { Csuk? z?r?jel kezel?se }
var
  P1: PElemT;
begin
  P^.Szam := R;
  if (P^.ZJel > 0) then
    Dec(P^.ZJel)
  else
  begin
   { kor?bbi m?veletek v?grehajt?sa visszafel? haladva
      (csak a z?r?jelen bel?l) }
    while (not VoltHiba) and (P^.Prev <> Nil) and (P^.ZJel = 0) do
    begin
      P1 := P^.Prev;
      P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
      P1^.Muv := P^.Muv;
      Dispose(P);
      P := P1;
    end; { while }
    if not VoltHiba then
    begin
      if P^.ZJel > 0 then
        Dec(P^.ZJel);
      SzamKep(P^.Szam);
    end; { if }
  end; { else }
end; { CsZaroJel }

procedure Egyenlo;      { Egyenl?s?gjel kezel?se }
var
  P1: PElemT;
begin
  P^.Szam := R;
 { kor?bbi m?veletek v?grehajt?sa visszafel? haladva }
  while (not VoltHiba) and (P^.Prev <> Nil)  do
  begin
    P1 := P^.Prev;
    P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
    P1^.Muv := P^.Muv;
    Dispose(P);
    P := P1;
  end; { while }
  if not VoltHiba then
  begin
    P^.ZJel := 0;
    SzamKep(P^.Szam);
  end; { if }
end; { Egyenlo }

procedure Ellentett;    { +/- bill. lekezel?se }
begin
  if KS[1] = '-' then
    Delete(KS, 1, 1)
  else if (Length(KS) < SzamSzel) and (KS <> '0') then
    KS := '-' + KS;
end; { Ellentett }

var
  I: Integer;
begin { VegreHajtB }
  if B = biAC then
    Reset
  else
    if not VoltHiba then               { hiba ut?n csak AC lehet }
      if B = biPlMi then               { +/- }
        Ellentett
      else if (B = biBol) and          { negat?v kitev? a tudom?nyos alakban }
        (Length(KS) < SzamSzel) and (KS[Length(KS)] = 'E') then
          KS := KS + '-'
      else if B in SzamBevBill then
      begin
        if TorolKep then
          KS := '0';
        TorolKep := False;
        VoltMuv := False;
        SzamBev;
      end
      else if B = biNyit then          { nyit? z?r?jel: csak k?nyvel?s }
      begin
        Inc(P^.ZJel);
        P^.Szam := 0;
        KS := '0';
      end
      else
      begin
        Val(KS, R, I);
        if I <> 0 then                 { kijelz? nem ?rtelmes sz?m }
          Write(Beep)
        else
        begin
          TorolKep := True;
          if B = biDisp then            { SCI }
          begin
            NormKMod := not NormKMod;
            SzamKep(R);
          end
          else if B in MuvBill then
            MuvBev                     { (ez VoltMuv-et True-ra ?ll?tja) }
          else
          begin
            VoltMuv := False;
            if B in FuggvBill then
              FuggvBev
            else if B = biMem then     { Mem : Kijelz? a mem?ri?ba }
            begin
              Mem := R;
              VanMem := R <> 0;
            end
            else if B = biMPlu then    { M+ : Kijelz? hozz?ad?sa a mem?ri?hoz }
            begin
              if VanMem then
                Mem := Mem + R
              else
              begin
                Mem := R;
                VanMem := R <> 0;
              end;
            end
            else if B = biEgye then
              Egyenlo
            else if B = biCsuk then
              CsZaroJel
          end; { if B in MuvBev else }
        end; { if I else }
      end; { if B = biNyit else }
end; { VegreHajtB }

procedure KezelBill;
{ f? programciklus: kurzormozgat?s ?s billenty? lekezel?s }
var
  C: Char;              { lenyomott bill. (ReadKey-k?d) }
  ABill: Byte;          { kurzor poz?ci? (aktu?lis gomb sorsz?ma) }
  UjABill: Integer;     { kurzor ?j poz?ci?ja }
begin
  ABill := 1;
  repeat
    Kijelzo;
    GotoXY(((ABill - 1) mod RajzOszlop) * 4 + 3,
      2 * ((ABill - 1) div RajzOszlop) + 6);
    UjABill := ABill;
    Regs.AX := 0;
    repeat
      if VanEger then
      begin
        Regs.AX := 5;   { eg?rgomb lek?rdez?s }
        Regs.BX := 0;
        Intr($33, Regs);
      end;
    until (Regs.AX and 1 <> 0) or KeyPressed;
    if KeyPressed then
    begin
      C := UpCase(ReadKey);
      case C of
        #0:
          begin
            C:= ReadKey;
            case C of
              kbUp    : UjABill := ABill - RajzOszlop;
              kbDown  : UjABill := ABill + RajzOszlop;
              kbLeft  : UjABill := ABill - 1;
              kbRight : UjABill := ABill + 1;
              kbPgUp  : UjABill := (ABill - 1) mod RajzOszlop + 1;
              kbPgDn  : UjABill := MaxBill - RajzOszlop +
                                     (ABill - 1) mod RajzOszlop + 1;
              kbHome  : UjABill := 1;
              kbEnd   : UjABill := MaxBill;
              kbAltQ, kbAltX : C := kbEsc;
              else
                C := #0;
            end; { bels? case }
          end; { case #0 }
        kbBackSpace:
          begin
            UjABill := biBS;
            VegreHajtB(UjABill);
          end;
        kbEnter:
          if ABill <> biEsc then
            VegreHajtB(ABill)
          else
            C := kbEsc;
        else
        begin
          UjABill := Pos(C, HotKey);
          if (UjABill > 0) and (C <> ' ') then
            VegreHajtB(UjABill);
        end;
      end; { case }
    end { if KeyPressed }
    else                { eg?rgomb }
      if (Regs.CX mod 32 <> 0) and (Regs.DX mod 16 = 8) then
      begin
        UjABill := RajzOszlop * (Regs.DX div 16 - 2) + Regs.CX div 32 + 1;
        if UjABill <> biEsc then
          VegreHajtB(UjABill)
        else
          C := kbEsc;
        repeat          { v?rakoz?s az eg?rgomb felenged?s?re }
          Regs.AX := 6;
          Intr($33, Regs);
        until Regs.BX <> 0;
      end; { if Regs }
    if (UjABill > 0) and (UjABill <= MaxBill) then
      ABill := UjABill;
    if VoltHiba then
      ABill := biAC;
  until C = kbEsc;
end; { KezelBill }

begin { F?program }
  Init;
  KezelBill;
  RendesBef := True;    { jelzi, hogy nem kell magyar hiba?zenet a Done-ban }
end.                    { Done automatikusan megh?v?dik }
