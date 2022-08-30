{ ltal nos t bl zat-szerkeszt“ objektum unit
  Copyright (c) 1991-92  T¢th B lint
}
unit Szerk;

{$A+,B-,D+,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
interface

uses kbConst; { ReadKey kbXXXX konstansok }

const
  SPC: String[135] = '                                                    ' +
    '                                                                     ' +
    '            ';
  SBill: String[14] =
    kbAltA + kbAltE + kbAltI + kbAltO + kbAltU + kbAlt1 + kbAlt2 + kbAlt3 +
    kbAlt4 + kbAlt5 + kbAlt6 + kbAlt7 + kbAlt8 + kbAlt9;
  SKar: String[14] = ' ‚¡¢£”™šíøý';
  SzamJegyek: Set of Char = ['0'..'9'];
  SzerkValtozat: Boolean = True;

type
  TablFileT = File of Char;
  PString = ^String;
  PSzerk = ^TSzerk;
  TSzerk = Object { absztrakt tablazat-szerkeszto objektum }
   { allando mezok }
    GMaxSorMeret: Integer; { sorok maximalis szama }
    GOszlopMeret: Byte; { szerkesztheto oszlopok szama }
    GOsszOszlopMeret: Byte; { osszes oszlopok szama }
    GKepMeret: Integer; { egyszerre lathato sorok szama }
    GVirtSor: Integer; { ures sorok szama tabla vegen (0 vagy 1) }
    GSorSzelesseg: Byte; { egy sor karaktereinek szama }
   { valtozo mezok }
    Tabla: Array[1..999] of PString; { a tablazat sorainak mutatoi }
    GS: Integer; { aktualis sor }
    GO: Byte; { aktualis rublika soron belul }
    GP: Byte; { aktualis pozicio rublikan belul }
    GSorMeret: Integer; { sorok szama }
    GKepKezdet: Integer; { legfelso sor szama }
   { allando fuggvenyek }
    function GRubMeret(Oszlop: Byte): Byte; virtual; { rublika merete }
    function GRubKezdet(Oszlop: Byte ): Byte; virtual; { rub. kezdete - 1 }
   { tablazat-elero metodusok }
    procedure EAllok(Sor: Integer); { uj sor beszurasa }
    procedure EFelszab(Sor: Integer); { egy sor felszabaditasa }
    function GRub(Sor: Integer; Oszlop: Byte): String;
    function GKar(Sor: Integer; Oszlop, Poz: Byte): Char;
    procedure ERub(Sor: Integer; Oszlop: Byte; Tartalom: String);
    procedure EKar(Sor: Integer; Oszlop, Poz: Byte; Kar: Char);
    procedure EFormaz; virtual; { rublika formazasa }
    procedure EUjSor; virtual; { ha uj soron vagyunk, akkor letrehozza }
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure EKiirTabla;
    procedure EKiirRub(Sor: Integer; Oszlop: Byte); virtual;
    procedure EKiirSor(Sor: Integer); virtual;
    procedure EBeszurSor;
    procedure EBeirKar(Kar: Char); { karakter berakas vagy beszuras rub.ba }
    procedure EKiveszSor;
    procedure ETorolTabla;
    procedure ETorolSor(Sor: Integer);
    procedure ETorolRub(Sor: Integer; Oszlop: Byte);
    procedure ETorolKar;
    procedure EMacskaKorom; { felette levo rublika masolasa }
    function GValidKar(Kar: Char): Boolean; virtual; { megfelel-e a bill. }
    function GValidSzerk: Boolean; virtual; { akt. rublika szerkesztheto-e }
    procedure GBill(var Bill, SpecBill: Char); virtual;
    procedure EKezelBill(Bill, SpecBill: Char); virtual;
    procedure EKimentTabla(var F: TablFileT); { tablazat kiirasa F-be }
    procedure EBelepTabla; virtual; { belepes a tablazatba }
    procedure EKilepTabla; virtual; { kilepes a tablazatbol }
    procedure InitSzerk; virtual; { szerkeszto inicializalasa }
    constructor Init;
    destructor Done; virtual;
   { kurzor-mozgato metodusok }
    procedure EBal;
    procedure EJobb;
    procedure ERubBal(Elejere: Boolean);
    procedure ERubJobb;
    procedure ERubEleje;
    procedure ERubVege;
    procedure ESorEleje;
    procedure ESorVege;
    procedure ESorFel;
    procedure ESorLe;
    procedure ELapFel;
    procedure ELapLe;
    procedure ETablaEleje;
    procedure ETablaVege;
   { tablazat-kezelo metodusok }
  end; { TSzerk }

{ altalanos sztringformazo eljarasok }
function BalraHuz(S: String): String;
function NagyBetu(S: String): String;

procedure KimentWord(var F: TablFileT; W: Word); { szam kiirasa F-be }

var
  Kilepes, UjTabla, InsMode: boolean;

implementation

uses Crt;

function BalraHuz(S: String): String;
var
  B1, B2: Byte;
  St: String;
begin
  B1 := Length(S);
  while (B1 > 0) and (S[B1] = ' ') do
    Dec(B1);
  St := '';
  for B2 := 1 to B1 do
    if S[B2] <> ' ' then
      St := St + S[B2];
  BalraHuz := Copy(St + SPC, 1, Length(S));
end;

function NagyBetu(S: String): String;
var
  B: Byte;
  St: String;
begin
  St := S;
  for B := 1 to Length(St) do
    St[B] := UpCase(St[B]);
  NagyBetu := St;
end;

procedure KimentWord(var F: TablFileT; W: Word); { szam kiirasa F-be }
var
  C1, C2: Char;
begin
  C1 := Chr(Lo(W));
  C2 := Chr(Hi(W));
  Write(F, C1, C2);
end;

procedure ValtIns;
begin
  InsMode := not InsMode;
  Write(Beep);
end;

function TSzerk.GRubMeret; { absztrakt metodusok }
begin end;
function TSzerk.GRubKezdet;
begin end;
procedure TSzerk.EKurzor;
begin end;
procedure TSzerk.EFormaz;
begin end;

constructor TSzerk.Init;
var
  I: Integer;
begin
  for I := 1 to 999 do
    Tabla[I] := Nil;
  GSorMeret := 0;
  InitSzerk;
end;

destructor TSzerk.Done;
var
  I: Integer;
begin
  for I := 1 to GSorMeret do
    EFelSzab(I);
end;

procedure TSzerk.InitSzerk;
begin
  GS := 1;
  GO := 1;
  GP := 1;
  GKepKezdet := 1;
  InsMode := True;
end;

procedure TSzerk.EBelepTabla;
begin
  Kilepes := False;
  UjTabla := False;
end;

procedure TSzerk.EKilepTabla;
begin
  EFormaz;
end;

procedure TSzerk.EKimentTabla(var F: TablFileT);
var
  I, J: Integer;
  S: String;
begin
  KimentWord(F, GSorMeret);
  for I := 1 to GSorMeret do
    for J := 1 to GSorSzelesseg do
      Write(F, Tabla[I]^[J]);
end;

procedure TSzerk.EAllok(Sor: Integer);
begin
  GetMem(Tabla[Sor], GSorSzelesseg + 1);
  Tabla[Sor]^[0] := Chr(GSorSzelesseg);
end;

procedure TSzerk.EFelszab(Sor: Integer);
var
  I: Integer;
begin
  if Tabla[Sor] <> Nil then begin
    FreeMem(Tabla[Sor], GSorSzelesseg + 1);
    Tabla[Sor] := Nil;
  end;
end;

function TSzerk.GRub(Sor: Integer; Oszlop: Byte): String;
begin
  if (Sor <= GSorMeret) and (Sor > 0) then
    GRub := Copy(Tabla[Sor]^, GRubKezdet(Oszlop) + 1, GRubMeret(Oszlop))
  else
    GRub := Copy(SPC, 1, GRubMeret(Oszlop));
end;

function TSzerk.GKar(Sor: Integer; Oszlop, Poz: Byte): Char;
begin
  GKar := Tabla[Sor]^[GRubKezdet(Oszlop) + Poz];
end;

procedure TSzerk.ERub(Sor: Integer; Oszlop: Byte; Tartalom: String);
var
  B: Byte;
  S: String;
begin
  S := Tartalom + SPC;
  for B := 1 to GRubMeret(Oszlop) do
    Tabla[Sor]^[GRubKezdet(Oszlop) + B] := S[B];
end;

procedure TSzerk.EKar(Sor: Integer; Oszlop, Poz: Byte; Kar: Char);
begin
  Tabla[Sor]^[GRubKezdet(Oszlop) + Poz] := Kar;
end;

procedure TSzerk.EKiirRub(Sor: Integer; Oszlop: Byte);
begin
  EKurzor(Sor, Oszlop, 1);
  Write(GRub(Sor, Oszlop));
end;

procedure TSzerk.EKiirSor(Sor: Integer);
var B: Byte;
begin
  for B := 1 to GOsszOszlopMeret do
    EKiirRub(Sor, B);
end;

procedure TSzerk.EKiirTabla;
var I: Integer;
begin
  for I := GKepKezdet to GKepKezdet + GKepMeret - 1 do
    EKiirSor(I);
end;

procedure TSzerk.EBal;
begin
  if GP > 1 then
    Dec(GP)
  else
    ERubBal(False);
end;

procedure TSzerk.EJobb;
begin
  if GP < GRubMeret(GO) then
    Inc(GP)
  else
    ERubJobb;
end;

procedure TSzerk.ERubBal(Elejere: Boolean);
begin
  EFormaz;
  if GO > 1 then begin
    Dec(GO);
    GP := GRubMeret(GO);
  end
  else
    if GS > 1 then begin
      Dec(GS);
      GO := GOszlopMeret;
      GP := GRubMeret(GO);
      if GS < GKepKezdet then begin
        Dec(GKepKezdet);
        EKiirTabla;
      end;
    end;
  if Elejere then
    GP := 1;
end;

procedure TSzerk.ERubJobb;
begin
  EFormaz;
  if GO < GOszlopMeret then begin
    Inc(GO);
    GP := 1;
  end
  else
    if GS < GSorMeret + GVirtSor then begin
      Inc(GS);
      GO := 1;
      GP := 1;
      if GS >= GKepKezdet + GKepMeret then begin
        Inc(GKepKezdet);
        EKiirTabla;
      end;
    end;
end;

procedure TSzerk.ERubEleje;
begin
  GP := 1;
end;

procedure TSzerk.ERubVege;
begin
  GP := GRubMeret(GO);
  if GS <= GSorMeret then begin
    while (GKar(GS, GO, GP) = ' ') and (GP > 1) do
      Dec(GP);
    if (GP < GRubMeret(GO)) and (GKar(GS, GO, GP) <> ' ') then
      Inc(GP);
    if GP = 1 then
      GP := GRubMeret(GO);
  end;
end;

procedure TSzerk.ESorEleje;
begin
  EFormaz;
  GO := 1;
  GP := 1;
end;

procedure TSzerk.ESorVege;
begin
  EFormaz;
  GO := GOszlopMeret;
  GP := 1;
end;

procedure TSzerk.ESorFel;
begin
  EFormaz;
  if GS > 1 then begin
    Dec(GS);
    if GS < GKepKezdet then begin
      Dec(GKepKezdet);
      EKiirTabla;
    end;
  end;
end;

procedure TSzerk.ESorLe;
begin
  EFormaz;
  if GS < GSorMeret + GVirtSor then begin
    Inc(GS);
    if GS >= GKepKezdet + GKepMeret then begin
      Inc(GKepKezdet);
      EKiirTabla;
    end;
  end;
end;

procedure TSzerk.ELapFel;
begin
  EFormaz;
  if GKepKezdet > GKepMeret then
    Dec(GKepKezdet, GKepMeret)
  else
    GKepKezdet := 1;
  if GS > GKepMeret then
    Dec(GS, GKepMeret)
  else
    GS := 1;
  EKiirTabla;
end;

procedure TSzerk.ELapLe;
begin
  EFormaz;
  if GKepKezdet + GKepMeret <= GSorMeret + GVirtSor then
    Inc(GKepKezdet, GKepMeret);
  if GS + GKepMeret <= GSorMeret + GVirtSor then
    Inc(GS, GKepMeret)
  else
    GS := GSorMeret + GVirtSor;
  EKiirTabla;
end;

procedure TSzerk.ETablaEleje;
begin
  EFormaz;
  GKepKezdet := 1;
  GS := 1;
  GO := 1;
  GP := 1;
  EKiirTabla;
end;

procedure TSzerk.ETablaVege;
begin
  EFormaz;
  if GSorMeret + GVirtSor > GKepMeret then
    GKepKezdet := GSorMeret - GKepMeret + 2;
  GS := GSorMeret + GVirtSor;
  GO := 1;
  GP := 1;
  EKiirTabla;
end;

function TSzerk.GValidKar;
begin
  GValidKar := GValidSzerk and (Kar in [' '..'þ']);
end;

function TSzerk.GValidSzerk;
begin
  GValidSzerk := SzerkValtozat;
end;

procedure TSzerk.EUjSor;
begin
  if (GS > GSorMeret) and (GS < GMaxSorMeret) then begin
    Inc(GSorMeret);
    EAllok(GS);
    ETorolSor(GS);
    EKiirSor(GS);
  end;
end;

procedure TSzerk.EKiveszSor;
var
  I: Integer;
begin
  if GS <= GSorMeret then begin
    EFelszab(GS);
    for I := GS to GSorMeret - 1 do
      Tabla[I] := Tabla[I + 1];
    Tabla[GSorMeret] := Nil;
    Dec(GSorMeret);
    EKiirTabla;
  end;
end;

procedure TSzerk.ETorolTabla;
var
  I: Integer;
begin
  for I := 1 to GSorMeret do
    EFelszab(I);
  GSorMeret := 0;
  InitSzerk;
end;

procedure TSzerk.ETorolSor(Sor: Integer);
begin
  Tabla[Sor]^ := Copy(SPC, 1, GSorSzelesseg);
  EKiirSor(Sor);
end;

procedure TSzerk.ETorolRub(Sor: Integer; Oszlop: Byte);
begin
  ERub(Sor, Oszlop, '');
  EKiirRub(GS, GO);
  EFormaz;
  GP := 1;
end;

procedure TSzerk.ETorolKar;
var S: String;
begin
  S := GRub(GS, GO);
  Delete(S, GP, 1);
  ERub(GS, GO, S);
  EKiirRub(GS, GO);
end;

procedure TSzerk.EMacskaKorom;
begin
  if (GS > 1) and GValidSzerk then begin
    if GRub(GS - 1, GO) <> Copy(SPC, 1, GRubMeret(GO)) then
      EUjsor;
    if GS <= GSorMeret then begin
      ERub(GS, GO, GRub(GS - 1, GO));
      EKiirRub(GS, GO);
      EFormaz;
    end;
  end;
end;

procedure TSzerk.EBeszurSor;
var I: Integer;
begin
  EFormaz;
  if GS <= GSorMeret then begin
    for I := GSorMeret downto GS do
      Tabla[I + 1] := Tabla[I];
    EAllok(GS);
    Tabla[GS]^ := Copy(SPC, 1, GSorSzelesseg);
    Inc(GSorMeret);
    EKiirTabla;
  end;
end;

procedure TSzerk.EBeirKar(Kar: Char);
var S: String;
begin
  if GValidKar(Kar) then begin
    if Kar <> ' ' then
      EUjSor;
    if GS <= GSorMeret then begin
      if InsMode then begin
        S := GRub(GS, GO);
        Insert(Kar, S, GP);
        ERub(GS, GO, S);
      end
      else
        EKar(GS, GO, GP, Kar);
      EKiirRub(GS, GO);
    end;
    EJobb;
  end;
end;

procedure TSzerk.GBill(var Bill, SpecBill: Char);
begin
  Kilepes := False;
  UjTabla := False;
  SpecBill := #0;
  Bill := ReadKey;
  if (Bill = #0) and KeyPressed then
    SpecBill := ReadKey;
end;

procedure TSzerk.EKezelBill(Bill, SpecBill: Char);
var I: Integer;
begin
  case Bill of
    #0 : case SpecBill of
        kbLeft  : EBal;
        kbRight : EJobb;
        kbHome  : ERubEleje;
        kbEnd   : ERubVege;
        kbCtrlLeft  : ERubBal(True);
        kbCtrlRight : ERubJobb;
        kbCtrlHome  : ESorEleje;
        kbCtrlEnd   : ESorVege;
        kbUp   : ESorFel;
        kbDown : ESorLe;
        kbPgUp : ELapFel;
        kbPgDn : ELapLe;
        kbCtrlPgUp : ETablaEleje;
        kbCtrlPgDn : ETablaVege;
        kbAltM : EMacskaKorom;
        kbIns  : ValtIns;
        kbShiftTab : UjTabla := True;
        kbF6 : UjTabla := True;
        kbAltX : Kilepes := True;
        else
          if GValidSzerk and (GS <= GSorMeret) then
            case SpecBill of
              kbDel  : ETorolKar;
              kbAltR : ETorolRub(GS, GO);
              kbAltS : ETorolSor(GS);
              kbAltY : EKiveszSor;
              kbAltN : EBeszurSor;
              else begin
                I := Pos(SpecBill, SBill);
                if I > 0 then
                  EBeirKar(SKar[I]);
              end; { case else }
            end { case }
      end; { case SpecBill }
    kbEnter : ERubJobb;
    kbBackSpace :
      if GValidSzerk and ((GS > 1) or (GO > 1) or (GP > 1)) then begin
        EBal;
        if GS <= GSorMeret then
          ETorolKar;
      end;
    kbTab : UjTabla := True;
    kbEsc : Kilepes := True;
    else
      EBeirKar(Bill);
  end; { case Bill }
  if Kilepes or UjTabla then
    EKilepTabla;
end; { EKezelBill }

end.