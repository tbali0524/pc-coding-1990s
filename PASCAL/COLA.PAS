{ T¢th B†lint, 1992 }
program Cola; { Command Language Interpreter }

{$B-}
uses Crt, Graph;
const
  Szimbol: String[11*9] =
    'CLEAR    PLACE    PRINT    PUT      TAKE     ON       OFF      ' +
    'FROM     SQUARE   TRIANGLE CIRCLE   '; { megengedett szimb¢lumok }
  Elval = [' ', #9]; { elv†laszt¢ karakterek ( sz¢kîz, TAB ) }
  MaxMag = 6; { egym†sra helyezhetì dobozok maxim†lis sz†ma }
  MaxSzel = 15; { egym†s mellÇ helyezhetì dobozok maxim†lis sz†ma }
type
  PToronyT = ^ToronyT;
  ToronyT = Record { egy torony }
    Sq: Integer; { nÇgyzetek }
    Tr, { h†romszîgek }
    Ci: Boolean; { kîrîk }
    Next: PToronyT; { kîvetkezì torony }
  end;
var
  Polc: PToronyT; { balszÇlsì torony }
  F: Text; { COLA forr†sfile }
  O: Array[1..4] of Byte; { aktu†lis sor ( a szimb¢lumok sorsz†m†val ) }
  SorSz: Integer; { a sor sz†ma }
  FNev, { COLA forr†sfile neve }
  Sor: String; { aktu†lis sor }
  MaxX, MaxY: Word; { grafikus felbont†s }

procedure Initialize;
{ grafikus meghajt¢ inicializ†l†sa a BGIDEMO.PAS alapj†n }
var
  GraphDriver,
  GraphMode,
  ErrorCode: Integer;
  PathToDriver: String;
begin
  DirectVideo := False;
  PathToDriver := 'C:\BP\BGI';
  repeat
    GraphDriver := Detect;
    InitGraph(GraphDriver, GraphMode, PathToDriver);
    ErrorCode := GraphResult;
    if ErrorCode <> grOK then
    begin
      Writeln('Grafikus hiba: ', GraphErrorMsg(ErrorCode));
      if ErrorCode = grFileNotFound then
      begin
        Write('Adja meg a BGI meghajt¢ elÇrÇsi £tj†t: ');
        ReadLn(PathToDriver);
        WriteLn;
      end
      else
        Halt(1);
    end;
  until ErrorCode = grOK;
  MaxX := GetMaxX;
  MaxY := GetMaxY;
end; { Initialize }

procedure Done(S: String);
{ lez†r†s, mem¢ria felszabad°t†sa, Åzenet kiir†sa, fut†s befejezÇse }
var
  P: PToronyT;
begin
  while Polc <> Nil do
  begin
    P := Polc;
    Polc := Polc^.Next;
    Dispose(P);
  end;
  CloseGraph;
  Close(F);
  ClrScr;
  WriteLn('COLA: ', S);
  Halt;
end; { Done }

procedure Hiba(S: String);
{ hibaÅzenet, kilÇpÇs }
var
  S1: String;
begin
  if S = '' then
    S := 'Szintaktikus hiba';
  Str(SorSz, S1);
  Done(S + ' a(z) ' + S1 + '. sorban.');
end; { Hiba }

procedure SzetSzedSor(S: String);
{ a parancs Çs az operandusok k¢djainak kikeresÇse }
var
  I, J, K: Integer;
begin
  for I := 1 to 4 do
    O[I] := 0;
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  J := 1;
  for I := 1 to 4 do
  begin
    while (J <= Length(S)) and (S[J] in Elval) do
      Inc(J);
    K := J;
    while (K <= Length(S)) and (not(S[K] in Elval)) do
      Inc(K);
    if J <= Length(S) then
    begin
      O[I] := Pos(Copy(S, J, K - J), Szimbol);
      if O[I] > 0 then
        O[I] := O[I] div 9 + 1;
    end;
    J := K;
  end; { for I }
end; { SzetSzedSor }

function UjTorony: PToronyT;
{ £j torony lÇtrehoz†sa }
var
  I: Integer;
  P, P1: PToronyT;
begin
  New(P1);
  P1^.Sq := 0;
  P1^.Ci := False;
  P1^.Tr := False;
  P1^.Next := Nil;
  I := 1;
  if Polc <> Nil then
  begin
    P := Polc;
    while P^.Next <> Nil do
    begin
      Inc(I);
      P := P^.Next;
    end;
    P^.Next := P1;
  end
  else
    Polc := P1;
  if I = MaxSzel then
    Hiba('A polc betelt');
  UjTorony := P1;
end; { UjTorony }

procedure ComPlace;
const
  HS = 'PLACE operandus hiba';
var
  P: PToronyT;
begin
  if (O[3] <> 0) or (O[4] <> 0) then
    Hiba(HS);
  P := Polc;
  while (P <> Nil) and (P^.Ci or P^.Tr or (P^.Sq <> 0)) do
    P := P^.Next;
  if P = Nil then
    P := UjTorony;
  case O[2] of
     9: P^.Sq := 1;
    10: P^.Tr := True;
    11: P^.Ci := True;
    else
      Hiba(HS);
  end;
end; { ComPlace }

procedure ComPut;
const
  HS = 'PUT operandus hiba';
var
  P: PToronyT;
begin
  if (O[3] <> 6) or (O[4] <> 9) then
    Hiba(HS);
  P := Polc;
  case O[2] of
    9, 10: while (P <> Nil) and (P^.Ci or P^.Tr or (P^.Sq = MaxMag)) do
             P := P^.Next;
    11: while (P <> Nil) and (P^.Ci or P^.Tr or (P^.Sq <> 0)) do
          P := P^.Next;
    else
      Hiba(HS);
  end;
  if P = Nil then
    Hiba('Nem tudom nÇgyzetre rakni a dobozt');
  case O[2] of
     9: Inc(P^.Sq);
    10: P^.Tr := True;
    11: P^.Ci := True;
  end;
end; { ComPut }

procedure ComTake;
const
  HS = 'TAKE operandus hiba';
var
  P: PToronyT;

procedure ComTakeOff;
begin
  if O[4] <> 0 then
    Hiba(HS);
  case O[2] of
     9: begin
          while (P <> Nil) and (P^.Ci or P^.Tr or (P^.Sq <> 1)) do
              P := P^.Next;
          if P <> Nil then
            P^.Sq := 0
          else
            Hiba('Nem tudok egyedÅl lÇvì nÇgyzetet levenni');
        end;
    10: begin
          while (P <> Nil) and (P^.Ci or (not P^.Tr) or (P^.Sq <> 0))
            do
              P := P^.Next;
          if P <> Nil then
            P^.Tr := False
          else
            Hiba('Nem tudok egyedÅl lÇvì h†romszîget levenni');
        end;
    11: begin
          while (P <> Nil) and ((not P^.Ci) or P^.Tr or (P^.Sq <> 0))
            do
              P := P^.Next;
          if P <> Nil then
            P^.Ci := False
          else
            Hiba('Nem tudok kîrt levenni');
        end;
    else
      Hiba(HS);
  end; { case }
end; { ComTakeOff }

procedure ComTakeFrom;
begin
  if O[4] <> 9 then
    Hiba(HS);
  case O[2] of
     9: begin
          while (P <> Nil) and (P^.Ci or P^.Tr or (P^.Sq <= 1)) do
              P := P^.Next;
          if P <> Nil then
            Dec(P^.Sq)
          else
            Hiba('Nem tudok nÇgyzetet nÇgyzetrìl levenni');
        end;
    10: begin
          while (P <> Nil) and (P^.Ci or (not P^.Tr) or (P^.Sq = 0))
            do
              P := P^.Next;
          if P <> Nil then
            P^.Tr := False
          else
            Hiba('Nem tudok h†romszîget nÇgyzetrìl levenni');
        end;
    else
      Hiba(HS);
  end; { case }
end; { ComTakeFrom }

begin { ComTake }
  P := Polc;
  case O[3] of
    7: ComTakeOff;
    8: ComTakeFrom;
    else
      Hiba(HS);
  end;
end; { ComTake }

procedure ComPrint;
var
  P: PToronyT;
  I, J: Integer;
begin
  P := Polc;
  I := 0;
  Line(0, MaxY - 5, MaxX, MaxY - 5);
  while P <> Nil do
  begin
    Inc(I);
    with P^ do
      if Ci then
      begin
        Circle(I * 35 + 15, MaxY - 20, 15);
        OutTextXY(I * 35 + 12, MaxY - 24, 'C');
      end
      else
      begin
        for J := 1 to Sq do
        begin
          RecTangle(I * 35, MaxY - 5 - J * 30, I * 35 + 30,
            MaxY + 25 - J * 30);
          OutTextXY(I * 35 + 12, MaxY + 6 - J * 30, 'S');
        end;
        if Tr then
        begin
          Line(I * 35, MaxY - 5 - Sq * 30, I * 35 + 15, MaxY - 30 - Sq * 30);
          Line(I * 35 + 30, MaxY - 5 - Sq * 30,
            I * 35 + 15, MaxY - 30 - Sq * 30);
          OutTextXY(I * 35 + 12, MaxY - 16 - Sq * 30, 'T');
        end;
      end; { else }
    P := P^.Next;
  end;
  OutTextXY(1, 1, 'Nyomjon ENTER-t!');
  ReadLn;
  ClearViewPort;
end; { ComPrint }

procedure VegreHajt;
begin
  if (SorSz = 1) and (O[1] <> 1) then
    Hiba('Hi†nyzik a CLEAR');
  case O[1] of
    1: if SorSz = 1 then
         Polc := Nil
       else
         Done('CLEAR csak egyszer haszn†lhat¢.');
    2: ComPlace;
    3: ComPrint;
    4: ComPut;
    5: ComTake;
    else
      Hiba('Ismeretlen parancs');
  end;
end; { VegreHajt }

begin { fìprogram }
  WriteLn('COLA  The Command Language Interpreter   (c) T¢th B†lint, 1992');
  Write('FilenÇv: ');
  ReadLn(FNev);
  if FNev = '' then
    FNev := 'COLA.INP';
  Assign(F, FNev);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(2);
  end;
  Initialize;
  SorSz := 0;
  while not Eof(F) do
  begin
    Inc(SorSz);
    ReadLn(F, Sor);
    if Sor <> '' then
    begin
      SzetSzedSor(Sor);
      Vegrehajt;
    end;
  end;
  Done('Rendes programbefejezÇs');
end.
