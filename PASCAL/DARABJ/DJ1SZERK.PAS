{ DARABJEGYZêK NYILVèNTART¢ êS FELDOLGOZ¢ PROGRAM
  Copyright (c) 1991  T¢th B†lint

DarabjegyzÇk szerkesztì unit ( Turbo Pascal 6.0 )
}
unit DJ1Szerk;

{$E+,N+,B-,V-}

interface

uses Crt, Printer, Dos, DJ1Dolg;

procedure DarabJSZ;

implementation

procedure DarabJSZ;

const
  DVonal : DSorTipus = '«ƒƒƒ≈ƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    '≈ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒ∂';
  DVeg : DSorTipus = '»ÕÕÕœÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'œÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕœÕÕÕÕÕÕÕœÕÕÕÕÕº';

var
  DKezdet, TSZ : 1..MaxTSZ;
  TSor : 0..MaxT;
  TR : 1..MaxTR;
  TP : 1..22;
  DR : 1..MaxDR;
  DP : 1..18;
  FR : 1..MaxFR;
  FP : 1..32;
  DJMod : 1..3;
  Puffer : string[32];
  Vege, KiLepes : boolean;
  DI : integer;
  SJo : boolean;
  SNev : FNTipus;

procedure InitSz;
begin
  DJMod := 1;
  DKezdet := 1;
  TSZ := 1;
  DR := 2;
  DP := 1;
  FR := 1;
  FP := 1;
  Puffer := SPC;
end; {  InitSz }

procedure TorolDJ;

var
  DEv, DHo, DNap, DNapNev : word;
  DEvS        : string[4];
  DHoS, DNapS : string[2];
  TorolI      : byte;

begin { TorolDJ }
  for TorolI := 1 to MaxFR do
    DJFL[TorolI] := Copy(SPC, 1, DJFLMeret[TorolI]);
  GetDate(DEv, DHo, DNap, DNapNev);
  Str(DEv : 4, DevS);
  Str(DHo : 2, DHoS);
  Str(DNap : 2, DNapS);
  DJFL[2] := DEvS + '.' + DHoS + '.' + DNapS + '.';
  SorokSzama := 0;
  ToresSzam := 0;
  KezdoTor := 1;
  KovTSZ := 1;
  InitSz;
end; { TorolDJ }

function KiIrDJTores(ToresSz : integer) : DJTSTipus;

var
  KDJTI : byte;
  KDJTS : DJTSTipus;

begin
  if ToresSz < 1 then
    KiIrDJTores := '∫   ≥                      ≥        ≥        '
  else
  begin
    KDJTS := '∫ ';
    if ToresSzam < ToresSz then
      KDJTS := KDJTS + '  '
    else
      KDJTS := KDJTS + Chr(ToresSz + KezdoTor + 95) + ' ';
    for KDJTI := 1 to MaxTR do
      KDJTS := KDJTS + '≥' + DJT[ToresSz, KDJTI];
    KiIrDJTores := KDJTS;
  end; { else }
end; { KiIrDJTores }

procedure KiIrFejLec;
begin
  GotoXY(1, 1);
  WriteLn('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn('∫ ' + CegNev + ' ≥      DARABJEGYZêK      ≥ Rajz csoport:' +
    DJFL[1] + ' ≥ F1 Seg°tsÇg ∫');
  WriteLn('«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  WriteLn('∫ D†tum: ', DJFL[2], '≥ NÇv: ', DJFL[3],  ' ≥ Objektum: ',
    DJFL[4], ' ∫');
  WriteLn('«ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  Write(KiIrDJTores(ToresSzam - 2));
  WriteLn('≥ Rajzsz†m: ', DJFL[5], ' ∫');
  WriteLn('«ƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  Write(KiIrDJTores(ToresSzam - 1));
  WriteLn('≥ MegnevezÇs:                    ∫');
  WriteLn('«ƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¥ '
    + DJFL[6] + ' ∫');
  Write(KiIrDJTores(ToresSzam));
  WriteLn('≥ ' + DJFL[7] + ' ∫');
  WriteLn('ÃÕÕÕÿÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ—' +
    'ÕÕÕÕÕÕ—ÕÕÕÕÕÕÕ—ÕÕÕÕÕπ');
  WriteLn('∫TSZ≥ DB ≥    MEGNEVEZêS   ≥      MêRET      ≥   ANYAG   ≥' +
    'KG/DB ≥ S£LY  ≥ MSZ ∫');
  WriteLn('ÃÕÕÕÿÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÿ' +
    'ÕÕÕÕÕÕÿÕÕÕÕÕÕÕÿÕÕÕÕÕπ');
end; { KiIrFejLec }

procedure KiIrT;

var KTI : 0..2;

begin
  GoToXY(1, 6);
  for KTI := 2 downto 0 do
  begin
    Write(KiIrDJTores(TSor - KTI));
    WriteLn;
    WriteLn;
  end; { for }
end; { KiIrT }

function DSor(Sor : word) : DSorTipus;

var
  DSorI : 1..MaxDR;
  S : DSorTipus;

begin
  if Sor > SorokSzama then
    DSor := '∫   ≥    ≥                 ≥                 ≥           ≥' +
      '      ≥       ≥     ∫'
  else
  begin
    S := '∫';
    for DSorI := 1 to 6 do
      S := S + Copy(DJ[Sor]^[DSorI], 1, DJDRMeret[DSorI]) + '≥';
    S := S + Copy(DJ[Sor]^[8], 1, DJDRMeret[8]) + '≥' +
      Copy(DJ[Sor]^[7], 1, DJDRMeret[7]) + '∫';
    DSor := S;
  end; { else }
end; { DSor }

procedure DCrsr;
begin
  GoToXY(DJDRKezdoX[DR] + DP - 1, 14 + 2 * (TSZ - DKezdet));
end; { DCrsr }

procedure KiIrDJ;

var KDJI : byte;

begin
  GotoXY(1, 14);
  for KDJI := DKezdet to DKezdet + MaxDSor - 1 do
  begin
    WriteLn(DSor(KDJI));
    WriteLn(DVonal);
  end; { for }
  DCrsr;
end; { KiIrDJ }

procedure KiMentDJ;

var
  DJF : file of char;
  SzamS : string[8];
  B : boolean;
  KMI, KMJ, KMKod : integer;
  KMS : real;

procedure KiIrFbe(Elem : MaxSMeretT; Hossz : byte);

var KFI : byte;

begin
  for KFI := 1 to Hossz do
    Write(DJF, Elem[KFI]);
end; { KiIrFbe }

begin
  ClrScr;
  if Ut[1] = 'A' then
  begin
    Write('Rakja be az adatt†rol¢ lemezt az A: meghajt¢ba! [Enter] ');
    ReadLn;
  end; { if }
  WriteLn('DarabjegyzÇk mentÇse ...');
  Assign(DJF, Ut + RSZtoFN(DJFL[5], B) + '.DJF');
  {$I-}
  ReWrite(DJF);
  {$I+}
  if IOResult <> 0 then
  begin
    Write('I/O hiba! [Enter] ');
    ReadLn;
  end { if }
  else
  begin
    Str(SorokSzama : 3, SzamS);
    KiIrFbe(SzamS, 3);
    Str(KovTSZ : 3, SzamS);
    KiIrFbe(SzamS, 3);
    Str(ToresSzam : 2, SzamS);
    KiIrFbe(SzamS, 2);
    Str(KezdoTor : 2, SzamS);
    KiIrFbe(SzamS, 2);
    OsszSuly := 0;
    for KMI := 1 to SorokSzama do
    begin
      Val(DJ[KMI]^[MaxDR + 1], KMS, KMKod);
      OsszSuly := OsszSuly + KMS;
    end; { for }
    Str(OsszSuly : 8 : 1, SzamS);
    KiIrFbe(SzamS, 8);
    for KMI := 1 to MaxFR do
      KiIrFbe(DJFL[KMI], DJFLMeret[KMI]);
    for KMI := 1 to ToresSzam do
      for KMJ := 1 to MaxTR do
        KiIrFbe(DJT[KMI, KMJ], DJTMeret[KMJ]);
    for KMI := 1 to SorokSzama do
      for KMJ := 1 to MaxDR + 1 do
        KiIrFbe(DJ[KMI]^[KMJ], DJDRMeret[KMJ]);
    Close(DJF);
  end; { else }
  ClrScr;
  KiIrFejLec;
  KiIrDJ;
  if DJMod = 2 then
    KiIrT;
end; { KiMentDJ }

procedure Help(KezdoHKep : byte);

const
  HKepSzam = 10;

var
  HVege : boolean;
  HBill : char;
  HKep : byte;
  HJ : byte;

procedure MSZlap(Kezdo : byte);

var HI : integer;

begin
  Write('SZABVèNYKôNYVTèR');
  if Kezdo > 1 then
    WriteLn(' ( folytat†s )')
  else
    WriteLn;
  WriteLn(Copy(SPC, 1, 25), 'NÇv', Copy(SPC, 1, 15),
    'MSZ vagy k¢d  MÇrtÇkegysÇg');
  WriteLn('       ---------------------------------------------------' +
    '------------');
  for HI := Kezdo to Kezdo + 19 do
  begin
    Write(HI : 10, '. ');
    if HI <= AKMeret then
    begin
      Write(Pottyoz(HI), ' ');
      if MSZKodok[HI, 8] = ' ' then
      begin
        Write(Copy(MSZKodok[HI], 1, 6));
        case MSZvKod[HI] of
          '0' : Write('(k¢d) ');
          '1' : Write(' . . .');
        end; { case MSZvKod }
      end { if MSZKodok }
      else
        Write(MSZKodok[HI]);
      Write('  ');
      case MertEgys[HI] of
        '1' : WriteLn('db');
        '2' : WriteLn('m');
        '3' : WriteLn('m˝');
      end; { case }
    end { if HI }
    else
      WriteLn;
  end; { for }
end; { MSZlap }

begin { Segitseg }
  HKep := KezdoHKep;
  HVege := false;
  repeat
    ClrScr;
    WriteLn('Seg°tsÇg - kÇpernyì ', HKep : 2,
      '       Page Up / Page Down = lapoz†s');
    case HKep of
      1 : begin
          WriteLn;
          WriteLn('èltal†nos billentyñ funkci¢k');
          WriteLn('----------------------------');
          WriteLn;
          WriteLn(' F1 . . . . . .  Seg°tsÇg ( Billentyñ funkci¢k )');
          WriteLn(' Shift F1 . . .  Ismert anyagok list†ja');
          WriteLn(' Alt F1 . . . .  Szabv†nyok Çs k¢dok list†ja');
          WriteLn(' F2 . . . . . .  MentÇs h†ttÇrt†rol¢ra ( elìtte F5 )');
          WriteLn(' F3 . . . . . .  TîltÇs h†ttÇrt†rol¢r¢l');
          WriteLn(' F4 . . . . . .  Nyomtat†s ( elìtte F5 )');
          WriteLn(' F5 . . . . . .  DarabjegyzÇk formai ellenìrzÇse');
          WriteLn('                  ( Ha hib†t tal†l, akkor csipog Çs' +
            ' r††ll )');
          WriteLn(' F6 . . . . . .  S£lysz†mol†s a teljes darabjegyzÇk' +
            're ( ahol lehet )');
          WriteLn(' F7 . . . . . .  DarabjegyzÇk £j anyagainak felvÇte' +
            'le a szabv†nykînyvt†rba');
          WriteLn(' F8 . . . . . .  £j meghajt¢ Çs directory kijelîlÇse');
          WriteLn(' Alt F  . . . .  Ugr†s a fejlÇc mezìre');
          WriteLn(' Alt T  . . . .  Ugr†s a tîrÇs mezìre');
          WriteLn(' Alt D  . . . .  Ugr†s a tÇtel mezìre');
          WriteLn(' Tab, Shift Tab  Ugr†l†s a mezìk kîzîtt sorban');
          WriteLn(' Alt X, Esc . .  Vissza a fìmenÅhîz');
          Write('                  ( a darabjegyzÇk °gy elveszik, ' +
            'ezÇrt mentsÅk ki! )');
        end; { case 1 }
      2 : begin
          WriteLn('SzerkesztÇs');
          WriteLn('-----------');
          WriteLn(' '#27' '#26' '#24' '#25' . . . . . .  Kurzor moz' +
            'gat†s');
          WriteLn(' Ctrl '#27' '#26', Enter . .  LÇpkedÇs rublik†k ' +
            'kîzîtt');
          WriteLn(' Page Up / Down  . .  Lapoz†s elìre, h†tra');
          WriteLn(' Home / End  . . . .  Ugr†s rublika elejÇre, vÇgÇre');
          WriteLn(' Ctrl Home / End . .  Ugr†s sor elejÇre, vÇgÇre');
          WriteLn(' Ctrl Page Up / Down  Ugr†s darabjegyzÇk vagy m¢d' +
            'os°t†s mezì elejÇre, vÇgÇre');
          WriteLn(' BackSpace . . . . .  Elìzì karakter tîrlÇse');
          WriteLn(' Del . . . . . . . .  Kurzor alatti karakter ' +
            'tìrlÇse');
          WriteLn(' Ins . . . . . . . .  Sz¢kîz besz£r†sa');
          WriteLn(' Alt Z . . . . . . .  S£ly kisz†mol†sa ( ha lehetsÇ' +
            'ges )');
          WriteLn(' Alt B . . . . . . .  Aktu†lis anyag felvÇtele a ' +
            'szabv†nykînyvt†rba');
          WriteLn(' Alt R . . . . . . .  Rublika tîrlÇse');
          WriteLn(' Alt S . . . . . . .  EgÇsz sor tîrlÇse');
          WriteLn(' Alt Y . . . . . . .  Sor tîrlÇse, eltÅntetÇse' +
            ' a darabjegyzÇkbìl');
          WriteLn(' Alt N . . . . . . .  £j sor besz£r†sa');
          WriteLn(' Alt M . . . . . . .  Macskakîrîm');
          WriteLn(' Alt K . . . . . . .  Rublika m†sol†sa - a ' +
            'forr†srublika kijelîlÇse');
          WriteLn(' Alt V . . . . . . .  Rublika m†sol†sa - a ' +
            'cÇlrublika kijelîlÇse');
          WriteLn(' Alt 3 4 . . . . . .  Speci†lis karakterek ( Ì Çs ¯ )');
          WriteLn(' Alt A E I O U 1 2 .  êkezetes betÅk ( † Ç ° ¢ £' +
            ' î Å )');
          WriteLn;
          Write('Nem minden funkci¢ haszn†lhat¢ mindenhol, hanem csak ',
            'ott, ahol Çrtelme van.');
        end; { case 2 }
      3 : begin
          WriteLn;
          WriteLn('Be°r†si szab†lyok');
          WriteLn('-----------------');
          WriteLn('  Az MSZ rublik†ba az MSZ vagy k¢d elsì ît karakter' +
            'Çt kell beÅtni.');
          WriteLn('  A program †ltal ismeretlen anyagfÇlesÇg is tetszì' +
            'legesen be°rhat¢,');
          WriteLn('ekkor azonban a szabv†nyos megnevezÇs a darabjegyzÇ' +
            'kben tal†lt megnevezÇs.');
          WriteLn('  Csîvek, lemezek, kov†csolt darabok s£ly†t a progr' +
            'am sz†molja, ');
          WriteLn('Çs gombnyom†sra felaj†nlja. ( befoglal¢ s£ly )');
          WriteLn('  A mÇret rovat kitîltÇse:');
          WriteLn('    db  dimenzi¢ esetÇn:  jellemzì mÇret');
          WriteLn('    m   dimenzi¢ esetÇn:  jellemzì mÇret / mennyisÇg' +
            ' mm-ben');
          WriteLn('    m˝  dimenzi¢ esetÇn:  jellemzì mÇret / mennyisÇg' +
            ' mm * mm -ben');
          WriteLn('  Gy†rt†s esetÇn a kiindul¢ anyag jellemzìit kell be' +
            '°rni,');
          WriteLn('a tÇnyleges kÇszmÇretet ut†na, z†r¢jelben');
          WriteLn('  PÇld†ul            csì:  57x4/12600        , k¢d:' +
            ' 2448');
          WriteLn('         gy†rtott karima:  100x40(NA35,NNY16 , k¢d:' +
            ' *357');
          WriteLn('                   lemez:  10/350x420        , k¢d:' +
            ' 40');
          WriteLn('         gy†rtott csavar:  20/140(M20x135)   , k¢d:' +
            ' 4337');
          WriteLn('                  csavar:  M20x135           , k¢d:' +
            ' 2360');
          WriteLn('                     r£d:  20/1400           , k¢d:' +
            ' 4337');
          WriteLn('                  L-acÇl:  100x70x5/8000     , k¢d:' +
            ' 329');
          WriteLn('                Patent°v:  90¯-219.1x20R600  , k¢d:' +
            ' 2605');
          WriteLn('                 tol¢z†r:  NA150,NNY40       , k¢d:' +
            ' (1)1');
        end; { case 3 }
      4 : begin
          WriteLn;
          WriteLn('A gÇp †ltal ismert anyagok:');
          WriteLn('---------------------------');
          for HJ := 1 to IsmAnySzam do
            Write('     ', AnyagNevek[HJ], Copy(SPC, 1, 24));
          if WhereX > 1 then
            WriteLn;
          WriteLn;
          WriteLn('  Be°r†skor a kis- Çs nagybetÅk illetve a sz¢kîzîk ' +
            'nem sz†m°tanak,');
          WriteLn('ÅgyeljÅnk azonban a kîtìjelek, pontok stb. helyes ' +
            '°r†s†ra.');
        end; { case 4 }
      5..10 : MSZlap((HKep - 5) * 20 + 1);
    end; { case }
    GoToXY(28, 1);
    HBill := ReadKey;
    if HBill = #0 then
    begin
      if KeyPressed then
      begin
        HBill := ReadKey;
        case HBill of
          PgUp : HKep := (HKep + HKepSzam - 2) mod HKepSzam + 1;
          PgDn : HKep := HKep mod HKepSzam + 1;
          Home : HKep := 1;
          EndB : HKep := HKepSzam;
          ShiftF1 : HKep := 4;
          AltF1 : HKep := 5;
          else
            HVege := true;
        end; { case HBill }
      end; { if KeyPressed }
    end { if HBill }
    else
      HVege := true;
  until HVege;
  ClrScr;
  KiIrFejLec;
  KiIrDJ;
  if DJMod = 2 then
    KiIrT;
end; { Segitseg }

procedure Ellenoriz;

var
  SNev : FNTipus;
  SI, SJ : integer;

begin
  SNev := RSZtoFN(DJFL[5], SJo);
  if not SJo then
  begin
    DJMod := 1;
    FR := 5;
    FP := 1;
  end; { if }
  SI := 0;
  while SJo and (SI < MaxFR - 1) do
  begin
    Inc(SI);
    if DJFL[SI] = Copy(SPC, 1, DJFLMeret[SI]) then
    begin
      SJo := false;
      DJMod := 1;
      FR := SI;
      FP := 1;
    end; { if }
  end; { while }
  SI := 0;
  while SJo and (SI < SorokSzama) do
  begin
    Inc(SI);
    SJ := 0;
    while SJo and (SJ < MaxDR + 1) do
    begin
      Inc(SJ);
      if DJ[SI]^[SJ] = Copy(SPC, 1, DJDRMeret[SJ]) then
      begin
        SJo := false;
        DJMod := 3;
        if (SI < DKezdet) or (SI >= DKezdet + MaxDSor) then
          if SI > 3 then
            DKezdet := SI - 2
          else
            DKezdet := 1;
        TSZ := SI;
        if SJ <= MaxDR then
          DR := SJ
        else
          DR := 6;
        DP := 1;
        KiIrDJ;
      end; { if DJ }
    end; { while SJ }
  end; { while SI }
  Vege := not SJo;
  if not SJo then
    Write(Beep);
end; { Ellenoriz }

procedure Save;
begin
  Ellenoriz;
  if SJo then
    KiMentDJ;
end; { Save }

procedure Load;

var FNev : FNevTipus;

begin
  if Ut[1] = 'A' then
  begin
    ClrScr;
    Write('Rakja be az adatt†rol¢ lemezt az A: meghajt¢ba! [Enter] ');
    ReadLn;
  end; { if }
  ToltLista('', false, FNev);
  if FNev <> '' then
  begin
    BeToltFN(FNev);
    InitSz;
  end;
  ClrScr;
  KiIrFejLec;
  KiIrDJ;
  if DJMod = 2 then
    KiIrT;
end; { Load }

procedure NyomtatDJ;

var NI, NJ : integer;

begin
  Ellenoriz;
  if SJo then
  begin
    ClrScr;
    Write('DarabjegyzÇk kinyomtat†sa - KÇsz°tse elì a nyomtat¢t! [Enter] ');
    ReadLn;
    Write('Nyomtat†s ... ');
    for NI := 0 to SorokSzama div NySor do
    begin
      WriteLn(Lst, '…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕ' +
        'ÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª');
      WriteLn(Lst, '∫ ' + CegNev + ' ≥     DARABJEGYZêK       ≥ Rajz ' +
        'csoport: ' + DJFL[1] + '≥ Oldal:', NI + 1 : 2, '/',
        SorokSzama div NySor + 1 : 2, ' ∫');
      WriteLn(Lst, '«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ' +
        'ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
      WriteLn(Lst, '∫ D†tum: ' + DJFL[2] + '≥ NÇv: ' + DJFL[3] +
        ' ≥ Objektum: ' + DJFL[4] + ' ∫');
      WriteLn(Lst, '«ƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ' +
        'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
      Write(Lst, KiIrDJTores(ToresSzam - 2));
      WriteLn(Lst, '≥ Rajzsz†m: ' + DJFL[5] + ' ∫');
      WriteLn(Lst, '«ƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ' +
        'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
      Write(Lst, KiIrDJTores(ToresSzam - 1));
      WriteLn(Lst, '≥ MegnevezÇs:                    ∫');
      WriteLn(Lst, '«ƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¥ '
        + DJFL[6] + ' ∫');
      Write(Lst, KiIrDJTores(ToresSzam));
      WriteLn(Lst, '≥ ' + DJFL[7] + ' ∫');
      WriteLn(Lst, 'ÃÕÕÕÿÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕ' +
        'ÕÕÕÕÕ—ÕÕÕÕÕÕ—ÕÕÕÕÕÕÕ—ÕÕÕÕÕπ');
      WriteLn(Lst, '∫TSZ≥ DB ≥    MEGNEVEZêS   ≥      MêRET      ≥   ANY' +
        'AG   ≥KG/DB ≥ S£LY  ≥ MSZ ∫');
      WriteLn(Lst, 'ÃÕÕÕÿÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕ' +
        'ÕÕÕÕÕÿÕÕÕÕÕÕÿÕÕÕÕÕÕÕÿÕÕÕÕÕπ');
      for NJ := 1 to NySor - 1 do
      begin
        WriteLn(Lst, DSor(NI * NySor + NJ));
        WriteLn(Lst, DVonal);
      end; { for NJ }
      WriteLn(Lst, DSor((NI + 1) * NySor));
      WriteLn(Lst, DVeg);
      if (NI + 1) * NySor >= SorokSzama then
        Write(Lst, SPC + Copy(SPC, 1, 22) + 'ôsszs£ly: ', OsszSuly : 8 : 1,
          ' kg');
      Write(Lst, FormFeed);
    end; { for NI }
    ClrScr;
    KiIrFejLec;
    KiIrDJ;
    if DJMod = 2 then
      KiIrT;
  end; { if SJo }
end; { NyomtatDJ }

procedure KgDb(TSzam : integer); { DB es KG /DB rublika formazasa }
                                 { es a szorzat a SULY rublikaba }
var
  KDI, KDJ, KDK : integer;
  KDR : real;

begin
  KDI := DJDRMeret[2];
  while (KDI > 0) and (DJ[TSzam]^[2, KDI] = ' ') do
    Dec(KDI);
  if KDI > 0 then
  begin
    Val(Copy(DJ[TSzam]^[2], 1, KDI), KDJ, KDK);
    Str(KDJ : 4, DJ[TSzam]^[2]);
    KDI := DJDRMeret[6];
    while (KDI > 0) and (DJ[TSzam]^[6, KDI] = ' ') do
      Dec(KDI);
    if KDI > 0 then
    begin
      Val(Copy(DJ[TSzam]^[6], 1, KDI), KDR, KDK);
      if (KDK = 0) and (KDR * KDJ < 100000) then
      begin
        if KDR >= 1000 then
        begin
          if KDR >= 10000 then
            Str(Round(KDR) : 6, DJ[TSzam]^[6])
          else
            Str(KDR : 6 : 1, DJ[TSzam]^[6])
        end { if KDR >= 1000 }
        else
          Str(KDR : 6 : 2, DJ[TSzam]^[6]);
        Str(KDJ * KDR : 7 : 1, DJ[TSzam]^[8]);
      end { if KDK }
      else
        DJ[TSzam]^[8] := '       ';
    end { belso if KDI }
    else
      DJ[TSzam]^[8] := '       ';
  end { kulso if KDI }
  else
    DJ[TSzam]^[8] := '       ';
end; { KgDb }

procedure DFormaz;

var
  BK, BI, BJ : integer;

begin
  if TSZ <= SorokSzama then
  begin
    case DR of
      1 : if TSZ = SorokSzama then
        begin
          BI := DJDRMeret[1];
          while (BI > 0) and (DJ[TSZ]^[1, BI] = ' ') do
            Dec(BI);
          if BI > 0 then
          begin
            Val(Copy(DJ[TSZ]^[1], 1, BI), BJ, BK);
            if (BK = 0) and (BJ < MaxTSZ) then
              KovTSz := BJ + 1;
          end; { if BI }
        end; { if TSZ }
      2, 6 : begin
          KgDb(TSZ);
          GoToXY(1, WhereY);
          Write(DSor(TSZ));
        end; { if DR }
      4, 5, 7 : begin
        BK := DJDRMeret[DR];
        while (BK > 1) and (DJ[TSZ]^[DR, BK] = ' ') do
          Dec(BK);
        if BK > 1 then
        begin
          for BI := BK - 1 downto 1 do
            if DJ[TSZ]^[DR, BI] = ' ' then
            begin
              Delete(DJ[TSZ]^[DR], BI, 1);
              DJ[TSZ]^[DR] := DJ[TSZ]^[DR] + ' ';
            end; { if }
          GoToXY(1, WhereY);
          Write(DSor(TSZ));
        end; { if }
      end; { case 3 }
    end; { case }
  end; { if }
end; { DFormaz }

procedure SulySzamol; { sulyok szamolasa az egesz darabjegyzekben }

var
  SST, SSJ, SSK : integer;
  ESuly, TMeny, Kg : real;
  AKMut, SSI : byte;
  JelMeret : JMTipus;
  MertE : char;
  JSzam : comp;
  UjAny : AnyTipus;
  Sik : boolean;

begin
  if (DJMod = 3) and (TSZ <= SorokSzama) then
    DFormaz;
  for SST := 1 to SorokSzama do
  begin
    MeretFelDolg(SST, JelMeret, TMeny, MertE, Sik);
    if Sik then
    begin
      MSZFelDolg(SST, AKMut, MertE, false, Sik);
      if Sik and (AKMut <= AKMeret) and
        (DJ[SST]^[5] <> Copy(SPC, 1, DJDRMeret[5])) then
      begin
        UjAny[0] := Chr(DJDRMeret[5]);
        for SSI := 1 to DJDRMeret[5] do
          UjAny[SSI] := UpCase(DJ[SST]^[5, SSI]);
        KeszitJSZ(AKMut, JelMeret, UjAny, JSzam, ESuly);
        if ESuly > 0 then
        begin
          Val(DJ[SST]^[2], SSJ, SSK);
          if (SSJ > 0) and (DJ[SST]^[2] <> Copy(SPC, 1, DJDRMeret[2])) then
          begin
            Kg := ESuly * TMeny / SSJ;
            if Kg >= 1000 then
              if Kg >= 10000 then
                Str(Round(Kg) : 6, DJ[SST]^[6])
              else
                Str(Kg : 6 : 1, DJ[SST]^[6])
            else
              Str(Kg : 6 : 2, DJ[SST]^[6]);
            KgDb(SST);
          end; { if SSJ }
        end; { if ESuly }
      end; { if Sik and }
    end; { if Sik }
  end; { for }
  KiIrDJ;
end; { SulySzamol }

procedure AKFrissites; { darabjegyzek osszes uj szabvanyanak felvetele }
                       { a szabvanykonyvtarba }
var
  SST : integer;
  TMeny : real;
  AKMut : byte;
  JelMeret : JMTipus;
  MertE : char;
  Sik : boolean;

begin
  if (DJMod = 3) and (TSZ <= SorokSzama) then
    DFormaz;
  for SST := 1 to SorokSzama do
  begin
    MeretFelDolg(SST, JelMeret, TMeny, MertE, Sik);
    if Sik then
      MSZFelDolg(SST, AKMut, MertE, true, Sik);
  end; { for }
end; { AKFrissites }

procedure DJUjMD;
begin
  ClrScr;
  UjMD;
  ClrScr;
  KiIrFejLec;
  KiIrDJ;
  if DJMod = 2 then
    KiIrT;
end; { DJUjMD }

procedure RTab;
begin
  DJMod := DJMod mod 3 + 1;
  Vege := true;
end; { RTab }

procedure RShiftTab;
begin
  DJMod := (DJMod + 1) mod 3 + 1;
  Vege := true;
end; { RShiftTab }

procedure RAltF;
begin
  DJMod := 1;
  Vege := true;
end; { RAltF }

procedure RAltT;
begin
  if ToresSzam < MaxT then
  begin
    DJMod := 2;
    Vege := true;
  end; { if }
end; { RAltT }

procedure RAltD;
begin
  DJMod := 3;
  Vege := true;
end; { RAltD }

procedure Eszkep;

var EBill : char;

begin
  if SorokSzama > 0 then
  begin
    ClrScr;
    Write('Biztos benne? (Az eddig ki nem mentett adatok elvesznek!)' +
      '  [I/N] ');
    repeat
      EBill := UpCase(ReadKey);
    until EBill in ['I', 'N', Esc];
    case EBill of
      'I' : begin
          Vege := true;
          KiLepes := true;
        end;
      'N', Esc : begin
         ClrScr;
         KiIrFejLec;
         KiIrDJ;
         if DJMod = 2 then
           KiIrT;
       end;
    end; { case }
  end { if }
  else
  begin
    Vege := true;
    KiLepes := true;
  end; { else }
end; { Eszkep }

procedure FLSzerk;

var FBill : char;

procedure FCrsr;
begin
  GoToXY(DJFLKezdoX[FR] + FP - 1, DJFLKezdoY[FR]);
end; { FCrsr }

procedure KiIrFR;
begin
  GoToXY(DJFLKezdoX[FR], DJFLKezdoY[FR]);
  Write(DJFL[FR]);
  FCrsr;
end; { KiIrFR }

procedure FLCtrlLeftA;
begin
  FR := (FR + MaxFR - 2) mod MaxFR + 1;
  FP := DJFLMeret[FR];
end; { FLCtrlLeftA }

procedure FCtrlLeftA;
begin
  FR := (FR + MaxFR - 2) mod MaxFR + 1;
  FP := 1;
end; { FCtrlLeftA }

procedure FLeftA;
begin
  if FP > 1 then
    Dec(FP)
  else
    FLCtrlLeftA;
end; { FLeftA }

procedure FCtrlRightA;
begin
  FR := FR mod MaxFR + 1;
  FP := 1;
end; { FCtrlRightA }

procedure FRightA;
begin
  if FP < DJFLMeret[FR] then
    Inc(FP)
  else
    FCtrlRightA;
end; { FRightA }

procedure FEnd;
begin
  FP := DJFLMeret[FR];
  while (FP > 1) and (DJFL[FR, FP] = ' ') do
    Dec(FP);
end; { FEnd }

procedure FAltR; { rublika torlese }
begin
  DJFL[FR] := Copy(SPC, 1, DJFLMeret[FR]);
  FP := 1;
  KiIrFR;
end; { FAltR }

procedure FDel;
begin
  Delete(DJFL[FR], FP, 1);
  DJFL[FR] := DJFL[FR] + ' ';
  KiIrFR;
end; { FDel }

procedure FIns;
begin
  Delete(DJFL[FR], DJFLMeret[FR], 1);
  Insert(' ', DJFL[FR], FP);
  KiIrFR;
end; { FIns }

procedure FBeIr(FBill : char);
begin
  DJFL[FR, FP] := FBill;
  Write(FBill);
  FRightA;
end; { FBeIr }

begin { FLSzerk }
  repeat
    FCrsr;
    FBill := ReadKey;
    case FBill of
      #0 : if KeyPressed then
        begin
          FBill := ReadKey;
          case FBill of
            LeftA  : FLeftA;
            RightA : FRightA;
            Home   : FP := 1;
            EndB   : FEnd;
            UpA, CtrlLeftA : FCtrlLeftA;
            DownA, CtrlRightA : FCtrlRightA;
            CtrlHome : begin
                FR := 1;
                FP := 1;
              end;
            CtrlEnd : begin
                FR := MaxFR;
                FEnd;
              end;
            Del      : FDel;
            Ins      : FIns;
            AltR     : FAltR;
            F1       : Help(1);
            ShiftF1  : Help(4);
            AltF1    : Help(5);
            F2       : Save;
            F3       : Load;
            F4       : NyomtatDJ;
            F5       : Ellenoriz;
            F6       : SulySzamol;
            F7       : AKFrissites;
            F8       : DJUjMD;
            ShiftTab : RShiftTab;
            AltD     : RAltD;
            AltT     : RAltT;
            AltX     : Eszkep;
            AltA     : FBeIr('†');
            AltE     : FBeIr('Ç');
            AltU     : FBeIr('£');
            AltI     : FBeIr('°');
            AltO     : FBeIr('¢');
            Alt1     : FBeIr('î');
            Alt2     : FBeIr('Å');
          end; { case }
          FBill := ' ';
        end; { if }
      BackSpace  : begin
          FLeftA;
          FDel;
        end; { case BackSpace }
      ' '..'˛' : FBeIr(FBill);
      Enter : FCtrlRightA;
      Tab : RTab;
      Esc : Eszkep;
    end; { case FBill }
  until Vege;
end; { FLSzerk }

procedure TSzerk;

var
  TBill : char;
  TI : byte;
  TEv, THo, TNap, TNapNev : word;
  TEvS, THoS, TNapS : string[2];

procedure TCtrlLeftA;
begin
  TR := (TR + MaxTR - 2) mod MaxTR + 1;
  TP := 1;
end; { TCtrlLeftA }

procedure TLeftA;
begin
  if TP > 1 then
    Dec(TP)
  else
  begin
    TR := (TR + MaxTR - 2) mod MaxTR + 1;
    TP := DJTMeret[TR];
  end; { else }
end; { TLeftA }

procedure TCtrlRightA;
begin
  TR := TR mod MaxTR + 1;
  TP := 1;
end; { TCtrlRightA }

procedure TRightA;
begin
  if TP < DJTMeret[TR] then
    Inc(TP)
  else
    TCtrlRightA;
end; { TRightA }

procedure TUpA;
begin
  if TSor > 3 then
  begin
    Dec(TSor);
    KiIrT;
  end; { if }
end; { TUpA }

procedure TDownA;
begin
  if TSor < ToresSzam then
  begin
    Inc(TSor);
    KiIrT;
  end; { if }
end; { TDownA }

procedure TEnd;
begin
  TP := DJTMeret[TR];
  while (TP > 1) and (DJT[TSor, TR, TP] = ' ') do
    Dec(TP);
end; { TEnd }

procedure TPgUp;
begin
  if TSor > 3 then
  begin
    if TSor > 6 then
      Dec(TSor, 3)
    else
      TSor := 3;
    KiIrT;
  end; { if }
end; { TPgUp }

procedure TPgDn;
begin
  if TSor < ToresSzam - 3 then
    Inc(TSor, 3)
  else
    TSor := ToresSzam;
  KiIrT;
end; { TPgDn }

procedure TCtrlPgUp;
begin
  if ToresSzam > 3 then
  begin
    TSor := 3;
    KiIrT;
  end; { if }
end;{ TCtrlPgUp }

procedure TCtrlPgDn;
begin
  TSor := ToresSzam;
  TR := 1;
  TP := 1;
  KiIrT;
end; { TCtrlPgPgDn }

procedure TAltM; { macskakorom }
begin
  if TSor > 1 then
  begin
    DJT[TSor, TR] := DJT[TSor - 1, TR];
    GoToXY(1, 10);
    Write(KiIrDJTores(TSor));
  end; { if }
end; { TAltM }

procedure TAltR; { rublika torlese }
begin
  DJT[TSor, TR] := Copy(SPC, 1, DJTMeret[TR]);
  TP := 1;
  GoToXY(1, 10);
  Write(KiIrDJTores(TSor));
end; { TAltR }

procedure TDel;
begin
  Delete(DJT[TSor, TR], TP, 1);
  DJT[TSor, TR] := DJT[TSor, TR] + ' ';
  GoToXY(1, 10);
  Write(KiIrDJTores(TSor));
end; { TDel }

procedure TIns;
begin
  Delete(DJT[TSor, TR], DJTMeret[TR], 1);
  Insert(' ', DJT[TSor, TR], TP);
  GoToXY(1, 10);
  Write(KiIrDJTores(TSor));
end; { TIns }

procedure TEll;

begin
  if DJT[ToresSzam, 1] = Copy(SPC, 1, DJTMeret[1]) then
  begin
    Dec(ToresSzam);
    TSor := ToresSzam;
  end; { if }
  KiIrT;
end; { TEll }

procedure TBeIr(BBill : char);
begin
    DJT[TSor, TR, TP] := BBill;
  Write(BBill);
  TRightA;
end; { TBeIr }

begin { TSzerk }
  if ToresSzam < MaxT then
    Inc(ToresSzam)
  else
  begin
    Inc(KezdoTor);
    for TI := 2 to MaxT do
      DJT[TI - 1] := DJT[TI];
  end; { else }
  TSor := ToresSzam;
  for TI := 1 to MaxTR do
    DJT[TSor, TI] := Copy(SPC, 1, DJTMeret[TI]);
  GetDate(TEv, THo, TNap, TNapNev);
  Str(TEv mod 100 : 2, TEvS);
  Str(THo : 2, THoS);
  Str(TNap : 2, TNapS);
  DJT[TSor, 2] := TEvS + '.' + THoS + '.' + TNapS;
  TR := 1;
  TP := 1;
  KiIrT;
  repeat
    GoToXY(DJTKezdoX[TR] + TP - 1, 10);
    TBill := ReadKey;
    case TBill of
      #0 : if KeyPressed then
        begin
          TBill := ReadKey;
          case TBill of
            UpA      : TUpA;
            DownA    : TDownA;
            PgUp     : TPgUp;
            PgDn     : TPgDn;
            CtrlPgUp : TCtrlPgUp;
            CtrlPgDn : TCtrlPgDn;
            F1       : Help(1);
            ShiftF1  : Help(4);
            AltF1    : Help(5);
            F2       : Save;
            F3       : Load;
            F4       : NyomtatDJ;
            F5       : Ellenoriz;
            F6       : SulySzamol;
            F7       : AKFrissites;
            F8       : DJUjMD;
            ShiftTab : RShiftTab;
            AltF     : RAltF;
            AltD     : RAltD;
            else
              if TSor = ToresSzam then
                case TBill of
                  LeftA      : TLeftA;
                  RightA     : TRightA;
                  Home       : TP := 1;
                  EndB       : TEnd;
                  CtrlLeftA  : TCtrlLeftA;
                  CtrlRightA : TCtrlRightA;
                  CtrlHome : begin
                      TR := 1;
                      TP := 1;
                    end;
                  CtrlEnd : begin
                      TR := MaxTR;
                      TEnd;
                    end;
                  Del  : TDel;
                  Ins  : TIns;
                  AltM : TAltM;
                  AltR : TAltR;
                  AltX : Eszkep;
                  AltA : TBeIr('†');
                  AltE : TBeIr('Ç');
                  AltU : TBeIr('£');
                  AltI : TBeIr('°');
                  AltO : TBeIr('¢');
                  Alt1 : TBeIr('î');
                  Alt2 : TBeIr('Å');
                end; { case }
          end; { case }
          TBill := ' ';
        end; { if }
      Tab : RTab;
      Esc : Eszkep;
      else
        if TSor = ToresSzam then
          case TBill of
            BackSpace  : begin
                TLeftA;
                TDel;
              end; { case BackSpace }
            ' '..'˛' : TBeIr(TBill);
            Enter : TCtrlRightA;
          end; { case }
    end; { case }
  until Vege;
  TEll;
end; { TSzerk }

procedure DSzerk;

var DBill : char;

procedure RCtrlLeftA;
begin
  DFormaz;
  if DR > 1 then
  begin
    Dec(DR);
    DP := DJDRMeret[DR];
  end { then }
  else
  begin
    if TSZ > 1 then
    begin
      Dec(TSZ);
      DR := MaxDR;
      DP := DJDRMeret[MaxDR];
      if DKezdet > TSZ then
      begin
        Dec(DKezdet);
        KiirDJ;
      end; { if }
    end; { if TSZ }
  end; { if DR else }
end; { RCtrlLeftA }

procedure DCtrlLeftA;
begin
  RCtrlLeftA;
  DP := 1;
end; { DCtrlLeftA }

procedure DLeftA;
begin
  if DP > 1 then
    Dec(DP)
  else
    RCtrlLeftA;
end; { DLeftA }

procedure DCtrlRightA;
begin
  DFormaz;
  if DR < MaxDR then
  begin
    Inc(DR);
    DP := 1;
  end { then }
  else
  begin
    if TSZ < SorokSzama + 1 then
    begin
      Inc(TSZ);
      if TSZ = SorokSzama + 1 then
        DR := 2
      else
        DR := 1;
      DP := 1;
      if TSZ > DKezdet + MaxDSor - 1 then
      begin
        Inc(DKezdet);
        KiirDJ;
       end;
    end; { if TSZ }
  end; { if DR else }
end; { DCtrlRightA }

procedure DRightA;
begin
  if DP < DJDRMeret[DR] then
    Inc(DP)
  else
    DCtrlRightA;
end; { DRightA }

procedure DUpA;
begin
  if TSZ > 1 then
  begin
    DFormaz;
    Dec(TSZ);
    if TSZ < DKezdet then
    begin
      Dec(DKezdet);
      KiirDJ;
    end; { if }
  end; { if TSZ > }
end; { DUpA }

procedure DDownA;
begin
  if TSZ <= SorokSzama then
  begin
    DFormaz;
    Inc(TSZ);
    if TSZ > DKezdet + MaxDSor - 1 then
    begin
      Inc(DKezdet);
      KiirDJ;
    end; { if TSZ > }
  end; { if TSZ < }
end; { DDownA }

procedure DEnd;
begin
  DP := DJDRMeret[DR];
  while (DP > 1) and (DJ[TSZ]^[DR, DP] = ' ') do
    Dec(DP);
end; { DEnd }

procedure DPgUp;
begin
  DFormaz;
  if DKezdet > MaxDSor then
    Dec(DKezdet, MaxDSor)
  else
    DKezdet := 1;
  if TSZ > MaxDSor then
    Dec(TSZ, MaxDSor)
  else
    TSZ := 1;
  KiIrDJ;
end; { DPgUp }

procedure DPgDn;
begin
  DFormaz;
  if DKezdet < SorokSzama - MaxDSor + 2 then
    Inc(DKezdet, MaxDSor);
  if TSZ < SorokSzama - MaxDSor + 2 then
    Inc(TSZ, MaxDSor)
  else
    TSZ := SorokSzama + 1;
  KiIrDJ;
end; { DPgDn }

procedure DCtrlPgUp;
begin
  DFormaz;
  DKezdet := 1;
  TSZ := 1;
  if SorokSzama > 0 then
    DR := 1
  else
    DR := 2;
  DP := 1;
  KiIrDJ;
end;{ DCtrlPgUp }

procedure DCtrlPgDn;
begin
  DFormaz;
  if SorokSzama > MaxDSor - 1 then
    DKezdet := Sorokszama - MaxDSor + 2;
  TSZ := Sorokszama + 1;
  DR := 2;
  DP := 1;
  KiIrDJ;
end; { DCtrlPgPgDn }

procedure DAltS; { sor torlese }

var DAltSI : 1..MaxDR + 1;

begin
  if TSZ <= SorokSzama then
  begin
    for DAltSI := 1 to MaxDR + 1 do
      DJ[TSZ]^[DAltSI] := Copy(SPC, 1, DJDRMeret[DAltSI]);
    GoToXY(1, WhereY);
    Write(DSor(TSZ));
  end; { for }
end; { DAltS }

procedure DAltY; { sor torlese, kivetele }

var
  DAltYI : 1..MaxTSZ;
  DAltYJ : 1..MaxDR + 1;

begin
  if TSZ <= SorokSzama then
  begin
    Dispose(DJ[TSZ]);
    for DAltYI := TSZ + 1 to SorokSzama do
      DJ[DaltYI - 1] := DJ[DaltYI];
    DJ[SorokSzama] := nil;
    Dec(SorokSzama);
    KiIrDJ;
  end; { if }
end; { DAltY }

procedure DAltN; { sor beszurasa }

var
  DAltNI : 1..MaxTSZ;
  DAltNJ : 1..MaxDR + 1;

begin
  if (SorokSzama < MaxTSZ) and (TSZ <= SorokSzama) then
  begin
    DFormaz;
    for DAltNI := SorokSzama downto TSZ do
      DJ[DaltNI + 1] := DJ[DaltNI];
    Inc(SorokSzama);
    Inc(KovTSZ);
    New(DJ[TSZ]);
    DAltS;
    KiIrDJ;
  end; { if }
end; { DAltN }

procedure DAltR; { rublika torlese }
begin
  DJ[TSZ]^[DR] := Copy(SPC, 1, DJDRMeret[DR]);
  DP := 1;
  DFormaz;
  DCrsr;
  Write(DJ[TSZ]^[DR]);
end; { DAltR }

procedure UjSorE;
begin
  if (TSZ > SorokSzama) and (TSZ < MaxTSZ) then
  begin
    Inc(SorokSzama);
    New(DJ[SorokSzama]);
    DAltS;
    if DR > 1 then
    begin
      Str(KovTSZ : 3, DJ[TSZ]^[1]);
      GoToXY(2, WhereY);
      Write(KovTSZ : 3);
    end; { if DR }
    DCrsr;
    Inc(KovTSZ);
  end; { if TSZ }
end; { UjSorE }

procedure DAltM; { macskakorom }
begin
  if TSZ > 1 then
  begin
    if DJ[TSZ - 1]^[DR] <> Copy(SPC, 1, DJDRMeret[DR]) then
      UjSorE;
    DJ[TSZ]^[DR] := DJ[TSZ - 1]^[DR];
    DFormaz;
    GoToXY(1, WhereY);
    Write(DSor(TSZ));
  end; { if }
end; { DAltM }

procedure DAltV; { Puffer masolasa rublikaba }
begin
  if Copy(Puffer + SPC, 1, DJDRMeret[DR]) <> Copy(SPC, 1, DJDRMeret[DR])
    then
      UjSorE;
  DJ[TSZ]^[DR] := Copy(Puffer + SPC, 1, DJDRMeret[DR]);
  DFormaz;
  GoToXY(1, WhereY);
  Write(DSor(TSZ));
end; { DAltV }
 
procedure DAltZ; { Suly szamolasa }

var
  AKMut, DZI : byte;
  DZJ, DZK   : integer;
  MertE      : char;
  JSzam      : comp;
  JelMeret   : JMTipus;
  UjAny      : AnyTipus;
  Sik        : boolean;
  ESuly, TMeny, Kg : real;

begin
  if TSZ <= SorokSzama then
  begin
    DFormaz;
    DP := 1;
    MeretFelDolg(TSZ, JelMeret, TMeny, MertE, Sik);
    if not Sik then
    begin
      DR := 4;
      Write(Beep);
      Exit;
    end; { if }
    MSZFelDolg(TSZ, AKMut, MertE, false, Sik);
    if not Sik then
    begin
      DR := 4;
      Write(Beep);
      Exit;
    end; { if }
    if AKMut <= AKMeret then
    begin
      if DJ[TSZ]^[5] = Copy(SPC, 1, DJDRMeret[5]) then
      begin
        DR := 5;
        Write(Beep);
        Exit;
      end; { if DJ }
      UjAny[0] := Chr(DJDRMeret[5]);
      for DZI := 1 to DJDRMeret[5] do
        UjAny[DZI] := UpCase(DJ[TSZ]^[5, DZI]);
      KeszitJSZ(AKMut, JelMeret, UjAny, JSzam, ESuly);
      if ESuly > 0 then
      begin
        DR := 6;
        Val(DJ[TSZ]^[2], DZJ, DZK);
        if (DZJ = 0) or (DJ[TSZ]^[2] = Copy(SPC, 1, DJDRMeret[2])) then
        begin
          DR := 2;
          Write(Beep);
          Exit;
        end; { if DZJ }
        Kg := ESuly * TMeny / DZJ;
        if Kg >= 1000 then
          if Kg >= 10000 then
            Str(Round(Kg) : 6, DJ[TSZ]^[6])
          else
            Str(Kg : 6 : 1, DJ[TSZ]^[6])
        else
          Str(Kg : 6 : 2, DJ[TSZ]^[6]);
        DFormaz;
      end { if ESuly }
      else
      begin
        DR := 6;
        Write(Beep);
        Exit;
      end; { if ESuly else }
    end { if AKMut }
    else
    begin
      DR := 6;
      Write(Beep);
    end; { if AKMut else }
  end { if TSZ }
  else
    Write(Beep);
end; { DAltZ }

procedure DAltB;

var
  AKMut, RegiAKMeret : byte;
  MertE : char;
  TMeny : real;
  JelMeret : JMTipus;
  Sik : boolean;

begin
  if TSZ <= SorokSzama then
  begin
    DFormaz;
    MeretFelDolg(TSZ, JelMeret, TMeny, MertE, Sik);
    if not Sik then
    begin
      DP := 1;
      DR := 4;
      Write(Beep);
      Exit;
    end; { if }
    RegiAKMeret := AKMeret;
    MSZFelDolg(TSZ, AKMut, MertE, true, Sik);
    if (not Sik) or (AKMeret = RegiAKMeret) then
      Write(Beep);
  end { if TSZ }
  else
    Write(Beep);
end; { DAltB }

procedure DDel;
begin
  Delete(DJ[TSZ]^[DR], DP, 1);
  DJ[TSZ]^[DR] := DJ[TSZ]^[DR] + ' ';
  GoToXY(1, WhereY);
  Write(DSor(TSZ));
end; { DDel }

procedure DIns;
begin
  Delete(DJ[TSZ]^[DR], DJDRMeret[DR], 1);
  Insert(' ', DJ[TSZ]^[DR], DP);
  GoToXY(1, WhereY);
  Write(DSor(TSZ));
end; { DIns }

procedure DBeIr(BBill : char);
begin
  if BBill <> ' ' then
    UjSorE;
  DJ[TSZ]^[DR, DP] := BBill;
  Write(BBill);
  DRightA;
end; { DBeIr }

begin { DSzerk }
  repeat
    DCrsr;
    DBill := ReadKey;
    case DBill of
      #0 : if KeyPressed then
        begin
          DBill := ReadKey;
          case DBill of
            LeftA      : DLeftA;
            RightA     : DRightA;
            UpA        : DUpA;
            DownA      : DDownA;
            Home       : DP := 1;
            EndB       : DEnd;
            PgUp       : DPgUp;
            PgDn       : DPgDn;
            CtrlLeftA  : DCtrlLeftA;
            CtrlRightA : DCtrlRightA;
            CtrlHome : begin
                DR := 1;
                DP := 1;
              end;
            CtrlEnd : begin
                DR := MaxDR;
                DP := 1;
              end;
            CtrlPgUp : DCtrlPgUp;
            CtrlPgDn : DCtrlPgDn;
            AltM     : DAltM;
            AltV     : DAltV;
            F1       : Help(1);
            ShiftF1  : Help(4);
            AltF1    : Help(5);
            F2       : Save;
            F3       : Load;
            F4       : NyomtatDJ;
            F5       : Ellenoriz;
            F6       : SulySzamol;
            F7       : AKFrissites;
            F8       : DJUjMD;
            ShiftTab : RShiftTab;
            AltF     : RAltF;
            AltT     : RAltT;
            AltX     : Eszkep;
          end; { case }
          if DR in [3, 4] then
            case DBill of
              AltA : DBeIr('†');
              AltE : DBeIr('Ç');
              AltU : DBeIr('£');
              AltI : DBeIr('°');
              AltO : DBeIr('¢');
              Alt1 : DBeIr('î');
              Alt2 : DBeIr('Å');
              Alt3 : DBeIr('Ì');
              Alt4 : DBeIr('¯');
            end; { case }
          if TSZ <= SorokSzama then
            case DBill of
              Del  : DDel;
              Ins  : DIns;
              AltS : DAltS;
              AltY : DAltY;
              AltN : DAltN;
              AltR : DAltR;
              AltK : Puffer := DJ[TSZ]^[DR];
              AltZ : DAltZ;
              AltB : DAltB;
            end; { case }
          DBill := ' ';
        end; { if }
      BackSpace : begin
          DLeftA;
          DCrsr;
          if TSZ <= SorokSzama then
            DDel;
        end; { case BackSpace }
      ' ', '0'..'9' : DBeIr(DBill);
      '.' : if DR <> 2 then
              DBeIr(DBill);
      '!'..'˛' : if not (DR in [2, 6]) then
                   DBeIr(DBill);
      Tab : RTab;
      Enter : DCtrlRightA;
      Esc : Eszkep;
    end; { case DBill }
  until Vege;
  DFormaz;
end; { DSzerk }

begin { DarabJSZ }
  TorolDJ;
  KiIrFejLec;
  KiIrDJ;
  KiLepes := false;
  repeat
    Vege := false;
    case DJMod of
      1 : FLSzerk;
      2 : TSzerk;
      3 : DSzerk;
    end; { case }
  until KiLepes;
  for DI := SorokSzama downto 1 do
    Dispose(DJ[DI]);
  SorokSzama := 0;
end; { DarabJSZ }

end. { unit }