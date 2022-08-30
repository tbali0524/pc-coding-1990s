{ MCS6510 MikroProcesszor Emul tor }
{         K¢drtelmez“ Unit        }
{ Copyright (c) 1991  T¢th B lint  }

unit Emul6510;

interface

const

 { CimzesModok }
  Spec = 0;
  Acc  = 1;
  Imm  = 2;
  ZP   = 3;
  ZPX  = 4;
  ZPY  = 5;
  AbsM = 6;
  AbsX = 7;
  AbsY = 8;
  Rel  = 9;
  IndX = 10;
  IndY = 11;
  AbsI = 12;

 { CimzesModok helyfoglalasai }
  CMH : array[Spec..AbsI] of 1..3 =
  (1, 1, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3);

 { Utasitasok }
  FE  = 0; { Future Expansion - ertelmezhetetlen kod }
  ADC = $10;
  ANDK = $20;
  ASL = $30;
  BCC = $40;
  BCS = $50;
  BEQ = $60;
  BIT = $70;
  BMI = $80;
  BNE = $90;
  BPL = $A0;
  BRK = $B0;
  BVC = $C0;
  BVS = $D0;
  CLC = $E0;
  CLD = $F0;
  CLI = $100;
  CLV = $110;
  CMP = $120;
  CPX = $130;
  CPY = $140;
  DECK = $150;
  DEX = $160;
  DEY = $170;
  EOR = $180;
  INCK = $190;
  INX = $1A0;
  INY = $1B0;
  JMP = $1C0;
  JSR = $1D0;
  LDA = $1E0;
  LDX = $1F0;
  LDY = $200;
  LSR = $210;
  NOP = $220;
  ORA = $230;
  PHA = $240;
  PHP = $250;
  PLA = $260;
  PLP = $270;
  ROL = $280;
  ROR = $290;
  RTI = $2A0;
  RTS = $2B0;
  SBC = $2C0;
  SEC = $2D0;
  SED = $2E0;
  SEI = $2F0;
  STA = $300;
  STX = $310;
  STY = $320;
  TAX = $330;
  TAY = $340;
  TSX = $350;
  TXA = $360;
  TXS = $370;
  TYA = $380;

 { UtasitasKodok }
  UK : array[0..$FF] of word =
 (BRK, ORA + IndX, FE, FE, FE, ORA + ZP, ASL + ZP, FE,
    PHP, ORA + Imm, ASL + Acc, FE, FE, ORA + AbsM, ASL + AbsM, FE,
  BPL + Rel, ORA + IndY, FE, FE, FE, ORA + ZPX, ASL + ZPX, FE,
    CLC, ORA + AbsY, FE, FE, FE, ORA + AbsX, ASL + AbsX, FE,
  JSR + AbsM, ANDK + IndX, FE, FE, BIT + ZP, ANDK + ZP, ROL + ZP, FE,
    PLP, ANDK + Imm, ROL + Acc, FE, BIT + AbsM, ANDK + AbsM, ROL + AbsM, FE,
  BMI + Rel, ANDK + IndY, FE, FE, FE, ANDK + ZPX, ROL + ZPX, FE,
    SEC, ANDK + AbsY, FE, FE, FE, ANDK + AbsX, ROL + AbsX, FE,
  RTI, EOR + IndX, FE, FE, FE, EOR + ZP, LSR + ZP, FE,
    PHA, EOR + Imm, LSR + Acc, FE, JMP + AbsM, EOR + AbsM, LSR + AbsM, FE,
  BVC + Rel, EOR + IndY, FE, FE, FE, EOR + ZPX, LSR + ZPX, FE,
    CLI, EOR + AbsY, FE, FE, FE, EOR + AbsX, LSR + AbsX, FE,
  RTS, ADC + IndX, FE, FE, FE, ADC + ZP, ROR + ZP, FE,
    PLA, ADC + Imm, ROR + Acc, FE, JMP + AbsI, ADC + AbsM, ROR + AbsM, FE,
  BVS + Rel, ADC + IndY, FE, FE, FE, ADC + ZPX, ROR + ZPX, FE,
    SEI, ADC + AbsY, FE, FE, FE, ADC + AbsX, ROR + AbsX, FE,
  FE, STA + IndX, FE, FE, STY + ZP, STA + ZP, STX + ZP, FE,
    DEY, FE, TXA, FE, STY + AbsM, STA + AbsM, STX + AbsM, FE,
  BCC + Rel, STA + IndY, FE, FE, STY + ZPX, STA + ZPX, STX + ZPY, FE,
    TYA, STA + AbsY, TXS, FE, FE, STA + AbsX, FE, FE,
  LDY + Imm, LDA + IndX, LDX + Imm, FE, LDY + ZP, LDA + ZP, LDX + ZP, FE,
    TAY, LDA + Imm, TAX, FE, LDY + AbsM, LDA + AbsM, LDX + AbsM, FE,
  BCS + Rel, LDA + IndY, FE, FE, LDY + ZPX, LDA + ZPX, LDX + ZPX, FE,
    CLV, LDA + AbsY, TSX, FE, LDY + AbsX, LDA + AbsX, LDX + AbsY, FE,
  CPY + Imm, CMP + IndX, FE, FE, CPY + ZP, CMP + ZP, DECK + ZP, FE,
    INY, CMP + Imm, DEX, FE, CPY + AbsM, CMP + AbsM, DECK + AbsM, FE,
  BNE + Rel, CMP + IndY, FE, FE, FE, CMP + ZPX, DECK + ZPX, FE,
    CLD, CMP + AbsY, FE, FE, FE, CMP + AbsX, DECK + AbsY, FE,
  CPX + Imm, SBC + IndX, FE, FE, CPX + ZP, SBC + ZP, INCK + ZP, FE,
    INX, SBC + Imm, NOP, FE, CPX + AbsM, SBC + AbsM, INCK + AbsM, FE,
  BEQ + Rel, SBC + IndY, FE, FE, FE, SBC + ZPX, INCK + ZPX, FE,
    SED, SBC + AbsY, FE, FE, FE, SBC + AbsX, INCK + AbsY, FE);

 { Regiszterek nevei fejlechez }
  RNevek : string[28] = 'AC  XR  YR  SP  SR  NV-BDIZC';

 { Hexadecimalis szamjegyek }
  HexSzamJegy : string[16] = '0123456789ABCDEF';

type
  MTipus   = array[0..$FFFE] of byte;
  RTipus   = record
               A, X, Y, SP         : byte;
               PC                  : word;
               C, Z, I, D, B, V, N : 0..1;
             end; { record }
  HSBTipus = string[2];
  HSWTipus = string[4];

var
  M         : ^MTipus;
  R         : RTipus;
  OpB, CMod : byte;
  OpW, UKod : word;
  LeFagyott : boolean;

function HSB(Bajt : byte) : HSBTipus;
function HSW(Szo : word) : HSWTipus;
procedure KiIrRegs;
procedure KiIrPCRegs;
procedure Cra;
procedure OpKepzes;
procedure O2Kepzes;
procedure VegreHajt;
procedure Step;
procedure Futtat;
procedure Close6510;

implementation

var
  M2  : ^byte;
  O2W : word;
  O2B : byte;

procedure Eval(E : word); { SR jelzobitjeinek allitasa E szerint }
begin
  with R do
  begin
    if E = 0 then
      Z := 1
    else
      Z := 0;
    N := E shr 7 and 1;
  end; { with }
end; { Eval }

procedure EvalC(E : word);
begin
  Eval(E);
  if E > $FF then
    R.C := 1
  else
    R.C := 0;
end; { EvalC }

function PackSR : byte; { SR jelzobitjeinek osszegyujtese byte-ba }
begin
  with R do
    PackSR := C or Z shl 1 or I shl 2 or D shl 3 or B shl 4 or 32 or
              V shl 6 or N shl 7;
end; { PackSR }

procedure UnPackSR(PSR : byte); { jelzobitek allitasa PSR szerint }
begin
  with R do
  begin
    C := PSR and 1;
    Z := PSR and 2 shr 1;
    I := PSR and 4 shr 2;
    D := PSR and 8 shr 3;
    B := PSR and 16 shr 4;
    V := PSR and 64 shr 6;
    N := PSR and 128 shr 7;
  end; { with }
end; { UnPackSR }

function HSB(Bajt : byte) : HSBTipus; { Bajt hexadecimalisan }
begin
  HSB := HexSzamJegy[Bajt shr 4 + 1] + HexSzamJegy[Bajt and $0F + 1];
end; { HSB }

function HSW(Szo : word) : HSWTipus; { Szo hexadecimalisan }
begin
  HSW := HSB(Hi(Szo)) + HSB(Lo(Szo));
end; { HSW }

procedure KiIrRegs; { Regiszterek kiirasa }
begin
  with R do
    WriteLn(HSB(A), '  ', HSB(X), '  ', HSB(Y), '  ', HSB(SP),
            '  ', HSB(PackSR), '  ', N, V, ' ', B, D, I, Z, C);
end; { KiIrRegs }

procedure KiIrPCRegs;
begin
  WriteLn(' PC    ', RNevek);
  Write(HSW(R.PC), '   ');
  KiIrRegs;
end; { KiIrPCRegs }

procedure Cra;
begin
  WriteLn;
  WriteLn('Illegal instruction code - Operation aborted');
  KiIrPCRegs;
  R.PC := (R.PC + 1) and $FFFF;
end; { Cra }

procedure OpKepzes;
begin
  UKod := UK[M^[R.PC]];
  CMod := UKod and $0F;
  if UKod = FE then
    LeFagyott := true
  else
  begin
    UKod := UKod and $FFF0;
    with R do
      case CMH[CMod] of
        2 : OpB := M^[(PC + 1) and $FFFF];
        3 : OpW := M^[(PC + 1) and $FFFF] or M^[(PC + 2) and $FFFF] shl 8;
      end; { case }
  end; { else }
end; { OpKepzes }

procedure O2Kepzes;
begin
  with R do
    case CMod of
      Acc  : O2B := A;
      Imm  : O2B := OpB;
      ZP   : begin
               O2W := OpB;
               O2B := M^[O2W];
             end;
      ZPX  : begin
               O2W := (OpB + X) and $FF;
               O2B := M^[O2W];
             end;
      ZPY  : begin
               O2W := (OpB + Y) and $FF;
               O2B := M^[O2W];
             end;
      AbsM : begin
               O2W := OpW;
               O2B := M^[O2W];
             end;
      AbsX : begin
               O2W := (OpW + X) and $FFFF;
               O2B := M^[O2W];
             end;
      AbsY : begin
               O2W := (OpW + Y) and $FFFF;
               O2B := M^[O2W];
             end;
      Rel  : O2B := OpB;
      IndX : begin
               O2W := M^[(OpB + X) and $FF] or
                      M^[(OpB + X + 1) and $FF] shl 8;
               O2B := M^[O2W];
             end;
      IndY : begin
               O2W := (M^[OpB] + (M^[(OpB + 1) and $FF] shl 8) + Y)
                      and $FFFF;
               O2B := M^[O2W];
             end;
      AbsI : O2W := M^[OpW] or M^[(OpW + 1) and $FFFF] shr 8;
    end; { case }
end; { O2Kepzes }

procedure RelUgras;
begin
  with R do
    if O2B < $80 then
      PC := (PC + O2B) and $FFFF
    else
      PC := (PC + O2B + $1FF00) and $FFFF;
end; { RelUgras }

procedure PushB(Bajt : byte); { bajt berakasa a verembe }
begin
  M^[$100 or R.SP] := Bajt;
  R.SP := (R.SP + $FF) and $FF;
end; { PushB }

procedure PushW(Szo : word); { word berakasa a verembe }
begin
  PushB(Hi(Szo));
  PushB(Lo(Szo));
end; { PushW }

function PullB : byte; { byte kivetele a verembol }
begin
  R.SP := (R.SP + 1) and $FF;
  PullB := M^[$100 or R.SP];
end; { PullB }

function PullW : word; { word kivetele a verembol }

var PCL : byte;

begin
  PCL := PullB;
  PullW := PCL or PullB shl 8;
end; { PullW }

procedure VegreHajt; { Aktualis utasitaskod vegrehajtasa }

var Er : word;

begin
  with R do
  begin
    PC := (PC + CMH[CMod]) and $FFFF;
    case UKod of
      ADC : begin
              Er := A + O2B + C;
              EvalC(Er);
              A := Er and $FF;
              V := A shr 6 and 1;
            end;
      ANDK : begin
               A := A and O2B;
               Eval(A);
             end;
      ASL : begin
              Er := O2B shl 1;
              EvalC(Er);
              if CMod = Acc then
                A := Er and $FF
              else
                M^[O2W] := Er and $FF;
            end;
      BCC : if C = 0 then
              RelUgras;
      BCS : if C = 1 then
              RelUgras;
      BEQ : if Z = 1 then
              RelUgras;
      BIT : begin
              Er := A and O2B;
              Eval(Er);
              V := (Er shr 6) and 1;
            end;
      BMI : if N = 1 then
              RelUgras;
      BNE : if Z = 0 then
              RelUgras;
      BPL : if N = 0 then
              RelUgras;
    { BRK : ; }
      BVC : if V = 0 then
              RelUgras;
      BVS : if V = 1 then
              RelUgras;
      CLC : C := 0;
      CLD : D := 0;
      CLI : I := 0;
      CLV : V := 0;
      CMP : begin
              Er := A or $100 - O2B;
              EvalC(Er);
            end;
      CPX : begin
              Er := X or $100 - O2B;
              EvalC(Er);
            end;
      CPY : begin
              Er := Y or $100 - O2B;
              EvalC(Er);
            end;
      DECK : begin
               M^[O2W] := (O2B + $FF) and $FF;
               Eval(M^[O2W]);
             end;
      DEX : begin
              X := (X + $FF) and $FF;
              Eval(X);
            end;
      DEY : begin
              Y := (Y + $FF) and $FF;
              Eval(Y);
            end;
      EOR : begin
              A := A xor O2B;
              Eval(A);
            end;
      INCK : begin
               M^[O2W] := (O2B + 1) and $FF;
               Eval(M^[O2W]);
             end;
      INX : begin
              X := (X + 1) and $FF;
              Eval(X);
            end;
      INY : begin
              Y := (Y + 1) and $FF;
              Eval(Y);
            end;
      JMP : PC := O2W;
      JSR : begin
              PushW((PC + $FFFF) and $FFFF);
              PC := O2W;
            end;
      LDA : begin
              A := O2B;
              Eval(A);
            end;
      LDX : begin
              X := O2B;
              Eval(X);
            end;
      LDY : begin
              Y := O2B;
              Eval(Y);
            end;
      LSR : begin
              Er := O2B shr 1;
              Eval(Er);
              C := O2B and 1;
              if CMod = Acc then
                A := Er
              else
                M^[O2W] := Er;
            end;
    { NOP : ; }
      ORA : begin
              A := A or O2B;
              Eval(A);
            end;
      PHA : PushB(A);
      PHP : PushB(PackSR);
      PLA : A := PullB;
      PLP : UnPackSR(PullB);
      ROL : begin
              Er := O2B shl 1 or C;
              EvalC(Er);
              if CMod = Acc then
                A := Er and $FF
              else
                M^[O2W] := Er and $FF;
            end;
      ROR : begin
              Er := O2B shr 1 or C shl 7;
              Eval(Er);
              C := O2B and 1;
              if CMod = Acc then
                A := Er
              else
                M^[O2W] := Er;
            end;
      RTI : begin
              UnPackSR(PullB);
              PC := PullW;
            end;
      RTS : begin
              PC := PullW;
              PC := (PC + 1) and $FFFF;
            end;
      SBC : begin
              Er := A + C + $FF - O2B;
              EvalC(Er);
              A := Er and $FF;
              V := (A shr 6) and 1;
            end;
      SEC : C := 1;
      SED : D := 1;
      SEI : I := 1;
      STA : M^[O2W] := A;
      STX : M^[O2W] := X;
      STY : M^[O2W] := Y;
      TAX : begin
              X := A;
              Eval(X);
            end;
      TAY : begin
              Y := A;
              Eval(Y);
            end;
      TSX : begin
              X := SP;
              Eval(X);
            end;
      TXA : begin
              A := X;
              Eval(A);
            end;
      TXS : SP := X;
      TYA : begin
              A := Y;
              Eval(A);
            end;
    end; { case }
  end; { with }
end; { VegreHajt }

procedure Step; { Soronkovetkezo utasitas ertelmezese }
begin
  OpKepzes;
  if LeFagyott then
    Cra
  else
  begin
    O2Kepzes;
    VegreHajt;
  end; { else }
end; { Step }

procedure Futtat; { Futtatas BRK-ig }
begin
  LeFagyott := false;
  repeat
    Step;
  until (UKod = BRK) or LeFagyott;
end; { Futtat }

procedure Close6510; { Memoria felszabaditasa }
begin
  Dispose(M2);
  Dispose(M);
end;

procedure Init6510; { CPU inicializalas }
begin
  if MaxAvail < SizeOf(MTipus) + 1 then
  begin
    WriteLn('Nincs eleg memoria');
    Halt(1);
  end;
  New(M);
  New(M2);
  R.SP := $FF;
  UnPackSR(0);
  Eval(R.A);
end; { Init6510 }

begin { Inicializacios resz }
  Init6510;
end. { unit }