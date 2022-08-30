{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1991,97 by T¢th B lint       }
{                                                }
{************************************************}

unit CGlobals; { Glob lis (CPU) deklar ci¢k }

interface

const

 { Cimz‚sm¢dok }
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

 { Cimz‚sm¢dok helyfoglal sai byte-ban }
  CMH: Array[Spec..AbsI] of Byte =
    (1, 1, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3);

 { Utas¡t sok }
  FE  = 0;              { Future Expansion - ‚rtelmezhetetlen k¢d }
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

 { Utas¡t sk¢dok }
  UK: Array[0..$FF] of Word =
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
    CLD, CMP + AbsY, FE, FE, FE, CMP + AbsX, DECK + AbsX, FE,
  CPX + Imm, SBC + IndX, FE, FE, CPX + ZP, SBC + ZP, INCK + ZP, FE,
    INX, SBC + Imm, NOP, FE, CPX + AbsM, SBC + AbsM, INCK + AbsM, FE,
  BEQ + Rel, SBC + IndY, FE, FE, FE, SBC + ZPX, INCK + ZPX, FE,
    SED, SBC + AbsY, FE, FE, FE, SBC + AbsX, INCK + AbsX, FE);

type
  PMem = ^TMem;
  TMem = Array[0..$FFFE] of Byte;      { 64K mem¢ria blokk }

  TRegs = record                       { regiszterek }
    A, X, Y, SP, SR: Byte;
    PC: Word;
  end;

var
  Regs: TRegs;

implementation

end.