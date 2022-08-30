{    Szamitastechnika verseny VIII. fordulo
  Toth Balint, Berzseny Daniel Gimnazium, 1991.
}
program Bali7169;

uses
  Crt;

const
  MaxAtomSzam   = 16;

type
  KotesTipus    = 0..6;
  IndexTipus    = 1..MaxAtomSzam;
  CHMatrixTipus = array[IndexTipus, IndexTipus] of KotesTipus;

const
  Sztirol : CHMatrixTipus =
    ((0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (2, 0, 4, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 4, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 2, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 2, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 2, 0),
     (0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 2),
     (0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0));
  Proba1 : CHMatrixTipus =
    ((0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (2, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 3, 0, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 3, 3, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 2, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 2, 0, 3, 0, 3, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 3, 0, 2, 3, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 2, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
  Proba2 : CHMatrixTipus =
    ((0, 2, 0, 4, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (2, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 2, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (4, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));

var
  CHMatrix               : CHMatrixTipus;
  AtomSzam               : 4..MaxAtomSzam;
  SzenSzam, HidrogenSzam : 0..MaxAtomSzam;
  MarVolt, GyuruTag      : array[IndexTipus] of boolean;
  Ut, GyuruUt            : array[IndexTipus] of IndexTipus;
  Hidr                   : IndexTipus;
  I, J, K, L,
  GyuruUtHossz           : integer;
  Letezo, Telitetlen,
  Gyurus, Aromas         : boolean;

procedure CHBeKeres;
begin
  Write('Kerem a szenhidrogen atomjainak szamat! (4-', MaxAtomSzam, ') ');
  repeat
    Read(AtomSzam);
  until AtomSzam in [4..MaxAtomSzam];
  for I := 1 to AtomSzam do
    CHMatrix[I, I] := 0;
  WriteLn('Kerem a szenhidrogen egyes atomjai kozott levo koteseket ',
          'felkotesekben(!)');
  for I := 1 to AtomSzam - 1 do
    for J := I + 1 to AtomSzam do
    begin
      repeat
        Write('A(z) ', I : 2, '. es a(z) ', J : 2, '. atom kozotti ',
                'felkotesek szama: ');
        Read(CHMatrix[I, J]);
      until CHMatrix[I, J] in [0..6];
      CHMatrix[J, I] := CHMatrix[I, J];
    end; { for J }
end; { CHBeKeres }

procedure CHSzamlalas;
begin
  Letezo := true;
  HidrogenSzam := 0;
  SzenSzam := 0;
  I := AtomSzam + 1;
  repeat
    Dec(I);
    K := 0;
    for J := 1 to AtomSzam do
      K := K + CHMatrix[I, J];
    case K of
      2 : begin
            Inc(HidrogenSzam);
            Hidr := I;
          end;
      8 : Inc(SzenSzam);
      else
        Letezo := false;
    end; { case }
  until (not Letezo) or (I = 1);
end; { CHSzamlalas }

procedure Vizsgal(Jelenlegi, Elozo : IndexTipus);

var
  A                : IndexTipus;

begin
  Inc(I);
  Ut[I] := Jelenlegi;
  MarVolt[Jelenlegi] := true;
  for A := 1 to AtomSzam do
    if (CHMatrix[Jelenlegi, A] > 0) and (A <> Elozo) then
      if MarVolt[A] then
      begin
        J := I;
        repeat
          Dec(J);
        until (J = 0) or (Ut[J] = A);
        if J > 0 then
        begin
          J := I + 1;
          repeat
            Dec(J);
            GyuruTag[Ut[J]] := true;
          until (Ut[J] = A) or (J = 1);
          if Gyurus then
          begin
            K := 1;
            repeat
              Inc(K);
            until (Ut[K] <> GyuruUt[K]) or (K = I);
            for L := K - 1 to J do
              GyuruTag[Ut[L]] := true;
            for L := K - 1 to GyuruUtHossz do
              GyuruTag[GyuruUt[L]] := true;
          end;
          Gyurus := true;
          GyuruUt := Ut;
          GyuruUtHossz := I;
        end
      end
      else
        Vizsgal(A, Jelenlegi);
  Dec(I);
end; { Vizsgal }

procedure CHVizsgalat;
begin
  for I := 1 to AtomSzam do
  begin
    MarVolt[I] := false;
    GyuruTag[I] := false;
  end;
  Gyurus := false;
  I := 0;
  Vizsgal(Hidr, Hidr);
  for I := 1 to AtomSzam do
    if not MarVolt[I] then
      Letezo := false;
end; { CHVizsgalat }

procedure AromasE;
begin
  Aromas := false;
  I := 1;
  repeat
  Inc(I);
    J := 0;
    repeat
      Inc(J);
      Aromas := CHMatrix[I, J] = 3;
    until Aromas or (J = I - 1);
  until Aromas or (I = AtomSzam);
end; { AromasE }

procedure TelitetlenE;
begin
  Telitetlen := false;
  I := 1;
  repeat
  Inc(I);
    J := 0;
    repeat
      Inc(J);
      Telitetlen := CHMatrix[I, J] in [4, 6];
    until Telitetlen or (J = I - 1);
  until Telitetlen or (I = AtomSzam);
end; { TelitetlenE }

begin { Program }
  ClrScr;
  WriteLn('S Z E N H I D R O G E N - V I Z S G A L O   P R O G R A M');
  WriteLn('(c) Copyright: 1991. T¢th B lint, Berzsenyi Daniel Gimnazium');
  WriteLn;
  CHBeKeres;                            { Megadott szenhidrogen }
{ WriteLn('A sztirolt vizsgalom.');
  CHMatrix := Sztirol; AtomSzam := 16; }   { Sztirol vizsgalata }
{ CHMatrix := Proba1;  AtomSzam := 12; }    { Proba1 vizsgalata }
{ CHMatrix := Proba2;  AtomSzam := 7;  }    { Proba2 vizsgalata }
  CHSzamlalas;
  if Letezo then
    if SzenSzam > 0 then
      if Hidrogenszam > 0 then
      begin
        CHVizsgalat;
        if Letezo then
        begin
          WriteLn('Letezik ilyen szenhidrogen.');
          WriteLn('Szenatomok szama: ', SzenSzam);
          WriteLn('Hidrogenatomok szama: ', HidrogenSzam);
          if Gyurus then
          begin
            WriteLn('Gyurus.');
            WriteLn('A gyuruben szereplo vagy  azokat osszekoto atomok:');
            for I := 1 to AtomSzam do
              if GyuruTag[I] then
                Write(I : 3, ',');
            WriteLn;
            AromasE;
            if Aromas then
              WriteLn('Aromas.');
          end { if Gyurus }
          else
          begin
            WriteLn('Nem gyurus.');
            Aromas := false;
          end; { else }
          if not Aromas then
          begin
            TelitetlenE;
            if Telitetlen then
              WriteLn('Telitetlen.')
            else
              WriteLn('Telitett.');
          end; { if not Aromas }
        end { if Letezo }
        else
          WriteLn('Nem osszefuggo molekula.');
      end { if HidrogenSzam }
      else
        WriteLn('Ebben nincs hidrogen.')
    else
      WriteLn('Ebben nincs szen.')
  else
    WriteLn('Nem letezik ilyen szenhidrogen, mert a(z) ', I,
            '. atom kotesszama ', K div 2, '.', (K mod 2) * 5);
  repeat
  until KeyPressed;
end. { Program }