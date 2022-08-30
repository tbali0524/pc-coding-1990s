{******************************************}
{                                          }
{        S T E F I   - gr fprogram         }
{                                          }
{   Copyright (c) 1995,96 by T¢th B lint   }
{           Borland Pascal 7.0             }
{                                          }
{******************************************}

{ Graf szerkeszto }
unit GrSzerk;

{$B-,X+}

interface

uses GrStrukt;

const
 { ReadKey kodok }
  kbLeft  = #75;        { #0 ut n }
  kbRight = #77;
  kbUp    = #72;
  kbDown  = #80;
  kbHome  = #71;
  kbEnd   = #79;
  kbPgUp = #73;
  kbPgDn = #81;
  kbCtrlLeft  = #115;
  kbCtrlRight = #116;
  kbCtrlHome  = #119;
  kbIns = #82;
  kbDel = #83;
  kbShiftTab = #15;
  kbAltC = #46;
  kbAltE = #18;
  kbAltG = #34;
  kbAltH = #35;
  kbAltI = #23;
  kbAltP = #25;
  kbAltT = #20;
  kbAltU = #22;
  kbBackSpace = #8;     { els“ ReadKey-re }
  kbTab   = #9;
  kbEnter = #13;
  kbEsc   = #27;

 { szerkeszto terulet helyzete }
  SzStartX = 175;
  SzStartY = 4;
  SzMeretX = 460;
  SzMeretY = 471;

{ ========================================================================== }

procedure RajzolGraf(G: PGraf; PirosCs, LilaCs: Integer; LilaEl: PAdjMatrix);
procedure ElhelyezGraf(G: PGraf);
procedure Szerk(G: PGraf);

{ ========================================================================== }
implementation
{ ========================================================================== }

uses Crt, Graph;

{ Graf kirajzolasa }
{  LilaCs csucs lila, PirosCs csucs piros, a tobbi feher }
{  LilaCs -> PirosCs el piros, }
{  LilaEl-ben adjacenciamatrixszal adott elek lilak, a tobbi cian }
procedure RajzolGraf(G: PGraf; PirosCs, LilaCs: Integer; LilaEl: PAdjMatrix);

var
  A, B, D: Integer;
  C: Real;
  S: String;

  { El kirajzolasa }
  procedure ElRajz(I, J: Integer; VisszaIs: Boolean);

    { Iranyjelzo rajzolasa elre }
    procedure Nyilhegy;
    begin
      MoveTo(A + Round(10 * Cos(C - 0.8 * Pi)),
             B + Round(10 * Sin(C - 0.8 * Pi)));
      LineTo(A, B);
      LineTo(A + Round(10 * Cos(C + 0.8 * Pi)),
             B + Round(10 * Sin(C + 0.8 * Pi)));
    end; { Nyilhegy }

  begin { ElRajz }
    with G^ do
    begin
      Line(XPoz^[I], YPoz^[I], XPoz^[J], YPoz^[J]);
      if Iranyitott then
      begin
        A := XPoz^[J] - XPoz^[I];
        B := YPoz^[J] - YPoz^[I];
        if A > 0 then
          C := ArcTan(B / A)
        else if A < 0 then
            C := ArcTan(B / A) + Pi
        else { A = 0 }
          if B > 0 then
            C := Pi / 2
          else
            C := -Pi / 2;
        A := (XPoz^[I] + XPoz^[J]) div 2;
        B := (YPoz^[I] + YPoz^[J]) div 2;
        if AdjM^[I, J] > 0 then
          Nyilhegy;
        if VisszaIs and (AdjM^[J, I] > 0) then
        begin
          C := C + Pi;
          Nyilhegy;
        end;
        if ElSuly <> Nil then
        begin
          if I < J then
            D := TextHeight('M') + 4
          else
            D := -4;
          if AdjM^[I, J] > 0 then
          begin
            Str(ElSuly^[I, J], S);
            OutTextXY(A, B - D, S);
          end;
          if VisszaIs and (AdjM^[J, I] > 0) then
          begin
            Str(ElSuly^[J, I], S);
            OutTextXY(A, B + D - TextHeight('M'), S);
          end;
        end; { if ElSuly }
      end { if Iranyitott }
      else
        if ElSuly <> Nil then
        begin
          Str(ElSuly^[I, J], S);
          OutTextXY((XPoz^[I] + XPoz^[J]) div 2,
            (YPoz^[I] + YPoz^[J]) div 2 + 4, S);
        end;
    end; { with }
  end; { ElRajz }

  { Csucs kirajzolasa }
  procedure CsucsRajz(I: Integer);
  begin
    with G^ do
    begin
      Bar(XPoz^[I] - 2, YPoz^[I] - 2, XPoz^[I] + 2, YPoz^[I] + 2);
      OutTextXY(XPoz^[I] - TextWidth('M') - 4,
        YPoz^[I] - TextHeight('M') - 4, Betu(I));
      if CsucsSuly <> Nil then
      begin
        Str(CsucsSuly^[I], S);
        OutTextXY(XPoz^[I] + 4, YPoz^[I] + 4, S);
      end;
    end;
  end; { CsucsRajz }

var
  RegiTS: TextSettingsType;
  RegiFS: FillSettingsType;
  I, J: Integer;
begin { RajzolGraf }
  SetViewPort(SzStartX, SzStartY, SzStartX + SzMeretX, SzStartY + SzMeretY,
    ClipOn);
  ClearViewPort;
  GetTextSettings(RegiTS);
  GetFillSettings(RegiFS);
  with G^ do
  begin
   { Elek kirajzolasa }
    SetTextJustify(CenterText, TopText);
    SetColor(3);
    for I := 1 to Cs do
      for J := I + 1 to Cs do
        if (AdjM^[I, J] <> 0) or (AdjM^[J, I] <> 0) then
          ElRajz(I, J, True);
    if LilaEl <> Nil then
    begin
      SetColor(5);
      for I := 1 to Cs do
        for J := 1 to Cs do
          if LilaEl^[I, J] <> 0 then
            ElRajz(I, J, False);
    end;
    if (LilaCs > 0) and (PirosCs > 0) and (AdjM^[LilaCs, PirosCs] <> 0) then
    begin
      SetColor(4);
      ElRajz(LilaCs, PirosCs, False);
    end;
   { Csucsok kirajzolasa }
    SetTextJustify(LeftText, TopText);
    SetFillStyle(SolidFill, 7);
    SetColor(7);
    for I := 1 to Cs do
      CsucsRajz(I);
    if (PirosCs > 0) and (PirosCs <= Cs) then
    begin
      SetFillStyle(SolidFill, 4);
      SetColor(4);
      CsucsRajz(PirosCs);
    end;
    if (LilaCs > 0) and (LilaCs <= Cs) then
    begin
      SetFillStyle(SolidFill, 5);
      SetColor(5);
      CsucsRajz(LilaCs);
    end;
  end; { with }
  SetTextJustify(RegiTS.Horiz, RegiTS.Vert);
  SetFillStyle(RegiFS.Pattern, RegiFS.Color);
end; { RajzolGraf }

{ ========================================================================== }

{ Grafcsucsok elhelyezese egysegkoron }
procedure ElhelyezGraf(G: PGraf);
var
  I: Integer;
begin
  with G^ do
  begin
    if XPoz = Nil then
      New(XPoz);
    if YPoz = Nil then
      New(YPoz);
    for I := 1 to Cs do
    begin
      XPoz^[I] := SzMeretX div 2
                   + Round((SzMeretY / 2 - 25) * Cos(2 * I * Pi / Cs));
      YPoz^[I] := SzMeretY div 2
                   + Round((SzMeretY / 2 - 25) * Sin(2 * I * Pi / Cs));
    end;
  end; { with }
end; { ElhelyezGraf }

{ ========================================================================== }
{ Graf szerkeszto }
{ ========================================================================== }

{ Billentyuk felsorolasa }
procedure Help;
var
  I:Integer;

  { Sztring kiiras }
  procedure WriteOut(const S: String);
  begin
    OutTextXY(5, I, S);
    Inc(I, TextHeight('M') + 3);
  end; { WriteOut }

begin
  Rectangle(0, 0, SzStartX - 6, SzStartY + SzMeretY + 4);
  MoveTo(2,10);
  I := 10;
  WriteOut('     S T E F I ');
  WriteOut('');
  WriteOut('');
{$IFDEF ENGLISH }
  WriteOut('(c) B lint T¢th,1995');
  WriteOut('');
  WriteOut('====================');
  WriteOut('');
  WriteOut('    GRAPH EDITOR');
  WriteOut('');
  WriteOut('Cursor moving:');
  WriteOut(' - Arrows,');
  WriteOut(' - Ctrl ® ¯, PgUp/Dn');
  WriteOut('   (greater steps)');
  WriteOut(' - Ctrl Home (center)');
  WriteOut(' - Home (nearest n.)');
  WriteOut(' - End (current node)');
  WriteOut(' - Tab, Shift Tab');
  WriteOut('  (next/prev node)');
  WriteOut('');
  WriteOut('Other commands:');
  WriteOut('');
  WriteOut('Enter: current node');
  WriteOut('      (red) follows');
  WriteOut('       the cursor');
  WriteOut('Ins : new node');
  WriteOut('Del : delete node');
  WriteOut('C   : node weight');
  WriteOut('S   : edge start');
  WriteOut('       (purple)');
  WriteOut('SPC : edge set/clr');
  WriteOut('F   : edge direct.');
  WriteOut('E   : edge weight');
  WriteOut('AltU: delete edge');
  WriteOut('AltG: delete graph');
  WriteOut('AltT: full graph');
  WriteOut('AltP: place on side');
  WriteOut('AltH: place circle');
  WriteOut('AltI: directed gr.');
  WriteOut('AltC: node w. off');
  WriteOut('AltE: edge w. off');
  WriteOut('Esc : exit editor');
{$ELSE}
  WriteOut('(c) T¢th B lint,1995');
  WriteOut('');
  WriteOut('====================');
  WriteOut('');
  WriteOut('   GRFSZERKESZT™');
  WriteOut('');
  WriteOut('Kurzormozgat s:');
  WriteOut(' - Nyilak,');
  WriteOut(' - Ctrl ® ¯, PgUp/Dn');
  WriteOut('   (nagyobb l‚p‚sek)');
  WriteOut(' - Ctrl Home (k”z‚p)');
  WriteOut(' - Home (k”zeli cs.)');
  WriteOut(' - End (akt. cs£cs)');
  WriteOut(' - Tab, Shift Tab');
  WriteOut('  (k”v./el“z“ cs£cs)');
  WriteOut('');
  WriteOut('Egy‚b billenty–k:');
  WriteOut('');
  WriteOut('Enter: akt. cs£cs');
  WriteOut('      (piros) k”veti');
  WriteOut('       a kurzort');
  WriteOut('Ins : £j cs£cs');
  WriteOut('Del : cs£cs t”rl‚se');
  WriteOut('C   : cs£css£ly');
  WriteOut('S   : ‚l kezd“pont');
  WriteOut('       (lila)');
  WriteOut('SPC : ‚l h£z s/t”rl');
  WriteOut('F   : ‚l ir ny¡t s');
  WriteOut('E   : ‚ls£ly megad s');
  WriteOut('AltU: ‚lek t”rl‚se');
  WriteOut('AltG: gr f t”rl‚se');
  WriteOut('AltT: teljes gr f');
  WriteOut('AltP: p ros gr f');
  WriteOut('AltH: gr f elhely.');
  WriteOut('AltI: ir ny¡tott g.');
  WriteOut('AltC: cs£css£ly ki');
  WriteOut('AltE: ‚ls£ly ki');
  WriteOut('Esc : kil‚p‚s');
{$ENDIF}
end; { Help }

{ ========================================================================== }

{ Csucs vagy elsuly bekerese }
procedure BekerSuly(var Suly: Integer; const Title: String);
const
  AblX = 120;                            { ablak X meretenek fele }
var
  RegiTS: TextSettingsType;
  RegiFS: FillSettingsType;
  Inp: Integer;
  S: String;
  B: Char;
begin
  SetViewPort(SzStartX + SzMeretX div 2 - AblX, SzStartY + SzMeretY div 2 - 25,
    SzStartX + SzMeretX div 2 + AblX, SzStartY + SzMeretY div 2 + 25, ClipOn);
  ClearViewPort;
  GetTextSettings(RegiTS);
  GetFillSettings(RegiFS);
  SetTextJustify(CenterText, TopText);
  SetFillStyle(EmptyFill, 15);
  SetColor(15);
  Rectangle(0, 0, AblX * 2, 50);
  OutTextXY(AblX, 6, Title);
  Inp := Suly;
  repeat
    Bar(1, 10 + TextHeight('M'),  AblX * 2 - 2, 49);
    Str(Inp, S);
    OutTextXY(AblX, 15 + TextHeight('M'), S);
    B := ReadKey;
    case B of
      #0:          ReadKey;
      kbBackSpace: Inp := Inp div 10;
      '-':         Inp := -Inp;
      '0'..'9':    if Abs(Inp) < 1000 then
                     Inp := Inp * 10 - Ord('0') + Ord(B);
    end; { case }
  until (B = kbEnter) or (B = kbEsc);
  if B = kbEnter then
    Suly := Inp;
  SetTextJustify(RegiTS.Horiz, RegiTS.Vert);
  SetFillStyle(RegiFS.Pattern, RegiFS.Color);
  SetViewPort(SzStartX, SzStartY, SzStartX + SzMeretX, SzStartY + SzMeretY,
    ClipOn);
end; { BekerSuly }

{ ========================================================================== }

{ Graf szerkeszto }
procedure Szerk(G: PGraf);
var
  I, J: Integer;
  C: Char;
  X, Y: Integer;        { kurzor }
  B: Char;              { lenyomott billentyu }
  Frissit: Boolean;     { kell-e ujrarajzolni a grafot }
  Kovet: Boolean;       { aktualis csucs koveti-e a kurzort }
  AktCs: Integer;       { aktualis csucs }
  StartCs: Integer;     { el kezdopontja }

  { Kurzor kirajzolas/torles }
  procedure Kurzor;
  begin
    SetColor(15);
    SetWriteMode(XORPut);
    Line (X - 5, Y - 5, X + 5, Y + 5);
    Line (X - 5, Y + 5, X + 5, Y - 5);
    SetWriteMode(NormalPut);
  end; { Kurzor }

begin { Szerk }
  with G^ do
  begin
    if AdjM = Nil then
      New(AdjM);
    if XPoz = Nil then
      New(XPoz);
    if YPoz = Nil then
      New(YPoz);
    X := SzMeretX div 2;
    Y := SzMeretY div 2;
    Frissit := True;
    Kovet := False;
    AktCs := 1;
    StartCs := 0;
    SetLineStyle(SolidLn, 0, NormWidth);
    SetTextStyle(DefaultFont, HorizDir, 1);
    SetTextJustify(LeftText, TopText);
    Help;
    Rectangle(SzStartX - 4, SzStartY - 4, SzStartX + SzMeretX + 4,
      SzStartY + SzMeretY + 4);
    SetViewPort(SzStartX, SzStartY, SzStartX + SzMeretX, SzStartY + SzMeretY,
      ClipOn);

    repeat
      if Frissit then
      begin
        RajzolGraf(G, AktCs, StartCs, Nil);
        Frissit := False;
      end;
      Kurzor;
      B := UpCase(ReadKey);
      Kurzor;
      case B of
        #0:  begin
               B := ReadKey;
               case B of
                 kbUp:        Y := Max(Y - 1, 0);
                 kbDown:      Y := Min(Y + 1, SzMeretY);
                 kbLeft:      X := Max(X - 1, 0);
                 kbRight:     X := Min(X + 1, SzMeretX);
                 kbCtrlLeft:  X := Max(X - 20, 0);
                 kbCtrlRight: X := Min(X + 20, SzMeretX);
                 kbPgUp:      Y := Max(Y - 20, 0);
                 kbPgDn:      Y := Min(Y + 20, SzMeretY);
                 kbCtrlHome:            { kurzor a kozeppontba }
                   begin
                     X := SzMeretX div 2;
                     Y := SzMeretY div 2;
                   end;
                 kbHome:                { kurzor a legkozelebbi csucsba }
                   if Cs > 0 then
                   begin
                     AktCs := 1;
                     for I := 2 to Cs do
                       if ((Abs(XPoz^[AktCs] - X) + Abs(YPoz^[AktCs] - Y)))
                           > ((Abs(XPoz^[I] - X) + Abs(YPoz^[I] - Y))) then
                         AktCs := I;
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                     Frissit := True;
                   end; { case kbHome }
                 kbEnd:                 { kurzor az aktualis csucsba }
                   if Cs > 0 then
                   begin
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                   end;
                 kbShiftTab:            { elozo csucs kivalasztasa }
                   if Cs > 0 then
                   begin
                     AktCs := (AktCs + Cs - 2) mod Cs + 1;
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                     Frissit := True;
                   end;
                 kbIns:                 { uj csucs kirakasa }
                   if Cs < MaxCsucs then
                   begin
                     Inc(Cs);
                     for I := 1 to Cs do
                     begin
                       AdjM^[I, Cs] := 0;
                       AdjM^[Cs, I] := 0;
                     end;
                     if CsucsSuly <> Nil then
                       CsucsSuly^[Cs] := 0;
                     if ElSuly <> Nil then
                       for I := 1 to Cs do
                       begin
                         ElSuly^[I, Cs] := 0;
                         ElSuly^[Cs, I] := 0;
                       end;
                     XPoz^[Cs] := X;
                     YPoz^[Cs] := Y;
                     AktCs := Cs;
                     Frissit := True;
                   end; { case kbIns }
                 kbDel:                 { csucs torlese }
                   if Cs > 0 then
                   begin
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                     Dec(Cs);
                     for I := AktCs to Cs do
                       for J := 1 to Cs + 1 do
                         AdjM^[I, J] := AdjM^[I + 1, J];
                     for I := AktCs to Cs do
                       for J := 1 to Cs do
                         AdjM^[J, I] := AdjM^[J, I + 1];
                     for I := AktCs to Cs do
                     begin
                       XPoz^[I] := XPoz^[I + 1];
                       YPoz^[I] := YPoz^[I + 1];
                     end;
                     if CsucsSuly <> Nil then
                       for I := AktCs to Cs do
                         CsucsSuly^[I] := CsucsSuly^[I + 1];
                     if ElSuly <> Nil then
                     begin
                       for I := AktCs to Cs do
                         for J := 1 to Cs + 1 do
                           ElSuly^[I, J] := ElSuly^[I + 1, J];
                       for I := AktCs to Cs do
                         for J := 1 to Cs do
                           ElSuly^[J, I] := ElSuly^[J, I + 1];
                     end;
                     if StartCs > AktCs then
                       Dec(StartCs);
                     if AktCs > Cs then
                       AktCs := 1;
                     Frissit := True;
                   end; { case kbDel }
                 kbAltU:                { osszes el torlese }
                   begin
                     for I := 1 to Cs do
                       for J := 1 to Cs do
                         AdjM^[I, J] := 0;
                     Frissit := True;
                   end;
                 kbAltG:                { graf torlese }
                   begin
                     Cs := 0;
                     StartCs := 0;
                     Frissit := True;
                   end;
                 kbAltT:                { osszes el behuzasa }
                   begin
                     for I := 1 to Cs do
                       for J := I + 1 to Cs do
                       begin
                         AdjM^[I, J] := 1;
                         AdjM^[J, I] := 1;
                       end;
                     Frissit := True;
                   end; { case kbAltT }
                 kbAltP:                { paros graf }
                   if (Cs > 1) and (AktCs > 1) then
                   begin
                     if AktCs > 2 then
                     begin
                       for I := 1 to AktCs - 1 do
                       begin
                         XPoz^[I] := 60;
                         YPoz^[I] := 40 + ((SzMeretY - 80) div (AktCs - 2))
                           * (I - 1);
                       end;
                     end
                     else
                     begin
                       XPoz^[1] := 60;
                       YPoz^[1] := SzMeretY div 2;
                     end;
                     if AktCs < Cs then
                     begin
                       for I := AktCs to Cs do
                       begin
                         XPoz^[I] := SzMeretX - 60;
                         YPoz^[I] := 40 + ((SzMeretY - 80) div (Cs - AktCs))
                           * (I - AktCs);
                       end;
                     end
                     else
                     begin
                       XPoz^[Cs] := SzMeretX - 60;
                       YPoz^[Cs] := SzMeretY div 2;
                     end;
                     for I := 1 to Cs do
                       for J := 1 to Cs do
                         AdjM^[I, J] := 0;
                     for I := 1 to AktCs - 1 do
                       for J := AktCs to Cs do
                         AdjM^[I, J] := 1;
                     if not Iranyitott then
                       for I := 1 to AktCs - 1 do
                         for J := AktCs to Cs do
                           AdjM^[J, I] := 1;
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                     Frissit := True;
                   end; { case kbAltP }
                 kbAltH:                { csucsok elhelyezese koron }
                   if Cs > 0 then
                   begin
                     ElhelyezGraf(G);
                     X := XPoz^[AktCs];
                     Y := YPoz^[AktCs];
                     Frissit := True;
                   end;
                 kbAltI:
                   begin                { iranyitottsag ki/be }
                     Iranyitott := not Iranyitott;
                     if not Iranyitott then
                       for I := 1 to Cs do
                         for J := I + 1 to Cs do
                           if AdjM^[I, J] <> 0 then
                           begin
                             AdjM^[J, I] := 1;
                             if ElSuly <> Nil then
                               ElSuly^[J, I] := ElSuly^[I, J];
                           end
                           else if AdjM^[J, I] <> 0 then
                           begin
                             AdjM^[I, J] := 1;
                             if ElSuly <> Nil then
                               ElSuly^[I, J] := ElSuly^[J, I];
                           end;
                     Frissit := True;
                   end; { case kbAltI }
                 kbAltC:                { csucssulyozas ki }
                   if CsucsSuly <> Nil then
                   begin
                     Dispose(CsucsSuly);
                     CsucsSuly := Nil;
                     Frissit := True;
                   end;
                 kbAltE:                { elsulyozas ki }
                   if ElSuly <> Nil then
                   begin
                     Dispose(ElSuly);
                     ElSuly := Nil;
                     Frissit := True;
                   end;
               end; { case }
               B := #0;
             end; { case #0 }
        kbTab:                          { kovetkezo csucs kivalasztasa }
          if Cs > 0 then
          begin
            AktCs := AktCs mod Cs + 1;
            X := XPoz^[AktCs];
            Y := YPoz^[AktCs];
            Frissit := True;
          end;
        kbEnter:                        { akt. csucs koveti a kurzort ki/be }
          Kovet := not Kovet;
        'C':                            { akt. csucssuly bevitele }
          if Cs > 0 then
          begin
            if CsucsSuly = Nil then
            begin
              New(CsucsSuly);
              for I := 1 to Cs do
                CsucsSuly^[I] := 0;
            end;
            {$IFDEF ENGLISH }
            BekerSuly(CsucsSuly^[AktCs], 'Weight of '
              + Betu(AktCs) + ':');
            {$ELSE }
            BekerSuly(CsucsSuly^[AktCs], 'Adja meg a(z) '
              + Betu(AktCs) + ' cs£cs s£ly t:');
            {$ENDIF}
            Frissit := True;
          end; { case C }
        'E':                            { elsuly bevitele }
          if (Cs > 0) and (StartCs <> 0) and (StartCs <> AktCs)
            and (AdjM^[StartCs, AktCs] > 0) then
          begin
            if ElSuly = Nil then
            begin
              New(ElSuly);
              for I := 1 to Cs do
                for J := 1 to Cs do
                  ElSuly^[I, J] := 0;
            end;
            if Iranyitott then
              C := '¯'
            else
              C := '-';
            {$IFDEF ENGLISH }
            BekerSuly(ElSuly^[StartCs, AktCs], 'Weight of '
              + Betu(StartCs) + C + Betu(AktCs) + ':');
            {$ELSE }
            BekerSuly(ElSuly^[StartCs, AktCs], 'Adja meg a(z) '
              + Betu(StartCs) + C + Betu(AktCs)
              + ' ‚l s£ly t:');
            {$ENDIF}
            if not Iranyitott then
              ElSuly^[AktCs, StartCs] := ElSuly^[StartCs, AktCs];
            Frissit := True;
          end; { case E }
        'S':                            { el kezdopont kijelolese }
          if Cs > 0 then
          begin
            StartCs := AktCs;
            Frissit := True;
          end;
        ' ':                            { uj el kirakasa / regi torlese }
          if (Cs > 0) and (StartCs <> 0) and (StartCs <> AktCs) then
          begin
            if (AdjM^[StartCs, AktCs] + AdjM^[AktCs, StartCs]) = 0 then
            begin
              AdjM^[StartCs, AktCs] := 1;
              AdjM^[AktCs, StartCs] := 1;
            end
            else
            begin
              AdjM^[StartCs, AktCs] := 0;
              AdjM^[AktCs, StartCs] := 0;
            end;
            Frissit := True;
          end; { case SPACE }
        'F':                            { el iranyitas megforditasa }
          if Iranyitott and (Cs > 0) and (StartCs <> 0) and (StartCs <> AktCs)
            then
          begin
            I := AdjM^[StartCs, AktCs] + AdjM^[AktCs, StartCs] * 2;
            if I > 0 then
            begin
              I := I mod 3 + 1;
              AdjM^[StartCs, AktCs] := I mod 2;
              AdjM^[AktCs, StartCs] := I div 2;
              Frissit := True;
            end;
          end; { case F }
      end; { case }
      if Kovet and (Cs > 0) and ((X <> XPoz^[AktCs]) or (Y <> YPoz^[AktCs]))
        then
      begin
        XPoz^[AktCs] := X;
        YPoz^[AktCs] := Y;
        Frissit := True;
      end;
    until B = kbEsc;
    if ElSuly <> Nil then
      for I := 1 to Cs do
        for J := 1 to Cs do
          if AdjM^[I, J] = 0 then
            ElSuly^[I, J] := 0;
    if Cs = 0 then
    begin
      if CsucsSuly <> Nil then
      begin
        Dispose(CsucsSuly);
        CsucsSuly := Nil;
      end;
      if ElSuly <> Nil then
      begin
        Dispose(ElSuly);
        ElSuly := Nil;
      end;
    end;
  end; { with }
end; { Szerk }

{ ========================================================================== }

end.
