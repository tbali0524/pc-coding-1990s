{***********************************************}
{                                               }
{        S T E F I   - gr fprogram              }
{               1.0c verzi¢                     }
{                                               }
{   Copyright (c) 1995,96,2001 by T¢th B lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0        }
{                                               }
{***********************************************}

{ Grafalgoritmusok }
unit GrafAlg;

{$B-}

interface

uses GrStrukt;

procedure SzamitEl(G: PGraf);
procedure SzamitIncM(G: PGraf);
procedure SzamitKomp(G: PGraf);
procedure SzamitFokLista(G: PGraf);
procedure SzamitEulerUt(G: PGraf);
procedure SzamitPruferKod(G: PGraf);
procedure SzamitMinTav(G: PGraf);
procedure SzamitExcentritas(G: PGraf);
procedure SzamitMinFeszitoFa(G: PGraf);
procedure SzamitTopRendezes(G: PGraf);
procedure SzamitErosKomp(G: PGraf);
procedure SzamitKorM(G: PGraf);

{ ========================================================================== }
implementation
{ ========================================================================== }

{ Elek szamanak kiszamitasa }
{  Be: AdjM }
{  Ki: El }
procedure SzamitEl(G: PGraf);
var
  I, J: Integer;
begin
  with G^ do
  begin
    El := 0;
    for I := 1 to Cs do
      for J := 1 to Cs do
        if AdjM^[I, J] <> 0 then
          Inc(El);
    if not Iranyitott then
      El := El div 2;
  end; { with }
end; { SzamitEl }

{ ========================================================================== }

{ Incidenciamatrix kiszamitasa }
{  Be: AdjM }
{  Ki: IncM, El }
procedure SzamitIncM(G: PGraf);
var
  I, J: Integer;
begin
  with G^ do
  begin
    El := 0;
    if Cs > 0 then
    begin
      if IncM = Nil then
        New(IncM);
      for I := 1 to MaxCsucs do
        for J := 1 to MaxEl do
          IncM^[I, J] := 0;
      if Iranyitott then
      begin
        for I := 1 to Cs do
          for J := 1 to Cs do
            if AdjM^[I, J] <> 0 then
            begin
              Inc(El);
              IncM^[I, El] := -1;
              IncM^[J, El] := 1;
            end;
      end { if Iranyitott }
      else
        for I := 1 to Cs do
          for J := I + 1 to Cs do
            if AdjM^[I, J] <> 0 then
            begin
              Inc(El);
              IncM^[I, El] := 1;
              IncM^[J, El] := 1;
            end;
    end { if Cs > 0 }
  end; { with }
end; { SzamitIncM }

{ ========================================================================== }

{ Komponensek kiszamitasa }
{  Be: AdjM }
{  Ki: Komp, KompLista }
procedure SzamitKomp(G: PGraf);

  procedure BejarKomp(Csucs: Integer);          { melysegi bejaras }
  var
    I: Integer;
  begin
    with G^ do
    begin
      KompLista^[Csucs] := Komp;
      for I := 1 to Cs do
        if ((AdjM^[Csucs, I] > 0) or (AdjM^[I, Csucs] > 0))
            and (KompLista^[I] <> Komp) then
          BejarKomp(I);
    end; { with }
  end; { BejarKomp }

var
  I: Integer;
begin { SzamitKomp }
  with G^ do
  begin
    Komp := 0;
    if Cs > 0 then
    begin
      if KompLista = Nil then
        New(KompLista);
      for I := 1 to Cs do
        KompLista^[I] := 0;
      for I := 1 to Cs do
        if KompLista^[I] = 0 then
        begin
          Inc(Komp);
          BejarKomp(I);
        end;
    end; { if Cs > 0 }
  end; { with }
end; { SzamitKomp }

{ ========================================================================== }

{ Fokszamok kiszamitasa }
{  Be: AdjM }
{  Ki: KiFokLista, BeFokLista }
procedure SzamitFokLista(G: PGraf);
var
  I, J: Integer;
begin
  with G^ do
    if Cs > 0 then
    begin
      if KiFokLista = Nil then
        New(KiFokLista);
      if BeFokLista = Nil then
        New(BeFokLista);
      for I := 1 to Cs do
      begin
        KiFokLista^[I] := 0;
        BeFokLista^[I] := 0;
      end;
      for I := 1 to Cs do
        for J := 1 to Cs do
          if AdjM^[I, J] > 0 then
          begin
            Inc(KiFokLista^[I]);
            Inc(BeFokLista^[J]);
          end;
    end; { if Cs }
end; { SzamitFokLista }

{ ========================================================================== }

{ Euler bejaras szamitasa }
{  Be: AdjM, BefokLista, KifokLista, Komp, El }
{  Ki: EulerUt, VanEulerUt, VanEulerKor }
procedure SzamitEulerUt(G: PGraf);
var
  I, J: Integer;
  Start: Integer;
  Last: Integer;
  WAdjM: TAdjMatrix;
  AktCs: Integer;
  AktEl: Integer;
begin
  with G^ do
  begin
    if Komp = NemIsm then
      SzamitKomp(G);
    VanEulerKor := Hamis;
    if Komp <> 1 then
      VanEulerUt := Hamis
    else
    begin
      if (KiFokLista = Nil) or (BeFokLista = Nil) then
        SzamitFokLista(G);
      Start := 0;
      Last := 0;
      VanEulerUt := Igaz;
      I := 1;
      while (I <= Cs) and (VanEulerUt <> Hamis) do
      begin
        if Iranyitott then
        begin
          if (KiFokLista^[I] mod 2) <> 0 then
            if Start = 0 then
              Start := I
            else if Last = 0 then
              Last := I
            else
              VanEulerUt := Hamis;
        end
        else
          case (KiFokLista^[I] - BeFokLista^[I]) of
            1:  if Start = 0 then
                  Start := I
                else
                  VanEulerUt := Hamis;
            -1: if Last = 0 then
                  Last := I
                else
                  VanEulerUt := Hamis;
            0:  ;
            else
              VanEulerUt := Hamis;
          end; { case }
        Inc(I);
      end; { while }
      if (VanEulerUt = Igaz) then
        if (Start = 0) or (Last = 0) then
        begin
          VanEulerUt := Hamis;
          if (Start = 0) and (Last = 0) then
          begin
            VanEulerKor := Igaz;
            Start := 1;
          end;
        end;
      if (VanEulerUt = Igaz) or (VanEulerKor = Igaz) then
      begin
        if El = NemIsm then
          SzamitEl(G);
        if EulerUt = Nil then
          New(EulerUt);
        for I := 1 to El + 1 do
          EulerUt^[I] := 0;
        for I := 1 to Cs do
          for J := 1 to Cs do
            WAdjM[I, J] := AdjM^[I, J];
        EulerUt^[1] := Start;
        AktEl := 0;
        AktCs := Start;
(*        while AktEl < El do
        begin
          J := 1;
          while (J <= Cs) and (WAdjM[AktCs, J] = 0) do
            Inc(J);
          if WAdjM[AktCs, J] <> 0 then
          begin
            WAdjM[AktCs, J] := 0;
            Inc(AktEl);
            EulerUt^[AktEl + 1] := J;
            AktCs := J;
          end
          else if (AktEl <> El) then
          begin

          end;

        end; { while }
*)      end; { if VanEulerUt }
    end; { if Komp = 1 else }
  end; { with }
end; { SzamitEulerUt }

{ ========================================================================== }

{ Prufer-kod meghatarozasa }
{  Be: AdjM, Komp, El }
{  Ki: PruferKod }
procedure SzamitPruferKod(G: PGraf);
var
  I, J, K, L: Integer;
  FokSz: Integer;
  WAdjM: TAdjMatrix;
begin
  with G^ do
    if (not Iranyitott) and (Cs > 1) then
    begin
      if El = NemIsm then
        SzamitEl(G);
      if Komp = NemIsm then
        SzamitKomp(G);
      if (Komp = 1) and (El = (Cs - 1)) then
      begin
        if PruferKod = Nil then
          New(PruferKod);
        for I := 1 to Cs do
          for J := 1 to Cs do
            WAdjM[I, J] := AdjM^[I, J];
        for L := 1 to Cs - 1 do
        begin
          I := 0;
          repeat
            Inc(I);
            FokSz := 0;
            for K := 1 to Cs do
              if WAdjM[I, K] <> 0 then
              begin
                J := K;
                Inc(FokSz);
              end;
          until (FokSz = 1);
          WAdjM[I, J] := 0;
          WAdjM[J, I] := 0;
          PruferKod^[L] := J;
        end; { for }
      end; { if Komp }
    end; { if not Iranyitott }
end; { SzamitPruferKod }

{ ========================================================================== }

{ Minimalis koltsegu utak kiszamitasa Floyd modszerrel }
{  Be: AdjM, ElSuly }
{  Ki: MinTav, MinUtKozepso }
procedure SzamitMinTav(G: PGraf);
var
  I, J, K: Integer;
begin
  with G^ do
    if (ElSuly <> Nil) and (Cs > 0) then
    begin
      if MinTav = Nil then
        New(MinTav);
      if MinUtKozepso = Nil then
        New(MinUtKozepso);
      for I := 1 to Cs do
        for J := 1 to Cs do
        begin
          if AdjM^[I, J] <> 0 then
            MinTav^[I, J] := ElSuly^[I, J]
          else if I = J then
            MinTav^[I, J] := 0
          else
            MinTav^[I, J] := MaxSuly;
          MinUtKozepso^[I, J] := 0;
        end;
      for K := 1 to Cs do
        for I := 1 to Cs do
          for J := 1 to Cs do
            if MinTav^[I, J] > (MinTav^[I, K] + MinTav^[K, J]) then
            begin
              MinTav^[I, J] := MinTav^[I, K] + MinTav^[K, J];
              MinUtKozepso^[I, J] := K;
            end;
      for I := 1 to Cs do
        MinTav^[I, I] := MaxSuly;
    end; { if ElSuly }
end; { SzamitMinTav }

{ ========================================================================== }

{ Excentritasok es centrum kiszamitasa }
{  Be: MinTav, ElSuly }
{  Ki: Excentritas, Centrum }
procedure SzamitExcentritas(G: PGraf);
var
  I, J, K: Integer;
begin
  with G^ do
    if ElSuly <> Nil then
    begin
      if MinTav = Nil then
        SzamitMinTav(G);
      if Excentritas = Nil then
        New(Excentritas);
      for I := 1 to Cs do
      begin
        Excentritas^[I] := -MaxSuly;
        for J := 1 to Cs do
          if (I <> J) and (Excentritas^[I] < MinTav^[J, I]) then
            Excentritas^[I] := MinTav^[J, I];
      end;
      Centrum := 1;
      for I := 2 to Cs do
        if Excentritas^[I] < Excentritas^[Centrum] then
          Centrum := I;
      if (Cs = 0) or (Excentritas^[Centrum] = MaxSuly) then
        Centrum := NemIsm;
    end; { if ElSuly }
end; { SzamitExcentritas }

{ ========================================================================== }

{ Minimalis koltsegu feszitofa kiszamitasa Prim modszerrel }
{  Be: AdjM, ElSuly, Komp }
{  Ki: MinFeszitoFa, MinFeszFaKoltseg }
procedure SzamitMinFeszitoFa(G: PGraf);
var
  Kozel: TCsucsLista;
  MinSuly: TCsucsLista;
  U: Array[1..MaxCsucs] of Boolean;
  CsSzam: Integer;
  I, J: Integer;
begin
  with G^ do
    if (not Iranyitott) and (ElSuly <> Nil) and (Cs > 0) then
    begin
      if Komp = NemIsm then
        SzamitKomp(G);
      if Komp = 1 then
      begin
        if MinFeszitoFa = Nil then
          New(MinFeszitoFa);
        for I := 1 to Cs do
          for J := 1 to Cs do
            MinFeszitoFa^[I, J] := 0;
        U[1] := True;
        Kozel[1] := MaxSuly;
        MinSuly[1] := MaxSuly;
        for I := 2 to Cs do
        begin
          U[I] := False;
          Kozel[I] := 1;
          if AdjM^[I, 1] <> 0 then
            MinSuly[I] := ElSuly^[I, 1]
          else
            MinSuly[I] := MaxSuly;
        end;
        MinFeszFaKoltseg := 0;
        CsSzam := 1;
        while CsSzam < Cs do
        begin
          J := 1;
          for I := 2 to Cs do
            if MinSuly[I] < MinSuly[J] then
              J := I;
          MinFeszitoFa^[Kozel[J], J] := 1;
          MinFeszitoFa^[J, Kozel[J]] := 1;
          Inc(MinFeszFaKoltseg, ElSuly^[Kozel[J], J]);
          if not U[J] then
          begin
            Inc(CsSzam);
            U[J] := True;
          end;
          Kozel[J] := MaxSuly;
          MinSuly[J] := MaxSuly;
          for I := 1 to Cs do
            if (not U[I]) and (Kozel[I] <> MaxSuly)
              and (AdjM^[J, I] <> 0) and (ElSuly^[J, I] <= MinSuly[I]) then
            begin
              Kozel[I] := J;
              MinSuly[I] := ElSuly^[J, I];
            end;
        end; { while }
      end; { if Komp }
    end; { if Iranyitott }
end; { SzamitMinFeszitoFa }

{ ========================================================================== }

{ DAG topologikus rendezese }
{  Be: AdjM }
{  Ki: TopRendezes, DAG }
procedure SzamitTopRendezes(G: PGraf);
var
  MSzam: TCsucsLista;
  Szam: Integer;
  Jelol: Array[1..MaxCsucs] of Boolean;
  TopRendSzam: Integer;

  procedure BejarKomp(Csucs: Integer);          { melysegi bejaras }
  var
    I: Integer;
  begin
    Inc(Szam);
    MSzam[Csucs] := Szam;
    for I := 1 to G^.Cs do
      if G^.AdjM^[Csucs, I] <> 0 then
      begin
        if (MSzam[I] <> 0) and (MSzam[I] < MSzam[Csucs])
            and (not Jelol[I]) then
          G^.DAG := Hamis                       { visszael }
        else if MSzam[I] = 0 then
          BejarKomp(I);
      end;
    Jelol[Csucs] := True;
    Inc(TopRendSzam);
    G^.TopRendezes^[TopRendSzam] := Csucs;
  end; { BejarKomp }

var
  I: Integer;
begin { SzamitTopRendezes }
  with G^ do
  begin
    if Iranyitott then
      DAG := Igaz
    else
      DAG := Hamis;
    if Cs > 0 then
    begin
      if TopRendezes = Nil then
        New(TopRendezes);
      for I := 1 to Cs do
      begin
        MSzam[I] := 0;
        Jelol[I] := False;
      end;
      Szam := 0;
      TopRendSzam := 0;
      for I := 1 to Cs do
        if MSzam[I] = 0 then
          BejarKomp(I);
    end; { if Cs > 0 }
  end; { with }
end; { SzamitTopRendezes }

{ ========================================================================== }

{ Erosen osszefuggo komponensek kiszamitasa }
{  Be: TopRendezes }
{  Ki: ErosKompLista, ErosKomp }
procedure SzamitErosKomp(G: PGraf);
var
  WAdjM: TAdjMatrix;

  procedure BejarKomp(Csucs: Integer);          { melysegi bejaras }
  var
    I: Integer;
  begin
    with G^ do
    begin
      ErosKompLista^[Csucs] := ErosKomp;
      for I := 1 to Cs do
        if ((WAdjM[Csucs, I] > 0) and (ErosKompLista^[I] = 0)) then
          BejarKomp(I);
    end; { with }
  end; { BejarKomp }

var
  I, J: Integer;
begin { SzamitErosKomp }
  with G^ do
    if Iranyitott then
    begin
      ErosKomp := 0;
      if Cs > 0 then
      begin
        if ErosKompLista = Nil then
          New(ErosKompLista);
        if TopRendezes = Nil then
          SzamitTopRendezes(G);
        for I := 1 to Cs do
          for J := 1 to Cs do
            WAdjM[I, J] := AdjM^[J, I];
        for I := 1 to Cs do
          ErosKompLista^[I] := 0;
        for I := Cs downto 1 do
          if ErosKompLista^[TopRendezes^[I]] = 0 then
          begin
            Inc(ErosKomp);
            BejarKomp(TopRendezes^[I]);
          end;
      end; { if Cs > 0 }
    end; { if Iranyitott }
end; { SzamitErosKomp }

{ ========================================================================== }

{ Korok kiszamitasa }
{  Be: AdjM }
{  Ki: KorM, Kor }
{    meghivja SzamitKomp-ot is }
procedure SzamitKorM(G: PGraf);

  function KorEgyezes(var UjKor: TCsucsLista; KorSzam: Integer): Boolean;
    { Seged fuggveny: UjKor-t osszehasonlitja KorM KorSzam-adik soraval }
  var
    I: Integer;
  begin
    I := 1;
    while (I < MaxCsucs) and (Abs(UjKor[I]) = Abs(G^.KorM^[KorSzam, I]))
        and (UjKor[I] <> 0) do
      Inc(I);
    KorEgyezes := (Abs(UjKor[I]) = Abs(G^.KorM^[KorSzam, I]));
  end; { KorEgyezes }

  procedure BejarKomp(Csucs: Integer; CsLista: TCsucsLista; CsListaH: Integer);
    { Melysegi bejaras, rekurziv eljaras }
  var
    I, J, K, L, N: Integer;
    B: Boolean;
    C: Integer;
    CsL: TCsucsLista;
    H: Integer;
    UjKor: TCsucsLista;

    procedure KorVizsg;
      { Segedfuggveny, csak hogy ne szerepeljen 2x a kod }
    var
       M: Integer;
    begin
       { L szerint megy a ciklus UjKor hosszara }
       { a kor barmely csucsanal kezdodhet, megis meg kell talalnunk }
       L := 1;
       while (not B) and (L <= H - J + 1) do
       begin
         { K szerint megy a ciklus az eddigi korok szamara }
         { minden eddigi korrel osszehasonlitunk }
         K := 1;
         while (not B) and (K <= G^.Kor) do
         begin
           if KorEgyezes(UjKor, K) then
             B := True;
           Inc(K);
         end; { while K }
         { Most ciklikusan gorgetunk UjKoron a kovetkezo teszthez }
         N := UjKor[1];
         for M := 1 to H - J do
            UjKor[M] := UjKor[M + 1];
         UjKor[H - J + 1] := N;
         Inc(L);
       end; { while L }
    end; { KorVizsg }

  begin { BejarKomp }
    with G^ do
    begin
      CsL := CsLista;
      H := CsListaH;
      Inc(H);
      CsL[H] := Csucs;
      C := Abs(Csucs);
      for I := 1 to Cs do
        if Kor < MaxKor then
          if ((AdjM^[C, I] > 0) or (AdjM^[I, C] > 0)) then
            { C-bol I-be megy el }
          begin
            { megnezzuk I benne van mar az eddig bejart csucsok kozott }
            J := 1;
            while (J < (H - 1)) and (Abs(CsL[J]) <> I) do
              Inc(J);
            if (J < (H - 1)) and (Abs(CsL[J]) = I) then
              { Kort talaltunk csak meg nem biztos hogy uj }
            begin
              { Kimasoljuk a kor csucsait CsL megfelelo reszerol }
              for K := J to H do
                UjKor[K - J + 1] := CsL[K];
              K := H - J + 2;
              while K <= MaxCsucs do
              begin
                UjKor[K] := 0;
                Inc(K);
              end;
              { Most teszteljuk, hogy ez a kor nem volt-e mas kezdettel (B) }
              B := False;
              { UjKor-t keresi KorMatrixban, barmelyik csucsnal is kezdodik }
              KorVizsg;
              { De a forditott koruljarast nem talalja meg, azt kulon nezzuk }
              if not B then
              begin
                { helyben megforditjuk UjKor-t }
                for K := 1 to (H - J + 1) div 2 do
                begin
                  N := UjKor[K];
                  UjKor[K] := UjKor[H - J + 2 - K];
                  UjKor[H - J + 2 - K] := N;
                end; { for K }
                { UjKor-t keresi KorMatrixban, barmelyik csucsnal is kezdodik }
                KorVizsg;
              end; { if not B }
              if not B then
                { most mar tenyleg uj kor, elmenthetjuk KorM kovetkezo soraba }
              begin
                if Kor < MaxKor then
                  Inc(Kor);
                for K := J to H do
                  KorM^[Kor, K - J + 1] := CsL[K];
              end { if not B }
            end { if J }
            else if (H = 1) or ((I <> Abs(CsL[H - 1])) and (I <> C)) then
              { Nincs kor es az uj el nem is az elozo el vissza, tehat bejarjuk }
            begin
              if (AdjM^[C, I] > 0) then
                BejarKomp(I, CsL, H)
              else
                BejarKomp(-I, CsL, H);
            end;
          end; { if AdjM }
    end; { with }
  end; { BejarKomp }

var
  I, J, K: Integer;
  CsL: TCsucsLista;
begin { SzamitKorM }
  with G^ do
  begin
    if Cs > 0 then
    begin
      Kor := 0;
      if KorM = Nil then
        New(KorM);
      for I := 1 to MaxKor do
        for J := 1 to MaxEl do
          KorM^[I, J] := 0;
      { ezutan osszefuggo grafra eleg lenne egy BejarKomp(1) hivas,
        de mi minden komponensre elinditjuk egyszer a bejarast }
      if KompLista = Nil then
         SzamitKomp(G);
      for I := 1 to Cs do
      begin
        K := KompLista^[I];
        if K <> 0 then
        begin
          for J := I to Cs do
            if KompLista^[J] = K then
              KompLista^[J] := 0;
          for J := 1 to MaxCsucs do
            CsL[J] := 0;
          BejarKomp(I, CsL, 0);
        end; { if K <> 0 }
      end; { for I }
        { menet kozben elrontottuk KompListat, ezert vissza kell allitani: }
      SzamitKomp(G);
    end; { if Cs > 0 }
  end; { with }
end; { SzamitKorM }

{ ========================================================================== }

end.
