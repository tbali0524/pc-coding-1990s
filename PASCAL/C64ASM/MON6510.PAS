{ MCS6510 MikroProcesszor Emul tor }
{         Monitor Unit             }
{ Copyright (c) 1991  T¢th B lint  }

unit Mon6510;

interface

const Esc = #27;

procedure MExecute;
procedure MTrace;
procedure Monitor;
procedure DisAssembler;
procedure Assembler;
procedure Tolt(LNev : string);
procedure MLoad;
procedure MSave;
procedure MFill;
procedure MCopy;
procedure MCompare;
procedure MHunt;
procedure MRegisters;

implementation

uses Crt, Emul6510;

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
  Enter      = #13;

 { Utasitasok nevei }
  InstrS : string[228] =
   '*** ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRK BVC BVS CLC CLD CLI ' +
   'CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY JMP JSR LDA LDX LDY LSR ' +
   'NOP ORA PHA PHP PLA PLP ROL ROR RTI RTS SBC SEC SED SEI STA STX STY ' +
   'TAX TAY TSX TXA TXS TYA ';

procedure Varakozik;
begin
  WriteLn(' - Press Enter!');
  ReadLn;
end; { Varakozik }

function HexKonv(KS : HSWTipus; KHossz : byte; var KSikerult : boolean)
         : word;

var
  KSzo        : word;
  KBajt, KKod : byte;

begin
  if Length(KS) <= (KHossz shl 1) then
  begin
    KSzo := 0;
    KBajt := 0;
    repeat
      KKod := Pos(UpCase(KS[KBajt + 1]), HexSzamJegy);
      if KKod > 0 then
        KSzo := (KSzo shl 4) or (KKod - 1);
      Inc(KBajt);
    until (KBajt = Length(KS)) or (KKod = 0);
    KSikerult := (KBajt = Length(KS)) and (KKod > 0);
    HexKonv := KSzo;
  end { then }
  else
  begin
    KSikerult := false;
    HexKonv := 0;
  end; { else }
end; { HexKonv }

procedure BeOlvas(BSzoveg : string; BHossz : byte; var BSzo : word);

var
  BS        : string;
  BSikerult : boolean;
  BKod      : integer;

begin
  repeat
    Write(BSzoveg);
    ReadLn(BS);
    if BS[1] = '$' then
      BSzo := HexKonv(Copy(BS, 2, BHossz shl 1), BHossz, BSikerult)
    else
    begin
      Val(BS, BSzo, BKod);
      BSikerult := (BKod = 0) and (BSzo < (1 shl (BHossz shl 3)));
    end; { else }
  until BSikerult;
end; { BeOlvas }

procedure KiIrInstr;

var DI : shortint;

begin
  OpKepzes;
  Write(HSB(M^[R.PC]), '  ');
  case CMH[CMod] of
    1 : Write('         ');
    2 : Write(HSB(OpB), '       ');
    3 : Write(HSB(Lo(OpW)), '  ', HSB(Hi(OpW)), '   ');
  end; { case }
  Write(Copy(InstrS, (UKod and $FFF0) shr 2 + 1, 4));
  case CMod of
    Spec : Write('      ');
    Acc  : Write('A     ');
    Imm  : Write('#', HSB(OpB), '   ');
    ZP   : Write(HSB(OpB), '    ');
    ZPX  : Write(HSB(OpB), ',X  ');
    ZPY  : Write(HSB(OpB), ',Y  ');
    AbsM : Write(HSW(OpW), '  ');
    AbsX : Write(HSW(OpW), ',X');
    AbsY : Write(HSW(OpW), ',Y');
    Rel  : begin
             if OpB < $80 then
               DI := OpB
             else
               DI := OpB - $100;
             Write(HSW(((R.PC + 2) and $FFFF + $10000 + DI) and $FFFF),
                   '  ');
           end; { case Rel }
    IndX : Write('(', HSB(OpB), ',X)');
    IndY : Write('(', HSB(OpB), '),Y');
    AbsI : Write('(', HSW(OpW), ')');
  end; { case }
end; { KiIrInstr }

procedure ExecRutin;
begin
  WriteLn('Executing . . .');
  Futtat;
  WriteLn;
  Write('Executing ended');
  Varakozik;
end; { ExecRutin }

procedure MExecute;
begin
  ClrScr;
  BeOlvas('Execute from : ', 2, R.PC);
  ExecRutin;
end; { MExecute }

procedure MTrace;

var TBill : char;

begin
  repeat
    ClrScr;
    BeOlvas('Trace from : ', 2, R.PC);
    WriteLn('Tracing . . .');
    LeFagyott := false;
    WriteLn(' PC     Code       Instruction   ', RNevek);
    Write('                                 ');
    KiIrRegs;
    repeat
      Write(HSW(R.PC), '   ');
      KiIrInstr;
      if LeFagyott then
        Cra
      else
      begin
        O2Kepzes;
        VegreHajt;
        Write('   ');
        KiIrRegs;
        TBill := UpCase(ReadKey);
      end; { else }
    until (UKod = BRK) or LeFagyott or
          (TBill in ['N', 'E', 'Q', 'X', Esc]);
  until TBill <> 'N';
  if (TBill = 'E') and (UKod <> BRK) then
  begin
    WriteLn;
    ExecRutin;
  end { then }
  else
  begin
    WriteLn;
    Write('Tracing ended');
    Varakozik;
  end; { else }
end; { MTrace }

procedure Monitor;

var
  MKezdet, MSzo  : word;
  MJegy, MKod    : byte;
  MBill          : char;

procedure KiIrMSor(SKezdet : word);

var KMSK : byte;

begin
  Write(HSW(SKezdet), '  ');
  for KMSK := 0 to $F do
    Write(HSB(M^[SKezdet or KMSK]), ' ');
  Write(' ');
  for KMSK := 0 to $F do
    if M^[SKezdet or KMSK] >= 32 then
      Write(Chr(M^[SKezdet or KMSK]))
    else
      Write('.');
  WriteLn;
end; { KiIrMSor }

procedure KiIrMon;

var KMJ : word;

begin
  GoToXY(1, 1);
  KMJ := MKezdet;
  repeat
    KiIrMSor(KMJ);
    Inc(KMJ, $10);
  until (KMJ = (MKezdet + $180)) or (KMJ = 0);
  ClrEol;
end; { KiIrMon }

procedure MoveMonCrsr;
begin
  GoToXY( 3 * ((MSzo - MKezdet) and $F) + 8 - MJegy,
         (MSzo - MKezdet) shr 4 + 1);
end; { MoveMonCrsr }

procedure MLeftA;
begin
  if ((MSzo and $F) > 0) or (MJegy = 0) then
  begin
    Dec(MSzo, MJegy);
    MJegy := 1 - MJegy;
  end; { if }
end; { MLeftA }

procedure MRightA;
begin
  if ((MSzo and $F) < $F) or (MJegy = 1) then
  begin
    MJegy := 1 - MJegy;
    Inc(MSzo, MJegy);
  end; { if }
end; { MRightA }

procedure MUpA;
begin
  if (MSzo > $F) then
  begin
    Dec(MSzo, $10);
    if MSzo < MKezdet then
    begin
      Dec(MKezdet, $10);
      GoToXY(1, 1);
      InsLine;
      KiIrMSor(MKezdet);
      GoToXY(1, 25);
      ClrEol;
    end; { if MSzo < }
  end; { if MSzo > }
end; { MUpA }

procedure MDownA;
begin
  if (MSzo < $FFF0) then
  begin
    Inc(MSzo, $10);
    if MSzo > (MKezdet + $17F) then
    begin
      Inc(MKezdet, $10);
      GoToXY(1, 1);
      DelLine;
      GoToXY(1, 24);
      KiIrMSor(MKezdet + $170);
    end; { if MSzo > }
  end; { if MSzo < }
end; { MDownA }

procedure MHome;
begin
  MSzo := MSzo and $FFF0;
  MJegy := 1;
end ; { MHome }

procedure MEnd;
begin
  MSzo := MSzo or $F;
  MJegy := 0;
end ; { MEnd }

procedure MPgUp;
begin
  if MKezdet > $17F then
  begin
    Dec(MKezdet, $180);
    Dec(MSzo, $180);
  end { if }
  else
  begin
    MKezdet := 0;
    MSzo := MSzo and $F;
  end; { else }
  KiIrMon;
end; { MPgUp }

procedure MPgDn;
begin
  if MKezdet < $FE80 then
  begin
    Inc(MKezdet, $180);
    Inc(MSzo, $180);
  end { if }
  else
  begin
    MKezdet := $FE80;
    MSzo := $FFF0 or (MSzo and $F);
  end; { else }
  KiIrMon;
end; { MPgDn }

procedure MCtrlLeftA;
begin
  MLeftA;
  MLeftA;
end; { MCtrlLeftA }

procedure MCtrlRightA;
begin
  MRightA;
  MRightA;
end; { MCtrlRightA }

procedure MCtrlHome;
begin
  MSzo := MKezdet;
  MJegy := 1;
end ; { MCtrlHome }

procedure MCtrlEnd;
begin
  MSzo := MKezdet + $17F;
  MJegy := 0;
end ; { MCtrlEnd }

procedure MCtrlPgUp;
begin
  MKezdet := 0;
  MSzo := 0;
  MJegy := 1;
  KiIrMon;
end ; { MCtrlPgUp }

procedure MCtrlPgDn;
begin
  MKezdet := $FE80;
  MSzo := $FFFF;
  MJegy := 0;
  KiIrMon;
end ; { MCtrlPgDn }

procedure MShiftTab;
begin
  MSzo := MSzo xor 8;
end; { MShiftTab }

procedure MEnter;
begin
  if MSzo < $FFF0 then
  begin
    MHome;
    MDownA;
  end; { if }
end; { MEnter }

begin { Monitor }
  repeat
    ClrScr;
    BeOlvas('Starting address: ', 2, MKezdet);
    ClrScr;
    MKezdet := MKezdet and $FFF0;
    MSzo := MKezdet;
    MJegy := 1;
    KiIrMon;
    repeat
      MoveMonCrsr;
      MBill := UpCase(ReadKey);
      if MBill = #0 then
      begin
        if KeyPressed  then
        begin
          MBill := ReadKey;
          case MBill of
            LeftA      : MLeftA;
            RightA     : MRightA;
            UpA        : MUpA;
            DownA      : MDownA;
            Home       : MHome;
            EndB       : MEnd;
            PgUp       : MPgUp;
            PgDn       : MPgDn;
            CtrlLeftA  : MCtrlLeftA;
            CtrlRightA : MCtrlRightA;
            CtrlHome   : MCtrlHome;
            CtrlEnd    : MCtrlEnd;
            CtrlPgUp   : MCtrlPgUp;
            CtrlPgDn   : MCtrlPgDn;
            ShiftTab   : MShiftTab;
          end; { case }
          MBill := ' ';
        end; { if KeyPressed }
      end { if MBill then }
      else
      begin
        MKod := Pos(MBill, HexSzamJegy);
        if MKod > 0 then
        begin
          M^[MSzo] := (M^[MSzo] and ($F shl ((1 - MJegy) shl 2))) or
                     ((MKod - 1) shl (MJegy shl 2));
          GoToXY(1, WhereY);
          KiIrMSor(MSzo and $FFF0);
          if ((MSzo and $F) = $F) and (MJegy = 0) then
            MEnter
          else
            MRightA;
        end { if MKod }
        else
          if MBill = Enter then
            MEnter;
      end; { if MBill else }
    until MBill in ['N', 'Q', 'X', Esc];
  until MBill <> 'N';
end; { Monitor }

procedure KiIrDSor;
begin
  Write(HSW(R.PC), '   ');
  KiIrInstr;
  WriteLn;
  R.PC := (R.PC + CMH[CMod]) and $FFFF;
end; { KiIrDSor }

procedure DisAssembler;

var
  DPCSave : word;
  DBill   : char;

procedure DPgDn;

var DB : byte;

begin
  ClrScr;
  for DB := 1 to 24 do
    KiIrDSor;
end; { DPgDn }

begin { Disassembler }
  DPCSave := R.PC;
  repeat
    ClrScr;
    Beolvas('Disassemble from : ', 2, R.PC);
    DPgDn;
    repeat
      DBill := UpCase(ReadKey);
      case DBill of
        #0     : if KeyPressed then
                 begin
                   DBill := ReadKey;
                   case DBill of
                     DownA    : KiIrDSor;
                     PgDn     : DPgDn;
                     CtrlPgUp : begin
                                  R.PC := 0;
                                  ClrScr;
                                  DPgDn;
                                end; { case CtrlPgUp }
                   end; { case DBill }
                   DBill := ' ';
                 end; { if }
        Enter  : KiIrDSor;
      end; { case  DBill }
    until DBill in ['N', 'Q', 'X', Esc]
  until DBill in ['Q', 'X', Esc];
  R.PC := DPCSave;
end; { DisAssembler }

procedure Assembler;

var
  AS      : string[10];
  AI      : integer;
  APCSave : word;
  AX, AY,
  AB, AB2 : byte;
  AJo     : boolean;

begin
  APCSave := R.PC;
  repeat
    ClrScr;
    BeOlvas('Starting address: ', 2, R.PC);
    repeat
      Write(HSW(R.PC), '   ');
      AX := WhereX;
      AY := WhereY;
      repeat
        ReadLn(AS);
        GoToXY(AX, AY);
        ClrEol;
        for AB := 1 to Length(AS) do
          AS[AB] := UpCase(AS[AB]);
        if Length(AS) in [3..10] then
        begin
          if Length(AS) = 3 then
            AS := AS + ' ';
          UKod := Pos(Copy(AS, 1, 4), InstrS);
          if UKod > 0 then
            UKod := (UKod - 1) shl 2;
          if UKod <> FE then
          begin
            AJo := true;
            case Length(AS) of
               4 : if (UKod = ASL) or (UKod = LSR) or
                      (UKod = ROL) or (UKod = ROR) then
                     CMod := Acc
                   else
                     CMod := Spec;
               5 : if AS[5] = 'A' then
                     CMod := Acc
                   else
                     AJo := false;
               6 : begin
                     CMod := ZP;
                     AB := 5;
                   end; { case 6 }
               7 : if AS[5] = '#' then
                   begin
                     CMod := Imm;
                     AB := 6;
                   end { then }
                   else
                     AJo := false;
               8 : begin
                     AB := 5;
                     if AS[7] = ',' then
                       case AS[8] of
                         'X' : CMod := ZPX;
                         'Y' : CMod := ZPY;
                         else
                           AJo := false;
                       end { case }
                     else
                       if (AS[1] = 'B') and (Copy(AS, 1, 4) <> 'BIT ') then
                         CMod := Rel
                       else
                         CMod := AbsM;
                   end; { case 8 }
              10 : if AS[5] = '(' then
                   begin
                     AB := 6;
                     if Copy(AS, 8, 3) = ',X)' then
                       CMod := IndX
                     else
                       if Copy(AS, 8, 3) = '),Y' then
                         CMod := IndY
                       else
                         if AS[10] = ')' then
                           CMod := AbsI
                         else
                           AJo := false;
                   end { if AS }
                   else
                   begin
                     AB := 5;
                     if AS[9] = ',' then
                       case AS[10] of
                         'X' : CMod := AbsX;
                         'Y' : CMod := AbsY;
                         else
                           AJo := false
                       end { case }
                     else
                       AJo := false;
                   end; { else }
              else
                AJo := false;
            end; { case }
            if AJo then
            begin
              UKod := UKod or CMod;
              AB2 := 0;
              while (UK[AB2] <> UKod) and (AB2 < $FF) do
                Inc(AB2);
              if UK[AB2] = UKod then
              begin
                with R do
                begin
                  case CMH[CMod] of
                    1 : begin
                          M^[PC] := AB2;
                        end; { case 1 }
                    2 : begin
                          if CMod = Rel then
                          begin
                            OpW :=HexKonv(Copy(AS, AB, 4), 2, AJo);
                            if AJo then
                            begin
                              AI := (OpW - (PC + 2) and $FFFF);
                              if (AI >= 0) and (AI < $80) then
                                OpB := AI
                              else
                                if (AI < 0) and (AI >= -128) then
                                  OpB := AI + $100
                                else
                                  AJo := false;
                            end; { if AJo }
                          end { if CMod }
                          else
                            OpB := HexKonv(Copy(AS, AB, 2), 1, AJo);
                          if AJo then
                          begin
                            M^[PC] := AB2;
                            M^[(PC + 1) and $FFFF] := OpB;
                          end; { if }
                        end; { case 2 }
                    3 : begin
                          OpW :=HexKonv(Copy(AS, AB, 4), 2, AJo);
                          if AJo then
                          begin
                            M^[PC] := AB2;
                            M^[(PC + 1) and $FFFF] := Lo(OpW);
                            M^[(PC + 2) and $FFFF] := Hi(OpW);
                          end; { if }
                        end; { case }
                  end; { case }
                  if AJo then
                  begin
                    GoToXY(1, AY);
                    KiIrDSor;
                  end; { if AJo }
                end; { with }
              end { if UK }
              else
                AJo := false;
            end; { if AJo }
          end { if UKod }
          else
            AJo :=false;
        end { if Length }
        else
          AJo := false;
      until AJo or (AS = 'Q') or (AS = 'X') or (AS = 'N');
    until not AJo;
  until AS <> 'N';
  R.PC := APCSave;
end; { Assembler }

procedure Tolt(LNev : string);

var
  LF       : file of byte;
  LB1, LB2 : byte;
  LJ, LVeg : word;

procedure IllegalF;
begin
  Close(LF);
  Write('Not MCS6510 memory file');
  Varakozik;
end; { IllegalF }

begin { Tolt }
  Assign(LF, LNev);
  {$I-}
  Reset(LF);
  {$I+}
  if IOResult = 0 then
    if FileSize(LF) > 7 then
    begin
      Read(LF, LB1, LB2);
      if (LB1 = $6E) and (LB2 = $19) then
      begin
        Read(LF, LB1, LB2);
        Read(LF, LB1, LB2);
        LJ := LB1 or LB2 shl 8;
        Read(LF, LB1, LB2);
        LVeg := LB1 or LB2 shl 8;
        if (LVeg > LJ) and (FileSize(LF) > LVeg - LJ + 8) then
        begin
          repeat
            Read(LF, M^[LJ]);
            Inc(LJ);
          until (LJ >= LVeg) or (LJ = 0);
          Close(LF);
        end { if VegCim }
        else
          IllegalF;
      end  { if LB1 }
      else
        IllegalF;
    end { if FileSize }
    else
      IllegalF
  else
  begin
    Write('I/O Error');
    Varakozik;
  end; { else }
end; { Tolt }

procedure MLoad;

var LName : string;

begin
  ClrScr;
  Write('Enter path & filename to load:  ');
  ReadLn(LName);
  Tolt(LName);
end; { MLoad }

procedure MSave;

var
  SF        : file of byte;
  SNev      : string;
  SB1, SB2  : byte;
  SJ, SVeg,
  SStart    : word;

begin;
  ClrScr;
  Write('Enter path & filename to save:  ');
  ReadLn(SNev);
  BeOlvas('Save starting address :    ', 2, SJ);
  repeat
    BeOlvas('Save ending address :      ', 2, SVeg);
  until SVeg >= SJ;
  Assign(SF, SNev);
  {$I-}
  Rewrite(SF);
  {$I+}
  if IOResult = 0 then
  begin
    SB1 := $6E;
    SB2 := $19;
    Write(SF, SB1, SB2);
    Write(SF, SB1, SB2);
    SB1 := Lo(SJ);
    SB2 := Hi(SJ);
    Write(SF, SB1, SB2);
    SB1 := Lo(SVeg);
    SB2 := Hi(SVeg);
    Write(SF, SB1, SB2);
    repeat
      Write(SF, M^[SJ]);
      Inc(SJ);
    until (SJ > SVeg) or (SJ = 0);
    Close(SF);
  end { if }
  else
  begin
    Write('I/O Error');
    Varakozik;
  end; { else }
end; { MSave }

procedure MFill;

var
  FKezdet, FVeg, FBajt, FJ : word;

begin
  ClrScr;
  BeOlvas('Fill from : ', 2, FKezdet);
  repeat
    BeOlvas('     to   : ', 2, FVeg);
  until FVeg >= FKezdet;
  BeOlvas('Fill with : ', 1, FBajt);
  for FJ := FKezdet to FVeg do
    M^[FJ] := FBajt;
end; { MFill }

procedure MCopy;

var CKezdet, CVeg, CCim, CJ : word;

begin
  ClrScr;
  BeOlvas('Copy from   : ', 2, CKezdet);
  repeat
    BeOlvas('     to     : ', 2, CVeg);
  until CVeg >= CKezdet;
  repeat
    BeOlvas('New address : ', 2, CCim);
  until (CCim + (CVeg - CKezdet)) <= $FFFF;
  if CCim > CKezdet then
    for CJ := CVeg - CKezdet downto 0 do
      M^[CCim + CJ] := M^[CKezdet + CJ]
  else
    for CJ := 0 to CVeg - CKezdet do
      M^[CCim + CJ] := M^[CKezdet + CJ];
end; { MCopy }

procedure MCompare;

var PKezdet, PVeg, PCim, PSzamlalo, PJ : word;

begin
  ClrScr;
  BeOlvas('Compare from : ', 2, PKezdet);
  repeat
    BeOlvas('        to   : ', 2, PVeg);
  until PVeg >= PKezdet;
  repeat
    BeOlvas('Compare with : ', 2, PCim);
  until (PCim + (PVeg - PKezdet)) <= $FFFF;
  WriteLn;
  PSzamlalo := 0;
  PJ := 0;
  repeat
    if M^[PKezdet + PJ] <> M^[PCim + PJ] then
    begin
      if PSzamlalo = 0 then
        WriteLn('Differences:');
      Write(HSW(PKezdet + PJ), ' ');
      Inc(PSzamlalo);
      if (PSzamlalo mod $180) = 0 then
        ReadLn;
    end; { if M^ }
    Inc(PJ);
  until PJ > (PVeg - PKezdet + 1);
  WriteLn;
  WriteLn(PSzamlalo, ' differences found');
  WriteLn;
  Write('Comparing ended');
  Varakozik;
end; { MCompare }

procedure MHunt;

var
  HKezdet, HVeg,
  HSzamlalo, HJ  : word;
  HB             : byte;
  HJo            : boolean;
  HS, HS2        : string;

begin
  ClrScr;
  BeOlvas('Hunt from : ', 2, HKezdet);
  repeat
    BeOlvas('     to   : ', 2, HVeg);
  until HVeg >= HKezdet;
  repeat
    repeat
      Write('Hunt for  : ');
      ReadLn(HS);
    until Length(HS) > 1;
    if HS[1] = '"' then
    begin
      HJo := true;
      HS2 := Copy(HS, 2, Length(HS) - 1);
    end { then }
    else
    begin
      for HB := 1 to Length(HS) do
        HS[HB] := UpCase(HS[HB]);
      HB := 1;
      HS2 := '';
      repeat
        HS2 := HS2 + Chr(HexKonv(Copy(HS, HB, 2), 1, HJo));
        Inc(HB, 3);
      until ((HB + 1) > Length(HS)) or (not HJo);
    end; { else }
  until HJo and ((HVeg - HKezdet + 1) >= Length(HS2));
  WriteLn;
  HSzamlalo := 0;
  for HJ := HKezdet to HVeg - Length(HS2) + 1 do
  begin
    HB := 0;
    HJo := true;
    repeat
      HJo := M^[HJ + HB] = Ord(HS2[HB + 1]);
      Inc(HB);
    until (not HJo) or (HB = Length(HS2));
    if HJo then
    begin
      if HSzamlalo = 0 then
        WriteLn('Found at:');
      Write(HSW(HJ), ' ');
      Inc(HSzamlalo);
      if (HSzamlalo mod $180) = 0 then
        ReadLn;
    end; { HJo }
  end; { for }
  WriteLn;
  WriteLn(HSzamlalo, ' addresses found');
  WriteLn;
  Write('Hunting ended');
  Varakozik;
end; { MHunt }

procedure MRegisters;
begin
  ClrScr;
  WriteLn('Registers: ');
  WriteLn;
  KiIrPCRegs;
  WriteLn;
  Varakozik;
end; { MRegisters }

end. { unit Mon6510 }