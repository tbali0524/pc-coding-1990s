{  K ê P L E T    Verzi¢ 2.0
  Matematikai kifejezÇs-kiÇrtÇkelÇs   (c) 1992  T¢th B†lint

  Fìprogram Çs felhaszn†l¢i felÅlet

  ENGLISH LANGUAGE EXTENSION by T¢th B†lint, 1995
  Compile with -dENGLISH to get all messages in english.

}
program Keplet;

{$B-}
uses Crt, kbConst, Szerk, Kifejt;

const
{$IFDEF ENGLISH}
  HelpFileNev = 'FORMULA.HLP';
  AlapDefNev = 'STARTUP.DEF';
  MentDefNev = 'SAVED.DEF';
{$ELSE}
  HelpFileNev = 'KEPLET.HLP';
  AlapDefNev = 'ALAPERT.DEF';
  MentDefNev = 'MENT.DEF';
{$ENDIF}

var
  T: Byte; { aktu†lis objektum sorsz†ma (1=TKif, 2=TFuggv, 3=TKonst) }
  Puf: Array[2..3] of String; { puffer sorm†sol†shoz }
  OldExitProc: Pointer; { eredeti kilÇpÇsi elj†r†s }
  RendesBef: Boolean; { Done elj†r†sban: False = Runtime error }
  Bi, SB: Char; { ReadKey k¢dok }

type
  PKif = ^TKif;
  TKif = Object(TSzerk) { kifejezÇs mezì }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure GBill(var Bill, SpecBill: Char); virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure EKezelBill(Bill, SpecBill: Char); virtual;
    procedure InitSzerk; virtual;
    constructor Init;
  end;

  PFuggv = ^TFuggv;
  TFuggv = Object(TSzerk) { fÅggvÇny-szerkesztì }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure EFormaz; virtual;
    procedure GBill(var Bill, SpecBill: Char); virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure InitSzerk; virtual;
  end;

  PKonst = ^TKonst;
  TKonst = Object(TSzerk) { konstans-szerkesztì }
    function GRubMeret(Oszlop: Byte): Byte; virtual;
    function GRubKezdet(Oszlop: Byte ): Byte; virtual;
    procedure EKurzor(Sor: Integer; Oszlop, Poz: Byte); virtual;
    procedure EFormaz; virtual;
    procedure GBill(var Bill, SpecBill: Char); virtual;
    function GValidKar(Kar: Char): Boolean; virtual;
    procedure InitSzerk; virtual;
  end;

procedure TorolKijelzo;
begin
  GoToXY(30, 10);
  Write(Copy(SPC, 1, 51));
  GoToXY(30, 10);
end;

function AreYouSure: Boolean;
var
  C: Char;
begin
  TorolKijelzo;
{$IFDEF ENGLISH}
  Write('Are you sure? [Y/N] ');
  repeat
    C := UpCase(ReadKey);
  until C in ['Y', 'N', kbEsc];
  AreYouSure := C = 'Y';
{$ELSE}
  Write('Biztos benne? [I/N] ');
  repeat
    C := UpCase(ReadKey);
  until C in ['I', 'N', kbEsc];
  AreYouSure := C = 'I';
{$ENDIF}
  TorolKijelzo;
end;

{ TKif objektum }
function TKif.GRubMeret(Oszlop: Byte): Byte;
begin
  GRubMeret := 66;
end;

function TKif.GRubKezdet(Oszlop: Byte ): Byte;
begin
  GRubKezdet := 0;
end;

procedure TKif.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
begin
  GoToXY(13 + Poz, 12);
end;

procedure TKif.GBill(var Bill, SpecBill: Char);
begin
  TSzerk.GBill(Bill, SpecBill);
  Bill := UpCase(Bill);
end;

function TKif.GValidKar(Kar: Char): Boolean;
begin
  GValidKar := (Kar in [' '..'~']) and TSzerk.GValidKar(Kar);
end;

procedure TKif.EKezelBill(Bill, SpecBill: Char);
var
  Par: ParamT;
  S: String;

procedure AritHiba;
begin
  Write(Beep);
{$IFDEF ENGLISH}
  Write('Error: ', HibaUzenet[HibaKod], '!');
  GoToXY(30, 11);
  Write('Press Enter!');
{$ELSE}
  Write('Hiba: ', HibaUzenet[HibaKod], '!');
  GoToXY(30, 11);
  Write('Nyomjon Enter-t!');
{$ENDIF}
  repeat
  until ReadKey in [kbEnter, kbEsc];
  GoToXY(30, 11);
  Write(Copy(SPC, 1, 16));
  TorolKijelzo;
  HibaKod := 0;
end;

procedure EredmenybolKonstans;
begin
  EFormaz;
  TorolKijelzo;
  if GRub(1, 1) <> Copy(SPC, 1, GRubMeret(1)) then
  begin
    Str(Kifejez(GRub(1, 1), 0, Par), S);
    if HibaKod = 0 then
{$IFDEF ENGLISH}
      Write('Value of expression: ', S)
{$ELSE}
      Write('A kifejezÇs ÇrtÇke: ', S)
{$ENDIF}
    else
      AritHiba;
    EKilepTabla;
    T := 3;
    with Sz[3]^ do
    begin
      EBelepTabla;
      if GSorMeret + GVirtSor > GKepMeret then
        GKepKezdet := GSorMeret - GKepMeret + 2;
      GS := GSorMeret + 1;
      GO := 1;
      GP := 1;
      if GS < GMaxSorMeret then
      begin
        EAllok(GS);
        ERub(GS, 1, '');
        ERub(GS, 2, S);
        Inc(GSorMeret);
      end;
      EKiirTabla;
    end; { with }
  end; { if }
end; { EredmenybolKonstans }

begin { TKif.EKezelBill }
  if Bill = kbEnter then
  begin
    EFormaz;
    TorolKijelzo;
    if GRub(1, 1) <> Copy(SPC, 1, GRubMeret(1)) then
    begin
      Str(Kifejez(GRub(1, 1), 0, Par), S);
      if HibaKod = 0 then
{$IFDEF ENGLISH}
      Write('Value of expression: ', S)
{$ELSE}
      Write('A kifejezÇs ÇrtÇke: ', S)
{$ENDIF}
      else
        AritHiba;
    end;
  end
  else
    case SpecBill of
      kbAltY, kbAltN: ;
      kbAltK: EredmenybolKonstans;
      kbAltS: ETorolRub(GS, GO);
      else
        TSzerk.EKezelBill(Bill, SpecBill);
    end; { case }
  if GRub(1, 1) = Copy(SPC, 1, GRubMeret(1)) then
    TorolKijelzo;
end; { TKif.EkezelBill }

procedure TKif.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 1;
  GOszlopMeret := 1;
  GOsszOszlopMeret := 1;
  GKepMeret := 1;
  GVirtSor := 0;
  GSorSzelesseg := 66;
  GSorMeret := 1;
end;

constructor TKif.Init;
begin
  TSzerk.Init;
  EAllok(1);
  ETorolSor(1);
end;

{ TFuggv objektum }

type
  TFIT = Array[1..3] of Byte;

function TFuggv.GRubMeret(Oszlop: Byte): Byte;
const
  TFRubM: TFIT = (8, 1, 66);
begin
  GRubMeret := TFRubM[Oszlop]
end;

function TFuggv.GRubKezdet(Oszlop: Byte ): Byte;
const
  TFRubK: TFIT = (0, 8, 9);
begin
  GRubKezdet := TFRubK[Oszlop];
end;

procedure TFuggv.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
const
  TFKurzX: TFIT = (1, 10, 12);
begin
  GoToXY(TFKurzX[Oszlop] + Poz, 15 + Sor - GKepKezdet);
end;

procedure TFuggv.EFormaz;
begin
  if (GS <= GSorMeret) and (GO = 1) then
  begin
    ERub(GS, GO, Balrahuz(GRub(GS, GO)));
    EKiirRub(GS, GO);
  end;
end;

procedure TFuggv.GBill(var Bill, SpecBill: Char);
begin
  TSzerk.GBill(Bill, SpecBill);
  Bill := UpCase(Bill);
end;

function TFuggv.GValidKar(Kar: Char): Boolean;
var
  B: Boolean;
begin
  case GO of
    1 : B := Kar in ['A'..'Z', '0'..'9', ' '];
    2 : B := Kar in ['1'..'9', ' '];
    3 : B := True;
  end;
  GValidKar := B and TSzerk.GValidKar(Kar);
end;

procedure TFuggv.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 999;
  GOszlopMeret := 3;
  GOsszOszlopMeret := 3;
  GKepMeret := Hi(WindMax) - 14;
  GVirtSor := 1;
  GSorSzelesseg := 75;
end;

{ TKonst objektum }
function TKonst.GRubMeret(Oszlop: Byte): Byte;
begin
  GRubMeret := (Oszlop - 1) * 9 + 8; { 8, 17 }
end;

function TKonst.GRubKezdet(Oszlop: Byte ): Byte;
begin
  GRubKezdet := (Oszlop - 1) * 8; { 0, 8 }
end;

procedure TKonst.EKurzor(Sor: Integer; Oszlop, Poz: Byte);
begin
  GoToXY((Oszlop - 1) * 9 + 1 + Poz, 3 + Sor - GKepKezdet);
end;

procedure TKonst.EFormaz;
var
  I, K: Integer;
  R: Real;
  S: String;
begin
  if GS <= GSorMeret then
    if GO = 1 then
    begin
      ERub(GS, GO, Balrahuz(GRub(GS, GO)));
      EKiirRub(GS, GO);
    end
    else
    begin
      I := GRubMeret(2);
      while (I > 0) and (GKar(GS, 2, I) = ' ') do
        Dec(I);
      if I > 0 then
      begin
        Val(Copy(GRub(GS, 2), 1, I), R, K);
        if K = 0 then
        begin
          Str(R, S);
          ERub(GS, GO, S);
          EKiirRub(GS, GO);
        end;
      end; { if I }
    end; { if GO }
end; { TKonst.EFormaz }

procedure TKonst.GBill(var Bill, SpecBill: Char);
begin
  TSzerk.GBill(Bill, SpecBill);
  Bill := UpCase(Bill);
end;

function TKonst.GValidKar(Kar: Char): Boolean;
var
  B: Boolean;
begin
  if GO = 1 then
    B := (Kar in ['A'..'Z', '0'..'9', ' '])
  else
    B := (Kar in ['0'..'9', '.', '+', '-', ' ', '.', 'E']);
  GValidKar := B and TSzerk.GValidKar(Kar);
end;

procedure TKonst.InitSzerk;
begin
  TSzerk.InitSzerk;
  GMaxSorMeret := 999;
  GOszlopMeret := 2;
  GOsszOszlopMeret := 2;
  GKepMeret := 8;
  GVirtSor := 1;
  GSorSzelesseg := 25;
end;

procedure SzerkKep;
var
  I: Integer;
begin
  ClrScr;
{$IFDEF ENGLISH}
  WriteLn('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn('∫     C O N S T A N T S    ∫                F O R M U L A   V2.0');
  WriteLn('∫        ≥                 ∫     Mathematical expression evaluating program');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫        Copyright (c) 1992,95 by T¢th B†lint');
  WriteLn('∫        ≥                 ∫     This program is shareware, please register!');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫                    Press F1 for help!');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫');
  WriteLn('»ÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
  WriteLn('EXPRESSION: ');
  WriteLn('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn('∫                             F U N C T I O N S            ' +
    '                   ∫');
  for I := 1 to Hi(WindMax) - 14 do
    WriteLn('∫        ≥ ≥                                             ' +
      '                     ∫');
  Write('»ÕÕÕÕÕÕÕÕœÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
{$ELSE}
  WriteLn('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn('∫   K O N S T A N S O K    ∫                      K ê P L E T');
  WriteLn('∫        ≥                 ∫      Matematikai kifejezÇs-kiÇrtÇkelì program');
  WriteLn('∫        ≥                 ∫                      Verzi¢: 2.0');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫          Copyright (c) 1992  T¢th B†lint');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫      Seg°tsÇghez nyomja meg az F1 billentyñt!');
  WriteLn('∫        ≥                 ∫');
  WriteLn('∫        ≥                 ∫');
  WriteLn('»ÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
  WriteLn('A KIFEJEZêS:');
  WriteLn('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn('∫                             F ö G G V ê N Y E K          ' +
    '                   ∫');
  for I := 1 to Hi(WindMax) - 14 do
    WriteLn('∫        ≥ ≥                                             ' +
      '                     ∫');
  Write('»ÕÕÕÕÕÕÕÕœÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ' +
    'ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
{$ENDIF}
  for I := 1 to 3 do
    Sz[I]^.EKiirTabla;
end;

function KimentF(var F: Text): Boolean;
{ Defin°ci¢k kimentÇse F-be. (H°v†s elìtt Assign kell)
  EredmÇny: sikerÅlt-e
}
var
  I, K: Integer;
begin
  {$I-}
  Rewrite(F);
{$IFDEF ENGLISH}
  WriteLn(F, '; FORMULA 2.0 definition file');
{$ELSE}
  WriteLn(F, '; KêPLET 2.0 defin°ci¢sf†jl');
{$ENDIF}
  if Sz[3]^.GSorMeret > 0 then
  begin
    WriteLn(F);
{$IFDEF ENGLISH}
    WriteLn(F, '[Constants:]');
{$ELSE}
    WriteLn(F, '[Konstansok:]');
{$ENDIF}
    for I := 1 to Sz[3]^.GSorMeret do
      WriteLn(F, Sz[3]^.GRub(I, 1), '=', Sz[3]^.GRub(I, 2));
  end;
  if Sz[2]^.GSorMeret > 0 then
  begin
    WriteLn(F);
{$IFDEF ENGLISH}
    WriteLn(F, '[Functions:]');
{$ELSE}
    WriteLn(F, '[FÅggvÇnyek:]');
{$ENDIF}
    for I := 1 to Sz[2]^.GSorMeret do
    begin
      K := Sz[2]^.GRubMeret(3);
      while (K > 1) and (Sz[2]^.GKar(I, 3, K) = ' ') do
        Dec(K);
      WriteLn(F, Sz[2]^.GRub(I, 1), '(', Sz[2]^.GRub(I, 2), ')=',
        Copy(Sz[2]^.GRub(I, 3), 1, K));
    end;
  end; { if }
  Close(F);
  {$I+}
  KimentF := IOResult = 0;
end; { KimentF }

procedure Kiment;
var
  FN: String;
  F: Text;
begin
  ClrScr;
{$IFDEF ENGLISH}
  WriteLn('SAVING FUNCTION AND CONSTANT DEFINITIONS');
  WriteLn;
  WriteLn('If you want this list to be the default at startup,');
  WriteLn('use ', AlapDefNev, ' as filename!');
  WriteLn;
  Write('Filename: ');
{$ELSE}
  WriteLn('FöGGVêNY- êS KONSTANSDEFIN°CI¢K KIMENTêSE');
  WriteLn;
  WriteLn('Ha azt akarja, hogy ez a lista legyen az alapÇrtelmezÇs,');
  WriteLn('akkor ', AlapDefNev, '-et adjon meg f†jlnÇvnek!');
  WriteLn;
  Write('F†jlnÇv: ');
{$ENDIF}
  ReadLn(FN);
  Assign(F, FN);
  if KimentF(F) then
{$IFDEF ENGLISH}
    Write('Ok. [Enter]')
{$ELSE}
    Write('Rendben. [Enter]')
{$ENDIF}
  else
  begin
    Write(Beep);
{$IFDEF ENGLISH}
    Write('I/O error! [Enter]');
{$ELSE}
    Write('I/O hiba! [Enter]');
{$ENDIF}
  end;
  ReadLn;
  SzerkKep;
end; { Kiment }

function BetoltF(var F: Text; HozzaFuzes: Boolean): Boolean;
{ Defin°ci¢k betîltÇse F-bìl. (H°v†s elìtt Assign kell)
  Ha HozzaFuzes = False akkor elîtte tîrli a t†bl†zatot.
  EredmÇny: sikerÅlt-e
}
var
  J, K, H: Integer;
  S: String;
  Tip: Integer; { 1 = konstans, 2 = fÅggvÇny }
begin
  {$I-}
  Reset(F);
  H := IOResult;
  if H = 0 then
  begin
    if HozzaFuzes then
    begin
      J := Sz[2]^.GSorMeret;
      K := Sz[3]^.GSorMeret;
    end
    else
    begin
      Sz[2]^.ETorolTabla;
      Sz[3]^.ETorolTabla;
      J := 0;
      K := 0;
    end;
    Tip := 0;
    while not Eof(F) do
    begin
      ReadLn(F, S);
      if (S <> '') and (S[1] <> ';') then
{$IFDEF ENGLISH}
        if S = '[Constants:]' then
          Tip := 1
        else if S = '[Functions:]' then
          Tip := 2
{$ELSE}
        if S = '[Konstansok:]' then
          Tip := 1
        else if S = '[FÅggvÇnyek:]' then
          Tip := 2
{$ENDIF}
        else
          if (Tip = 1) and (Length(S) >= 9) and (S[9] = '=') then
          begin
            Inc(K);
            Sz[3]^.EAllok(K);
            Sz[3]^.ERub(K, 1, Copy(S, 1, 8));
            Sz[3]^.ERub(K, 2, Copy(S, 10, 255));
          end
          else if (Tip = 2) and (Length(S) >= 12) and (S[9] = '(') and
            (S[10] in [' ', '1'..'9']) and (S[11] = ')') and (S[12] = '=')
            then
          begin
            Inc(J);
            Sz[2]^.EAllok(J);
            Sz[2]^.ERub(J, 1, Copy(S, 1, 8));
            Sz[2]^.ERub(J, 2, S[10]);
            Sz[2]^.ERub(J, 3, Copy(S, 13, 255));
          end;
    end; { while }
    Close(F);
    H := IOResult;
    Sz[2]^.GSorMeret := J;
    Sz[3]^.GSorMeret := K;
    Sz[2]^.InitSzerk;
    Sz[3]^.InitSzerk;
  end; { if }
  {$I+}
  BetoltF := H = 0;
end; { BetoltF }

procedure Betolt;
var
  FN: String;
  F: Text;
begin
  ClrScr;
{$IFDEF ENGLISH}
  WriteLn('LOADING FUNCTION AND CONSTANT DEFINITIONS');
  WriteLn;
  Write('Filename: ');
{$ELSE}
  WriteLn('FöGGVêNY- êS KONSTANSDEFIN°CI¢K BETôLTêSE');
  WriteLn;
  Write('F†jlnÇv: ');
{$ENDIF}
  ReadLn(FN);
  Assign(F, FN);
  if BetoltF(F, False) then
{$IFDEF ENGLISH}
    Write('Ok. [Enter]')
{$ELSE}
    Write('Rendben. [Enter]')
{$ENDIF}
  else
  begin
    Write(Beep);
{$IFDEF ENGLISH}
    Write('I/O error! [Enter]');
{$ELSE}
    Write('I/O hiba! [Enter]');
{$ENDIF}
  end;
  ReadLn;
  SzerkKep;
end; { Betolt }

procedure Beilleszt;
var
  FN: String;
  F: Text;
begin
  ClrScr;
{$IFDEF ENGLISH}
  WriteLn('APPENDING FUNCTION AND CONSTANT DEFINITIONS FROM FILE TO LIST');
  WriteLn;
  Write('Filename: ');
{$ELSE}
  WriteLn('FöGGVêNY- êS KONSTANSDEFIN°CI¢K HOZZèILLESZTêSE A TèBLèZATHOZ');
  WriteLn;
  Write('F†jlnÇv: ');
{$ENDIF}
  ReadLn(FN);
  Assign(F, FN);
  if BetoltF(F, True) then
{$IFDEF ENGLISH}
    Write('Ok. [Enter]')
{$ELSE}
    Write('Rendben. [Enter]')
{$ENDIF}
  else
  begin
    Write(Beep);
{$IFDEF ENGLISH}
    Write('I/O error! [Enter]');
{$ELSE}
    Write('I/O hiba! [Enter]');
{$ENDIF}
  end;
  ReadLn;
  SzerkKep;
end; { Beilleszt }

procedure Segit(KezdoHKep : byte);
var
  HVege, Kiirando : Boolean;
  HBill : Char;
  HKepSzam, HKep : Integer;
  F: Text;
  S: String;
begin
  Assign(F, HelpFileNev);
  {$I-}
  Reset(F);
  ReadLn(F, S);
  ReadLn(F, S);
  if Length(S) >= 3 then
    HKepSzam := 10 * (Ord(S[2]) - Ord('0'))
      + Ord(S[3]) - Ord('0')
  else
    HKepSzam := 0;
  HVege := (IOResult <> 0) or (HKepSzam < 1) or (HKepSzam < KezdoHKep);
  if HVege then
  begin
    TorolKijelzo;
    Write(Beep);
{$IFDEF ENGLISH}
    Write('Helpfile is not available! [Enter]');
{$ELSE}
    Write('Seg°tsÇgf†jl nem elÇrhetì! [Enter]');
{$ENDIF}
    repeat
    until ReadKey in [kbEnter, kbEsc];
    TorolKijelzo;
  end;
  HKep := KezdoHKep;
  while not HVege do
  begin
    ClrScr;
{$IFDEF ENGLISH}
    WriteLn('FORMULA 2.0  Helpscreen ', HKep :2,
      ' / ', HKepSzam :2, '       Page Up / Page Down to browse');
{$ELSE}
    WriteLn('KêPLET 2.0  Seg°tsÇg - kÇpernyì ', HKep :2,
      ' / ', HKepSzam :2, '       Page Up / Page Down = lapoz†s');
{$ENDIF}
    WriteLn;
    Kiirando := False;
    Reset(F);
    while not Eof(F) do
    begin
      ReadLn(F, S);
{$IFDEF ENGLISH}
      if (Copy(S, 1, 8) = '[Screen ') and (Length(S) >= 10) then
        Kiirando := HKep = 10 * (Ord(S[9]) - Ord('0'))
          + Ord(S[10]) - Ord('0')
{$ELSE}
      if (Copy(S, 1, 10) = '[KÇpernyì ') and (Length(S) >= 12) then
        Kiirando := HKep = 10 * (Ord(S[11]) - Ord('0'))
          + Ord(S[12]) - Ord('0')
{$ENDIF}
      else
        if Kiirando then
          WriteLn(S);
    end;
    Close(F);
    if IOResult <> 0 then
    begin
      Write(Beep);
{$IFDEF ENGLISH}
      WriteLn('Error in helpfile! [Enter]');
{$ELSE}
      WriteLn('Hiba a seg°tsÇgf†jlban! [Enter]');
{$ENDIF}
      ReadLn;
      HVege := True;
    end
    else
    begin
{$IFDEF ENGLISH}
      GoToXY(36, 1);
{$ELSE}
      GoToXY(44, 1);
{$ENDIF}
      HBill := ReadKey;
      if HBill = #0 then
      begin
        HBill := ReadKey;
        case HBill of
          kbPgUp : HKep := (HKep + HKepSzam - 2) mod HKepSzam + 1;
          kbPgDn : HKep := HKep mod HKepSzam + 1;
          kbHome : HKep := 1;
          kbEnd : HKep := HKepSzam;
          kbAltF1 : HKep := 5;
          else
            HVege := true;
        end; { case HBill }
      end { if HBill }
      else
        HVege := true;
    end; { else }
  end; { while }
  SzerkKep;
end; { Segit }

procedure Done; far;
var
  I: Integer;
  F: Text;
begin
  ExitProc := OldExitProc;
  ClrScr;
  if RendesBef then
{$IFDEF ENGLISH}
  begin 
    WriteLn('FORMULA 2.0 : Good-bye!');
    WriteLn;
    WriteLn('This program is shareware.');
    WriteLn('  See REGISTER.DOC for more information about registration.');
  end
{$ELSE}
    WriteLn('KêPLET 2.0 : Viszl†t a kîvetkezì tal†lkoz†sig!')
{$ENDIF}
  else
  begin
{$IFDEF ENGLISH}
    WriteLn('FORMULA 2.0 : Arithmetic overflow!');
    Assign(F, MentDefNev);
    if KimentF(F) then
      WriteLn('Definitions were saved in file ', MentDefNev);
    WriteLn('Please restart the program!');
{$ELSE}
    WriteLn('KêPLET 2.0 : Aritmetikai t£lcsordul†s!');
    Assign(F, MentDefNev);
    if KimentF(F) then
      WriteLn('Defin°ci¢k kimentÇsre kerÅltek a ', MentDefNev,' nevñ f†jlba.');
    WriteLn('Ind°tsa £jra a programot!');
{$ENDIF}
  end;
  for I := 1 to 3 do
    Dispose(Sz[I], Done);
end; { Done }

procedure Init;
var
  F: Text;
  S: String;
begin
  RendesBef := False;
  OldExitProc := ExitProc;
  ExitProc := @Done; { saj†t kilÇpÇsi elj†r†s }
  Sz[1] := New(PKif, Init);
  Sz[2] := New(PFuggv, Init);
  Sz[3] := New(PKonst, Init);
  Puf[2] := Copy(SPC, 1, Sz[2]^.GSorSzelesseg);
  Puf[3] := Copy(SPC, 1, Sz[3]^.GSorSzelesseg);
  if ParamCount <> 0 then
    S := ParamStr(1)
  else
    S := AlapDefNev;
  Assign(F, S);
  if not BetoltF(F, False) then
    Write(Beep);
  T := 1;
  SzerkKep;
end; { Init }


begin { fìprogram }
  Init;
  repeat
    Sz[T]^.EBelepTabla;
    repeat
      with Sz[T]^ do
      begin
        EKurzor(GS, GO, GP);
        GBill(Bi, SB);
        EKezelBill(Bi, SB);
        case SB of
          kbF1 : Segit(1);
          kbAltF1 : Segit(5);
          kbF2 : Kiment;
          kbF3 : if AreYouSure then
                   Betolt;
          kbF4 : Beilleszt;
          kbAltT : if (T <> 1) and AreYouSure then
                   begin
                     ETorolTabla;
                     EKiirTabla;
                   end;
          kbAltW : if (T <> 1) and (GS <= GSorMeret) then
                   begin
                     Puf[T] := Tabla[GS]^;
                     Write(Beep);
                   end;
          kbAltV : if (T <> 1) then
                   begin
                     EUjSor;
                     if GS <= GSorMeret then
                       Tabla[GS]^ := Puf[T];
                     EKiirSor(GS);
                   end;
          kbAltX : Kilepes := AreYouSure;
        end; { case }
        if Bi = kbEsc then
          Kilepes := AreYouSure;
      end; { with }
      if UjTabla then
        if Bi = kbTab then
          T := T mod 3 + 1
        else if SB = kbShiftTab then
          T := (T + 4) mod 3 + 1;
    until Kilepes or UjTabla;
  until Kilepes;
  RendesBef := True; { Done automatikusan megh°v¢dik }
end. { fìprogram }
