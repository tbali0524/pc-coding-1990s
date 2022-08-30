{***********************************************}
{                                               }
{        S T E F I   - gr†fprogram              }
{               1.0c verzi¢                     }
{                                               }
{   Copyright (c) 1995,96,2001 by T¢th B†lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0        }
{                                               }
{***********************************************}

{ Graf struktura es kezelese }
unit GrStrukt;

interface

const
  TitleStr = 'S T E F I   v1.0c  Copyright (c) 1995-2001 by B†lint T¢th'; { cim }
  SPC = '                           ';          { segedsztring a jelenteshez }
  Vonal = '---------------------------';
  GrfIdent = 1974;                              { GRF file azonosito }
  NemIsm = -1;                                  { meg nem ismert ertek }
  Igaz   = 1;
  Hamis  = 0;

  MaxCsucs = 26;                                { csucsok maximalis szama }
  MaxEl    = MaxCsucs * (MaxCsucs - 1);         { elek maximalis szama }
  MaxKor   = 1000;                              { korok maximalis szama }
  MaxVagat = 100;                               { vagatok maximalis szama }

  MaxSuly  = 10000;                             { minden sulynal nagyobb }

 { InpData mezoi (mely bemeno adatok szerepeljenek a jelentesben) }
  InpAll       = $0007;	{ mind }
  InpCsucsSuly = $0001;
  InpElSuly    = $0002;
  InpAdjM      = $0004;
 { ResData mezoi (mely eredmenyek szerepeljenek a jelentesben) }
  ResAll          = $FFFF; { mind }
  ResIncM         = $0001;
  ResKomp         = $0002;
   ResTagLista     = $0000;
  ResFokLista     = $0004;
  ResKorLista     = $0008;
   ResEulerUt      = $0000;
  ResPruferKod    = $0010;
  ResMinTav       = $0020;
  ResExcentritas  = $0040;
  ResMinFeszitofa = $0080;
  ResTopRendezes  = $0100;
  ResErosKomp     = $0200;
 { RepWidth ertekei (milyen szeles legyen a jelentes) }
  RepW80          = $0000;
  RepW128         = $0001;
  RepW250         = $0002;
 { RepLang ertekei (milyen nyelvu legyen a jelentes) }
  RepEnglish      = $0000;
  RepHungarian    = $0001;

type

 { csucsok adatai }
  PCsucsLista = ^TCsucsLista;
  TCsucsLista = Array[1..MaxCsucs] of Integer;
 { elek adatai }
  PElLista = ^TElLista;
  TElLista = Array[1..MaxEl + 1] of Integer;
 { adjacenciamatrix }
  PAdjMatrix = ^TAdjMatrix;
  TAdjMatrix = Array[1..MaxCsucs, 1..MaxCsucs] of Integer;
 { incidenciamatrix }
  PIncMatrix = ^TIncMatrix;
  TIncMatrix = Array[1..MaxCsucs, 1..MaxEl] of ShortInt;
 { kormatrix }
     { KorM ertelmezese nem szabalyos
     { minden kor egy sor, benne felsorolva az erintett csucsok sorszama }
     { az utolso utan 0 elem }
     { csucs-sorszam -1 szeres, ha az iranyitas ellentetes a koruljarassal }
  PKorMatrix = ^TKorMatrix;
  TKorMatrix = Array[1..MaxKor, 1..MaxCsucs] of ShortInt;
 { vagatmatrix }
  PVagatMatrix = ^TVagatMatrix;
  TVagatMatrix = Array[1..MaxVagat, 1..MaxEl] of ShortInt;

{ ========================================================================== }

 { graf informacios rekord }
  PGraf = ^TGraf;
  TGraf = record

   { szerkesztotol kapott adatok }
    Cs: Integer;                { csucsok szama }
    Iranyitott: Boolean;        { iranyitott-e }
    AdjM: PAdjMatrix;           { adjacenciamatrix }
    CsucsSuly: PCsucsLista;     { csucsok sulyozasa }
    ElSuly: PAdjMatrix;         { elek sulyozasa }
    XPoz, YPoz: PCsucsLista;    { pozicio a kepernyon (csak szerkeszteshez) }

   { szamolt adatok }
    El: Integer;                { elek szama }
    Kor: Integer;               { korok szama }
    Vagat: Integer;             { vagatok szama }
    Komp: Integer;              { komponensek szama }
    Tag: Integer;               { tagok szama }
    Artik: Integer;             { artikulaciok szama }
    Centrum: Integer;           { centrum (minimalis excentritasu csucs) }
    MinFeszFaKoltseg: Integer;  { minimalis koltsegu feszitofa koltsege }
    ErosKomp: Integer;          { erosen osszefuggo komponensek szama }

    IncM: PIncMatrix;           { incidenciamatrix }
    KorM: PKorMatrix;           { kormatrix spec ertelmezes szerint }
    VagatM: PVagatMatrix;       { vagatmatrix }
    KompLista: PCsucsLista;     { komponensek (melyik csucs melyik komp.ben) }
    TagLista: PCsucsLista;      { tagok (melyik csucs melyik tagban) }
    ArtikLista: PCsucsLista;    { artikulaciok (1=art. 0=nem art.) }
    KiFokLista: PCsucsLista;    { csucsok ki fokszamai }
    BeFokLista:  PCsucsLista;   { csucsok be fokszamai }
    EulerUt: PElLista;          { Euler vonal (az erintett csucsok sorban) }
    PruferKod: PCsucsLista;     { Prufer-kod }
    MinTav: PAdjMatrix;         { minimalis tavolsagok }
    MinUtKozepso: PAdjMatrix;   { minimalis koltsegu utak kozepso elemei }
    Excentritas: PCsucsLista;   { excentritasok }
    MinFeszitoFa: PAdjMatrix;   { minimalis koltsegu feszitofa }
    TopRendezes: PCsucsLista;   { DAG topologikus rendezese }
                                { (a csucsok forditott sorrendben) }
    ErosKompLista: PCsucsLista; { erosen osszefuggo komponensek }

    { igen-nem kerdesek }
    VanEulerUt: ShortInt;
    VanEulerKor: ShortInt;
    DAG: ShortInt;
  end; { TGraf }

{ ========================================================================== }

const
 { kitoltetlen graf rekord }
  UresGraf: TGraf = (
    Cs: 0;
    Iranyitott: False;
    AdjM: Nil;
    CsucsSuly: Nil;
    ElSuly: Nil;
    XPoz: Nil;
    YPoz: Nil;

    El: NemIsm;
    Kor: NemIsm;
    Vagat: NemIsm;
    Komp: NemIsm;
    Tag: NemIsm;
    Artik: NemIsm;
    Centrum: NemIsm;
    MinFeszFaKoltseg: NemIsm;
    ErosKomp: NemIsm;

    IncM: Nil;
    KorM: Nil;
    VagatM: Nil;
    KompLista: Nil;
    TagLista: Nil;
    ArtikLista: Nil;
    KiFokLista: Nil;
    BeFokLista: Nil;
    EulerUt: Nil;
    PruferKod: Nil;
    MinTav: Nil;
    MinUtKozepso: Nil;
    Excentritas: Nil;
    MinFeszitoFa: Nil;
    TopRendezes: Nil;
    ErosKompLista: Nil;

    VanEulerUt: NemIsm;
    VanEulerKor: NemIsm;
    DAG: NemIsm
  ); { UresGraf }

{ ========================================================================== }

function Max(A, B: Integer): Integer;
function Min(A, B: Integer): Integer;
function Betu(Csucs: Integer): Char;
function GetMinUt(G: PGraf; I, J: Integer): String;
function SaveGraf(G: PGraf; const FName: String): Boolean;
function LoadGraf(var G: PGraf; const FName: String): Boolean;
function Jelentes(G: PGraf; const FName: String;
  InpData, ResData, RepWidth, RepLanguage: Word): Boolean;
procedure DisposeResults(G: PGraf);
procedure DisposeGraf(G: PGraf);

{ ========================================================================== }
implementation

type
  RepLabelT = Array[1..30, RepEnglish..RepHungarian] of String[50];

const
  ny : RepLabelT = (
    ('Node weights:',                  'Cs£css£lyok:'),
    ('Edge weights:',                  'êls£lyok:'),
    ('Adjacence matrix:',              'Adjacenciam†trix:'),
    ('Incidence matrix (conjugated):', 'Incidenciam†trix (konjug†lt):'),
    ('(continued...)',                 '(folytat†s...)'),
    ('Number of circles: ',            'Kîrîk sz†ma: '),
    ('Circle matrix:',                 'Kîrm†trix:'),
    ('Number of cuts: ',               'V†gatok sz†ma: '),
    ('Cut matrix:',                    'V†gatm†trix:'),
    ('Components:',                    'Komponensek:'),
    ('Strong components:',             'Erìsen îsszefÅggì komponensek:'),
    ('Number of members: ',            'Tagok sz†ma: '),
    ('Members:',                       'Tagok:'),
    ('Number of articulations: ',      'Artikul†ci¢k sz†ma: '),
    ('Articulations: ',                'Artikul†ci¢k: '),
    ('Node degrees:',                  'Cs£csok foksz†mai:'),
    (' Out:',                          ' Ki: '),
    (' In: ',                          ' Be: '),
    ('Has an (open) Euler-line.',      'Van ny°lt Euler-vonala.'),
    ('Has an Euler-circle.',           'Van z†rt Euler-vonala.'),
    ('Has no Euler-line.',             'Nincs Euler-bej†r†sa.'),
    ('Euler-line: ',                   'Euler-vonal: '),
    ('PrÅfer code: ',                  'PrÅfer-k¢d: '),
    ('Minimal cost pathes with total costs:', 'Minim†lis kîltsÇgñ utak az îsszkîltsÇgekkel:'),
    ('Center: ',                       'Centrum: '),
    ('Excentricities:',                'Excentrit†sok:'),
    ('Minimal cost spanning tree (adjacence matrix):', 'Minim†lis kîltsÇgñ fesz°tìfa (adjacenciam†trix):'),
    ('(Total cost: ',                  '(ôsszkîltsÇg: '),
    ('Topologic order: ',              'Topol¢gikus rendezÇs: '),
    ('Circles: ',                      'Kôrôk: ')
  ); { ny }

{ ========================================================================== }

function Max(A, B: Integer): Integer;
begin
  if A >= B then
    Max := A
  else
    Max := B;
end; { Max }

{ ========================================================================== }

function Min(A, B: Integer): Integer;
begin
  if A <= B then
    Min := A
  else
    Min := B;
end; { Min }

{ ========================================================================== }

{ Csucs betujele }
function Betu(Csucs: Integer): Char;
begin
  Betu := Chr(Ord('A') + Csucs - 1);
end; { Betu }

{ ========================================================================== }

{ Minimalis koltsegu I->J ut visszaadasa MinUtKozepso segitsegevel }
function GetMinUt(G: PGraf; I, J: Integer): String;
var
  K: Integer;
begin
  K := G^.MinUtKozepso^[I, J];
  if K = 0 then
    GetMinUt := ''
  else
    GetMinUt := GetMinUt(G, I, K) + Betu(K) + GetMinUt(G, K, J);
end; { GetMinUt }

{ ========================================================================== }

{ Graf kimentese }
function SaveGraf(G: PGraf; const FName: String): Boolean;
var
  F: File of Integer;
  I, J: Integer;
begin
  Assign(F, FName);
  {$I-}
  Rewrite(F);
  if IOResult <> 0 then
    SaveGraf := False
  else
  begin
    with G^ do
    begin
      I := GrfIdent;
      Write(F, I);
      Write(F, Cs);
      I := 0;
      if Iranyitott then
        I := 1;
      if AdjM <> Nil then
        I := I or 2;
      if CsucsSuly <> Nil then
        I := I or 4;
      if ElSuly <> Nil then
        I := I or 8;
      if XPoz <> Nil then
        I := I or 16;
      if YPoz <> Nil then
        I := I or 32;
      Write(F, I);
      if AdjM <> Nil then
        for I := 1 to Cs do
          for J := 1 to Cs do
            Write(F, AdjM^[I, J]);
      if CsucsSuly <> Nil then
        for I := 1 to Cs do
          Write(F, CsucsSuly^[I]);
      if ElSuly <> Nil then
        for I := 1 to Cs do
          for J := 1 to Cs do
            Write(F, ElSuly^[I, J]);
      if XPoz <> Nil then
        for I := 1 to Cs do
          Write(F, XPoz^[I]);
      if YPoz <> Nil then
        for I := 1 to Cs do
          Write(F, YPoz^[I]);
    end; { with }
    Close(F);
    SaveGraf := IOResult = 0;
  end; { else }
  {$I+}
end; { SaveGraf }

{ ========================================================================== }

{ Graf betoltese }
function LoadGraf(var G: PGraf; const FName: String): Boolean;
var
  F: File of Integer;
  I, J, K: Integer;
begin
  New(G);
  G^ := UresGraf;
  Assign(F, FName);
  {$I-}
  Reset(F);
  if IOResult <> 0 then
    LoadGraf := False
  else
  begin
    Read(F, K);
    if (IOResult <> 0) or (K <> GrfIdent) then
      LoadGraf := False
    else
    begin
      with G^ do
      begin
        Read(F, Cs);
        Read(F, K);
        Iranyitott := (K and 1) = 1;
        if (K and 2) <> 0 then
          New(AdjM);
        if (K and 4) <> 0 then
          New(CsucsSuly);
        if (K and 8) <> 0 then
          New(ElSuly);
        if (K and 16) <> 0 then
          New(XPoz);
        if (K and 32) <> 0 then
          New(YPoz);
        if AdjM <> Nil then
          for I := 1 to Cs do
            for J := 1 to Cs do
              Read(F, AdjM^[I, J]);
        if CsucsSuly <> Nil then
          for I := 1 to Cs do
            Read(F, CsucsSuly^[I]);
        if ElSuly <> Nil then
          for I := 1 to Cs do
            for J := 1 to Cs do
              Read(F, ElSuly^[I, J]);
        if XPoz <> Nil then
          for I := 1 to Cs do
            Read(F, XPoz^[I]);
        if YPoz <> Nil then
          for I := 1 to Cs do
            Read(F, YPoz^[I]);
      end; { with }
      if IOResult <> 0 then
      begin
        DisposeGraf(G);
        New(G);
        G^ := UresGraf;
        LoadGraf := False;
      end
      else
        LoadGraf := True;
    end; { if (IOResult <> 0) or (K <> GrfIdent) else }
    Close(F);
  end; { if IOResult <> 0 else }
  {$I+}
end; { LoadGraf }

{ ========================================================================== }

{ Jelentes keszitese }
{  (InpData, ResData: mely adatok szerepeljenek a jelentesben, }
{   RepWidth: jelentes max szelessege, RepLanguage: jelentes nyelve) }
function Jelentes(G: PGraf; const FName: String;
  InpData, ResData, RepWidth, RepLanguage: Word): Boolean;
var
  F: Text;
  I, J, K, L, M, N: Integer;
  W: Integer;
  S: String;
begin
  Assign(F, FName);
  {$I-}
  Rewrite(F);
  if IOResult <> 0 then
    Jelentes := False
  else
  begin
    case RepWidth of
      RepW80:  W := 79;
      RepW128: W := 127;
      RepW250: W := 249;
    end;
    WriteLn(F, TitleStr);
    WriteLn(F);
    with G^ do
    begin
      if RepLanguage = RepEnglish then
      begin
        WriteLn(F, 'GRAPH REPORT');
        WriteLn(F, '============');
        WriteLn(F);
        if Iranyitott then
          WriteLn(F, 'Directed.')
        else
          WriteLn(F, 'Undirected.');
        WriteLn(F, 'Number of nodes: ', Cs);
        if El <> NemIsm then
          WriteLn(F, 'Number of edges: ', El);
        if Komp <> NemIsm then
        begin
          WriteLn(F, 'Number of components: ', Komp);
          if Komp = 1 then
            WriteLn(F, '(Connected.)');
          WriteLn(F, 'Rank: ', Cs - Komp);
          if El <> NemIsm then
          begin
            WriteLn(F, 'Nullity: ', El - Cs + Komp);
            if (not Iranyitott) and (El = (Cs - Komp)) then
              if Komp = 1 then
                WriteLn(F, 'Tree.')
              else if Komp > 1 then
                WriteLn(F, 'Forest (acyclic).');
          end;
          if Kor <> NemIsm then
            if Kor < MaxKor then
              WriteLn(F, ny[6, RepLanguage], Kor)
            else
              WriteLn(F, ny[6, RepLanguage], 'at least ', Kor);
        end; { if Komp }
        if DAG = Igaz then
          WriteLn(F, 'DAG (directed acyclic graph).')
        else if (DAG = Hamis) and Iranyitott then
          WriteLn(F, 'Not DAG. (Has a directed circle.)');
      end { if RepLanguage }
      else
      begin
        WriteLn(F, 'JELENTêS GRèFR¢L');
        WriteLn(F, '================');
        WriteLn(F);
        if Iranyitott then
          WriteLn(F, 'Ir†ny°tott.')
        else
          WriteLn(F, 'Ir†ny°tatlan.');
        WriteLn(F, 'Cs£csok sz†ma: ', Cs);
        if El <> NemIsm then
          WriteLn(F, 'êlek sz†ma: ', El);
        if Komp <> NemIsm then
        begin
          WriteLn(F, 'Komponensek sz†ma: ', Komp);
          if Komp = 1 then
            WriteLn(F, '(ôsszefÅggì.)');
          WriteLn(F, 'Rang: ', Cs - Komp);
          if El <> NemIsm then
          begin
            WriteLn(F, 'Nullit†s: ', El - Cs + Komp);
            if (not Iranyitott) and (El = (Cs - Komp)) then
              if Komp = 1 then
                WriteLn(F, 'Fagr†f.')
              else if Komp > 1 then
                WriteLn(F, 'Erdì (kîrmentes).');
          end;
          if Kor <> NemIsm then
            if Kor < MaxKor then
              WriteLn(F, ny[6, RepLanguage], Kor)
            else
              WriteLn(F, ny[6, RepLanguage], 'legal†bb ', Kor);
        end; { if Kor }
        if DAG = Igaz then
          WriteLn(F, 'DAG (ir†ny°tott kîrmentes gr†f).')
        else if (DAG = Hamis) and Iranyitott then
          WriteLn(F, 'Nem DAG. (Van benne ir†ny°tott kîr.)');
      end; { if RepLanguage else }
      WriteLn(F);

      if (CsucsSuly <> Nil) and ((InpData and InpCsucsSuly) <> 0) then
      begin
        WriteLn(F, ny[1, RepLanguage]);
        K := 6;                         { ilyen szeles egy oszlop }
        L := (W - 1) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, ' ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, ' ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          Write(F, ' ');
          for I := 1 to N do
            Write(F, CsucsSuly^[M * L + I] :K);
          WriteLn(F);
          WriteLn(F);
        end; { for M }
      end; { if CsucsSuly }

      if (ElSuly <> Nil) and ((InpData and InpElSuly) <> 0)  then
      begin
        WriteLn(F, ny[2, RepLanguage]);
        K := 6;                         { ilyen szeles egy oszlop }
        L := (W - 3) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          for I := 1 to Cs do
          begin
            Write(F, ' ', Betu(I), '|');
            for J := M * L + 1 to M * L + N do
              if AdjM^[I, J] <> 0 then
                Write(F, ElSuly^[I, J] :K)
              else
                Write(F, Copy(SPC, 1, K - 1), '.');
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if ElSuly }

      if (AdjM <> Nil) and (Cs > 0) and ((InpData and InpAdjM) <> 0) then
      begin
        WriteLn(F, ny[3, RepLanguage]);
        K := 3;                         { ilyen szeles egy oszlop }
        L := (W - 3) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          for I := 1 to Cs do
          begin
            Write(F, ' ', Betu(I), '|');
            for J := M * L + 1 to M * L + N do
              Write(F, AdjM^[I, J] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if AdjM }

      if (IncM <> Nil) and ((ResData and ResIncM) <> 0) then
      begin
        WriteLn(F, ny[4, RepLanguage]);
        K := 3;                         { ilyen szeles egy oszlop }
        L := W div K;                   { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          if M <> 0 then
            WriteLn(ny[5, RepLanguage]);
          for J := 1 to El do
          begin
            for I:= M * L + 1 to M * L + N do
              Write(F, IncM^[I, J] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if IncM }

(*      if KorM <> Nil then
      begin
        WriteLn(F, ny[7, RepLanguage]);
        K := 3;                         { ilyen szeles egy oszlop }
        L := W div K;                   { ennyi csucs fer egy sorba }
        for M := 0 to (El - 1) div L do
        begin
          if M <> ((El - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := El - L * ((El - 1) div L);
          if M <> 0 then
            WriteLn(ny[5, RepLanguage]);
          for I := 1 to Kor do
          begin
            for J := M * L + 1 to M * L + N do
              Write(F, KorM^[I, J] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if KorM }
*)
      if (KorM <> Nil) and (Kor <> NemIsm) and (Kor > 0)
          and ((ResData and ResKorLista) <> 0) then
      begin
        Write(F, ny[30, RepLanguage]);
        if Kor < MaxKor then
          WriteLn(F)
        else if RepLanguage = RepEnglish then
          WriteLn(F, ' (the first ', Kor, ')')
        else
          WriteLn(F, ' (az elsì ', Kor, ')');
        for I := 1 to Kor do
        begin
          Write(F, '  ', Betu(KorM^[I, 1]));
          J := 2;
          while (J <= Cs) and (KorM^[I, J] <> 0) do
          begin
            if (J mod (W - 15)) = 0 then
            begin
              WriteLn(F);
              Write(F, '              ');
            end;
            if not Iranyitott then
              Write(F, '-')
            else if (KorM^[I, J] > 0) then
              Write(F, '>')
            else
              Write(F, '<');
            Write(F, Betu(Abs(KorM^[I, J])));
            Inc(J);
          end;
          if not Iranyitott then
            Write(F, '-')
          else if (AdjM^[Abs(KorM^[I, J - 1]), Abs(KorM^[I, 1])] > 0) then
            Write(F, '>')
          else
            Write(F, '<');
          WriteLn(F, ' (', Betu(Abs(KorM^[I, 1])), ')');
        end; { for I }
        WriteLn(F);
      end; { if KorM }

      if Vagat <> NemIsm then
        WriteLn(F, ny[8, RepLanguage], Vagat);
      if VagatM <> Nil then
      begin
        WriteLn(F, ny[9, RepLanguage]);
        K := 3;                         { ilyen szeles egy oszlop }
        L := W div K;                   { ennyi csucs fer egy sorba }
        for M := 0 to (El - 1) div L do
        begin
          if M <> ((El - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := El - L * ((El - 1) div L);
          if M <> 0 then
            WriteLn('ny5[RepLanguage]');
          for I := 1 to Vagat do
          begin
            for J := M * L + 1 to M * L + N do
              Write(F, VagatM^[I, J] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if VagatM }

      if (KompLista <> Nil) and (Komp > 0)
        and ((ResData and ResKomp) <> 0) then
      begin
        WriteLn(F, ny[10, RepLanguage]);
        for I := 1 to Komp do
        begin
          Write(F, I :3, ': ');
          for J := 1 to Cs do
            if KompLista^[J] = I then
              Write(F, Betu(J), ' ');
          WriteLn(F);
        end;
        WriteLn(F);
      end; { if KompLista }

      if (ErosKompLista <> Nil) and (ErosKomp > 0)
        and ((ResData and ResErosKomp) <> 0) then
      begin
        WriteLn(F, ny[11, RepLanguage]);
        for I := 1 to ErosKomp do
        begin
          Write(F, I :3, ': ');
          for J := 1 to Cs do
            if ErosKompLista^[J] = I then
              Write(F, Betu(J), ' ');
          WriteLn(F);
        end;
        WriteLn(F);
      end; { if ErosKompLista }

      if (ResData and ResTagLista) <> 0 then
      begin
        if Tag <> NemIsm then
          WriteLn(F, ny[12, RepLanguage], Tag);
        if TagLista <> Nil then
        begin
          WriteLn(F, ny[13, RepLanguage]);
          for I := 1 to Tag do
          begin
            Write(F, I :3, ': ');
            for J := 1 to Cs do
              if TagLista^[J] = I then
                Write(F, Betu(J), ' ');
            WriteLn(F);
          end;
        end; { if TagLista }
        if Artik <> NemIsm then
          WriteLn(F, ny[14, RepLanguage], Artik);
        if ArtikLista <> Nil then
        begin
          Write(F, ny[15, RepLanguage]);
          for I := 1 to Cs do
            if ArtikLista^[I] <> 0 then
              Write(F, Betu(I), ' ');
          WriteLn(F);
          WriteLn(F);
        end; { if ArtikLista }
      end; { if ResData and ResTagLista }

      if (KiFokLista <> Nil) and ((ResData and ResFokLista) <> 0) then
      begin
        WriteLn(F, ny[16, RepLanguage]);
        K := 3;                         { ilyen szeles egy oszlop }
        L := (W - 5) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, '     ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, '      ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          if Iranyitott then
            Write(F, ny[17, RepLanguage])
          else
          Write(F, '     ');
          for I := M * L + 1 to M * L + N do
            Write(F, KiFokLista^[I] :K);
          WriteLn(F);
          if Iranyitott then
          begin
            Write(F, ny[18, RepLanguage]);
            for I := M * L + 1 to M * L + N do
              Write(F, BeFokLista^[I] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if KiFokLista }

      if (ResData and ResEulerUt) <> 0 then
      begin
        if VanEulerUt = Igaz then
          WriteLn(F, ny[19, RepLanguage])
        else if VanEulerUt = Hamis then
          if VanEulerKor = Igaz then
            WriteLn(F, ny[20, RepLanguage])
          else if VanEulerKor = Hamis then
          begin
            WriteLn(F, ny[21, RepLanguage]);
            WriteLn(F);
          end;
        if EulerUt <> Nil then
        begin
          Write(F, ny[22, RepLanguage]);
          for I := 1 to El do
          begin
            Write(F, Betu(EulerUt^[I]), '-');
            if (I mod (W - 15)) = 0 then
            begin
              WriteLn(F);
              Write(F, '              -');
            end;
          end;
          WriteLn(F, Betu(EulerUt^[El + 1]));
          WriteLn(F);
        end; { if EulerUt }
      end; { if ResData and ResEulerUt }

      if (PruferKod <> Nil) and ((ResData and ResPruferKod) <> 0) then
      begin
        Write(F, ny[23, RepLanguage]);
        for I := 1 to Cs - 1 do
          Write(F, Betu(PruferKod^[I]), ' ');
        WriteLn(F);
      end; { if PruferKod }

      if (MinTav <> Nil) and (MinUtKozepso <> Nil)
        and ((ResData and ResMinTav) <> 0) then
      begin
        WriteLn(F, ny[24, RepLanguage]);
        K := Max(9, Cs + 1);            { ilyen szeles egy oszlop }
        L := (W - 3) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          for I := 1 to Cs do
          begin
            Write(F, ' ', Betu(I), '|');
            for J := M * L + 1 to M * L + N do
              if (MinTav^[I, J] <> MaxSuly) then
              begin
                S := Betu(I) + GetMinUt(G, I, J) + Betu(J);
                Write(F, Copy(SPC, 1, K - Length(S)), S);
              end
              else
                Write(F, Copy(SPC, 1, K - 1), '.');
            WriteLn(F);
            Write(F, '  |');
            for J := M * L + 1 to M * L + N do
              if (MinTav^[I, J] <> MaxSuly) then
              begin
                Str(MinTav^[I, J], S);
                Write(F, Copy(SPC, 1, K - Length(S) - 2), '(', S, ')');
              end
              else
                Write(F, Copy(SPC, 1, K));
            WriteLn(F);
            WriteLn(F, '  |');
          end; { for I }
          WriteLn(F);
        end; { for M }
      end; { if MinTav }

      if (Centrum <> NemIsm) and ((ResData and ResExcentritas) <> 0) then
        WriteLn(F, ny[25, RepLanguage], Betu(Centrum));
      if (Excentritas <> Nil) and ((ResData and ResExcentritas) <> 0) then
      begin
        WriteLn(F, ny[26, RepLanguage]);
        K := 6;                         { ilyen szeles egy oszlop }
        L := (W - 1) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, ' ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, ' ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          Write(F, ' ');
          for I := M * L + 1 to M * L + N do
            if Excentritas^[I] < MaxSuly then
              Write(F, Excentritas^[I] :K)
            else
              Write(F, Copy(SPC, 1, K - 2), '+Ï');
          WriteLn(F);
          WriteLn(F);
        end; { for M }
      end; { if Excentritas }

      if (MinFeszitoFa <> Nil) and ((ResData and ResMinFeszitoFa) <> 0) then
      begin
        WriteLn(F, ny[27, RepLanguage]);
        if MinFeszFaKoltseg <> NemIsm then
          WriteLn(F, ny[28, RepLanguage], MinFeszFaKoltseg, ')');
        K := 3;                         { ilyen szeles egy oszlop }
        L := (W - 3) div K;             { ennyi csucs fer egy sorba }
        for M := 0 to (Cs - 1) div L do
        begin
          if M <> ((Cs - 1) div L) then
            N := L                      { ennyi csucs kell ebbe a sorba }
          else
            N := Cs - L * ((Cs - 1) div L);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(SPC, 1, K - 1), Betu(M * L + I));
          WriteLn(F);
          Write(F, '   ');
          for I := 1 to N do
            Write(F, Copy(Vonal, 1, K));
          WriteLn(F);
          for I := 1 to Cs do
          begin
            Write(F, ' ', Betu(I), '|');
            for J := M * L + 1 to M * L + N do
              Write(F, MinFeszitoFa^[I, J] :K);
            WriteLn(F);
          end;
          WriteLn(F);
        end; { for M }
      end; { if MinFeszitoFa }

      if (TopRendezes <> Nil) and (DAG = Igaz)
        and ((ResData and ResTopRendezes) <> 0) then
      begin
        Write(F, ny[29, RepLanguage]);
        for I := Cs downto 1 do
          Write(F, Betu(TopRendezes^[I]), ' ');
        WriteLn(F);
      end; { if TopRendezes }
    end; { with G^ }
    Close(F);
    Jelentes := IOResult = 0;
  end; { if IOResult else }
  {$I+}
end; { Jelentes }

{ ========================================================================== }

{ Szamolasi eredmenyek torlese }
procedure DisposeResults(G: PGraf);
begin
  with G^ do
  begin
    if IncM <> Nil then
      Dispose(IncM);
    if KorM <> Nil then
      Dispose(KorM);
    if VagatM <> Nil then
      Dispose(VagatM);
    if KompLista <> Nil then
      Dispose(KompLista);
    if TagLista <> Nil then
      Dispose(TagLista);
    if ArtikLista <> Nil then
      Dispose(ArtikLista);
    if KiFokLista <> Nil then
      Dispose(KiFokLista);
    if BeFokLista <> Nil then
      Dispose(BeFokLista);
    if EulerUt <> Nil then
      Dispose(EulerUt);
    if PruferKod <> Nil then
      Dispose(PruferKod);
    if MinTav <> Nil then
      Dispose(MinTav);
    if MinUtKozepso <> Nil then
      Dispose(MinUtKozepso);
    if Excentritas <> Nil then
      Dispose(Excentritas);
    if MinFeszitoFa <> Nil then
      Dispose(MinFeszitoFa);
    if TopRendezes <> Nil then
      Dispose(TopRendezes);
    if ErosKompLista <> Nil then
      Dispose(ErosKompLista);

    El := NemIsm;
    Kor := NemIsm;
    Vagat := NemIsm;
    Komp := NemIsm;
    Tag := NemIsm;
    Artik := NemIsm;
    Centrum := NemIsm;
    MinFeszFaKoltseg := NemIsm;
    ErosKomp := NemIsm;

    IncM := Nil;
    KorM := Nil;
    VagatM := Nil;
    KompLista := Nil;
    TagLista := Nil;
    ArtikLista := Nil;
    KiFokLista := Nil;
    BeFokLista := Nil;
    EulerUt := Nil;
    PruferKod := Nil;
    MinTav := Nil;
    MinUtKozepso := Nil;
    Excentritas := Nil;
    MinFeszitoFa := Nil;
    TopRendezes := Nil;
    ErosKompLista := Nil;

    VanEulerUt := NemIsm;
    VanEulerKor := NemIsm;
    DAG := NemIsm;
  end; { with }
end; { DisposeResults }

{ ========================================================================== }

{ Graf megszuntetese }
procedure DisposeGraf(G: PGraf);
begin
  with G^ do
  begin
    if AdjM <> Nil then
      Dispose(AdjM);
    if CsucsSuly <> Nil then
      Dispose(CsucsSuly);
    if ElSuly <> Nil then
      Dispose(ElSuly);
    if XPoz <> Nil then
      Dispose(XPoz);
    if YPoz <> Nil then
    Dispose(YPoz);
  end; { with }
  DisposeResults(G);
  Dispose(G);
end; { DisposeGraf }

{ ========================================================================== }

end.
