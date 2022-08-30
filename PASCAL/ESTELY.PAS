{ Est‚lytervez“ program }
{ T¢th B lint, 1993 }
program Estely;

{$B-,R-,Q-,S-}
uses Crt, Graph;

const
  kbEsc   = #27; { ReadKey billenty–k¢dok }
  kbEnter = #13;
  kbLeft  = #75; { #0 ut n }
  kbRight = #77;
  kbUp    = #72;
  kbDown  = #80;
  kbHome  = #71;
  kbEnd   = #79;
  kbPgUp  = #73;
  kbPgDn  = #81;

const
  Max = 10;              { emberek maxim lis sz ma }
type
  ViszonyT = Array[1..Max, 1..Max] of Integer;
  PozT = Array[1..Max, 1..2] of Integer;
  ErtekT = Array[1..Max] of Real;
var
  GraphDriver, GraphMode: Integer;
  MaxX, MaxY: Integer;  { k‚perny“ m‚rete }
  TavRacs, TavNegyz: LongInt;
  N: Integer;           { emberek sz ma }
  Viszony: ViszonyT;    { emberek k”z”tti szimp tia foka }
  Kedv: ErtekT;         { emberek ked‚ly llapota }
  Poz, UjPoz: PozT;     { emberek poz¡ci¢ja l‚p‚s el“tt ‚s ut n }
  Torol: Boolean;       { FALSE = cs¡kh£z s }
  Sulyoz: Boolean;      { FALSE = szimp tia: ide lis t vols g }
  Negyz: Boolean;       { TRUE = t vols g n‚gyzetes, FALSE = r csgeometria }
  Vege: Boolean;
  I: Integer;

procedure KiirViszony;  { viszonyt bl zat ki¡r sa }

procedure KiirSor(Sor: Integer); { egy sor ki¡r sa }
var
  I: Integer;
begin
  Write(Sor :2, ' º');
  for I := 1 to N - 1 do
    Write(Viszony[Sor, I] :2, '³');
  WriteLn(Viszony[Sor, N] :2, 'º');
end; { KiirSor }

var
  I, J: Integer;
begin
  ClrScr;
  WriteLn(' SZIMPTIA-TBLZAT  (', N, ' r‚sztvev“)');
  Write('   ');
  for I := 1 to N do
    Write(I :3);
  WriteLn;
  Write('   É');
  for I := 1 to N - 1 do
    Write('ÍÍÑ');
  WriteLn('ÍÍ»');
  for J := 1 to N - 1 do
  begin
    KiirSor(J);
    Write('   Ç');
    for I := 1 to N - 1 do
      Write('ÄÄÅ');
    WriteLn('ÄÄ¶');
  end;
  KiirSor(N);
  Write('   È');
  for I := 1 to N - 1 do
    Write('ÍÍÏ');
  WriteLn('ÍÍ¼');
end; { KiirViszony }

procedure ClrViszony;   { res viszonyt bl zat }
var
  I, J: Integer;
begin
  for I := 1 to Max do
    for J := 1 to Max do
      Viszony[I, J] := 0;
end; { ClrViszony }

procedure SzerkViszony; { viszonyt bl zat szerkeszt‚se }
var
  I, J: Integer;
  X, Y: Integer;
  Ch: Char;
begin
  Window(37, 1, 80, 25);
  TextColor(Yellow);
  WriteLn('          ESTLY-TERVEZ™ PROGRAM');
  WriteLn('            T¢th B lint, 1993');
  WriteLn;
  TextColor(Cyan);
  WriteLn('Szimp tia-t bl zat kit”lt‚se:');
  WriteLn('-----------------------------');
  WriteLn('  0..9   sz m be¡r sa');
  WriteLn('  -      ellentett');
  WriteLn('  C      t bl zat t”rl‚se');
  WriteLn('  R      v‚letlen t bl zat');
  WriteLn('  T      t bl zat jobb fels“ fel‚nek tkr.');
  WriteLn('  PAGE UP/DOWN  r‚sztvev“k sz m nak  ll.');
  WriteLn('  ENTER  szimul ci¢ megkezd‚se');
  WriteLn('  ESC    kil‚p‚s a programb¢l');
  WriteLn;
  WriteLn('Szimul ci¢ alatt kiadhat¢ parancsok:');
  WriteLn('------------------------------------');
  WriteLn('  S      szimp tia: s£lyoz s / ide lis t v');
  WriteLn('  T      t vols g: n‚gyzetes/r csgeometria');
  WriteLn('  C      cs¡kh£z s ki / be');
  WriteLn('  R      £j (v‚letlen) poz¡ci¢k');
  WriteLn('  ENTER  szimul ci¢ meg ll¡t sa / ind¡t sa');
  WriteLn('  E      szimp tia-t bl zat szerkeszt‚se');
  WriteLn('  ESC    kil‚p‚s a programb¢l');
  WriteLn('(A sz¡n az  ltal nos k”z‚rzetet mutatja)');
  TextColor(Green);
  Window(1, 1, 36, 25);
  KiirViszony;
  X := 2;
  Y := 1;
  repeat
    GotoXY(3 + X * 3, 2 + Y * 2);
    Ch := UpCase(ReadKey);
    case Ch of
      #0: begin
            Ch := ReadKey;
            case Ch of
              kbLeft:  if X > 1 then Dec(X);
              kbRight: if X < N then Inc(X);
              kbUp:    if Y > 1 then Dec(Y);
              kbDown:  if Y < N then Inc(Y);
              kbHome:  begin
                         X := 2;
                         Y := 1;
                       end;
              kbEnd:   begin
                         X := N;
                         Y := N - 1;
                       end;
              kbPgUp:  if N < Max then
                       begin
                         Inc(N);
                         KiirViszony;
                       end;
              kbPgDn:  begin
                         if N > 2 then
                         begin
                           Dec(N);
                           if X > N then
                             X := N;
                           if Y > N then
                             Y := N;
                           KiirViszony;
                         end;
                       end;
              else
                Ch := #0;
            end; { case }
          end; { case #0 }
      'C': begin
             ClrViszony;
             KiirViszony;
           end;
      'R': begin
             for I := 1 to N do
             begin
               for J := 1 to N do
                 Viszony[I, J] := Integer(Random(19)) - 9;
               Viszony[I, I] := 0;
             end;
             KiirViszony;
           end;
      'T': begin
             for I := 2 to Max do
               for J := 1 to I - 1 do
                 Viszony[I, J] := Viszony[J, I];
             KiirViszony;
           end;
      '-': begin
             Viszony[Y, X] := -Viszony[Y, X];
             KiirViszony;
           end;
      '0'..'9':
           if X <> Y then
           begin
             if Viszony[Y, X] >= 0 then
               Viszony[Y, X] := Ord(Ch) - Ord('0')
             else
               Viszony[Y, X] := -(Ord(Ch) - Ord('0'));
             KiirViszony;
           end;
      kbEsc: Vege := True;
    end; { case }
  until Vege or (Ch = kbEnter);
  Window(1, 1, 80, 25);
  TextColor(LightGray);
  ClrScr;
end; { SzerkViszony }

procedure RndPoz;       { v‚letlen poz¡ci¢k }
var
  I: Integer;
begin
  for I := 1 to N do
  begin
    Poz[I, 1] := Random(MaxX + 1);
    Poz[I, 2] := Random(MaxY + 1);
  end;
end;

function Ertek(Ember, X, Y: Integer): Real;
var
  E: Real;
  L: LongInt;
  I: Integer;
begin
  E := 0;
  for I := 1 to N do
  begin
    if Negyz then
      L := Sqr(LongInt(Poz[I, 1] - X)) + Sqr(LongInt(Poz[I, 2] - Y))
    else
      L := Abs(Poz[I, 1] - X) + Abs(Poz[I, 2] - Y);
    if L = 0 then
      L := 1;
    if Sulyoz then
      E := E + Viszony[Ember, I] / L
    else
    begin
      if Negyz then
        L := Abs((9 - Viszony[Ember, I]) * TavNegyz - L) { elt‚r‚s az ide list¢l }
      else
        L := Abs((9 - Viszony[Ember, I]) * TavRacs - L);
      if L = 0 then
        L := 1;
      E := E + 1 / L;
    end;
  end;
  Ertek := E;
end; { Ertek }

procedure Rajzol;
var
  I, C: Integer;
  L: LongInt;
begin
  if Torol then
    ClearDevice;
  for I := 1 to N do
  begin
    Kedv[I] := Ertek(I, Poz[I, 1], Poz[I, 2]);
    L := Round((Kedv[I] * 1000));
    if L > 480 then
      C := LightRed
    else if L > 240 then
      C := LightMagenta
    else if L > 120 then
      C := Red
    else if L > 60 then
      C := Magenta
    else if L > 30 then
      C := Yellow
    else if L > 15 then
      C := White
    else if L > 3 then
      C := LightCyan
    else if L > -3 then
      C := LightGreen
    else if L > -15 then
      C := Cyan
    else if L > -30 then
      C := LightBlue
    else if L > -60 then
      C := Green
    else if L > -120 then
      C := Blue
    else if L > -240 then
      C := Blue
    else
      C := DarkGray;
    if C > GetMaxColor then
      C := GetMaxColor;
    PutPixel(Poz[I, 1], Poz[I, 2], C)
  end;
end; { Rajzol }

procedure Lepes;
const
  LepVar = 9;
  Delta: Array[1..LepVar, 1..2] of Integer =
    ((0, 0), (1, 0), (1, 1), (0, 1), (-1, 1),
    (-1, 0), (-1, -1), (0, -1), (1, -1));
var
  I, J: Integer;
  X, Y: Integer;
  LJLep: Integer;       { eddigi legjobb l‚p‚s sorsz ma }
  LJErtek: Real;        { eddigi legjobb l‚p‚s ‚rt‚ke }
  E: Real;
begin
  for I := 1 to N do
  begin
    LJErtek := Kedv[I];
    LJLep := 1;
    for J := 2 to LepVar do
    begin
      X := Poz[I, 1] + Delta[J, 1];
      Y := Poz[I, 2] + Delta[J, 2];
      if (X >= 0) and (X <= MaxX) and (Y >= 0) and (Y <= MaxY) then
      begin
        E := Ertek(I, X, Y);
        if E > LJErtek then
        begin
          LJErtek := E;
          LJLep := J;
        end; { if E }
      end; { if X }
    end; { for J }
    UjPoz[I, 1] := Poz[I, 1] + Delta[LJLep, 1];
    UjPoz[I, 2] := Poz[I, 2] + Delta[LJLep, 2];
  end; { for I }
end; { Lepes }

procedure Ciklus;
var
  Ch: Char;
  Mehet: Boolean;
begin
  Mehet := True;
  Ch := #0;
  repeat
    if Mehet then
    begin
      Rajzol;
      Lepes;
      Poz := UjPoz;
    end;
    if KeyPressed then
    begin
      Ch := UpCase(ReadKey);
      case Ch of
        kbEsc:
             Vege := True;
        kbEnter:
             Mehet := not Mehet;
        'S': Sulyoz := not Sulyoz;
        'C': Torol := not Torol;
        'T': Negyz := not Negyz;
        'R': begin
               RndPoz;
               ClearDevice;
               Mehet := True;
             end;
      end; { case }
    end; { if }
  until Vege or (Ch = 'E');
end; { Ciklus }

begin { f“program }
  InitGraph(GraphDriver, GraphMode, 'C:\BP\BGI');
  if GraphResult <> grOk then
    Halt;
  MaxX := GetMaxX;
  MaxY := GetMaxY;
  TavRacs := (MaxX + MaxY) mod 20;
  TavNegyz := 32000;     { VGA }
  N := 6;
  Vege := False;
  Torol := True;
  Sulyoz := True;
  Negyz := False;
  Randomize;
  ClrViszony;
  RndPoz;
  repeat
    RestoreCrtMode;
    SzerkViszony;
    for I := 1 to N do
      Kedv[I] := -9 * N;
    if not Vege then
    begin
      SetGraphMode(GraphMode);
      Ciklus;
    end;
  until Vege;
  CloseGraph;
end.