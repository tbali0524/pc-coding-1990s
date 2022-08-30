{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B†lint       }
{                                                }
{************************************************}

unit CAsm; { Assembler }

{$B-,X+}
interface

uses Dos, CGlobals, CMemTool, CSzimb, CKif;

const
  ASMExt = '.ASM';
  REPExt = '.REP';
  LABELCom = '.LABEL';

type

 { .OPT rekord }
  TOpt = Record
    S: Boolean;         { szimb¢lumlista }
    L: Boolean;         { soronkÇnti lista }
    M: Boolean;         { mem¢riatÇrkÇp }
    T: Boolean;         { îsszegzÇs }
    OFileName: PathStr; { kimeneti f†jlnÇv }
    RFileName: PathStr; { jelentÇs f†jlnÇv }
    MFileName: PathStr; { mem¢riatÇrkÇp f†jlnÇv }
    PCStart: Word;      { PC kezdìÇrtÇke }
  end;

 { Assembler }
  PAsm = ^TAsm;
  TAsm = object(TKif)
    Parent: PAsm;       { INCLUDE f†jln†l a h°v¢, egyÇbkÇnt Nil }
    M: PMem;            { 64K mem¢riablokk }
    ForrasFName: PathStr; { assembly forr†sf†jl neve }
    ForrasFile: Text;   { assembly forr†sf†jl }
    Opt: TOpt;          { .OPT rekord }
    SrcCimke: PSrcCimke;       { forr†s cimke t†bl†zat (.LABEL) }
    InclFiles: PInclFiles;     { forr†s include f†jlok nevei }
    IncBinFiles: PIncBinFiles; { bin†ris include f†jlok nevei }
    Map: PMem;          { mapfile }
    ActLGL: Word;       { utols¢ glob†lis cimke c°me }
    FileCount: Word;    { egyedi sorsz†m minden forr†s include f†jlnak }
    ThisFileLines,      { leford°tott sorok sz†ma ebben a f†jlban }
    TotalLines,         { leford°tott sorok sz†ma (îsszegzÇshez) }
    TotalFiles,         { feldolgozott forr†sf†jlok îsszsz†ma }
    TotalData,          { adatmÇret }
    TotalCode,          { k¢dmÇret }
    TotalInstr: Word;   { utas°t†sok sz†ma }
    VoltRep: Boolean;   { elkÇszÅlt-e a jelentÇsf†jl }
    VoltMap: Boolean;   { elkÇszÅlt-e a mapf†jl }
    PC: Word;           { soronkîvetkezì utas°t†s helye (ill. a * ÇrtÇke) }
    LineNum: Word;      { aktu†lis sor sorsz†ma }
    EredSor: String;    { aktu†lis sor (eredeti) }
    Sor: String;        { aktu†lis sor (feldolgoz†s alatt) }

    PCMin, PCMax: Word; { mettìl meddig tîrtÇnt k¢dgener†l†s (2. menet) }
    UjPC: Word;         { a sor feldolgoz†sa ut†ni PC (2. menet) }
    VoltAdat: Boolean;  { volt-e adat gener†l†s a sorban (2. menet) }
    VoltUt: Boolean;    { volt-e utas°t†s a sorban (2. menet) }
    VoltInclude: Boolean; { volt-e .INCLUDE a sorban (2. menet) }
    VoltUgras: Boolean; { volt-e ugr†s .GOTO, .IF miatt a sorban (2. menet) }
    VoltEnd: Boolean;   { volt-e .END a sorban (2. menet) }
    InclHibaState: Word;     { INCLUDE f†jlbeli hib†n†l a hiba†llapot }
    InclHibaLineNum: Word;   { INCLUDE f†jlbeli hib†n†l a hib†s sor sz†ma }
    InclHibaEredSor: String; { INCLUDE f†jlbeli hib†n†l a hib†s sor }
    InclHibaFName: PathStr;  { INCLUDE f†jlbeli hib†n†l a hib†s f†jl neve }

    constructor Init(var AForrasFName: PathStr; AM: PMem; AParent: PAsm;
      AOpt: TOpt);
    destructor Done; virtual;
    procedure OpenInput;
    procedure OlvasSor;
    function ElsoSzo(var JoAzon: Boolean): String;
    function ElsoParam: String;
    function CimzesMod(UKod: Word): Word;
    procedure GetInclHibaAdat(P: PAsm);
    procedure FordDir1(FD: String);
    procedure FeldolgSor1;
    procedure ElsoMenet;
    procedure OpenReport;
    procedure AdjustPC(Uj: Word; Ut: Boolean);
    procedure Utasitas2(UKod: Word);
    procedure FordDir2(FD: String);
    procedure ReportSor;
    procedure FeldolgSor2;
    procedure ReportMap;
    procedure ReportSummary;
    procedure MasodikMenet;
    procedure Fordit;
  end; { TAsm }

const
  AsmInfo: String[80] = 'C64ASM v1.1a - C64 (6510) Assembler  ' +
    'Copyright (c) 1993-2001 by B†lint T¢th';

 { AlapÇrtelmezett (Åres) .OPT rekord }
  DefaultOpt: TOpt = (
    S: False;
    L: False;
    M: False;
    T: False;
    OFileName: '';
    RFileName: '';
    MFileName: '';
    PCStart: $0801);

 { Az egyes hibak¢doknak megfelelì hibaÅzenetek }
  HibaUzenet: Array[1..28] of String[44] = (
    '',                         {21}
    'Out of memory',            {22}
    'Cannot open source file',  {23}
    'Cannot open output file',  {24}
    '', '', '', '', '', '',     {25-30}
    'Error in expression',      {41}
    'Constant too large',
    ') expected',
    'Operand expected',
    'Undefined symbol',
    'Expression expected',
    'Redefinition of existing constant or label',
    'Syntax error',
    'Division by zero',
    'Invalid addressing mode for this instruction',
    'Byte operand expected',
    'Branch out of range',
    'Invalid compiler directive',
    'Invalid parameter',
    'Error in include file',
    'Endless loop in include file calls',
    'Cannot open include file',
    'Possible endless loop with .GOTO or .IF'
  );

function HibaJel(ErNum, LineNum: Word; FName: PathStr): String;
procedure KiveszSpace(var S: String);

implementation

var
  RepFile: Text;        { jelentÇsf†jl }

{ ================================================================== }
{ HibajelentÇs }
function HibaJel(ErNum, LineNum: Word; FName: PathStr): String;
var
  S1, S2: String;
begin
  Str(ErNum, S1);
  if ErNum < ECOffset then
    HibaJel := 'Error #' + S1 + ' : ' + HibaUzenet[ErNum - 20]
  else
  begin
    Str(LineNum, S2);
    HibaJel := 'Error #' + S1 + ' in ' + FName + ' at line ' + S2 + ' : '
      + HibaUzenet[ErNum - ECOffset + 10];
  end;
end; { HibaJel }

{ ================================================================== }
{ Sz¢kîz Çs TAB kivÇtele (az idÇzìjelben levìk nem) }
procedure KiveszSpace(var S: String);
var
  I: Integer;
  S1: String;
  ParatlanZ: Boolean;   { idÇzìjel nyitva }
begin
  S1 := '';
  ParatlanZ := False;
  for I := 1 to Length(S) do
  begin
    if ParatlanZ or not (S[I] in [' ', #9]) then
    begin
      S1 := S1 + S[I];
      if S[I] = '"' then
        ParatlanZ := not ParatlanZ;
    end;
  end; { for }
  S := S1;
end; { KiveszSpace }

{ ================================================================== }
{ TAsm objektum }

constructor TAsm.Init(var AForrasFName: PathStr; AM: PMem; AParent: PAsm;
  AOpt: TOpt);
begin
  inherited Init;
  FNameExt(AForrasFName, ASMExt);
  ForrasFName := AForrasFName;
  M := AM;

  Parent := AParent;
  Opt := AOpt;
  New(SrcCimke, Init);
  New(InclFiles, Init);
  New(IncBinFiles, Init);
  if Parent <> Nil then
  begin
    Map := Parent^.Map;
    Opt.PCStart := Parent^.PC;
  end
  else
    Map := Nil;
  ActLGL := 0;
  FileCount := 0;
  ThisFileLines := 0;
  TotalLines := 0;
  TotalFiles := 1;
  TotalData := 0;
  TotalCode := 0;
  TotalInstr := 0;
  VoltRep := False;
  VoltMap := False;
  PC := 0;
  LineNum := 0;
  EredSor := '';
  Sor := '';

  PCMin := $FFFF;
  PCMax := 0;
  UjPC := 0;
  VoltAdat := False;
  VoltUt := False;
  VoltInclude := False;
  VoltUgras := False;
  VoltEnd := False;
  InclHibaState := erNone;
  InclHibaLineNum := 0;
  InclHibaEredSor := '';
  InclHibaFName := '';
end; { Init }

destructor TAsm.Done;
begin
  Dispose(SrcCimke, Done);
  Dispose(InclFiles, Done);
  Dispose(IncBinFiles, Done);
  if (Parent = Nil) and (Map <> Nil) then
    Dispose(Map);
  inherited Done;
end; { Done }

{ ================================================================== }
{ Forr†sf†jl megnyit†s }
procedure TAsm.OpenInput;
begin
  {$I-}
  Assign(ForrasFile, ForrasFName);
  Reset(ForrasFile);
  {$I+}
  if IOResult <> 0 then
    State := erOpenAsm;
  LineNum := 0;
end; { OpenInput }

{ ================================================================== }
{ Sor olvas†sa ; -ig, nagybetñssÇ konvert†l†s (az idÇzìjelben lÇvìket nem) }
procedure TAsm.OlvasSor;
var
  I, J: Integer;
  ParosZ: Boolean;      { idÇzìjel csukva }
begin
  ReadLn(ForrasFile, EredSor);
  Inc(LineNum);
  Sor := '';
  ParosZ := True;
  I := 1;
  while (I <= Length(EredSor)) and not((EredSor[I] = ';') and ParosZ) do
  begin
    if ParosZ then
      Sor := Sor + UpCase(EredSor[I])
    else
      Sor := Sor + EredSor[I];
    if EredSor[I] = '"' then
      ParosZ := not ParosZ;
    Inc(I);
  end;
  BalraHuz(Sor);
end; { OlvasSor }

{ ================================================================== }
{ Sor elsì szav†nak (= -ig, :-ig, sz¢kîzig vagy TAB-ig) kivÇtele a Sor-b¢l }
{ Sor-nak h°v†skor BalraHuz-ottnak kell lennie, az eredmÇny Sor is az }
{ JoAzon = True, ha a sz¢ megfelel szimb¢lumnÇvnek }
function TAsm.ElsoSzo(var JoAzon: Boolean): String;
var
  I: Integer;
begin
  JoAzon := True;
  if Sor = '' then
    ElsoSzo := ''
  else
  begin
    I := 2;
    while (I <= Length(Sor)) and not (Sor[I] in ['=', ':', ' ', #9]) do
    begin
      if not (Sor[I] in SzimbKar) then
        JoAzon := False;
      Inc(I);
    end;
    if not (Sor[1] in SzimbKar) then
      JoAzon := False;
    ElsoSzo := Copy(Sor, 1, I - 1);
    Delete(Sor, 1, I - 1);
    BalraHuz(Sor);
  end; { else }
end; { ElsoSzo }

{ ================================================================== }
{ Sor elsì paramÇterÇnek (nem idÇzìjelben lÇvì vesszìig) kivÇtele a Sor-b¢l }
function TAsm.ElsoParam: String;
var
  I: Word;
  ParosZ: Boolean;   { idÇzìjel csukva }
begin
  if Sor = '' then
    ElsoParam := ''
  else
  begin
    I := 1;
    ParosZ := True;
    while (I <= Length(Sor)) and not((Sor[I] = ',') and ParosZ) do
    begin
      if Sor[I] = '"' then
        ParosZ := not ParosZ;
      Inc(I);
    end;
    ElsoParam := Copy(Sor, 1, I - 1);
    Delete(Sor, 1, I);
  end; { else }
end; { ElsoParam }

{ ================================================================== }
{ C°mzÇsm¢d meghat†roz†sa }
{ UKod az utas°t†sk¢d, Sor-ban a paramÇterek (elîtte KiveszSpace kell) }
{ Sor-ban a kifejezÇskiÇrtÇkelìnek megkÅldendì sztring marad }
function TAsm.CimzesMod(UKod: Word): Word;
var
  I, J: Word;        { kifejezÇs eleje, vÇge }
  UC: Word;
  B1, CM1: Byte;
  CM: Byte;
begin
  I := 1;
  J := Length(Sor);
  if Length(Sor) = 0 then
    if (UKod = ASL) or (UKod = LSR) or (UKod = ROL) or (UKod = ROR) then
      CM := Acc
    else
      CM := Spec
  else if Sor = 'A' then
    if (UKod = ASL) or (UKod = LSR) or (UKod = ROL) or (UKod = ROR) then
      CM := Acc
    else
      CM := AbsM
  else if Sor[1] = '#' then
  begin
    CM := Imm;
    I := 2;
  end
  else if (J >= 5) and (Sor[1] = '(') and (Copy(Sor, J - 2, 3) = '),Y') then
  begin
    CM := IndY;
    I := 2;
    Dec(J, 3);
  end
  else if (J >= 5) and (Sor[1] = '(') and (Copy(Sor, J - 2, 3) = ',X)') then
  begin
    CM := IndX;
    I := 2;
    Dec(J, 3);
  end
  else if (J >= 3) and (Sor[1] = '(') and (Sor[J] = ')') then
  begin
    UC := UKod or AbsI;
    B1 := 0;
    while (B1 < $FF) and (UK[B1] <> UC) do
      Inc(B1);
    if UC = UK[B1] then
    begin
      CM := AbsI;
      I := 2;
      Dec(J);
    end
    else
      CM := AbsM
  end
  else if (J >= 3) and (Copy(Sor, J - 1, 2) = ',X') then
  begin
    CM := AbsX;
    Dec(J, 2);
  end
  else if (J >= 3) and (Copy(Sor, J - 1, 2) = ',Y') and
    ((Sor[1] <> '(') or (Sor[J - 2] <> ')')) then
  begin
    CM := AbsY;
    Dec(J, 2);
  end
  else if (UKod = BCC) or (UKod = BCS) or (UKod = BEQ) or (UKod = BMI) or
      (UKod = BNE) or (UKod = BPL) or (UKod = BVC) or (UKod = BVS) then
    CM := Rel
  else
    CM := AbsM;
  if Sor <> '' then
    Sor := Copy(Sor, I, J - I + 1);
  if CM in [AbsM, AbsX, AbsY] then     { null†slap c°mzÇsek: csak ha az }
  begin                                { operandusban nincs szimb¢lumnÇv }
    I := Kiertekel(Sor, PC, False, ActLGL);
    if (State = erNone) and (I < $100) then
    begin
      case CM of
        AbsM: CM1 := ZP;
        AbsX: CM1 := ZPX;
        AbsY: CM1 := ZPY;
      end;
      UC := UKod or CM1;
      B1 := 0;
      while (B1 < $FF) and (UK[B1] <> UC) do
        Inc(B1);
      if UC = UK[B1] then
        CM := CM1;
    end { if State }
    else
      State := erNone;
  end; { if CM }
  CimzesMod := CM;
end; { CimzesMod }

{ ================================================================== }
{ Include f†jlbeli hiba esetÇn a hibaadatok kinyerÇse }
{  P: az include f†jl assembler objektuma }
procedure TAsm.GetInclHibaAdat(P: PAsm);
begin
  if P <> Nil then
  begin
    if P^.State = erOpenAsm then
      State := erOpenIncl
    else
    begin
      State := erIncl;
      if P^.State <> erIncl then
      begin
        InclHibaState := P^.State;
        InclHibaLineNum := P^.LineNum;
        InclHibaEredSor := P^.EredSor;
        InclHibaFName := P^.ForrasFName;
      end
      else
      begin
        InclHibaState := P^.InclHibaState;
        InclHibaLineNum := P^.InclHibaLineNum;
        InclHibaEredSor := P^.InclHibaEredSor;
        InclHibaFName := P^.InclHibaFName;
      end;
    end { if P^.State else }
  end; { if P <> }
end; { GetInclHibaAdat }

{ ================================================================== }
{ Ford°t¢ direkt°v†k (1. menet) }
procedure TAsm.FordDir1(FD: String);

procedure OptDir1;                     { .OPT }
var
  S1: String;
begin
  repeat
    S1 := ElsoParam;
    if S1 <> '' then
      case S1[1] of
        'S' : if (S1 = 'S') or (S1 = 'S+') then
                Opt.S := True
              else if S1 = 'S-' then
                Opt.S := False
              else
                State := erDirPar;
        'L' : if (S1 = 'L') or (S1 = 'L+') then
                Opt.L := True
              else if S1 = 'L-' then
                Opt.L := False
              else
                State := erDirPar;
        'T' : if (S1 = 'T') or (S1 = 'T+') then
                Opt.T := True
              else if S1 = 'T-' then
                Opt.T := False
              else
                State := erDirPar;
        'O' : if (Length(S1) > 2) and (S1[2] = '=') then
                Opt.OFileName := Copy(S1, 3, 255)
              else
                State := erDirPar;
        'R' : if (S1 = 'R') or (S1 = 'R+') then
              begin
                Opt.S := True;
                Opt.L := True;
                Opt.M := True;
                Opt.T := True;
              end
              else if (Length(S1) > 2) and (S1[2] = '=') then
                Opt.RFileName := Copy(S1, 3, 255)
              else
                State := erDirPar;
        'M' : if (S1 = 'M') or (S1 = 'M+') then
                Opt.M := True
              else if S1 = 'M-' then
                Opt.M := False
              else if (Length(S1) > 2) and (S1[2] = '=') then
                Opt.RFileName := Copy(S1, 3, 255)
              else
                State := erDirPar;
        else
          State := erDirPar
      end; { case }
  until (S1 = '') or (State <> erNone);
end; { OptDir }

{ ================================================================== }
procedure InclDir1;                    { .INCLUDE }
var
  P: PAsm;              { Assembler objektum az INCLUDE f†jlnak }
  FName, S1: PathStr;
begin
  S1 := FullFileName(Sor, ASMExt);
  P := @Self;
  while (P <> Nil) and (State = erNone) do
  begin
    if S1 = FullFileName(P^.ForrasFName, ASMExt) then
      State := erInclLoop;
    P := P^.Parent;
  end;
  if State = erNone then
  begin
    FName := Sor;
    FNameExt(FName, ASMExt);
    New(P, Init(FName, M, @Self, Opt));
    P^.ElsoMenet;
    if P^.State <> erNone then
      GetInclHibaAdat(P)
    else
    begin
      PC := P^.PC;
      Opt.S := P^.Opt.S;
      Opt.L := P^.Opt.L;
      Opt.T := P^.Opt.T;
      Opt.RFileName := P^.Opt.RFileName;
      Konst^.Hozzafuz(P^.Konst);         { szimb¢lumt†bla befñzÇse }
      Cimke^.Hozzafuz(P^.Cimke);
      Valt^.Hozzafuz(P^.Valt);
      HelyiCimke^.Hozzafuz(P^.HelyiCimke);
      HelyiKonst^.Hozzafuz(P^.HelyiKonst);
      SrcCimke^.Hozzafuz(P^.SrcCimke);
    end; { else }
    Dispose(P, Done);
  end; { if State }
end; { InclDir1 }

{ ================================================================== }
procedure IncBinDir1;                  { .INCBIN }
var
  FName: PathStr;
  B: Byte;
  StartA, EndA: Word;
begin
  FName := Sor;
  B := LoadAny(M, FName, StartA, EndA, 1);
  if B <> teNone then
    State := erOpenIncl
  else
  begin
    if StartA < PCMin then
      PCMin := StartA;
    if EndA > PCMax then
      PCMax := EndA;
    Inc(TotalFiles, 1);
    Inc(TotalData, EndA - StartA + 1);
    if (EndA <> $FFFF) then
      PC := EndA + 1
    else
      PC := $FFFF;
  end; { if B else }
end; { IncBinDir1 }

{ ================================================================== }
procedure LabelDir1;                   { .LABEL }
var
  S: String;
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
begin
  S := ElsoSzo(JoAzon);
  if not JoAzon then
    State := erDirPar;
  SrcCimke^.UjElem(S, 0, 0);
end; { LabelDir1 }

{ ================================================================== }
procedure GotoDir1;                    { .GOTO }
var
  S, S1, S2: String;
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
begin
  S := ElsoSzo(JoAzon);
  if not JoAzon then
    State := erDirPar
  else
  begin
    Close(ForrasFile);
    OpenInput;
    repeat
      OlvasSor;
      S1 := ElsoSzo(JoAzon);
      if (S1 <> LABELCom) and JoAzon then
        S1 := ElsoSzo(JoAzon);
      S2 := ElsoSzo(JoAzon);
    until Eof(ForrasFile) or ((S1 = LABELCom) and (S2 = S) and JoAzon);
    if (S1 <> LABELCom) then
      State := erUndef
    else if not SrcCimke^.UjElem(S, 0, 0) then
      State := erGotoLoop;
  end; { if not JoAzon else }
end; { GotoDir1 }

{ ================================================================== }
procedure IfDir1;                      { .IF }
var
  S, S1, S2: String;
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
  Feltetel: Word;       { feltÇtel kifejezÇs }
  I: Integer;
begin
  I := Pos('.GOTO', Sor);
  if I < 2 then
    State := erDirPar
  else
  begin
    Feltetel := Kiertekel(Copy(Sor, 1, I - 1), PC, True, ActLGL);
    if State = erNone then
    begin
      Sor := Copy(Sor, I + 5, 255);
      S := ElsoSzo(JoAzon);
      if not JoAzon then
        State := erDirPar
      else if Feltetel <> 0 then
      begin
        Close(ForrasFile);
        OpenInput;
        repeat
          OlvasSor;
          S1 := ElsoSzo(JoAzon);
          if (S1 <> LABELCom) and JoAzon then
            S1 := ElsoSzo(JoAzon);
          S2 := ElsoSzo(JoAzon);
        until Eof(ForrasFile) or ((S1 = LABELCom) and (S2 = S) and JoAzon);
        if (S1 <> LABELCom) then
          State := erUndef
        else if not SrcCimke^.UjElem(S, 0, 0) then
          State := erGotoLoop;
      end; { if Feltetel }
    end; { if State }
  end; { if I }
end; { IfDir1 }

{ ================================================================== }
procedure EndDir1;                    { .END }
begin
  Close(ForrasFile);
  OpenInput;
  repeat
    OlvasSor;
  until Eof(ForrasFile);
end; { EndDir1 }

{ ================================================================== }
begin { FordDir1 }
  if FD = '.OPT' then
    OptDir1
  else if FD = '.INCLUDE' then
    InclDir1
  else if FD = '.INCBIN' then
    IncBinDir1
  else if FD = '.LABEL' then
    LabelDir1
  else if FD = '.GOTO' then
    GotoDir1
  else if FD = '.IF' then
    IfDir1
  else if FD = '.END' then
    EndDir1
  else if FD = '.BYTE' then
    while ElsoParam <> '' do
      Inc(PC)
  else if FD = '.WORD' then
    while ElsoParam <> '' do
      Inc(PC, 2)
  else if (FD = '.ASC') or (FD = '.TEXT') or (FD = '.SCRL') or (FD = '.SCRU') then
    if (Length(Sor) > 2) and (Sor[1] = '"') and (Sor[Length(Sor)] = '"') then
      PC := PC + Length(Sor) - 2
    else
      State := erDirPar
  else if FD <> '.ENTRY' then          { a kompatibilitas miatt }
    State := erDir;
end; { FordDir1 }

{ ================================================================== }
{ Egy sor feldolgoz†sa (1. menet) }
procedure TAsm.FeldolgSor1;
var
  S1: String;           { elsì sz¢ }
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
  I: Integer;           { 0: cimke, -1: ÇrtÇkad†s, I>0: utas°t†s }

{ Konstans ÇrtÇkad†s }
procedure KonstErt;
var
  W: Word;
begin
  KiveszSpace(Sor);
  W := Kiertekel(Copy(Sor, 2, 255), PC, True, ActLGL);
  if State = erNone then
  begin
    if (S1[1] <> '_') and ((Cimke^.Keres(S1, 0) <> Nil) or
      (Valt^.Keres(S1, 0) <> Nil) or not Konst^.UjElem(S1, W, 0)) then
        State := erRedef
    else if (S1[1] = '_') and ((HelyiCimke^.Keres(S1, ActLGL) <> Nil) or
      not HelyiKonst^.UjElem(S1, W, ActLGL)) then
        State := erRedef;
  end;
  I := -1;
end; { KonstErt }

{ ================================================================== }
{ V†ltoz¢ ÇrtÇkad†s }
procedure ValtErt;
var
  W: Word;
begin
  KiveszSpace(Sor);
  W := Kiertekel(Copy(Sor, 3, 255), PC, True, ActLGL);
  if State = erNone then
    if (Cimke^.Keres(S1, 0) <> Nil) or (Konst^.Keres(S1, 0) <> Nil) then
      State := erRedef
    else
      Valt^.UjElem(S1, W, 0);
  I := -1;
end; { ValtErt }

{ ================================================================== }
begin { FeldolgSor1 }
  S1 := ElsoSzo(JoAzon);
  I := 0;
  if JoAzon then
  begin
    if Length(S1) = 3 then
      I := Pos(S1, InstrSet);
    if I = 0 then                      { szimb¢lum }
    begin
      if (Sor <> '') and (Sor[1] = '=') then
        KonstErt
      else if (Length(Sor) > 1) and (Sor[1] = ':') and (Sor[2] = '=') then
        ValtErt
      else if (S1[1] <> '_') and ((Konst^.Keres(S1, 0) <> Nil) or
        (Valt^.Keres(S1, 0) <> Nil) or not Cimke^.UjElem(S1, PC, 0)) then
          State := erRedef
      else if (S1[1] = '_') and ((HelyiKonst^.Keres(S1, ActLGL) <> Nil) or
        not HelyiCimke^.UjElem(S1, PC, ActLGL)) then
          State := erRedef
      else
      begin
        if S1[1] <> '_' then
          ActLGL := PC;
        S1 := ElsoSzo(JoAzon);         { kîvetkezì sz¢ kezelÇse }
        if Length(S1) = 3 then
          I := Pos(S1, InstrSet);
      end; { else }
    end; { if I }
  end; { if JoAzon }
  if I <> -1 then
  begin
    KiveszSpace(Sor);
    if (State = erNone) then
      if I <> 0 then                   { utas°t†s }
        Inc(PC, CMH[CimzesMod((I + 3) shl 2)])
      else if (S1 = '*') and (Length(Sor) > 1) then
      begin
        if Sor[1] = '=' then                                    { *= }
          PC := Kiertekel(Copy(Sor, 2, 255), PC, True, ActLGL)
        else if (Sor[1] = ':') and (Sor[2] = '=') then       { *:= }
          PC := Kiertekel(Copy(Sor, 3, 255), PC, True, ActLGL)
        else
          State := erSyntax;
      end { else if S1 }
      else if (S1 <> '') and (S1[1] = '.') then
        FordDir1(S1)
      else if (S1 <> '') then
        State := erSyntax;
  end; { if I }
end; { FeldolgSor1 }

{ ================================================================== }
{ Ford°t†s 1. menete (szimb¢lumt†bla elkÇsz°tÇse) }
procedure TAsm.ElsoMenet;
begin
  OpenInput;
  if State = erNone then
  begin
    PC := Opt.PCStart;
    while (State = erNone) and (not Eof(ForrasFile)) do
    begin
      OlvasSor;
      if Sor <> '' then
        FeldolgSor1;
    end; { while }
    Close(ForrasFile);
  end; { if }
end; { ElsoMenet }

{ ================================================================== }
{ JelentÇsf†jl megnyit†s, szimb¢lumt†bla ki°r†s (ha kell) }
procedure TAsm.OpenReport;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  if (Parent = Nil) and (Opt.S or Opt.L or Opt.T) then
  begin
    if Opt.RFileName = '' then
    begin
      FSplit(ForrasFName, D, N, E);
      Opt.RFileName := D + N + REPExt;
    end
    else
      FNameExt(Opt.RFileName, REPExt);
    {$I-}
    Assign(RepFile, Opt.RFileName);
    Rewrite(RepFile);
    {$I+}
    if IOResult <> 0 then
      Opt.RFileName := ''
    else
    begin
      WriteLn(RepFile, AsmInfo);
      WriteLn(RepFile);
      WriteLn(RepFile, 'Assembling ', ForrasFName);
      if Opt.S then
      begin
        WriteLn(RepFile);
        WriteLn(RepFile, 'SYMBOL TABLE:');
        WriteLn(RepFile, '-------------');
        if Konst^.Meret + HelyiKonst^.Meret + Valt^.Meret + Cimke^.Meret +
            HelyiCimke^.Meret + SrcCimke^.Meret = 0 then
          WriteLn(RepFile, '    <EMPTY>')
        else
        begin
          WriteLn(RepFile);
          WriteLn(RepFile, 'GLOBAL CONSTANTS:');
          Konst^.Lista(RepFile);
          WriteLn(RepFile);
          WriteLn(RepFile, 'GLOBAL VARIABLES:');
          Valt^.Lista(RepFile);
          WriteLn(RepFile);
          WriteLn(RepFile, 'GLOBAL LABELS:');
          Cimke^.Lista(RepFile);
          WriteLn(RepFile);
          WriteLn(RepFile, 'LOCAL CONSTANTS:');
          HelyiKonst^.Lista(RepFile);
          WriteLn(RepFile);
          WriteLn(RepFile, 'LOCAL LABELS:');
          HelyiCimke^.Lista(RepFile);
          WriteLn(RepFile);
          WriteLn(RepFile, 'SOURCE LABELS (for .IF and .GOTO):');
          SrcCimke^.Lista(RepFile);
        end; { if Konst^ else }
      end; { if Opt }
    end; { if IOResult else }
  end; { if Parent }
end; { OpenReport }

{ ================================================================== }
{ èllapotle°r¢k be†ll°t†sa k¢dgener†l†s ut†n (2. menet) }
{ Uj: UjPC, Ut = True ha utas°t†s volt }
procedure TAsm.AdjustPC(Uj: Word; Ut: Boolean);
begin
  if Ut then
  begin
    Inc(TotalCode, Uj - PC);
    Inc(TotalInstr);
    VoltUt := True;
  end
  else
  begin
    Inc(TotalData, Uj - PC);
    VoltAdat := True;
  end;
  if Uj - 1 > PCMax then
    PCMax := Uj - 1;
  if PC < PCMin then
    PCMin := PC;
  UjPC := Uj;
end; { AdjustPC }

{ ================================================================== }
{ Utas°t†s feldolgoz†sa (2. menet) }
procedure TAsm.Utasitas2(UKod: Word);
var
  CMod: Word;           { c°mzÇsm¢d }
  UC: Word;             { utas°t†s + c°mzÇsm¢d k¢dja }
  B1: Byte;             { CPU utas°t†sk¢d }
  H: Byte;              { utas°t†s hossza }
  W: Word;              { operandus }
  I: Integer;
begin
  CMod := CimzesMod(UKod);
  UC := UKod or CMod;
  B1 := 0;
  while (B1 < $FF) and (UK[B1] <> UC) do
    Inc(B1);
  if UC <> UK[B1] then
    State := erCimzes
  else
  begin
    H := CMH[CMod];
    if H > 1 then
      W := Kiertekel(Sor, PC, True, ActLGL);
    if State = erNone then
    begin
      if CMod = Rel then               { relat°v c°mzÇs }
      begin
        I := (LongInt(W) - LongInt(PC) - LongInt(2));
        if (I >= 0) and (I < $80) then
          W := I
        else if (I < 0) and (I >= -128) then
          W := I + $100
        else
          State := erBranch;
      end
      else if (H = 2) and (W >= $100) then
        State := erOpByte;
      if State = erNone then
      begin
        M^[PC] := B1;
        Map^[PC] := meCode;
        if H > 1 then
        begin
          M^[PC + 1] := Lo(W);
          Map^[PC + 1] := meCode;
          if H = 3 then
          begin
            M^[PC + 2] := Hi(W);
            Map^[PC + 2] := meCode;
          end;
        end;
        AdjustPC(PC + H, True);
      end; { if State }
    end; { if State }
  end; { if UC else }
end; { Utasitas2 }

{ ================================================================== }
{ Ford°t¢ direkt°v†k (2. menet) }
procedure TAsm.FordDir2(FD: String);

procedure ByteDir2;                    { .BYTE }
var
  W: Word;
  S1: String;
begin
  repeat
    S1 := ElsoParam;
    if S1 <> '' then
    begin
      W := Kiertekel(S1, UjPC, True, ActLGL);
      if State = erNone then
        if W >= $100 then
          State := erOpByte
        else
        begin
          M^[UjPC] := Lo(W);
          Map^[UjPC] := meByte;
          Inc(UjPC);
        end;
    end; { if S1 }
  until (S1 = '') or (State <> erNone);
  if UjPC <> PC then
    AdjustPC(UjPC, False);
end; { ByteDir2 }

{ ================================================================== }
procedure WordDir2;                    { .WORD }
var
  W: Word;
  S1: String;
begin
  repeat
    S1 := ElsoParam;
    if S1 <> '' then
    begin
      W := Kiertekel(S1, UjPC, True, ActLGL);
      if State = erNone then
      begin
        M^[UjPC] := Lo(W);
        M^[UjPC + 1] := Hi(W);
        Map^[UjPC] := meWord;
        Map^[UjPC + 1] := meWord;
        Inc(UjPC, 2);
      end;
    end; { if S1 }
  until (S1 = '') or (State <> erNone);
  if UjPC <> PC then
    AdjustPC(UjPC, False);
end; { WordDir2 }

{ ================================================================== }
procedure InclDir2;                    { .INCLUDE }
var
  P: PAsm;              { Assembler objektum az INCLUDE f†jlnak }
  FName: PathStr;
begin
  ReportSor;
  VoltInclude := True;
  FName := Sor;
  FNameExt(FName, ASMExt);
  New(P, Init(FName, M, @Self, Opt));
  P^.FileCount := FileCount;
  P^.Fordit;
  if P^.State <> erNone then
    GetInclHibaAdat(P)
  else
  begin
    UjPC := P^.PC;
    if P^.PCMin < PCMin then
      PCMin := P^.PCMin;
    if P^.PCMax > PCMax then
      PCMax := P^.PCMax;
    InclFiles^.Hozzafuz(P^.InclFiles);
    IncBinFiles^.Hozzafuz(P^.IncBinFiles);
    FileCount := P^.FileCount;
    Inc(TotalLines, P^.TotalLines);    { statisztik†k }
    Inc(TotalFiles, P^.TotalFiles);
    Inc(TotalData, P^.TotalData);
    Inc(TotalCode, P^.TotalCode);
    Inc(TotalInstr, P^.TotalInstr);
  end;
  Dispose(P, Done);
end; { InclDir2 }

{ ================================================================== }
procedure IncBinDir2;                  { .INCBIN }
var
  FName: PathStr;
  B: Byte;
  StartA, EndA: Word;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FName := Sor;
  B := LoadAny(M, FName, StartA, EndA, 1);
  if B <> teNone then
    State := erOpenIncl
  else
  begin
    if (EndA <> $FFFF) then
      PC := EndA + 1
    else
      PC := $FFFF;
    FSplit(FName, D, N, E);
    IncBinFiles^.UjElem(N + E, EndA - StartA + 1, FileCount);
    Inc(FileCount);
  end; { if B else }
end; { IncBinDir2 }

{ ================================================================== }
procedure GotoDir2;                    { .GOTO }
var
  S, S1, S2: String;
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
begin
  ReportSor;
  VoltUgras := True;
  S := ElsoSzo(JoAzon);
  Close(ForrasFile);
  OpenInput;
  repeat
    OlvasSor;
    S1 := ElsoSzo(JoAzon);
    if (S1 <> LABELCom) and JoAzon then
      S1 := ElsoSzo(JoAzon);
    S2 := ElsoSzo(JoAzon);
  until Eof(ForrasFile) or ((S1 = LABELCom) and (S2 = S) and JoAzon);
  Inc(ThisFileLines);
  Inc(TotalLines);
end; { GotoDir2 }

{ ================================================================== }
procedure IfDir2;                      { .IF }
var
  S, S1, S2: String;
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
  Feltetel: Word;       { feltÇtel kifejezÇs }
  I: Integer;
begin
  I := Pos('.GOTO', Sor);
  Feltetel := Kiertekel(Copy(Sor, 1, I - 1), PC, True, ActLGL);
  if State = erNone then
  begin
    Sor := Copy(Sor, I + 5, 255);
    S := ElsoSzo(JoAzon);
    if Feltetel <> 0 then
    begin
      ReportSor;
      VoltUgras := True;
      Close(ForrasFile);
      OpenInput;
      repeat
        OlvasSor;
        S1 := ElsoSzo(JoAzon);
        if (S1 <> LABELCom) and JoAzon then
          S1 := ElsoSzo(JoAzon);
        S2 := ElsoSzo(JoAzon);
      until Eof(ForrasFile) or ((S1 = LABELCom) and (S2 = S) and JoAzon);
      Inc(ThisFileLines);
      Inc(TotalLines);
    end; { if Feltetel }
  end; { if State }
end; { IfDir2 }

{ ================================================================== }
procedure EndDir2;                    { .END }
begin
  ReportSor;
  Close(ForrasFile);
  OpenInput;
  repeat
    OlvasSor;
  until Eof(ForrasFile);
  VoltEnd := True;
end; { EndDir2 }

{ ================================================================== }
var
  W: Word;
begin { FordDir2 }
  if FD = '.INCLUDE' then
    InclDir2
  else if FD = '.INCBIN' then
    IncBinDir2
  else if FD = '.GOTO' then
    GotoDir2
  else if FD = '.IF' then
    IfDir2
  else if FD = '.END' then
    EndDir2
  else if FD = '.BYTE' then
    ByteDir2
  else if FD = '.WORD' then
    WordDir2
  else if FD = '.ASC' then
  begin
    for W := 0 to Length(Sor) - 3 do
    begin
      M^[(PC + W) and $FFFF] := Ord(Sor[2 + W]);
      Map^[(PC + W) and $FFFF] := meAsc;
    end;
    AdjustPC(PC + Length(Sor) - 2, False);
  end
  else if FD = '.TEXT' then
  begin
    for W := 0 to Length(Sor) - 3 do
    begin
      M^[(PC + W) and $FFFF] := PC2CBMAscii(Ord(Sor[2 + W]));
      Map^[(PC + W) and $FFFF] := meText;
    end;
    AdjustPC(PC + Length(Sor) - 2, False);
  end
  else if FD = '.SCRL' then
  begin
    for W := 0 to Length(Sor) - 3 do
    begin
      M^[(PC + W) and $FFFF] := PC2SCRL(Ord(Sor[2 + W]));
      Map^[(PC + W) and $FFFF] := meScrL;
    end;
    AdjustPC(PC + Length(Sor) - 2, False);
  end
  else if FD = '.SCRU' then
  begin
    for W := 0 to Length(Sor) - 3 do
    begin
      M^[(PC + W) and $FFFF] := PC2SCRU(Ord(Sor[2 + W]));
      Map^[(PC + W) and $FFFF] := meScrU;
    end;
    AdjustPC(PC + Length(Sor) - 2, False);
  end;
end; { FordDir2 }

{ ================================================================== }
{ Egy sor feldolgoz†sa (2. menet) }
procedure TAsm.FeldolgSor2;
var
  S1: String;           { elsì sz¢ }
  JoAzon: Boolean;      { lehet szimb¢lumnÇv }
  I: Integer;           { 0: cimke, -1: ÇrtÇkad†s, I>0: utas°t†s }

{ V†ltoz¢ ÇrtÇkad†s }
procedure ValtErt2;
var
  W: Word;
begin
  KiveszSpace(Sor);
  W := Kiertekel(Copy(Sor, 3, 255), PC, True, ActLGL);
  if State = erNone then
    if (Cimke^.Keres(S1, 0) <> Nil) or (Konst^.Keres(S1, 0) <> Nil) then
      State := erRedef
    else
      Valt^.UjElem(S1, W, 0);
end; { ValtErt2 }

{ ================================================================== }
begin { FelDolgSor2 }
  S1 := ElsoSzo(JoAzon);
  I := 0;
  if JoAzon then
  begin
    if Length(S1) = 3 then
      I := Pos(S1, InstrSet);
    if I = 0 then
      if ((S1[1] <> '_') and (Cimke^.Keres(S1, 0) <> Nil)) or
          ((S1[1] = '_') and (HelyiCimke^.Keres(S1, ActLGL) <> Nil)) then
      begin                             { cimke }
        if (S1[1] <> '_') then
          ActLGL := PC;
        S1 := ElsoSzo(JoAzon);          { kîvetkezì sz¢ kezelÇse }
        if Length(S1) = 3 then
          I := Pos(S1, InstrSet);
      end
      else
      begin
        if (I = 0) and (Length(Sor) > 1) and (Sor[1] = ':')
          and (Sor[2] = '=') then       { v†ltoz¢ }
            ValtErt2;
        I := -1;                   { konstans: 1. menetben }
      end;
  end; { if JoAzon }
  if I <> -1 then
  begin
    KiveszSpace(Sor);
    if I <> 0 then                      { utas°t†s }
      Utasitas2((I + 3) shl 2)
    else if (S1 = '*') and (Length(Sor) > 1) then
    begin
      if Sor[1] = '=' then                                    { *= }
        UjPC := Kiertekel(Copy(Sor, 2, 255), PC, True, ActLGL)
      else if (Sor[1] = ':') and (Sor[2] = '=') then       { *:= }
        UjPC := Kiertekel(Copy(Sor, 3, 255), PC, True, ActLGL);
    end { else if S1 }
    else if (S1 <> '') and (S1[1] = '.') then
      FordDir2(S1);
  end; { if }
end; { FeldolgSor2 }

{ ================================================================== }
{ Egy sor a jelentÇsf†jlba }
procedure TAsm.ReportSor;
var
  S: String;
  W1, W2: Word;
  H: Byte;
  P: PAsm;
begin
  if not VoltEnd and (Opt.RFileName <> '') and Opt.L then
  begin
    S := '';
    P := Parent;
    while P <> Nil do
    begin
      S := S + '-';
      P := P^.Parent;
    end;
    if VoltInclude then
    begin
      if (Parent = Nil) or (State = erNone) then
        WriteLn(RepFile, '=====', S,' Back to source: ', ForrasFName);
    end
    else
    begin
      if LineNum = 1 then
      begin
        if Parent = Nil then
        begin
          WriteLn(RepFile);
          WriteLn(RepFile, 'COMPILING LIST:');
          WriteLn(RepFile, '---------------');
          WriteLn(RepFile);
          WriteLn(RepFile, '===== Processing main source: ', ForrasFName);
        end
        else
          WriteLn(RepFile, '=====', S, ' Processing included source: ', ForrasFName);
      end; { if LineNum }
      if VoltUgras then
        WriteLn(RepFile, '-- Jumping to line ', LineNum);
      if VoltUt then
        S := DisAsmSor(M, PC, H)
      else if PC <> UjPC then
      begin
        S := HWS(PC) + ' ';
        if VoltAdat then
        begin
          W2 := UjPC - PC - 1;
          if W2 > 2 then
            W2 := 2;
          for W1 := 0 to W2 do
            S := S + ' ' + HBS(M^[PC + W1]);
          if UjPC - PC > 3 then
            S := S + '...';
        end { if VoltAdat }
      end { else if PC }
      else
        S := '';
      WriteLn(RepFile, S, ' ': 32 - Length(S), LineNum:5, ')  ', EredSor);
    end; { if VoltInclude else }
  end; { if Opt }
end; { ReportSor }

{ ================================================================== }
{ Mem¢ritÇrkÇp a jelentÇsf†jlba }
procedure TAsm.ReportMap;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  I, J: Word;
  R: Boolean;
  MapFile: Text;
begin
  if Parent = Nil then
  begin
    if Opt.MFileName = '' then
    begin
      FSplit(ForrasFName, D, N, E);
      Opt.MFileName := D + N + MAPExt;
    end
    else
      FNameExt(Opt.MFileName, MAPExt);
    {$I-}
    Assign(MapFile, Opt.MFileName);
    Rewrite(MapFile);
    {$I+}
    if IOResult <> 0 then
      Opt.MFileName := ''
    else
    begin
      R := Opt.S or Opt.L or Opt.T;
      if R then
      begin
        WriteLn(RepFile);
        WriteLn(RepFile, 'MEMORY MAP:');
        WriteLn(RepFile, '-----------');
        WriteLn(RepFile);
      end;
      WriteLn(MapFile, '; ', AsmInfo);
      WriteLn(MapFile);
      WriteLn(MapFile, '; Memory map for ', ForrasFName);
      WriteLn(MapFile);
      if PCMin > PCMax then
      begin
        if R then
          WriteLn(RepFile, 'No memory written');
        WriteLn(MapFile, '  ; No memory written');
      end
      else
      begin
        J := PCMin;
        repeat
          I := J;
          while (J <= PCMax) and (Map^[I] = Map^[J]) do
            Inc(J);
          if R then
          begin
            Write(RepFile, '$' + HWS(I));
            if (J - I) > 1 then
              Write(RepFile, '-' + '$' + HWS(J - 1))
            else
              Write(RepFile, '      ');
            WriteLn(RepFile, '  ', meShortName[2 * Map^[I] + 1],
              meShortName[2 * Map^[I] + 2], '  ; ', meLongName[Map^[I]]);
          end;
          Write(MapFile, '$' + HWS(I));
          if (J - I) > 1 then
            Write(MapFile, '-' + '$' + HWS(J - 1))
          else
            Write(MapFile, '      ');
          WriteLn(MapFile, '  ', meShortName[2 * Map^[I] + 1],
            meShortName[2 * Map^[I] + 2], '  ; ', meLongName[Map^[I]]);
        until J >= PCMax;
      end; { if PCMin else }
      Close(MapFile);
      VoltMap := True;
    end; { if IOResult else }
  end; { if Parent }
end; { ReportMap }

{ ================================================================== }
{ ôsszegzÇs a jelentÇsf†jlba }
procedure TAsm.ReportSummary;
begin
  if Parent = Nil then
  begin
    WriteLn(RepFile);
    WriteLn(RepFile, 'SUMMARY:');
    WriteLn(RepFile, '--------');
    WriteLn(RepFile);
    WriteLn(RepFile, 'Total source compiled: ', TotalLines, ' lines in ',
      TotalFiles, ' file(s)');
    if TotalFiles > 1 then
    begin
      WriteLn(RepFile, 'Compiled source files:');
      InclFiles^.Lista(RepFile);
      WriteLn(RepFile, 'Included binary files:');
      IncBinFiles^.Lista(RepFile);
    end;
    WriteLn(RepFile, 'Symbol table:');
    if Konst^.Meret + HelyiKonst^.Meret + Valt^.Meret + Cimke^.Meret +
        HelyiCimke^.Meret + SrcCimke^.Meret = 0 then
      WriteLn(RepFile, ' <EMPTY>')
    else
    begin
      WriteLn(RepFile, Konst^.Meret :5, ' global constants');
      WriteLn(RepFile, HelyiKonst^.Meret :5, ' local constants');
      WriteLn(RepFile, Valt^.Meret :5, ' global variables');
      WriteLn(RepFile, Cimke^.Meret :5, ' global labels');
      WriteLn(RepFile, HelyiCimke^.Meret :5, ' local labels');
      WriteLn(RepFile, SrcCimke^.Meret :5, ' source labels');
    end;
    WriteLn(RepFile, 'Data size: ', TotalData, ' bytes');
    WriteLn(RepFile, 'Code size: ', TotalCode, ' bytes in ', TotalInstr,
      ' instructions');
    if PCMin <= PCMax then
      WriteLn(RepFile, 'Memory block affected: $', HWS(PCMin), ' - $',
        HWS(PCMax), ' (total size: ', PCMax - PCMin + 1, ' bytes)');
  end; { if Parent }
end; { ReportSummary }

{ ================================================================== }
{ Ford°t†s 2. menete (k¢dgener†l†s) }
procedure TAsm.MasodikMenet;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  W: Word;
begin
  OpenInput;
  if State = erNone then
  begin
    if Parent = Nil then
    begin
      if MaxAvail >= $11000 then
      begin
        New(Map);
        for W := 0 to $FFFF do
          Map^[W] := meEmpty;
      end
      else
        State := erNoMem;
    end; { if Parent }
    PC := Opt.PCStart;
    UjPC := PC;
    ActLGL := 0;
    while (State = erNone) and (not Eof(ForrasFile)) do
    begin
      VoltAdat := False;
      VoltUt := False;
      VoltInclude := False;
      VoltUgras := False;
      VoltEnd := False;
      OlvasSor;
      Inc(ThisFileLines);
      Inc(TotalLines);
      if Sor <> '' then
        FeldolgSor2;
      ReportSor;
      PC := UjPC;
    end; { while }
    Close(ForrasFile);
    FSplit(ForrasFName, D, N, E);
    InclFiles^.UjElem(N + E, ThisFileLines, FileCount);
    Inc(FileCount);
  end; { if }
end; { MasodikMenet }

{ ================================================================== }
{ Teljes ford°t†s }
procedure TAsm.Fordit;
begin
  ElsoMenet;
  if State = erNone then
  begin
    if (Opt.RFileName <> '') and not (Opt.S or Opt.L) then
      Opt.T := True;
    OpenReport;
    MasodikMenet;
    if Opt.RFileName <> '' then
    begin
      if (State <> erNone) and ((State <> erIncl) or (Parent = Nil)) then
      begin
        WriteLn(RepFile, '***** ', HibaJel(State, LineNum, ForrasFName));
        WriteLn(RepFile, EredSor);
      end
      else
        begin
          if Opt.M then
            ReportMap;
          if Opt.T then
            ReportSummary;
        end;
      if Parent = Nil then
        Close(RepFile);
      VoltRep := True;
    end;
  end;
end; { Fordit }

end.