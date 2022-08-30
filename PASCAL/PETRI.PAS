{ Nemes Tiham‚r Sz mit stechnikai verseny, II. fordul¢ }
{ T¢th B lint, Berzsenyi D niel Gimn zium }
{ Turbo Pascal 6.0 }

const
  MaxCs = 8;
  MaxAT = 8;
  MaxLepes = 8;

type

  PCsomoTipus = ^CsomoTipus;
  CsomoTipus = Record
    Bemenet, Kimenet: Array[1..MaxAT] of Boolean;
  end;

  PAtmenetTipus = ^AtmenetTipus;
  AtmenetTipus = Record
    Bemenet, Kimenet: Array[1..MaxCS] of Boolean;
  end;

  GrafTipus = Record
    Csomok: Array[1..MaxCS] of PCsomoTipus;
    Atmenetek: Array[1..MaxAT] of PAtmenetTipus;
  end;

  AllapotTipus = Array[1..MaxCs] of Integer;
  AllSorTipus = Array[1..MaxLepes] of AllapotTipus;

var
  Graf: GrafTipus;
  CsomokSzama, AtmenetekSzama: Integer;
  AllSor: AllSorTipus;
  SorHossz: Integer;
  HoltPont: Boolean;

procedure GrafBevitel;

procedure CsomoBevitel(Cs: Integer);
var
  J, K: Integer;
  S: String;
begin
  with Graf do
  begin
    WriteLn('A(z) ', Cs, '. csom¢b¢l: ');
    K := 0;
    repeat
      repeat
        ReadLn(S);
      until S <> '';
      S[1] := UpCase(S[1]);
      J := Ord(S[1]) - Ord('A') + 1;
      if (J >= 1) and (J <= AtmenetekSzama) then
        if Csomok[Cs]^.Kimenet[J] then
          WriteLn('M r volt.')
        else
        begin
          Csomok[Cs]^.Kimenet[J] := True;
          Atmenetek[J]^.Bemenet[Cs] := True;
          Inc(K);
        end
      else
        if S[1] <> '0' then
          WriteLn('Ilyen  tmenet nincs.');
    until (K = AtmenetekSzama) or (S[1] = '0');
  end; { with }
end; { CsomoBevitel }

procedure AtmenetBevitel(AT: Integer);
var
  J, K: Integer;
begin
  with Graf do
  begin
    WriteLn('A(z) ', Chr(AT + Ord('A') - 1), '  tmenetb“l: ');
    K := 0;
    repeat
      ReadLn(J);
      if (J >= 1) and (J <= CsomokSzama) then
        if Atmenetek[AT]^.Kimenet[J] then
          WriteLn('M r volt.')
        else
        begin
          Atmenetek[AT]^.Kimenet[J] := True;
          Csomok[J]^.Bemenet[AT] := True;
          Inc(K);
        end
      else
        if J <> 0 then
          WriteLn('Ilyen  tmenet nincs.');
    until (K = CsomokSzama) or (J = 0);
  end; { with }
end; { AtmenetBevitel }

var
 I, J: Integer;

begin { GrafBevitel }
  WriteLn('Adja meg a gr fot!');
  repeat
    Write('Csom¢k sz ma (1-', MaxCs, ') : ');
    ReadLn(CsomokSzama);
  until (CsomokSzama > 0) and (CsomokSzama <= MaxCs);
  repeat
    Write('Atmenetek sz ma (1-', MaxAT, ') : ');
    ReadLn(AtmenetekSzama);
  until (AtmenetekSzama > 0) and (AtmenetekSzama <= MaxAT);
  for I := 1 to CsomokSzama do
    New(Graf.Csomok[I]);
  for I := 1 to AtmenetekSzama do
    New(Graf.Atmenetek[I]);
  for I := 1 to CsomokSzama do
    for J := 1 to AtmenetekSzama do
    begin
      Graf.Csomok[I]^.Bemenet[J] := False;
      Graf.Csomok[I]^.Kimenet[J] := False;
      Graf.Atmenetek[J]^.Bemenet[I] := False;
      Graf.Atmenetek[J]^.Kimenet[I] := False;
    end;
  WriteLn;
  WriteLn('Csom¢k jel”l‚se: 1 - ', CsomokSzama);
  WriteLn('Atmenetek jel”l‚se: A - ', Chr(AtmenetekSzama + Ord('A') - 1));
  WriteLn('0 = Nincs t”bb nyil');
  WriteLn('Adja meg, hogy melyik  tmenetbe vezet nyil!');
  for I := 1 to CsomokSzama do
    CsomoBevitel(I);
  WriteLn;
  WriteLn('Adja meg, hogy melyik csom¢ba vezet nyil!');
  for I := 1 to AtmenetekSzama do
    AtmenetBevitel(I);
  WriteLn;
end; { GrafBevitel }

procedure GrafKiiras;

procedure CsomoKiiras;
var
  I, J, K: Integer;
begin
  with Graf do
  begin
    for I := 1 to CsomokSzama do
    begin
      Write('  A(z) ', I, '. csom¢b¢l ');
      K := 0;
      for J := 1 to AtmenetekSzama do
        if Csomok[I]^.Kimenet[J] then
          K := J;
      if K = 0 then
        WriteLn('nem vezet nyil')
      else
      begin
        for J := 1 to AtmenetekSzama do
          if Csomok[I]^.Kimenet[J] then
          begin
            Write(Chr(J + Ord('A') - 1));
            if J < K then
              Write(', ');
          end;
        WriteLn('  tmenet(ek)be vezet nyil');
      end; { else }
    end; { for I }
  end; { with }
end; { CsomoKiiras }

procedure AtmenetKiiras;
var
  I, J, K: Integer;
begin
  with Graf do
  begin
    for I := 1 to AtmenetekSzama do
    begin
      Write('  A(z) ', Chr(I + Ord('A') - 1), '  tmenetb“l ');
      K := 0;
      for J := 1 to CsomokSzama do
        if Atmenetek[I]^.Kimenet[J] then
          K := J;
      if K = 0 then
        WriteLn('nem vezet nyil')
      else
      begin
        for J := 1 to CsomokSzama do
          if Atmenetek[I]^.Kimenet[J] then
          begin
            Write(J, '.');
            if J < K then
              Write(', ');
          end;
        WriteLn(' csom¢(k)ba vezet nyil');
      end; { else }
    end; { for I }
  end; { with }
end; { AtmenetKiiras }

begin { GrafKiiras }
  WriteLn('A gr f:');
  WriteLn('-------');
  WriteLn('Csom¢k sz ma: ', CsomokSzama);
  WriteLn('Atmenetek sz ma: ', AtmenetekSzama);
  WriteLn('Nyilak: ');
  CsomoKiiras;
  AtmenetKiiras;
end; { GrafKiiras }

procedure AllapotBevitel(var All: AllapotTipus; Kezdo: Boolean);
var
  I: Integer;
begin
  WriteLn('K‚rem az egyes csom¢kban l‚v“ bigy¢k sz m t!');
  if Kezdo then
    WriteLn('( 0 vagy 1 )');
  for I := 1 to CsomokSzama do
  begin
    repeat
      Write('  A(z) ', I, '. csom¢ban: ');
      ReadLn(All[I]);
    until (All[I] >= 0) and ((not Kezdo) or (All[I] <= 1));
  end;
end; { AllapotBevitel }

procedure AllapotKiiras(All: AllapotTipus);
var
  I: Integer;
begin
  WriteLn('Az egyes csom¢kban l‚v“ bigy¢k sz ma:');
  for I := 1 to CsomokSzama do
    WriteLn('A(z) ', I, '. csom¢ban: ', All[I]);
  Write('[ Enter ] ');
  ReadLn;
end; { AllapotKiiras }

function Aktivizalhato(All: AllapotTipus; AT: Integer): Boolean;
var
  I: Integer;
  Akt: Boolean;
begin
  Akt := False;
  I := 1;
  repeat
    if Graf.Atmenetek[AT]^.Bemenet[I] then
      Akt := All[I] > 0;
    Inc(I);
  until Akt or (I > CsomokSzama);
  Aktivizalhato := Akt;
end; { Aktivizalhato }

procedure Aktivizal(All1: AllapotTipus; var All2: AllapotTipus;
  AT: Integer);
var
  I: Integer;
begin
  for I := 1 to CsomokSzama do
  begin
    if Graf.Atmenetek[AT]^.Bemenet[I] then
      if All1[I] > 0 then
        Dec(All2[I]);
    if Graf.Atmenetek[AT]^.Kimenet[I] then
      Inc(All2[I]);
  end;
end; { Aktivizal }

procedure Lepes(All1: AllapotTipus; var All2: AllapotTipus;
  var HoltP: Boolean);

var
  I, K: Integer;
  VersenyzoAT: Array[1..MaxAT] of Integer;

begin { Lepes }
  All2 := All1;
  K := 0;
  for I := 1 to AtmenetekSzama do
    if Aktivizalhato(All1, I) then
    begin
      Inc(K);
      VersenyzoAT[K] := I;
    end;
  HoltP := K = 0;
  if K > 0 then
    Aktivizal(All1, All2, VersenyzoAT[Random(K) + 1]);
end; { Lepes }

procedure AllSorKiiras(SHossz: Integer; NemTalalas: Boolean);
var
  I: Integer;
begin
  WriteLn('Kiindul si  llapot:');
  AllapotKiiras(AllSor[1]);
  for I := 2 to SHossz do
  begin
    WriteLn;
    WriteLn(I - 1, '. l‚p‚s ut ni  llapot:');
    AllapotKiiras(AllSor[I]);
  end;
  if (SHossz < MaxLepes) and NemTalalas then
    WriteLn('Itt holtpontra kerlt.');
end; { AllSorKiiras }

procedure F2;
begin
  AllapotBevitel(AllSor[1], True);
  WriteLn;
  WriteLn('Egy lehets‚ges  llapotsor:');
  WriteLn('--------------------------');
  SorHossz := 1;
  repeat
    Lepes(AllSor[SorHossz], AllSor[SorHossz + 1], HoltPont);
    Inc(SorHossz);
  until (SorHossz = MaxLepes) or HoltPont;
  AllSorKiiras(SorHossz, True);
  Write('[ Enter ] ');
  ReadLn;
end; { F2 }

procedure F3;

var
  Talalt: Boolean;
  ValtozatSzam: Integer;
  TalaltSor: AllSorTipus;
  TalaltHossz: Integer;
  CelAll: AllapotTipus;

function Egyezik(All1, All2: AllapotTipus): Boolean;
var
  I: Integer;
begin
  I := 1;
  while (I <= CsomokSzama) and (All1[I] = All2[I]) do
    Inc(I);
  Egyezik := I > CsomokSzama;
end; { Egyezik }

procedure Vizsgal;
var
  I, K: Integer;
  VersenyzoAT: Array[1..MaxAT] of Integer;

begin
  Inc(SorHossz);
  if Egyezik(AllSor[SorHossz], CelAll) then
  begin
    TalaltSor := AllSor;
    TalaltHossz := SorHossz;
    Talalt := True;
  end;
  if SorHossz = MaxLepes then
  begin
    Inc(ValtozatSzam);
    WriteLn;
    WriteLn(ValtozatSzam : 4 , '. vari ci¢:');
    WriteLn('-----------------');
    AllSorKiiras(SorHossz, False);
  end
  else
  begin
    K := 0;
    for I := 1 to AtmenetekSzama do
      if Aktivizalhato(AllSor[SorHossz], I) then
      begin
        Inc(K);
        VersenyzoAT[K] := I;
      end;
    if K = 0 then
    begin
      Inc(ValtozatSzam);
      WriteLn;
      WriteLn(ValtozatSzam : 4 , '. vari ci¢:');
      WriteLn('-----------------');
      AllSorKiiras(SorHossz, True);
    end
    else
      for I := 1 to K do
      begin
        AllSor[SorHossz + 1] := AllSor[SorHossz];
        Aktivizal(AllSor[SorHossz], AllSor[SorHossz + 1], VersenyzoAT[I]);
        Vizsgal;
      end;
  end; { if SorHossz else }
  Dec(SorHossz);
end;

begin { F3 }
  WriteLn('Adja meg a kiindul si  llapotot!');
  AllapotBevitel(AllSor[1], True);
  WriteLn('Adja meg a keresett c‚l llapotot!');
  AllapotBevitel(CelAll, False);
  SorHossz := 0;
  WriteLn;
  WriteLn('A keresett c‚l:');
  AllapotKiiras(CelAll);
  WriteLn;
  WriteLn('Az ”sszes  llapotsor:');
  WriteLn('---------------------');
  ValtozatSzam := 0;
  Talalt := False;
  Vizsgal;
  if Talalt then
  begin
    WriteLn;
    WriteLn('*** MEGTALALTAM! ***');
    WriteLn;
    WriteLn('Az  llapotsor:');
    WriteLn('--------------');
    AllSor := TalaltSor;
    AllSorKiiras(TalaltHossz, False);
  end
  else
    WriteLn('NEM TALALTAM');
  Write('[ Enter ] ');
  ReadLn;
end; { F3 }

procedure DoneGraf; { Graf dinamikus mezoinek felszabaditasa }
var
  I: Integer;
begin
  for I := 1 to CsomokSzama do
    if Graf.Csomok[I] <> NIL then
      Dispose(Graf.Csomok[I]);
  for I := 1 to AtmenetekSzama do
    if Graf.Atmenetek[I] <> NIL then
      Dispose(Graf.Atmenetek[I]);
end; { DoneGraf }

begin { program }
  WriteLn('Petri-Gr f     ( T¢th B lint, 1992 )');
  WriteLn;
  GrafBevitel;
  GrafKiiras;
  F2;
  F3;
  DoneGraf;
end.
