{ DARABJEGYZêK NYILVèNTART¢ êS FELDOLGOZ¢ PROGRAM
  Copyright (c) 1991  T¢th B†lint

DarabjegyzÇk feldolgoz¢ unit ( Turbo Pascal 6.0 )
}
unit DJ1Dolg;

{$E+,N+,B-,V-}

interface

uses Crt, Printer, Dos;

const
 { Specialis billentyukodok }
  LeftA      = #75;
  RightA     = #77;
  UpA        = #72;
  DownA      = #80;
  Home       = #71;
  EndB       = #79;
  PgUp       = #73;
  PgDn       = #81;
  CtrlLeftA  = #115;
  CtrlRightA = #116;
  CtrlHome   = #119;
  CtrlEnd    = #117;
  CtrlPgUp   = #132;
  CtrlPgDn   = #118;
  ShiftTab   = #15;
  AltF       = #33;
  AltT       = #20;
  AltD       = #32;
  AltY       = #21;
  AltS       = #31;
  AltN       = #49;
  AltR       = #19;
  AltM       = #50;
  AltK       = #37;
  AltV       = #47;
  AltZ       = #44;
  AltB       = #48;
  AltX       = #45;
  AltA       = #30;
  AltE       = #18;
  AltU       = #22;
  AltI       = #23;
  AltO       = #24;
  Alt1       = #120;
  Alt2       = #121;
  Alt3       = #122;
  Alt4       = #123;
  Ins        = #82;
  Del        = #83;
  F1         = #59;
  F2         = #60;
  F3         = #61;
  F4         = #62;
  F5         = #63;
  F6         = #64;
  F7         = #65;
  F8         = #66;
  ShiftF1    = #84;
  AltF1      = #104;

  Beep       = #7;
  BackSpace  = #8;
  Tab        = #9;
  FormFeed   = #12;
  Enter      = #13;
  Esc        = #27;

  SPC : string[32] = '                                        ';
  MaxKM = 120; { szabvanykonyvtar maximalis merete }
  MaxAJMeret = 1200; { anyagjegyzek maximalis merete }
  IsmAnySzam = 33; { ismert anyagok szama }
  AcelFS = 7.85; { acel fajsulya }
  ITFS   = 2; { IT fajsulya }
  BiztSzorzo : real = 1.1; { biztonsagi szorzo anyagrendeleshez }
  CegNev : string[17] = '  GANZ DANUBIUS  ';
  { Torescsoportok kodjai }
  ToresKodok : string[108] = '013 015 210 211 212 213 214 215 216 222 223 ' +
    '226 228 232 236 242 246 248 254 255 256 257 263 270 271 277 275';
  { Torescsoportok nevei }
  ToresNevek : array[0..26] of string[26] = (
    '    J¢v†hagy†si tervek    ', ' HegesztÇsi tÇrkÇp (Szer.)',
    ' èttekintì tervek (Elgìz.)', '     Dob Çs tartozÇkai    ',
    '         Ejtìcsîvek       ', '    Kaz†n felfÅggesztÇs   ',
    '       Elgìzîlîgtetì      ', '     Menyezeti csîvek     ',
    'Elgìzîlîgtetì îsszekîtì cs', '    Konvekt°v t£lhev°tì   ',
    '  Besug†rzott t£lhev°tì   ', 'T£lhev°tì îsszekîtì csîvek',
    '      T£lhev°tì hñtì      ', '     T†pv°zelìmeleg°tì    ',
    '   ECO îsszekîtì vezetÇk  ', '        Ujrahev°tì        ',
    'Ujrahev°tì îsszekîtì vezet', '     Ujrahev°tì hÅtì      ',
    '    V°ztelen°tì vezetÇk   ', '    ManomÇter vezetÇk     ',
    '    LÇgtelen°tì vezetÇk   ', 'Dob biztons†gi szelep vez.',
    '        MÇrìhelyek        ', '    DurvaszerelvÇnyek     ',
    '    DurvaszerelvÇnyek     ', '       Kop†svÇdelem       ',
    '       Lemezdobozok       ');
  { szabvanyok es kodok }
  MSZKodok : array[1..MaxKM] of string[12] = (
    '**2448 (DIN)', '*2448 (DIN) ', '2448  (DIN) ', '*357        ',
    '357         ', '2605  (DIN) ', '*99   (KVV) ', '**99  (KVV) ',
    '***99 (KVV) ', '(4)         ', '292-        ', '(6)         ',
    '1016  (DIN) ', '4374        ', '*5726       ', '5726        ',
    '40          ', '41          ', '778   (DVSZ)', '*4337       ',
    '4337        ', '5725        ', '4341        ', '326         ',
    '328         ', '329         ', '325         ', '2360        ',
    '2363        ', '2161        ', '2162        ', '2381        ',
    '2665        ', '2461        ', '2463        ', '2260        ',
    '2261        ', '2431        ', '2186        ', '2243        ',
    '2233        ', '220         ', '2206        ', '2207        ',
    '2202        ', '2203        ', '281   (KGST)', '(5)         ',
    '*(5)        ', '2           ', '7328        ', '120         ',
    '(8)1        ', '(8)2        ', '(8)3        ', '1683        ',
    '4749        ', '11264       ', '2093  (DIN) ', '(7)         ',
    '(2)         ', '(3)1        ', '(3)2        ', '(1)1        ',
    '(1)2        ', '(1)3        ', '(1)4        ', '(1)5        ',
    '(1)6        ', '(1)7        ', '(1)8        ', '(1)9        ',
    '*           ', '**          ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ',
    '            ', '            ', '            ', '            ');
  { szabvanyos elnevezesek }
  MSZNevek : array[1..MaxKM] of string[30] = (
    'Csì fix hosszban kamr†hoz     ', 'VarratnÇlk. a.csì fix hosszban',
    'Varrat nÇlkÅli acÇlcsì        ', 'Kov†csolt kîrt†rcsa           ',
    'Kov†csolt acÇlbuga            ', 'Patent°v                      ',
    'Melegen sajtolt szñk°tì       ', 'Melegen sajtolt T-idom        ',
    'KVV °vcsì                     ', 'Nadr†gcsì                     ',
    'Hegeszthetì told. acÇlkarima  ', 'SCHLICK porlaszt¢             ',
    'LaposacÇl g†t                 ', 'Hengerelt laposacÇl           ',
    'SzÇlesacÇl fix hosszban       ', 'Hengerelt szÇlesacÇl          ',
    'Hengerelt acÇl durvalemez     ', 'AcÇl finomlemez               ',
    'Perfor†lt lemez               ', 'KîracÇl fix hosszban          ',
    'Hengerelt kîracÇl             ', 'Hengerelt hatszîgacÇl         ',
    'Hengerelt nÇgyzetacÇl         ', 'Hengerelt U-acÇl              ',
    'Hengerelt egyenlìsz†r£ L-acÇl ', 'Heng. egyenlìtlensz†r£ L-acÇl ',
    'Hengerelt I-acÇl              ', 'Hatlapfejñ csavar             ',
    'Hatlapfejñ tîvigmenetes csavar', 'Hatlap£ anya                  ',
    'Hatlap£ alacsony anya         ', 'Gyñrñscsavar                  ',
    'Rug¢s al†tÇt                  ', 'Hatlapfejñ csavar II.         ',
    'H.l.f. tîvigmenetes csavar II.', 'Hatlap£ anya II.              ',
    'Hatlap£ alacsony anya II.     ', 'SÅllyesztett fejñ csavar      ',
    'Nyitott fesz°tìanya           ', 'Has°tott rîgz°tìszeg          ',
    'Csapszeg al†tÇt               ', 'Sasszeg                       ',
    'Al†tÇt U-szelvÇnyhez          ', 'Al†tÇt I-szelvÇnyhez          ',
    'LencsÇs al†tÇt                ', 'Kagyl¢s al†tÇt                ',
    'Al†tÇt                        ', 'Hì†ll¢tÅske keramikus gyñrñvel',
    'SzigetelÇstart¢ tÅske         ', 'L†gyacÇl huzal (dr¢t)         ',
    'Z†rtszelvÇny                  ', 'VarratnÇlkÅli menetes acÇlcsì ',
    'B£v¢ajt¢ întvÇny              ', 'Figyelìajt¢ întvÇny           ',
    'Robban¢ajt¢ întvÇny           ', 'Azbeszt-gumi (IT) lemez       ',
    'Azbeszt tîm°tìlemez           ', 'Azbeszt tîm°tìzsin¢r          ',
    'T†nyÇrrug¢                    ', 'Spir†lrug¢                    ',
    'RôCK rug¢kÇszlet              ', 'DARU t°pus£ felfÅggesztì elem ',
    'LISEGA t°p. felfÅggesztì elem ', 'Tol¢z†r                       ',
    'ètmenì elz†r¢szelep           ', 'Folyt¢k£pos szab†lyz¢szelep   ',
    'Visszacsap¢ szelep            ', 'Rug¢s biztons†gi szelep       ',
    'SegÇdvezÇrlÇsñ bizt. szelep   ', 'Viz†ll†smutat¢                ',
    'özemi csavarrug¢s manomÇter   ', 'Helyi hìmÇrì                  ',
    'Kaz†ndob kîpeny               ', 'MÇlydombor£ fenÇk komplett    ',
    'SekÇlydombor£ fenÇk           ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ', '                              ',
    '                              ');
  { MSZ vagy csak kod (1 = MSZ) }
  MSZvKod : string[MaxKM] = '111111111010111111111111111111111111111111111' +
    '11001110001111000000000000000' +
    '1111111111111111111111111111111111111111111111';
  { MertekEgyseg (1 = DB, 2 = M, 3 = M^2) }
  MertEgys : string[MaxKM] = '11211111111122123331222222211111111111111111' +
   '111112221113321111111111111111' +
   '1111111111111111111111111111111111111111111111';
  { AnyagNevek }
  AnyagNevek : array[1..IsmAnySzam] of string[11] = (
    '12CR1MOV   ', '12H1MFI    ', 'WB36       ', '10CRMO910  ',
    'SICROMAL10 ', 'SICROMAL8  ', 'X10CRAL18  ', 'X10CRAL7   ',
    'KO36       ', 'H14        ', 'H12        ', 'H10        ',
    'MCRMONIV   ', 'KL9        ', '13CRMO44   ', 'MCRMOV     ',
    'MCRMO      ', 'MC         ', 'KL8        ', '15MO3      ',
    '19MN6      ', '20M        ', 'ST45.8-III ', 'ST44.K     ',
    'ST35.8-III ', 'KL2        ', 'A50        ', 'A44B       ',
    'A44        ', 'A38B       ', 'A38        ', 'A35        ',
    'A34        ');

  AKMeret : byte = 74;
  MaxT    = 12; { modositas rovat sorainak szama }
  MaxTR   = 3; { modositas rovat rublikainak szama }
  MaxDR   = 7; { darabjegyzek rovat rublikainak szama }
  MaxDSor = 5; { egyszerre lathato sorok szama a darabjegyzek rovatban }
  MaxTSZ  = 300; { tetelek maximalis szama }
  MaxFR   = 7; { fejlec rublikainak szama }
  NySor   = 24; { egy lapra kerulo tetelek szama }
  AJSor   = 48; { nyomtatora kerulo sorok (fejlec nelkul) anyagjegyzekben }
  RJSor   = 24; { egy lapra kerulo rajzszamok rajzjegyzekben }
  MaxDirSize = 512; { egy konyvtarban levo rajzok maximalis szama }
  KiValNev : string[33] = '  sz†m£ rajz feldolgoz†sra kerÅl';
  SorokSzama : 0..MaxTSZ = 0;

type
  DJDRTipus = array[1..MaxDR + 1] of byte;
  FLTipus   = array[1..MaxFR] of byte;
  TorTipus  = array[1..MaxTR] of byte;

const
  DJDRMeret  : DJDRTipus = (3, 4, 17, 17, 11, 6, 5, 7);
  DJDRKezdoX : DJDRTipus = (2, 6, 11, 29, 47, 59, 74, 66);
  DJFLMeret  : FLTipus   = (3, 11, 17, 20, 20, 30, 30);
  DJFLKezdoX : FLTipus   = (61, 10, 28, 58, 58, 48, 48);
  DJFLKezdoY : FLTipus   = (2, 4, 4, 4, 6, 9, 10);
  DJTMeret   : TorTipus  = (22, 8, 8);
  DJTKezdoX  : TorTipus  = (6, 29, 38);

type
  MaxSMeretT = string[30];
  DJFLTipus  = array[1..MaxFR] of MaxSMeretT;
  DJTTipus   = array[1..MaxT, 1..MaxTR] of string[22];
  DJTetelTipus = array[1..MaxDR + 1] of string[18];
  DJTipus    = array[1..MaxTSZ] of ^DJTetelTipus;
  FNevTipus  = string[8];
  FNTipus    = string[12];
  RSZTipus   = string[16];
  AnyTipus   = string[11];
  JMTipus    = string[17];
  DSorTipus  = string[79];
  DJTSTipus  = string[45];
  AJSorTipus = record { anyagjegyzek egy sora }
      AKMutato  : 1..MaxKM;
      JelzoSzam : comp;
      TenylM, EgysSuly, Suly : real;
      JellM : JMTipus;
      Anyag : string[11];
      ErintRajz : string;
    end; { record }
  AJSorMutTipus = ^AJSorTipus;
  AJTipus = array[1..MaxAJMeret] of AJSorMutTipus;

var
  MBill : char;
  Ut    : PathStr;
  DJFL  : DJFLTipus;
  DJT   : DJTTipus;
  DJ    : DJTipus;
  ToresSzam  : 0..MaxT;
  OsszSuly : real;
  KovTSZ : 1..MaxTSZ;
  KezdoTor : byte;
  Kell : array[1..MaxDirSize] of boolean;
  I, Count : Integer;
  Dir : array[1..MaxDirSize] of FNevTipus;
  AM : RSZTipus;
  AS : FNTipus;

function RSZtoFN(RSZ : MaxSMeretT; var Sikerult : boolean) : FNTipus;
function FNtoRSZ(FN : FNTipus) : RSZTipus;
procedure BeToltFN(FN : FNTipus);
procedure ToltLista(Maszk : FNevTipus; TobbF : boolean;
                    var TNev: FNevTipus);
procedure UjMD;
function Pottyoz(AKS : byte) : MaxSMeretT;
procedure MenyFelDolg(Meny : JMTipus; var TM : real; var ME : char;
  var Sikerult : boolean);
procedure MeretFelDolg(TetSz : integer; var JM : JMTipus; var TM : real;
  var ME : char; var Sikerult : boolean);
procedure MSZFelDolg(TetSZ : integer; var AKM : byte; var ME : char;
  AKFrissit : boolean; var Sikerult : boolean);
procedure KeszitJSZ(AKM : integer; JM : JMTipus; UjAnyag : AnyTipus;
  var JSZ : comp; var ES : real);
procedure AnyagJT;
procedure AnyagJR;
procedure RajzJT;
procedure AnyagKonyvTarNy;

implementation

function RSZtoFN(RSZ : MaxSMeretT; var Sikerult : boolean) : FNTipus;

var
  FNS : FNTipus;
  TN : byte;

begin
  if (Length(RSZ) = 20) and (UpCase(RSZ[1]) in ['A'..'Z']) and
    (RSZ[2] in ['0'..'9']) and (RSZ[3] in ['0'..'9']) and
    (RSZ[4] = '-') and (RSZ[5] = '7') and (RSZ[6] in ['0'..'9']) and
    (RSZ[7] = '-') and (Copy(RSZ, 11, 3) = '-00') and
    (RSZ[14] in ['0'..'9']) and (RSZ[15] in ['0'..'9']) and
    (RSZ[16] in ['0'..'9']) and (Copy(RSZ, 17, 4) = '    ')then
  begin
    FNS := Copy(RSZ, 1, 3) + RSZ[6];
    TN := Pos(Copy(RSZ, 8, 3), ToresKodok);
    if (TN > 0) and (TN mod 4 = 1) then
      if TN < 104 then
        FNS := FNS + Chr(65 + TN div 4)
      else
        FNS := FNS + Chr(23 + TN div 4)
    else
      FNS := FNS + '0';
    FNS := FNS + Copy(RSZ, 14, 3);
    Sikerult := true;
  end
  else
    Sikerult := false;
  RSZtoFN := FNS;
end; { RSZtoFN }

function FNtoRSZ(FN : FNTipus) : RSZTipus;

var
  RSZS : RSZTipus;

begin
  RSZS := Copy(FN, 1, 3) + '-7' + FN[4] + '-';
  case FN[5] of
    '0' : RSZS := RSZS + '000';
    'A'..'Z' : RSZS := RSZS + Copy(ToresKodok, (Ord(FN[5]) - 65) * 4 +1, 3);
    '1' : RSZS := RSZS + Copy(ToresKodok, (Ord(FN[5]) - 49) * 4 + 105, 3);
  end; { case }
  RSZS := RSZS + '-00' + Copy(FN, 6, 3);
  FNtoRSZ := RSZS;
end; { FNtoRSZ }

procedure BeToltFN(FN : FNTipus);

var
  DJF : file of char;
  SzamS : string[8];
  BTI, BTJ, BTKod : integer;

procedure BTFbol(var Elem : MaxSMeretT; Hossz : byte);

var BTFI : byte;

begin
  Elem[0] := Chr(Hossz);
  for BTFI := 1 to Hossz do
    Read(DJF, Elem[BTFI]);
end; { BTFbol }

begin
  Assign(DJF, Ut + FN + '.DJF');
  {$I-}
  Reset(DJF);
  {$I+}
  if IOResult <> 0 then
  begin
    Write('I/O hiba! [Enter] ');
    ReadLn;
  end { if }
  else
  begin
    for BTI := 1 to SorokSzama do
      Dispose(DJ[BTI]);
    BTFbol(SzamS, 3);
    Val(SzamS, SorokSzama, BTKod);
    for BTI := 1 to SorokSzama do
      New(DJ[BTI]);
    BTFbol(SzamS, 3);
    Val(SzamS, KovTSZ, BTKod);
    BTFbol(SzamS, 2);
    Val(SzamS, ToresSzam, BTKod);
    BTFbol(SzamS, 2);
    Val(SzamS, KezdoTor, BTKod);
    BTFbol(SzamS, 8);
    Val(SzamS, OsszSuly, BTKod);
    for BTI := 1 to MaxFR do
      BTFbol(DJFL[BTI], DJFLMeret[BTI]);
    for BTI := 1 to ToresSzam do
      for BTJ := 1 to MaxTR do
        BTFbol(DJT[BTI, BTJ], DJTMeret[BTJ]);
    for BTI := 1 to SorokSzama do
      for BTJ := 1 to MaxDR + 1 do
        BTFbol(DJ[BTI]^[BTJ], DJDRMeret[BTJ]);
    Close(DJF);
  end; { else }
end; { BeToltFN }

procedure QuickSort(L, R: Integer);
var
  I, J: Integer;
  X, Y: FNevTipus;
begin
  I := L;
  J := R;
  X := Dir[(L + R) div 2];
  repeat
    while Dir[I] < X do Inc(I);
    while X < Dir[J] do Dec(J);
    if I <= J then
    begin
      Y := Dir[I];
      Dir[I] := Dir[J];
      Dir[J] := Y;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSort(L, J);
  if I < R then QuickSort(I, R);
end;

procedure FindFiles(Maszk : FNevTipus);
var
  F: SearchRec;
begin
  Count := 0;
  FindFirst(Ut + Maszk + '*.DJF', Archive, F);
  while (DosError = 0) and (Count < MaxDirSize) do
  begin
    Inc(Count);
    Dir[Count] := Copy(F.Name, 1, 8);
    FindNext(F);
  end;
end;

procedure ToltLista(Maszk : FNevTipus; TobbF : boolean;
                    var TNev: FNevTipus);
var
  I, PPos, KepPos : word;
  Bill : char;
 
procedure PrintFiles;
begin
  ClrScr;
  if TobbF then
    WriteLn('V†lassza ki a k°v†nt rajzokat SZ¢KôZ -zel,  VÇge = ENTER  ' +
      '( F1 = Seg°tsÇg )')
  else
    WriteLn('V†lassza ki a k°v†nt rajzot az ENTER-rel  ( F1 = Seg°tsÇg )');
  I := PPos - 1;
  repeat
    Inc(I);
    Write('  ', FNtoRSZ(Dir[I]), ' ');
    if TobbF and Kell[I] then
      WriteLn(KiValNev)
    else
      WriteLn(SPC);
  until (I - PPos = 22) or (I = Count);
end; { PrintFiles }

procedure TLSegitseg;
begin
  ClrScr;
  WriteLn;
  WriteLn('RAJZKIVèLASZTèS - SEG°TSêG');
  WriteLn('--------------------------');
  WriteLn;
  WriteLn(' '#24' '#25'  . . . . .  LÇpkedÇs a rajzok kîzîtt');
  WriteLn(' Home / End . .  Ugr†s lista elejÇre, vÇgÇre');
  WriteLn(' Page Up / Down  Lapoz†s elìre, h†tra');
  if TobbF then
  begin
    WriteLn(' Sz¢kîz . . . .  Rajz kiv†laszt†sa, kiv†laszt†s tîrlÇse');
    WriteLn(' Ins  . . . . .  ôsszes rajz kiv†laszt†sa');
    WriteLn(' Del  . . . . .  ôsszes kiv†laszt†s tîrlÇse');
  end; { if }
  WriteLn(' Enter  . . . .  VÇge');
  WriteLn(' Esc  . . . . .  KilÇpÇs rajz kiv†laszt†sa nÇlkÅl');
  repeat
  until KeyPressed;
  PrintFiles;
end; { TLSegitseg }

begin { ToltLista }
  FindFiles(Maszk);
  if Count > 0 then
  begin
    QuickSort(1, Count);
    PPos := 1;
    KepPos := 1;
    PrintFiles;
    repeat
      GotoXY(20, KepPos + 1);
      Bill := ReadKey;
      case Bill of
        #0 : if KeyPressed then
          begin
            Bill := ReadKey;
            case Bill of
              UpA : if PPos + KepPos > 2 then
                begin
                  Dec(KepPos);
                  if KepPos = 0 then
                  begin
                    KepPos := 1;
                    Dec(PPos);
                    PrintFiles;
                  end; { if KepPos }
                end; { if PPos }
              DownA : if PPos + KepPos - 1 < Count then
                begin
                  Inc(KepPos);
                  if KepPos = 24 then
                  begin
                    KepPos := 23;
                    Inc(PPos);
                    PrintFiles;
                  end; { if KepPos }
                end; { if PPos  }
              Home : begin
                  PPos := 1;
                  KepPos := 1;
                  PrintFiles;
                end; { case Home }
              EndB : begin
                  if Count > 23 then
                  begin
                    KepPos := 23;
                    PPos := Count - 22;
                  end { if }
                  else
                  begin
                    PPos := 1;
                    KepPos := Count;
                  end; { else }
                  PrintFiles;
                end; { case EndB }
              PgUp : begin
                  if PPos > 23 then
                    Dec(PPos, 23)
                  else
                  begin
                    PPos := 1;
                    KepPos := 1;
                  end; { else }
                  PrintFiles;
                end; { case PgUp }
              PgDn : begin
                  if PPos < Count - 46 then
                    Inc(PPos, 23)
                  else
                    if Count > 23 then
                    begin
                      KepPos := 23;
                      PPos := Count - 22;
                    end { if }
                    else
                    begin
                      PPos := 1;
                      KepPos := Count;
                    end; { else }
                  PrintFiles;
                end; { case PgDn }
              Ins : if TobbF then
                begin
                  for I := 1 to Count do
                    Kell[I] := true;
                  PrintFiles;
                end; { if }
              Del : if TobbF then
                begin
                  for I := 1 to Count do
                    Kell[I] := false;
                  PrintFiles;
                end; { if }
              F1 : TLSegitseg;
            end; { case }
            Bill := 'a';
          end; { if KeyPressed }
        ' ' : if TobbF then
          begin
            Kell[PPos + KepPos - 1] := not Kell[PPos + KepPos - 1];
            if Kell[PPos + KepPos - 1] then
              Write(KivalNev)
            else
              Write(SPC + ' ');
          end; { if TobbF }
        Esc : for I := 1 to Count do
                Kell[I] := false;
      end; { case }
    until Bill in [Enter, Esc];
    if Bill = Esc then
      TNev := ''
    else
      TNev := Dir[PPos + KepPos - 1];
  end
  else
  begin
    ClrScr;
    TNev := '';
    Write('Nincs megfelelì f†jl. [Enter] ');
    ReadLn;
  end; { else }
  ClrScr;
end; { ToltLista }

function Pottyoz(AKS : byte) : MaxSMeretT; { szabvanyneveket kiegesziti }

const Potty : string[30] = ' . . . . . . . . . . . . . . .';

var POI : byte;

begin
  POI := 30;
  while MSZNevek[AKS, POI] = ' ' do
    Dec(POI);
  if Odd(POI) then
    Pottyoz := Copy(MSZNevek[AKS], 1, POI) + ' '+ Copy(Potty, 1, 29 - POI)
  else
    Pottyoz := Copy(MSZNevek[AKS], 1, POI) + Copy(Potty, 1, 30 - POI);
end; { Pottyoz }

procedure UjMD;

var US : PathStr;

begin
  WriteLn('Aktu†lis meghajt¢ Çs directory:       ', Ut);
  Write('KÇrem az £j meghajt¢t Çs directory-t: ');
  ReadLn(US);
  if US <> '' then
  begin
    Ut := FExpand(US);
    if Ut[Length(Ut)] <> '\' then
      Ut := Ut + '\';
  end; { if US }
end; { UjMD }

procedure NyomtatRJSor(var T: text; FSzam, FSorSzam : integer;
  var OsszKeszSuly : real);

var
  DJF : file of char;
  BTKod : integer;
  SzamS : string[30];
  DJSuly : real;
  NyI : integer;

procedure BTFbol(var Elem : MaxSMeretT; Hossz : byte);

var
  BTFI : byte;
  SzamS : string[8];

begin
  Elem[0] := Chr(Hossz);
  for BTFI := 1 to Hossz do
    Read(DJF, Elem[BTFI]);
end; { BTFbol }

begin
  Assign(DJF, Ut + Dir[FSzam] + '.DJF');
  {$I-}
  Reset(DJF);
  {$I+}
  if IOResult <> 0 then
  begin
    Write('I/O hiba! [Enter] ');
    ReadLn;
    Exit;
  end; { if }
  Write(T, FSorSzam : 4, '. ');
  Seek(DJF, 69);
  BTFbol(SzamS, 16);
  Write(T, SzamS);
  Seek(DJF, 6);
  BTFbol(SzamS, 2);
  Val(SzamS, NyI, BTKod);
  if NyI > 0 then
    Write(T, '/' + Chr(NyI + 96))
  else
    Write(T, '  ');
  Seek(DJF, 89);
  BTFbol(SzamS, 30);
  Write(T, '  ', SzamS);
  Seek(DJF, 0);
  BTFbol(SzamS, 3);
  Val(SzamS, NyI, BTKod);
  Write(T, NyI div NySor + 1 : 4, ' lap  ');
  Seek(DJF, 10);
  BTFbol(SzamS, 8);
  Val(SzamS, DJSuly, BTKod);
  WriteLn(T, DJSuly : 8 : 1, ' kg');
  OsszKeszSuly := OsszKeszSuly + DJSuly;
  Seek(DJF, 119);
  BTFbol(SzamS, 30);
  if SzamS <> Copy(SPC, 1, 30) then
    WriteLn(T, Copy(SPC, 1, 26), SzamS)
  else
    WriteLn(T);
  Close(DJF);
end; { NyomtatRJSor }

procedure KiirListaFajl(TmpFNev : string);

var
  KBill : char;
  I : integer;
  S : string;
  L : text;

begin
  Write('Hov† °rjam: Nyomtat¢ra, KÇpernyìre vagy Lemezre (ASCII szîveg' +
    'file-ba? [N/K/L] ');
  repeat
    KBill := UpCase(ReadKey);
  until KBill in ['N', 'K', 'L'];
  WriteLn(KBill);
  Assign(L, Ut + TmpFNev + '.$$$');
  Reset(L);
  case KBill of
    'N' : begin
        Write('KÇsz°tse elì a nyomtat¢t! [Enter] ');
        ReadLn;
        Write('Nyomtat†s ... ');
        while not Eof(L) do
        begin
          ReadLn(L, S);
          WriteLn(Lst, S);
        end; { while }
        Erase(L);
      end; { case N }
    'K' : begin
        while not Eof(L) do
        begin
          ClrScr;
          I := 24;
          repeat
            Dec(I);
            ReadLn(L, S);
            if S[1] = FormFeed then
            begin
              WriteLn(S[1]);
              WriteLn(Copy(S, 2, Length(S) - 1));
            end
            else
              WriteLn(S);
          until (I = 0) or Eof(L);
          GoToXY(1, 25);
          Write('[Enter] ');
          ReadLn;
        end; { while }
        Erase(L);
      end; { case K }
    'L' : begin
        Write('KÇrem a lista-file nevÇt: ');
        ReadLn(S);
        Rename(L, Ut + S);
      end; { case L }
  end; { case }
  Close(L);
end; { KiirListaFajl }

procedure MenyFelDolg(Meny : JMTipus; var TM : real; var ME : char;
  var Sikerult : boolean);

var
  MeFDI, MeFDK : integer;
  MeFDR : real;

begin
  MeFDI := 0;
  while (MeFDI < Length(Meny)) and (not (Meny[MeFDI + 1] in ['x', '*'])) do
    Inc(MeFDI);
  if (Meny[MeFDI + 1] in ['x', '*']) and (MeFDI < Length(Meny) - 1) then
  begin { negyzetmeter }
    Val(Copy(Meny, 1, MeFDI), TM, MeFDK);
    if MeFDK <> 0 then
    begin
      Sikerult := false;
      Exit;
    end; { if MeFDK }
    Val(Copy(Meny, MeFDI + 2, Length(Meny)), MeFDR, MeFDK);
    if MeFDK <> 0 then
    begin
      Sikerult := false;
      Exit;
    end; { if MeFDK }
    TM := TM * MeFDR / 1000000;
    ME := '3';
  end { if Meny }
  else { meter }
  begin
    Val(Meny, TM, MeFDK);
    if MeFDK <> 0 then
    begin
      Sikerult := false;
      Exit;
    end; { if MeFDK }
    TM := TM / 1000;
    ME := '2';
  end; { if Meny else }
end; { MenyFelDolg }

procedure MeretFelDolg(TetSz : integer; var JM : JMTipus; var TM : real;
  var ME : char; var Sikerult : boolean);

var MFDI, MFDJ, MFDK : integer;

begin
  Sikerult := true;
  MFDI := 0; { jellemzo meret keresese }
  while (MFDI < DJDRMeret[4]) and
    (not (DJ[TetSz]^[4, MFDI + 1] in ['/', '(', ' '])) do
      Inc(MFDI);
  if MFDI = 0 then
  begin
    Sikerult := false;
    Exit;
  end; { if MFDI }
  JM := Copy(DJ[TetSz]^[4], 1, MFDI);
  if DJ[TetSz]^[4, MFDI + 1] = '/' then
  begin { mennyiseg keresese }
    if ((MFDI + 1) = DJDRMeret[4]) or
      (DJ[TetSz]^[4, MFDI + 2] in [' ', '(', 'x', '*']) then
    begin
      Sikerult := false;
      Exit;
    end; { if MFDI }
    MFDJ := MFDI + 1;
    while (MFDJ < DJDRMeret[4]) and
      (not (DJ[TetSz]^[4, MFDJ + 1] in ['(', ' '])) do
        Inc(MFDJ);
    MenyFelDolg(Copy(DJ[TetSz]^[4], MFDI + 2, MFDJ - MFDI - 1),
      TM, ME, Sikerult);
    if not Sikerult then
      Exit;
  end { if DJ }
  else { darab }
  begin
    ME := '1';
    TM := 1;
  end; { if DJ }
  Val(DJ[TetSz]^[2], MFDI, MFDK);
  TM := TM * MFDI; { tenyleges mennyiseg }
end; { MeretFelDolg }

procedure MSZFelDolg(TetSz : integer; var AKM : byte; var ME : char;
  AKFrissit : boolean; var Sikerult : boolean);

var MSZFDI, MSZFDJ : integer;

begin
  Sikerult := true;
  for MSZFDJ := 1 to DJDRMeret[7] do
    DJ[TetSz]^[7, MSZFDJ] := UpCase(DJ[TetSz]^[7, MSZFDJ]);
  MSZFDI := 0;
  repeat
    Inc(MSZFDI);
  until (MSZFDI = AKMeret + 1) or (DJ[TetSz]^[7] =
    Copy(MSZKodok[MSZFDI], 1, 5));
  if MSZFDI <= AKMeret then
  begin
    if MertEgys[MSZFDI] <> ME then
    begin
      Sikerult := false;
      Exit;
    end; { if MertEgys }
  end { if DJ }
  else
    if AKFrissit then
    begin { uj anyag felvetele az szabvanykonyvtarba }
      if AKMeret = MaxKM then
      begin
        Sikerult := false;
        Exit;
      end; { if AKMeret }
      AKMeret := MSZFDI;
      MSZNevek[AKMeret] := Copy(DJ[TetSz]^[3] + SPC, 1, 30);
      MSZKodok[AKMeret] := Copy(DJ[TetSz]^[7] + SPC, 1, 12);
      MertEgys[AKMeret] := ME;
    end; {if MSZFDI else }
  AKM := MSZFDI;
end; { MSZFelDolg }

procedure KeszitJSZ(AKM : integer; JM : JMTipus; UjAnyag : AnyTipus;
  var JSZ : comp; var ES : real);

var
  KI, KJ, KK, KKod : integer;
  K1, K2, K3 : real;

begin
  KI := 0;
  repeat
    Inc(KI);
  until (KI > IsmAnySzam) or (UjAnyag = AnyagNevek[KI]);
  KJ := 0; { elso szam elejenek keresese }
  while (KJ < Length(JM)) and
    (not (JM[KJ + 1] in ['.', '0'..'9'])) do
      Inc(KJ);
  K1 := 0;
  K2 := 0;
  K3 := 0;
  if KJ < Length(JM) then
  begin
    KK := KJ + 1; { elso szam vegenek keresese }
    while (KK < Length(JM)) and
      (JM[KK + 1] in ['.', '0'..'9']) do
        Inc(KK);
    Val(Copy(JM, KJ + 1, KK - KJ), K1, KKod);
    if KKod <> 2 then
    begin
      if KKod > 0 then
        Val(Copy(JM, KJ + 1, KKod - 1), K1, KKod);
      KJ := KK + 1; { masodik szam elejenek  keresese }
      while (KJ < Length(JM)) and
        (not (JM[KJ + 1] in ['.', '0'..'9'])) do
          Inc(KJ);
      if KJ < Length(JM) then
      begin
        KK := KJ + 1; { masodik szam vegenek keresese }
        while (KK < Length(JM)) and
          (JM[KK + 1] in ['.', '0'..'9']) do
            Inc(KK);
        Val(Copy(JM, KJ + 1, KK - KJ), K2, KKod);
        if KKod <> 2 then
        begin
          if KKod > 0 then
            Val(Copy(JM, KJ + 1, KKod - 1), K2, KKod);
          KJ := KK + 1; { harmadik szam elejenek  keresese }
          while (KJ < Length(JM)) and
            (not (JM[KJ + 1] in ['.', '0'..'9'])) do
              Inc(KJ);
          if KJ < Length(JM) then
          begin
            KK := KJ + 1; { harmadik szam vegenek keresese }
            while (KK < Length(JM)) and
              (JM[KK + 1] in ['.', '0'..'9']) do
                Inc(KK);
            Val(Copy(JM, KJ + 1, KK - KJ), K3, KKod);
            if KKod > 2 then
              Val(Copy(JM, KJ + 1, KKod - 1), K3, KKod);
            if (KKod <> 0) or (K3 >= 100000) then
              K3 := 0;
          end; { if KJ }
          if K2 >= 10000 then
            K2 := 0;
        end { if KKod }
        else
          K2 := 0;
      end; { if KJ }
      if K1 >= 100000 then
        K1 := 0;
    end { if KKod }
    else
      K1 := 0;
  end; { if KJ }
  JSZ := AKM * 1E+16 + KI * 1E+14 +
    (99999 - Round(K1)) * 1E+9 + (9999 - Round(K2)) * 1E+5 +
    (99999 - Round(K3));
  case AKM of
    3, 52 : ES := (K1 - K2) * Pi * K2 * AcelFS / 1000;
    1, 2, 73 : ES := (K1 - K2) * Pi * K2 * K3 * AcelFS / 1000000;
    4, 20 : ES := K1 * K1 * Pi * K2 * AcelFS / 4000000;
    5, 15 : ES := K1 * K2 * K3 * AcelFS / 1000000;
    13, 14, 16 : ES := K1 * K2 * AcelFS / 1000;
    17..19 : ES := K1 * AcelFS;
    21, 50 : ES := K1 * K1 * Pi * AcelFS / 4000;
    22 : ES := K1 * K1 * 0.002598 * AcelFS;
    23 : ES := K1 * K1 * AcelFS / 1000;
    51 : ES := K1 * K2 - (K1 - 2 * K3) * (K2 - 2 * K3) * AcelFS
           / 1000;
    56, 57 : ES := K1 * ITFS;
    58 : if K2 = 0 then
           ES := K1 * K1 * Pi * ITFS / 4000
         else
           ES := K1 * K2 * ITFS / 1000;
  else
    ES := 0;
  end; { case }
end; { KeszitJSZ }

procedure FelDolgoz;

var
  AJMeret, RajzSorSzam,
  TetSz, FI, FJ, FK : integer;
  AKMut : byte;
  JelMeret, Meny : string[17];
  RSorSz : string[4];
  TMeny : real;
  MertE : char; { mertekegyseg }
  Sikerult : boolean;
  AJ : AJTipus;

procedure Hiba;

var HI : integer;

begin
  Write('A feldolgoz†s megszakadt! [ENTER] ');
  for HI := SorokSzama downto 1 do
    Dispose(DJ[HI]);
  for HI := AJMeret downto 1 do
    Dispose(AJ[HI]);
  ReadLn;
end; { Hiba }

procedure TetelFelDolg(TetSz : integer; var Sikerult : boolean);

var
  TDI, TDJ, TDK, TDKod : integer;
  TSuly : real;
  UjAny : string[11];

function MegTalalta : boolean;

var
  MTI : integer;
  Any : string[11];

begin
  Any[0] := Chr(DJDRMeret[5]);
  with AJ[TDI]^ do
  begin
    for MTI := 1 to DJDRMeret[5] do
      Any[MTI] := UpCase(Anyag[MTI]);
    MegTalalta := (AKMutato = AKMut) and (JellM = JelMeret) and
      (Any = UjAny);
  end; { with }
end; { MegTalalta }

begin { TetelFelDolg }
  UjAny[0] := Chr(DJDRMeret[5]);
  for TDI := 1 to DJDRMeret[5] do
    UjAny[TDI] := UpCase(DJ[TetSz]^[5, TDI]);
  TDI := 0;
  repeat
    Inc(TDI);
  until (TDI = AJMeret + 1) or MegTalalta;
  if TDI <= AJMeret then
    with AJ[TDI]^ do
    begin
      TenylM := TenylM + TMeny;
      Val(DJ[TetSz]^[8], TSuly, TDKod);
      Suly := Suly + TSuly;
      TDJ := Length(ErintRajz);
      while (TDJ > 0) and (ErintRajz[TDJ] <> ',') do
        Dec(TDJ);
      Val(Copy(ErintRajz, TDJ + 1, Length(ErintRajz) - TDJ), TDK, TDKod);
      if TDK <> RajzSorSzam then
      begin
        Str(RajzSorSzam, RSorSz);
        ErintRajz := ErintRajz + ',' + RSorSz;
      end; { if TDK }
    end { if TDI }
  else
  begin { uj anyag felvetele az anyagjegyzekbe }
    if AJMeret = MaxAJMeret then
    begin
      Sikerult := false;
      WriteLn('AnyagjegyzÇk t£lcsordult.');
      Hiba;
      Exit;
    end; { if AJMeret }
    AJMeret := TDI;
    New(AJ[AJMeret]);
    with AJ[AJMeret]^ do
    begin
      AKMutato := AKMut;
      TenylM := TMeny;
      JellM := JelMeret;
      Anyag := DJ[TetSz]^[5];
      Val(DJ[TetSz]^[8], Suly, TDKod);
      Str(RajzSorSzam, RSorSz);
      ErintRajz := RSorSz;
      KeszitJSZ(AKMutato, JellM, UjAny, JelzoSzam, EgysSuly);
    end; { with }
  end; { if TDI else }
end; { TetelFelDolg }

procedure AJRendez(L, R: Integer); { gyorsrendezo jelzoszam szerint }

var
  I, J: Integer;
  X, Y: AJSorMutTipus;

begin
  I := L;
  J := R;
  X := AJ[(L + R) div 2];
  repeat
    while AJ[I]^.JelzoSzam < X^.JelzoSzam do Inc(I);
    while X^.JelzoSzam < AJ[J]^.JelzoSzam do Dec(J);
    if I <= J then
    begin
      Y := AJ[I];
      AJ[I] := AJ[J];
      AJ[J] := Y;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then AJRendez(L, J);
  if I < R then AJRendez(I, R);
end; { Rendez }

procedure NyomtatAJ;

var
  DEv, DHo, DNap, DNapNev : word;
  NI, NJ, NS, NO, NK : integer;
  Obj : string[20];
  TorNev : string[26];
  F : file of char;
  L : text;
  ABill : char;
  SN : string[30];
  SK : string[12];
  Szorzo, OsszKeszSuly : real;

procedure AJFejLec;
begin
  WriteLn(L, '…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕª');
  WriteLn(L, '∫  ' + CegNev + '  ≥       Objektum:        ≥ JegyzÇks' +
    'z†m:        ≥ Oldal: ∫');
  WriteLn(L, '∫                     ≥  ' + Obj + '  ≥   ' + Copy(AM, 1, 10)
    + '-A0000  ≥   ', NO : 2, '   ∫');
  WriteLn(L, '«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ∂');
  WriteLn(L, '∫ Poz°ci¢sz†m:        ≥      ANYAGJEGYZêK      ≥ TîrÇscso' +
    'port:                ∫');
  WriteLn(L, '∫                     ≥                        ≥  ' + TorNev
    + '  ∫');
  WriteLn(L, '«ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  WriteLn(L, '∫Sor-≥      MegnevezÇs  /  MSZ       ≥      RendelÇsi    ' +
    '   ≥                 ∫');
  WriteLn(L, '∫sz†m≥      MÇret       ≥   Anyag    ≥ s£ly (kg)≥ mennyis' +
    'Çg ≥ êrintett rajzok ∫');
  WriteLn(L, '«ƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ' +
    'ƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  WriteLn(L);
end; { AJFejLec }

procedure BeKerTor;
begin
  Write('Mi a tîrÇscsoport neve: ');
  ReadLn(TorNev);
  TorNev := Copy(TorNev + SPC, 1, 26);
end; { BeKerTor }

procedure KiNyNev;

var KNyJ : integer;

begin
  with AJ[NI]^ do
  begin
    WriteLn(L);
    NJ := 30;
    while MSZNevek[AKMutato, NJ] = ' ' do
      Dec(NJ);
    SN := Copy(MSZNevek[AKMutato], 1, NJ);
    Write(L, '      ', SN);
    if MSZvKod[AKMutato] = '1' then
    begin
      KNyJ := 1;
      while (MSZKodok[AKMutato, KNyJ] = '*') and (KNyJ < 12 ) do
        Inc(KNyJ);
      NJ := 12;
      while (MSZKodok[AKMutato, NJ] = ' ') and (NJ > 1) do
        Dec(NJ);
      SK := Copy(MSZKodok[AKMutato], KNyJ, NJ - KNyJ + 1);
      WriteLn(L, ' / ' + SK);
      Write(L, '      ');
      for KNyJ := 1 to Length(SN) + Length(SK) + 3 do
        Write(L, '-');
    end { if MSZvKod }
    else
    begin
      WriteLn(L);
      Write(L, '      ');
      for KNyJ := 1 to Length(SN) do
        Write(L, '-');
    end; {if MSZvKod else }
  end; { with }
  WriteLn(L);
  Inc(NS, 3);
end; { KiNyNev }

begin { NyomtatAJ }
  if MBill = 'A' then
    BeKerTor
  else
    case AS[5] of
      '0' : BeKerTor;
      'A'..'Z' : TorNev := ToresNevek[Ord(AS[5]) - 65];
      '1' : TorNev := ToresNevek[Ord(AS[5]) - 23];
    end; { case }
  NI := 1;
  while not Kell[NI] do
    Inc(NI);
  Assign(F, Ut + Dir[NI] + '.DJF');
  Assign(L, Ut + 'ANYAGJ.$$$');
  {$I-}
  Reset(F);
  Rewrite(L);
  {$I+}
  if IOResult <> 0 then
  begin
    Write('I/O hiba! [Enter] ');
    ReadLn;
    Exit;
  end; { if }
  Seek(F, 49);
  Obj[0] := Chr(20);
  for NI := 1 to 20 do
    Read(F, Obj[NI]);
  Close(F);
  GetDate(DEv, DHo, DNap, DNapNev);
  NO := 1;
  NS := 0;
  for NI := 1 to AJMeret do
    with AJ[NI]^ do
    begin
      if NS = 0 then
        AJFejLec;
      if (NS = 0) or (AJ[NI - 1]^.AKMutato <> AKMutato) then
        KiNyNev;
      Write(L, NI : 4, '. ', JellM, ' ' : 19 - Length(JellM), Anyag, '  ');
      if MertEgys[AKMutato] = '1' then
        Szorzo := 1
      else
        Szorzo := BiztSzorzo;
      if EgysSuly > 0 then
        Write(L, EgysSuly * TenylM * Szorzo : 9 : 1)
      else
        Write(L, Suly * Szorzo : 9 : 1);
      case MertEgys[AKMutato] of
        '1' : Write(L, Round(TenylM) : 7, '   db  ');
        '2' : Write(L, TenylM * Szorzo : 9 : 1, ' m   ');
        '3' : Write(L, TenylM * Szorzo : 9 : 1, ' m˝  ');
      end; { case }
      NK := 0;
      for NJ := 1 to Length(ErintRajz) do
      begin
        Inc(NK);
        if (NK > 14) and (ErintRajz[NJ - 1] = ',') then
        begin
          NK := 0;
          Inc(NS);
          WriteLn(L);
          Write(L, SPC + Copy(SPC, 1, 29));
        end; { if }
        Write(L, ErintRajz[NJ]);
      end; { for }
      WriteLn(L);
      Inc(NS);
      if Length(ErintRajz) < 18 then
      begin
        WriteLn(L);
        Inc(NS);
      end; { if Length }
      if (NS > AJSor) or (NI = AJMeret) then
      begin
        NS := 0;
        WriteLn(L, '»ÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕœ' +
          'ÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
        WriteLn(L);
        WriteLn(L, ' D†tum: ', DEv, '. ', DHo : 2, '. ', DNap : 2, '.' +
          Copy(SPC, 1, 29) + 'Al†°r†s: ...................');
        Write(L, FormFeed);
        Inc(NO);
      end; { if NS }
    end; { with }
  if (MBill = 'A') then
  begin
    WriteLn(L, Copy(SPC, 1, 24) + 'FELDOLGOZOTT RAJZOK RAJZJEGYZêKE:');
    WriteLn(L, Copy(SPC, 1, 24) + '---------------------------------');
    WriteLn(L);
    NJ := 0;
    OsszKeszSuly := 0;
    for NI := 1 to Count do
      if Kell[NI] then
      begin
        Inc(NJ);
        NyomtatRJSor(L, NI, NJ, OsszKeszSuly);
        if NJ mod (RJSor + 3) = 0 then
          Write(L, FormFeed);
      end; { if }
    WriteLn(L);
    WriteLn(L, SPC + '                  ôssz. kÇszs£ly:',
      OsszkeszSuly : 9 : 1, ' kg');
    WriteLn(L);
    WriteLn(L);
    WriteLn(L, ' D†tum: ', DEv, '. ', DHo : 2, '. ', DNap : 2, '.' +
      Copy(SPC, 1, 29) + 'Al†°r†s: ...................');
    Write(L, FormFeed);
  end; { if }
  Close(L);
  KiirListaFajl('ANYAGJ');
end; { NyomtatAJ }

begin { FelDolgoz }
  ClrScr;
  WriteLn('Feldolgoz†s ... ');
  AJMeret := 0;
  RajzSorSzam := 0;
  for FI := 1 to Count do { minden kivalasztott rajz }
    if Kell[FI] then
    begin
      BeToltFN(Dir[FI]);
      Inc(RajzSorSzam);
      for FJ := 1 to SorokSzama do { minden tetele }
      begin
        MeretFelDolg(FJ, JelMeret, TMeny, MertE, Sikerult);
        if not Sikerult then
        begin
          WriteLn('Hiba az ', RajzSorSzam, '. darabjegyzÇk ', FJ,
            '. sor†ban.');
          Hiba;
          Exit;
        end; { if }
        MSZFelDolg(FJ, AKMut, MertE, true, Sikerult);
        if not Sikerult then
        begin
          WriteLn('Hiba az ', RajzSorSzam, '. darabjegyzÇk ', FJ,
            '. sor†ban.');
          Hiba;
          Exit;
        end; { if }
        TetelFelDolg(FJ, Sikerult);
        if not Sikerult then
          Exit;
      end; { for FJ }
    end; { if Kell }
  if AJMeret = 0 then
  begin
    Write('Nincs kiv†lasztva rajz. [Enter] ');
    ReadLn;
    Exit;
  end; { if }
  AJRendez(1, AJMeret);
  for FK := SorokSzama downto 1 do
    Dispose(DJ[FK]);
  NyomtatAJ;
  for FK := AJMeret downto 1 do
    Dispose(AJ[FK]);
  SorokSzama := 0;
end; { FelDolgoz }

procedure AnyagJR;

var
  AI : integer;
  ASik : boolean;

begin
  repeat
    Write('KÇrem az objektumsz†mot: ');
    ReadLn(AM);
    AM := AM + '-000';
    AS := RSZtoFN(AM + '-00000    ', ASik);
  until ASik;
  for AI := 1 to MaxDirSize do
    Kell[AI] := false;
  ToltLista(Copy(AS, 1, 4), true, AS);
  if Count > 0 then
    Feldolgoz;
end; { AnyagJR }

procedure AnyagJT;

var
  AI : integer;
  ASik : boolean;

begin
  repeat
    Write('KÇrem az objektum- Çs a tîrÇssz†mot: ');
    ReadLn(AM);
    AS := RSZtoFN(AM + '-00000    ', ASik);
  until ASik;
  for AI := 1 to MaxDirSize do
    Kell[AI] := true;
  FindFiles(Copy(AS, 1, 5));
  if Count > 0 then
  begin
    QuickSort(1, Count);
    FelDolgoz;
  end
  else
  begin
    ClrScr;
    Write('Nincs megfelelì f†jl. [Enter] ');
    ReadLn;
  end; { else }
end; { AnyagJT }

procedure RajzJT;

var
  RM : RSZTipus;
  RS : FNTipus;
  RI, NI, NJ : integer;
  Obj : string[20];
  DEv, DHo, DNap, DNapNev : word;
  OsszKeszSuly : real;
  RSik : boolean;
  TorNev : string[26];
  F : file of char;
  L : text;

procedure RJFejLec;
begin
  WriteLn(L, '…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕª');
  WriteLn(L, '∫  ' + CegNev + '  ≥       Objektum:        ≥ JegyzÇks' +
    'z†m:        ≥ Oldal: ∫');
  WriteLn(L, '∫                     ≥  ' + Obj + '  ≥   ' + Copy(RM, 1, 10)
    +  '-R0000  ≥   ', NJ div RJSor + 1 : 2, '   ∫');
  WriteLn(L, '«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ∂');
  WriteLn(L, '∫ Poz°ci¢sz†m:        ≥      RAJZJEGYZêK       ≥ TîrÇscso' +
    'port:                ∫');
  WriteLn(L, '∫                     ≥                        ≥  ' + TorNev
    + '  ∫');
  WriteLn(L, '«ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ' +
    '¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  WriteLn(L, '∫SSz.≥Rajzsz†m /m¢dos°t†s≥            Rajzc°m            ' +
    '≥Darabj.≥    S£ly    ∫');
  WriteLn(L, '«ƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    '≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  WriteLn(L);
end; { RJFejLec }

begin
  repeat
    Write('KÇrem az objektum- Çs a tîrÇssz†mot: ');
    ReadLn(RM);
    RS := RSZtoFN(RM + '-00000    ', RSik);
  until RSik;
  for RI := 1 to MaxDirSize do
    Kell[RI] := true;
  FindFiles(Copy(RS, 1, 5));
  if Count > 0 then
  begin
    QuickSort(1, Count);
    case RS[5] of
      '0' : begin
          Write('Mi a tîrÇscsoport neve: ');
          ReadLn(TorNev);
          TorNev := Copy(TorNev + SPC, 1, 26);
        end; { case 0 }
      'A'..'Z' : TorNev := ToresNevek[Ord(RS[5]) - 65];
      '1' : TorNev := ToresNevek[Ord(RS[5]) - 23];
    end; { case }
    Assign(F, Ut + Dir[1] + '.DJF');
    Assign(L, Ut + 'RAJZJ.$$$');
    {$I-}
    Reset(F);
    Rewrite(L);
    {$I+}
    if IOResult <> 0 then
    begin
      Write('I/O hiba! [Enter] ');
      ReadLn;
      Exit;
    end; { if }
    Seek(F, 49);
    Obj[0] := Chr(20);
    for NI := 1 to 20 do
      Read(F, Obj[NI]);
    Close(F);
    NJ := 0;
    OsszKeszSuly := 0;
    for NI := 1 to Count do
      if Kell[NI] then
      begin
        if (NJ mod RJSor) = 0 then
        begin
          if NI > 1 then
            Write(L, FormFeed);
          RJFejLec;
        end; { if NJ }
        Inc(NJ);
        NyomtatRJSor(L, NI, NJ, OsszKeszSuly);
        if (NJ mod RJSor = 0) or (NI = Count) then
        begin
          WriteLn(L, '»ÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
            'ÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕº');
        end; { if NJ }
      end; { if Kell }
    WriteLn(L, SPC + '                  ôssz. kÇszs£ly:',
      OsszkeszSuly : 9 : 1, ' kg');
    WriteLn(L);
    WriteLn(L);
    GetDate(DEv, DHo, DNap, DNapNev);
    WriteLn(L, ' D†tum: ', DEv, '. ', DHo : 2, '. ', DNap : 2, '.' +
      Copy(SPC, 1, 29) + 'Al†°r†s: ...................');
    Write(L, FormFeed);
    Close(L);
    KiirListaFajl('RAJZJ');
  end
  else
  begin
    ClrScr;
    Write('Nincs megfelelì f†jl. [Enter] ');
    ReadLn;
  end; { else }
end; { RajzJT }

procedure AnyagKonyvTarNy;

var KI : 1..MaxKM;

begin
  Write('Szabv†nykînyvt†r kinyomtat†sa - KÇsz°tse elì a nyomtat¢t! ' +
    '[Enter] ');
  ReadLn;
  Write('Nyomtat†s ... ');
  WriteLn(Lst, SPC + 'SZABVèNYKôNYVTèR');
  WriteLn(Lst);
  WriteLn(Lst, Copy(SPC, 1, 25), 'NÇv', Copy(SPC, 1, 15),
    'MSZ vagy k¢d  MÇrtÇkegysÇg');
  WriteLn(Lst, '       ---------------------------------------------------' +
    '------------');
  WriteLn(Lst);
  for KI := 1 to AKMeret do
  begin
    Write(Lst, KI : 10, '. ', Pottyoz(KI), ' ');
    if MSZKodok[KI, 8] = ' ' then
    begin
      Write(Lst, Copy(MSZKodok[KI], 1, 6));
      case MSZvKod[KI] of
        '0' : Write(Lst, '(k¢d) ');
        '1' : Write(Lst, ' . . .');
      end; { case MSZvKod }
    end { if MSZKodok }
    else
      Write(Lst, MSZKodok[KI]);
    Write(Lst, '  ');
    case MertEgys[KI] of
      '1' : WriteLn(Lst, 'db');
      '2' : WriteLn(Lst, 'm');
      '3' : WriteLn(Lst, 'm˝');
    end; { case }
  end; { for }
  Write(Lst, FormFeed);
end; { AnyagKonyvTarNy }

end. { unit }