{ DARABJEGYZK NYILVNTART¢ S FELDOLGOZ¢ PROGRAM V2.0
  Copyright (c) 1991-92  T¢th B lint

Tablazat-szerkeszto objektumok unitja
}
unit DJSzerk;

{B-,D+,I+,L+,R+,S+,V+,X-}
interface

uses kbConst, Szerk;

const
  CegNev: String[17] = '  GANZ DANUBIUS  ';
  Vonal1 = 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ' +
    'ÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»';
  Vonal2 = 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' +
    'ÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ¶';
  Vonal3 = 'ÇÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' +
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶';
  Vonal4 = 'ÇÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' +
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶';
  Vonal5 = 'ÌÍÍÍØÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍ' +
    'ÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ¹';
  Vonal6 = 'ºTSZ³ DB ³    MEGNEVEZS   ³      MRET      ³   ANYAG   ³KG/' +
    'DB ³ S£LY  ³ MSZ º';
  Vonal7 = 'ÌÍÍÍØÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍØÍÍÍ' +
    'ÍÍÍØÍÍÍÍÍÍÍØÍÍÍÍÍ¹';
  Vonal8 = 'ÇÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄ' +
    'ÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄ¶';
  Vonal9 = 'ÈÍÍÍÏÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍ' +
    'ÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍ¼';
  Vonal0 = 'º   ³    ³                 ³                 ³           ³   ' +
    '   ³       ³     º';

type
  PFejLec = ^TFejLec;
  TFejlec = Object(TSzerk) { darabjegyzek fejlece }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure EFormaz; virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure EKezelBill(Bill, SpecBill: Char); virtual;
    procedure InitSzerk; virtual;
    constructor Init;
  end;

  PTores = ^TTores;
  TTores = Object(TSzerk) { darabjegyzek tores mezoje }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    function GValidSzerk: Boolean; virtual;
    procedure EKiirSor(Sor: Integer); virtual;
    procedure EKezelBill(Bill, SpecBill: Char); virtual;
    procedure EBelepTabla; virtual;
    procedure EKilepTabla; virtual;
    procedure InitSzerk; virtual;
  end;

  PTetel = ^TTetel;
  TTetel = Object(TSzerk) { darabjegyzek tetel mezoje }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure KgDb(Sor: Integer); { Kg es DB rublikak formazasa, Suly rub. }
    procedure EFormaz; virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure InitSzerk; virtual;
  end;

  PSzabvany = ^TSzabvany;
  TSzabvany = Object(TSzerk) { szabvanykonyvtar }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure EFormaz; virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure EKiirRub(Sor: Integer; Oszlop: Byte); virtual;
    procedure EKiirSor(Sor: Integer); virtual;
    procedure EBelepTabla; virtual;
    procedure InitSzerk; virtual;
  end;

procedure DJSzerkKep(D1, D2, D3: PSzerk);
procedure SzSzerkKep(D1: PSzerk);

implementation

uses Crt, Dos;

{ TFejLec objektum }
const
  FLOszlopMeret = 7;
type
  FLOTip = Array[1..FLOszlopMeret] of Byte;

function TFejLec.GRubMeret(Oszlop: Byte): Byte;
const
  FLRubMeret: FLOTip = (3, 11, 17, 20, 20, 30, 30);
begin
  GRubMeret := FLRubMeret[Oszlop];
end;

function TFejLec.GRubKezdet(Oszlop: Byte ): Byte;
const
  FLRubKezdet: FLOTip = (0, 3, 14, 31, 51, 71, 101);
begin
  GRubKezdet := FLRubKezdet[Oszlop];
end;

procedure TFejLec.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
const
  FLKurzorX: FLOTip = (60, 9, 27, 57, 57, 47, 47);
  FLKurzorY: FLOTip = (2, 4, 4, 4, 6, 9, 10);
begin
  GoToXY(FLKurzorX[Oszlop] + Poz, FLKurzorY[Oszlop]);
end;

procedure TFejLec.EFormaz;
begin
  if GO = 5 then begin
    ERub(1, 5, BalraHuz(NagyBetu(GRub(1, 5))));
    EKiirRub(GS, GO);
  end;
end;

function TFejLec.GValidKar(Kar: Char): Boolean;
begin
  if GO = 1 then
    GValidKar := TSzerk.GValidKar(Kar) and
      ((Kar in SzamJegyek) or (Kar = ' '))
  else
    GValidKar := TSzerk.GValidKar(Kar);
end;

procedure TFejLec.EKezelBill(Bill, SpecBill: Char);
begin
  if not (SpecBill in [kbAltS, kbAltY, kbAltN]) then
    TSzerk.EKezelBill(Bill, SpecBill);
end;

procedure TFejLec.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 1;
  GOszlopMeret := FLOszlopMeret;
  GOsszOszlopMeret := FLOszlopMeret;
  GKepMeret := 1;
  GVirtSor := 0;
  GSorSzelesseg := 131;
  GSorMeret := 1;
end;

constructor TFejLec.Init;
var
  A, B, C, D: Word;
  SA, SB, SC: String[4];
begin
  TSzerk.Init;
  EAllok(1);
  ETorolSor(1);
  GetDate(A, B, C, D);
  Str(A: 4, SA);
  Str(B: 2, SB);
  Str(C: 2, SC);
  ERub(1, 2, SA + '.' + SB + '.' + SC + '.');
end;

{ TTores objektum }
const
  TorOszlopMeret = 3;
type
  TorOTip = Array[1..TorOszlopMeret] of Byte;

function TTores.GRubMeret(Oszlop: Byte): Byte;
const
  TorRubMeret: TorOTip = (22, 8, 8);
begin
  GRubMeret := TorRubMeret[Oszlop];
end;

function TTores.GRubKezdet(Oszlop: Byte ): Byte;
const
  TorRubKezdet: TorOTip = (0, 22, 30);
begin
  GRubKezdet := TorRubKezdet[Oszlop];
end;

procedure TTores.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
const
  TorKurzorX: TorOTip = (5, 28, 37);
begin
  GoToXY(TorKurzorX[Oszlop] + Poz, 6 + 2 * (Sor - GKepKezdet));
end;

function TTores.GValidSzerk;
begin
  GValidSzerk := TSzerk.GValidSzerk and (GS = GSorMeret);
end;

procedure TTores.EKiirSor(Sor: Integer);
begin
  GoToXY(3, 6 + 2 * (Sor - GKepKezdet));
  if Sor <= GSorMeret then
    Write(Chr(Sor + Ord('a') - 1))               { *** }
  else
    Write(' ');
  TSzerk.EKiirSor(Sor);
end;

procedure TTores.EKezelBill(Bill, SpecBill: Char);
begin
  if not (SpecBill in [kbAltY, kbAltN]) then
    TSzerk.EKezelBill(Bill, SpecBill);
end;

procedure TTores.EBelepTabla;
var
  I: Integer;
  A, B, C, D: Word;
  SA, SB, SC: String[3];
begin
  TSzerk.EBelepTabla;
  if GSorMeret < GMaxSorMeret then begin
    Inc(GSorMeret);
    EAllok(GSorMeret);
  end
  else begin
    EFelszab(1);
    for I := 1 to GS - 1 do
      Tabla[I] := Tabla[I + 1];
    EAllok(GSorMeret);
  end;
  if GSorMeret > GKepMeret then
    GKepKezdet := GSorMeret - GKepMeret + 1
  else
    GKepKezdet := 1;
  GS := GSorMeret;
  GO := 1;
  GP := 1;
  Tabla[GS]^ := Copy(SPC, 1, GSorSzelesseg);
  GetDate(A, B, C, D);
  Str(A mod 100: 2, SA);
  Str(B: 2, SB);
  Str(C: 2, SC);
  ERub(GSorMeret, 2, SA + '.' + SB + '.' + SC);
  EKiirTabla;
end;

procedure TTores.EKilepTabla;
begin
  TSzerk.EKilepTabla;
  if GRub(GSorMeret, 1) = Copy(SPC, 1, GRubMeret(1)) then begin
    EFelszab(GSorMeret);
    Dec(GSorMeret);
  end;
  if GSorMeret > GKepMeret then
    GKepKezdet := GSorMeret - GKepMeret + 1
  else
    GKepKezdet := 1;
  EKiirTabla;
end;

procedure TTores.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 12;
  GOszlopMeret := TorOszlopMeret;
  GOsszOszlopMeret := TorOszlopMeret;
  GKepMeret := 3;
  GVirtSor := 0;
  GSorSzelesseg := 38;
end;

{ TTetel objektum }
const
  TetelOszlopMeret = 8;
type
  TetelOTip = Array[1..TetelOszlopMeret] of Byte;

function TTetel.GRubMeret(Oszlop: Byte): Byte;
const
  TetelRubMeret: TetelOTip = (3, 4, 17, 17, 11, 6, 5, 7);
begin
  GRubMeret := TetelRubMeret[Oszlop];
end;

function TTetel.GRubKezdet(Oszlop: Byte ): Byte;
const
  TetelRubKezdet: TetelOTip = (0, 3, 7, 24, 41, 52, 58, 63);
begin
  GRubKezdet := TetelRubKezdet[Oszlop];
end;

procedure TTetel.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
const
  TetelKurzorX: TetelOTip = (1, 5, 10, 28, 46, 58, 73, 65);
begin
  GoToXY(TetelKurzorX[Oszlop] + Poz, 14 + 2 * (Sor - GKepKezdet));
end;

procedure TTetel.KgDb(Sor: Integer);
var
  I, J, K: Integer;
  R: Real;
  S: String;
begin
  I := GRubMeret(2);
  while (I > 0) and (GKar(Sor, 2, I) = ' ') do
    Dec(I);
  if I > 0 then begin
    Val(Copy(GRub(Sor, 2), 1, I), J, K);
    Str(J : GRubMeret(2), S);
    ERub(Sor, 2, S);
    I := GRubMeret(6);
    while (I > 0) and (GKar(Sor, 6, I) = ' ') do
      Dec(I);
    if I > 0 then begin
      Val(Copy(GRub(Sor, 6), 1, I), R, K);
      if (K = 0) and (R * J < 100000) then begin
        if R >= 1000 then begin
          if R >= 10000 then
            Str(Round(R) : GRubMeret(6), S)
          else
            Str(R : GRubMeret(6) : 1, S)
        end { if R >= 1000 }
        else
          Str(R : GRubMeret(6) : 2, S);
        ERub(Sor, 6, S);
        Str(J * R : GRubMeret(8) : 1, S);
        ERub(Sor, 8, S);
      end { if K }
      else
        ERub(Sor, 8, '');
    end { belso if I }
    else
      ERub(Sor, 8, '');
  end { kulso if I }
  else
    ERub(Sor, 8, '');
end;

procedure TTetel.EFormaz;
var
  I, J, K: Integer;
begin
  if GS <= GSorMeret then
    case GO of
      1 : if GS = GSorMeret then begin
            I := GRubMeret(1);
            while (I > 0) and (GKar(GS, 1, I) = ' ') do
              Dec(I);
            if I > 0 then begin
              Val(Copy(GRub(GS, 1), 1, I), J, K);
              if (K = 0) and (J < GMaxSorMeret) then
                K := J + 1;                            { *** }
            end;
          end; { if GS }
      2, 6 : begin
          KgDb(GS);
          EKiirSor(GS);
        end;
      4, 5, 7 : begin
          ERub(GS, GO, Balrahuz(GRub(GS, GO)));
          EKiirRub(GS, GO);
        end;
    end; { case }
end;

function TTetel.GValidKar(Kar: Char): Boolean;
var B: Boolean;
begin
  if GO in [2, 6] then
    B := (Kar in SzamJegyek) or (Kar = ' ')
  else
    B := True;
  GValidKar := B and TSzerk.GValidKar(Kar);
end;

procedure TTetel.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 999;
  GOszlopMeret := TetelOszlopMeret - 1;
  GOsszOszlopMeret := TetelOszlopMeret;
  case Hi(WindMax) of
    42: GKepMeret := 14;
    49: GKepMeret := 17;
    else
      GKepMeret := 5;
  end;
  GVirtSor := 1;
  GSorSzelesseg := 70;
end;

{ TSzabvany objektum }
const
  SzabvanyOszlopMeret = 6;  { **** valos adatok hianyoznak **** }
type
  SzabvanyOTip = Array[1..SzabvanyOszlopMeret] of Byte;

function TSzabvany.GRubMeret(Oszlop: Byte): Byte;
const
  SzabvanyRubMeret: SzabvanyOTip = (30, 11, 3, 1, 1, 2);
begin
  GRubMeret := SzabvanyRubMeret[Oszlop];
end;

function TSzabvany.GRubKezdet(Oszlop: Byte ): Byte;
const
  SzabvanyRubKezdet: SzabvanyOTip = (0, 30, 41, 44, 45, 46);
begin
  GRubKezdet := SzabvanyRubKezdet[Oszlop];
end;

procedure TSzabvany.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
const
  SzabvanyKurzorX: SzabvanyOTip = (5, 37, 50, 54, 60, 66);
begin
  GoToXY(SzabvanyKurzorX[Oszlop] + Poz, 5 + Sor - GKepKezdet);
end;

procedure TSzabvany.EFormaz;
begin
  if GS <= GSorMeret then
    case GO of
      2 : begin
          ERub(GS, GO, Balrahuz(GRub(GS, GO)));
          EKiirRub(GS, GO);
        end;
      3..5 : begin
          ERub(GS, GO, NagyBetu(GRub(GS, GO)));
          EKiirRub(GS, GO);
        end;
      6 : if (GKar(GS, GO, 2) = ' ') then begin
          ERub(GS, GO, ' ' + GKar(GS, GO, 1));
          EKiirRub(GS, GO);
        end;
    end; { case }
end;

function TSzabvany.GValidKar(Kar: Char): Boolean;
var B: Boolean;
begin
  if (GO = 4) or (GO = 5) then
    B := (UpCase(Kar)) in ['I', 'N']
  else if GO = 6 then
    B := (Kar in SzamJegyek) or (Kar = ' ')
  else
    B := True;
  GValidKar := B and TSzerk.GValidKar(Kar);
end;

procedure TSzabvany.EKiirRub(Sor: Integer; Oszlop: Byte);
begin
  EKurzor(Sor, Oszlop, 1);
  if (Sor <= GSorMeret) and (Oszlop in [4, 5]) then
    case GKar(Sor, Oszlop, 1) of
      'I' : Write('Igen');
      'N' : Write('Nem ');
      else
        Write('    ');
    end
  else
    Write(GRub(Sor, Oszlop));
end;

procedure TSzabvany.EKiirSor(Sor: Integer);
begin
  GoToXY(1, 5 + Sor - GKepKezdet);
  if Sor <= GSorMeret then
    Write(Sor: 3)
  else
    Write('   ');
  TSzerk.EKiirSor(Sor);
end;

procedure TSzabvany.EBelepTabla;
begin
  GS := GSorMeret + 1;
  if GS > GKepMeret then
    GKepKezdet := GS - GKepMeret + 1
  else
    GKepKezdet := 1;
  GO := 1;
  GP := 1;
  EKiirTabla;
end;

procedure TSzabvany.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 999;
  GOszlopMeret := SzabvanyOszlopMeret;
  GOsszOszlopMeret := SzabvanyOszlopMeret;
  GKepMeret := Hi(WindMax) - 4;
  GVirtSor := 1;
  GSorSzelesseg := 48;
end;

procedure DJSzerkKep(D1, D2, D3: PSzerk);
var
  I: Integer;
begin
  ClrScr;
  WriteLn(Vonal1);
  WriteLn('º ' + CegNev + ' ³      DARABJEGYZK      ³ Rajz csoport: ' +
    '   ³ F1 Seg¡ts‚g º');
  WriteLn(Vonal2);
  WriteLn('º D tum:            ³ N‚v:                   ³ Objektum:     ' +
    '                 º');
  WriteLn(Vonal3);
  WriteLn('º   ³                      ³        ³        ³ Rajzsz m:     ' +
    '                 º');
  WriteLn(Vonal4);
  WriteLn('º   ³                      ³        ³        ³ Megnevez‚s:   ' +
    '                 º');
  WriteLn('ÇÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´               ' +
    '                 º');
  WriteLn('º   ³                      ³        ³        ³               ' +
    '                 º');
  WriteLn(Vonal5);
  WriteLn(Vonal6);
  WriteLn(Vonal7);
  for I := 1 to D3^.GKepMeret - 1 do
  begin
    WriteLn(Vonal0);
    WriteLn(Vonal8);
  end;
  WriteLn(Vonal0);
  Write(Vonal9);
  D1^.EKiirTabla;
  D2^.EKiirTabla;
  D3^.EKiirTabla;
end; { DJSzerkKep }

procedure SzSzerkKep(D1: PSzerk);
begin
  ClrScr;
  WriteLn('SZABVNYK™NYVTR SZERKESZTS');
end;

end. { unit }
