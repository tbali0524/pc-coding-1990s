{ T¢th B†lint, 1992 }
program STerms;

{$B-,I+,S+}
{$M 65520,0,655360}
uses Crt; { csak ReadKey }

const
  Max = 10; { s-termek maxim†lis hossza }
  MaxLep = 30; { normaliz†l†s maxim†lis lÇpÇssz†ma }

type
  PSTermT = ^STermT;
  STermT = Record
      Bal, Jobb: PSTermT; { melyik kÇt s-term egym†s mellÇ °r†s†b¢l Çs
                            bez†r¢jelezÇsÇbìl †ll az s-term.
                            Ha mindkettì Nil, akkor az s-term: S }
    end;

var
  B: Char;
  S, S1,
  Zar: String; {          Åres [  '' ], ha rîvid alak,
                 csuk¢ z†r¢jel [ ')' ], ha teljes alak }
  F: Text;
  R: STermT; { egy s-term }
  I,
  L, { redukci¢s lÇpÇsek sz†ma }
  N, { s-termek hossza }
  NotNorm, { nem normaliz†lhat¢ s-termek sz†ma }
  Total: Integer; { s-termek sz†ma }

procedure Megnyit(var F: Text; I: Integer);
{ I hossz£s†g£ s-termek file-j†nak hozz†rendelÇse F-hez }
var
  S: String;
begin
  Str(I, S);
  Assign(F, 'STERM' + Copy('00', 1, 2 - Length(S)) + S + '.STF');
end;

procedure GenSTerm;
{ Az îsszes s-term elì†ll°t†sa
    I hossz£s†g£ s-termek elì†ll°t†sa:
      ciklus J = 1 -tìl I - 1 -ig
          îsszep†ros°tja a J hossz£ s-termeket az I - J hossz£ s-termekkel
          minden lehetsÇges m¢don, az eredmÇnyt z†r¢jelbe rakva I hossz£
          s-termet kapunk.
}
var
  F, F1, F2: Text;
  S1, S2: String;
  I, J: Integer;
begin
  for I := 1 to N do
  begin
    Megnyit(F, I);
    Rewrite(F);
    if I = 1 then
      WriteLn(F, 'S.')
    else if I = 2 then
      WriteLn(F, '(SS' + Zar + '.')
    else
      for J := 1 to I - 1 do
      begin
        Megnyit(F1, J);
        Reset(F1);
        while not Eof(F1) do
        begin
          ReadLn(F1, S1);
          Megnyit(F2, I - J);
          Reset(F2);
          while not Eof(F2) do
          begin
            ReadLn(F2, S2);
            Write(F, '(', Copy(S1, 1, Length(S1) - 1),
              Copy(S2, 1, Length(S2) - 1), Zar);
            if (J = I - 1) and Eof(F1) and Eof(F2) then
              WriteLn(F, '.')
            else
              WriteLn(F, ';');
          end; { while F2 }
          Close(F2);
        end; { while F1 }
        Close(F1);
      end; { for J }
    Close(F);
  end; { for I }
end; { GenSTerm }

procedure ReadTerm(S: String; var R: STermT);
{ konvert†l†s stringbìl STermT t°pusba }
var
  I,
  ZaroSz,
  SSz: Integer;
begin
  if S = 'S' then
  begin
    R.Bal := Nil;
    R.Jobb := Nil;
  end
  else
  begin
    ZaroSz := 0;
    SSz := 0;
    I := 0;
    repeat
      Inc(I);
      if S[I] = 'S' then
        Inc(SSz)
      else
        Inc(ZaroSz);
    until (SSz = ZaroSz);
    New(R.Bal);
    ReadTerm(Copy(S, 2, I - 1), R.Bal^);
    New(R.Jobb);
    ReadTerm(Copy(S, I + 1, Length(S) - I), R.Jobb^);
  end;
end; { ReadTerm }

function PrintTerm(var R: STermT): String;
{ Konvert†l†s STermT t°pusb¢l stringbe.
  Felszabad°tja R-et a heap-bìl.
}
begin
  if (R.Bal = Nil) and (R.Jobb = Nil) then
    PrintTerm := 'S'
  else
  begin
    PrintTerm := '(' + PrintTerm(R.Bal^) + PrintTerm(R.Jobb^) + Zar;
    Dispose(R.Bal);
    Dispose(R.Jobb);
  end;
end; { PrintTerm }

procedure Masol(var M1: PSTermT; M2: PSTermT);
{ M†solatot kÇsz°t M2-rìl M1-be }
begin
  New(M1);
  M1^.Bal := Nil;
  M1^.Jobb := Nil;
  if M2^.Bal <> Nil then
  begin
    Masol(M1^.Bal, M2^.Bal);
    Masol(M1^.Jobb, M2^.Jobb);
  end;
end; { Masol }

procedure Reduce(var R: STermT);
{ KertÇszkedÇs: egy redukci¢s lÇpÇs vÇgrehajt†sa az †gak †trak†s†val.
  R-ben nem az egÇsz s-termet kapja, hanem csak azt a rÇszt, amelyen
  a reduk†l†s elvÇgezhetì.
  ( feltÇtel: vÇgig bal oldalon haladva R pont h†rom lÇpÇs mÇly legyen.)
}
var
  A, B, C: PSTermT;
begin
  A := R.Bal^.Bal^.Jobb;
  B := R.Bal^.Jobb;
  C := R.Jobb;
  Dispose(R.Bal^.Bal^.Bal); { S kivÇtele }
  Dispose(R.Bal^.Bal); { (SA) kivÇtele }
  New(R.Jobb);
  R.Bal^.Bal := A;
  R.Bal^.Jobb := C;
  R.Jobb^.Bal := B;
  Masol(R.Jobb^.Jobb, C);
end; { Reduce }

procedure Normalize(var R: STermT);
var
  VoltLepes: Boolean;

procedure Norm(var R: STermT);
{ kiv†lasztja a kîvetkezì reduk†l†s helyÇt Çs reduk†l is }
begin
  if (L <= MaxLep) and (not VoltLepes) then
    if (R.Bal <> Nil) and (R.Bal^.Bal <> Nil) and (R.Bal^.Bal^.Bal <> Nil)
      and (R.Bal^.Bal^.Bal^.Bal = Nil) then
    begin
      Reduce(R);
      Inc(L);
      VoltLepes := True;
    end
    else
      if R.Bal <> Nil then
      begin
        Norm(R.Bal^);
        Norm(R.Jobb^);
      end;
end; { Norm }

begin { Normalize }
  L := 0;
  repeat
    VoltLepes := False;
    Norm(R);
  until not VoltLepes;
end; { Normalize }

begin { fìprogram }
  WriteLn('S-TERM-ek   (c) T¢th B†lint, 1992.');
  repeat
    Write('Az s-termek hossza: ');
    ReadLn(N);
  until (N >= 1) and (N <= 10);
  Write('Haszn†ljak csuk¢ z†r¢jelet? [I/N] ');
  repeat
    B := UpCase(ReadKey);
  until B in ['I', 'N'];
  WriteLn(B);
  if B = 'I' then
    Zar := ')'
  else
    Zar := '';
  GenSTerm;
  Total := 0;
  NotNorm := 0;
  Megnyit(F, N);
  Reset(F);
  WriteLn('Eredeti s-term               ≥ Normaliz†lt s-term             ' +
    '      ≥ lÇpÇssz†m');
  WriteLn('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ' +
    'ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ');
  while not Eof(F) do
  begin
    ReadLn(F, S);
    Inc(Total);
    Delete(S, Length(S), 1);
    Write(S, ' ' : 29 - Length(S), '≥ ');
    S1 := '';
    for I := 1 to Length(S) do { csuk¢ z†r¢jelek kivÇtele }
      if S[I] <> ')' then
        S1 := S1 + S[I];
    ReadTerm(S1, R);
    Normalize(R);
    S := PrintTerm(R);
    Write(S, ' ' : 37 - Length(S), '≥ ');
    if L > MaxLep then
    begin
      WriteLn('nem normaliz†lt');
      Inc(NotNorm);
    end
    else
      WriteLn(L : 2);
    if (Total mod 24) = 22 then
    begin
      Write('[ Enter ] ');
      ReadLn;
    end;
  end; { while }
  Close(F);
  WriteLn;
  WriteLn('ôsszes ', N, ' hossz£s†g£ s-termek sz†ma: ', Total);
  WriteLn('Ebbìl nem normaliz†lhat¢ ', MaxLep, ' lÇpÇsben: ', NotNorm);
  Write('[ Enter ] ');
  ReadLn;
end.

{ MegjegyzÇsek:
      A programban nincs I/O ellenìrzÇs, °gy hiba esetÇn Runtime error-ral
    le†ll. Ha N = 10, akkor 145 KByte helyre van szÅksÇg az aktu†lis
    meghajt¢n. (Teljes s-term alak esetÇn 205K-ra.)
      A GenSTerm elj†r†s sokszor olvas ugyanazokb¢l a file-okb¢l, ezÇrt
    Norton Cache vagy RAM-disk haszn†lata javasolt.
}
