{ ========================================================================== }
{ Kulonbozo felszinu racsok atomjainak koordinatainak generalasa }
{ Mozgo reszecske utjanak vizsgalata }
{ Sikvetulet abrazolasa grafikusan }

{ (c) T¢th B lint, 1993-94 }
{ IBM PC, MS-DOS, Borland Pascal 7.0 }
{ ========================================================================== }

program RacsGen;

{$B-,X+}
uses Crt, Graph;

const
  MaxN = $FFF0 div SizeOf(Real);        { atomok max. szama (kb.10000) }
  PathToBGI = 'C:\BP\BGI';              { grafikus meghajto eleresi utja }

{ Bemeno adatok: }
const
  CellaX = 1.0;                 { elemi cella X merete [æm] }
  CellaY = 1.0;                             { Y }
  CellaZ = 1.0;                             { Z }
  RacsX = 12;                   { racs X merete [cellakban] }
  RacsY = 4;                         { Y }
  RacsZ = 6;                         { Z (felszinnel egyutt) }
  H = 4.0 * CellaZ;             { felszin magassaga (H > 0) }
  OX = 0.0;                     { legkisebb lehetseges X koordinata }
  OY = 0.0;                                          { Y }
  OZ = RacsZ * CellaZ - H;      { felszintol legtavolabbi atom Z koordinata }
  HatasTav = 1.0;               { mozgo reszecske megengedheto minimalis }
                                {  tavolsaga a tombtol a szabad elhaladashoz }
  RacsTipus = 2;                { 0 = teglatest csucsai }
                                { 1 = teglatest csucsai es kozeppontja }
                                { 2 = teglatest csucsai es lapkozeppontok }
  FelszinTipus = 1;             { 0 = sima felszin }
                                { 1 = fureszfogak }
                                { 2 = csonka gulak }
                                { 3 = inverz csonka gula (godrok) }
 { Felszin megadasa: }
  Fok = 60.0 * Pi / 180;        { fog meredeksege fureszfog felszinnel [rad] }
                                {   (0 < Fok < Pi/2) }
  Wx = 6.0 * CellaX;            { felszin elem teljes X merete }
  Wy = 4.0 * CellaY;                                { Y }
  Bx = 5.0 * CellaX;            { felszin elem "netto" X merete }
  By = 3.0 * CellaY;                                 { Y }
  Tx = 2.0 * CellaX;            { gula felszin elem keskenyebb X merete }
  Ty = 1.0 * CellaY;                                         { Y }

 { Mozgo reszecske adatai }
  X0 = OX + Bx + 0.47;          { reszecske koordinataja }
  Y0 = OY + By / 2 - 0.5;
  Z0 = OZ - CellaZ * RacsZ + 2 * H / 3;
  VX = 1.0;                     { reszecske sebessege }
  VY = 1.0;
  VZ = -0.98;

type
  PAtom = ^TAtom;
  TAtom = Array[1..MaxN] of Real;

{ Kimeno adatok: }
var
  N: Integer;                   { atomok szama }
  AX, AY, AZ: PAtom;            { atomok koordinatai }

var
  UX, UZ: Real;                 { 1 egyseg merete a kepernyon }

{ ========================================================================== }

{ A MOD B a valos szamok koreben (A >= 0, B <> 0) }
function RMod(A, B: Real): Real;
begin
  RMod := A - Int(A / B) * B;
end; { RMod }

{ ========================================================================== }

{ cos alfa kiszamitasa A es B oldalakbol) }
function Tan2Cos(A, B: Real): Real;
begin
  Tan2Cos := B / Sqrt(A * A + B * B);
end; { Tan2Cos }

{ ========================================================================== }

{ 2 szam maximuma }
function Max(A, B: Real): Real;
begin
  if A >= B then
    Max := A
  else
    Max := B;
end; { Max }

{ ========================================================================== }

{ Felszin aktualis magassaga fureszfog felszin eseten }
{ PX, PY a koordinatak (0 <= PX < Wx; 0 <= PY < Wy) }
{ VanHatasTav: 1 = figyelembe kell venni HatasTav-ot is; 0 = nem }
function HFureszfog(PX, PY: Real; VanHatasTav: Real): Real;
var
  R: Real;                              { legmagasabb pont X koordinataja }
begin
  R := H * Cos(Fok) / Sin(Fok);
  if PX <= R then
    HFureszfog := PX * Sin(Fok) / Cos(Fok)
      + VanHatasTav * HatasTav / Cos(Fok)
  else if PX < Bx then
    HFureszfog := H * (Bx - PX) / (Bx - R)
      + VanHatasTav * HatasTav / Tan2Cos(H, Bx - R)
  else
    HFureszfog := 0.0
      + VanHatasTav * HatasTav;
end; { HFureszfog }

{ ========================================================================== }

{ Felszin aktualis magassaga csonka gula felszin eseten }
{ PX, PY a koordinatak (0 <= PX < Wx; 0 <= PY < Wy) }
{ VanHatasTav: 1 = figyelembe kell venni HatasTav-ot is; 0 = nem }
{ (Inverz gulanal -1 kell 1 helyett) }
function HGula(PX, PY: Real; VanHatasTav: Real): Real;
var
  X1, Y1: Real;
begin
  X1 := Abs(PX - Bx / 2.0);
  Y1 := Abs(PY - By / 2.0);
  if (X1 * By) >= (Y1 * Bx) then
  begin
    if X1 >= (Bx / 2.0) then
      HGula := 0.0
        + VanHatasTav * HatasTav
    else if X1 <= (Tx / 2.0) then
      HGula := H
        + VanHatasTav * HatasTav
    else
      HGula := 2.0 * H * (Bx / 2.0 - X1) / (Bx - Tx)
        + VanHatasTav * HatasTav / Tan2Cos(H, (Bx - Tx) / 2.0);
  end
  else
  begin
    if Y1 >= (By / 2.0) then
      HGula := 0.0
        + VanHatasTav * HatasTav
    else if Y1 <= (Ty / 2.0) then
      HGula := H
        + VanHatasTav * HatasTav
    else
      HGula := 2.0 * H * (By / 2.0 - Y1) / (By - Ty)
        + VanHatasTav * HatasTav / Tan2Cos(H, (By - Ty) / 2.0);
  end;
end; { HGula }

{ ========================================================================== }

{ Tomb aktualis magassaga OZ nelkul }
{ X, Y a koordinatak }
{ VanHatasTav: 1 = figyelembe kell venni HatasTav-ot is; 0 = nem }
function TombMag(X, Y: Real; VanHatasTav: Real): Real;
var
  PX, PY: Real;
  M: Real;
begin
  if (X < OX) or (X >= OX + CellaX * RacsX)
    or (Y < OY) or (Y >= OY + CellaY * RacsY) then
      TombMag := 0.0
  else
  begin
    PX := RMod(X - OX, Wx);
    PY := RMod(Y - OY, Wy);
    case FelszinTipus of
      0: M := H + VanHatasTav * HatasTav;
      1: M := HFureszfog(PX, PY, VanHatasTav);
      2: M := HGula(PX, PY, VanHatasTav);
      3: M := H - HGula(PX, PY, -VanHatasTav);
    end; { case }
    TombMag := CellaZ * RacsZ - H + M;
  end;
end; { TombMag }

{ ========================================================================== }

{ Racs egy halojanak felepitese (parameterek: kezdokoord. cellaegysegben) }
procedure Felepit(SX, SY, SZ: Real);
var
  KX, KY, KZ: Real;             { aktualis atom koordinatak [æm]}
  IX, IY: Integer;              { ciklusvaltozok }
  M: Real;                      { tomb aktualis magassaga }
begin
  KX := OX + SX * CellaX;
  for IX := 0 to RacsX - 1 do
  begin
    KY := OY + SY * CellaY;
    for IY := 0 to RacsY - 1 do
    begin
      M := TombMag(KX, KY, 0.0);
      KZ := SZ * CellaZ;
      while KZ <= M do          { egymas feletti atomok }
      begin
        if N >= MaxN then       { tul sok atom, kilepes hibaval }
        begin
          WriteLn('Hiba:  Tul sok atom! (Max = ', MaxN, ')');
          Halt(1);
        end;
        N := N + 1;
        AX^[N] := KX;           { koordinatak tarolasa }
        AY^[N] := KY;
        AZ^[N] := OZ - KZ;      { a Z koordinata a felszin fele csokken }
        KZ := KZ + CellaZ;
      end; { while }
      KY := KY + CellaY;
    end; { for IY }
    KX := KX + CellaX;
  end; { for IX }
end; { Felepit }

{ ========================================================================== }

{ Atomok generalasa }
procedure GenAtomok;
begin
  N := 0;
  WriteLn('A tomb generalasa...');
  case RacsTipus of
    0:   Felepit(0  , 0  , 0  );
    1: begin
         Felepit(0  , 0  , 0  );
         Felepit(0.5, 0.5, 0.5);
       end;
    2: begin
         Felepit(0,   0,   0  );
         Felepit(0.5, 0.5, 0  );
         Felepit(0.5, 0  , 0.5);
         Felepit(0  , 0.5, 0.5);
       end;
  end; { case }
  WriteLn('Atomok szama: ', N);
end; { GenAtomok }

{ ========================================================================== }

{ Eredmeny kiirasa file-ba }
procedure KiirAtomok;
const
  FName = 'RACSGEN.OUT';
var
  F: Text;                      { ide irodik az eredmeny }
  I: Integer;
begin
  WriteLn('Az atomkoordinatak kiirasa ', FName, ' nevu file-ba...');
  Assign(F, FName);
  {$I-}
  Rewrite(F);
  {$I+}
  if IOresult <> 0 then
  begin
    WriteLn('I/O hiba:  Nem tudom letrehozni a kimeneti file-t!');
    Halt(2);
  end;
  WriteLn(F, N);
  for I := 1 to N do
    WriteLn(F, AX^[I], ', ', AY^[I], ', ', AZ^[I]);
  Close(F);
end; { KiirAtomok }

{ ========================================================================== }

{ Mozgo reszecske utjanak vizsgalata: fog-e meg az anyagba utkozni }
{ Fureszfog felszin eseten (VZ < 0) }
function UVFureszFog: Boolean;
var
  PX: Real;
  R, R1: Real;
begin
  PX := RMod(X0 - OX, Wx);
  PX := RMod(PX - H * Cos(Fok) / Sin(Fok) + Wx, Wx);
  if VX > 0.0 then
    PX := Wx - PX;
  if (H * Cos(Fok) / Sin(Fok)) < Bx then
    R1 := HatasTav / Tan2Cos(H, Bx - H * Cos(Fok) / Sin(Fok))
  else
    R1 := 0;
  R := Max(HatasTav / Cos(Fok), R1);
  UVFureszFog := (VX <> 0.0) and (Abs((OZ - CellaZ * RacsZ - R - Z0)
    * VX) >= Abs(VZ * PX));
end; { UVFureszfog }

{ ========================================================================== }

{ Mozgo reszecske utjanak vizsgalata: fog-e meg az anyagba utkozni }
{ Inverz csonka gula felszin eseten (VZ < 0) }
function UVInvGula: Boolean;
var
  PX, PY: Real;
  R: Real;
begin
  PX := RMod(X0 - OX, Wx);
  if VX > 0.0 then
    PX := Bx - PX;
  if Bx = Tx then
    R := HatasTav
  else
    R := HatasTav / Tan2Cos(H, (Bx - Tx) / 2.0);
  if (VX <> 0.0) and (Abs((OZ - CellaZ * RacsZ - R - Z0) * VX)
    >= Abs(VZ * PX)) then
      UVInvGula := True
  else
  begin
    PY := RMod(Y0 - OY, Wy);
    if VY > 0.0 then
      PY := By - PY;
    if By = Ty then
      R := HatasTav
    else
      R := HatasTav / Tan2Cos(H, (By - Ty) / 2.0);
    UVInvGula := (VY <> 0.0) and (Abs((OZ - CellaZ * RacsZ - R - Z0) * VY)
      >= Abs(VZ * PY));
  end; { else }
end; { UVInvGula }

{ ========================================================================== }

{ Mozgo reszecske utjanak vizsgalata: fog-e meg az anyagba utkozni }
function UtVizsg: Boolean;
begin
  if (X0 < OX) or (X0 >= OX + CellaX * RacsX)
    or (Y0 < OY) or (Y0 >= OY + CellaY * RacsY)
    or (Z0 > OZ) or (Z0 <= OZ - CellaZ * RacsZ - HatasTav) then
      UtVizsg := False
  else if (Z0 > OZ - TombMag(X0, Y0, 1.0)) or (VZ >= 0.0) then
    UtVizsg := True
  else
    case FelszinTipus of
      0: UtVizsg := False;
      1: UtVizsg := UVFureszfog;
      2: UtVizsg := True;
      3: UtVizsg := UVInvGula;
    end; { case }
end; { UtVizsg }

{ ========================================================================== }

{ XZ sikvetulet kirajzolasa }
procedure RajzolXZ;
var
  I: Integer;
  R: Real;
begin
  OutTextXY(0, 0, 'A tomb vetulete az XZ sikra');
  UX := GetMaxX / (CellaX * RacsX);
  UZ := GetMaxY / (CellaZ * RacsZ + HatasTav);
  if UX < UZ then
    UZ := UX
  else
    UX := UZ;
  for I := 1 to N do
    PutPixel(Trunc((AX^[I] - OX) * UX),
      GetMaxY - Trunc((OZ - AZ^[I]) * UZ), 7);
  R := OY + By / 2;
  for I := 0 to GetMaxX do
  begin
    PutPixel(I, Trunc(GetMaxY - TombMag(OX + I / UX, R, 0.0) * UZ), 5);
    PutPixel(I, Trunc(GetMaxY - TombMag(OX + I / UX, R, 1.0) * UZ), 6);
  end;
end; { RajzolXZ }

{ ========================================================================== }

{ Mozgo reszecske palyajanak kirajzolasa }
procedure RajzolMozgo;
var
  X1, Y1: Integer;
  X2, Y2: Integer;
  TX, TZ: Real;
begin
  X1 := Trunc((X0 - OX) * UX);
  Y1 := GetMaxY - Trunc((OZ - Z0) * UZ);
  if (VX <> 0.0) or (VZ <> 0.0) then
  begin
    if Abs(VZ) > Abs(VX) then
    begin
      if VZ > 0.0 then
        Y2 := GetMaxY
      else
        Y2 := 0;
      X2 := X1 + Trunc(VX * Abs((Y2 - Y1) / VZ));
    end
    else
    begin
      if VX > 0.0 then
        X2 := GetMaxX
      else
        X2 := 0;
      Y2 := Y1 + Trunc(VZ * Abs((X2 - X1) / VX));
    end;
    SetColor(4);
    Line(X1, Y1, X2, Y2);
  end; { if VX }
  PutPixel(X1, Y1, 3);
end; { RajzolMozgo }

{ ========================================================================== }

{ Foprogram }
var
  grDriver, grMode: Integer;
begin
  WriteLn;
  WriteLn('RacsGen  (c) 1993-94 by T¢th B lint');
  WriteLn;
  New(AX);
  New(AY);
  New(AZ);
  GenAtomok;
  KiirAtomok;
  WriteLn('A mozgo reszecske vizsgalata:');
  if (Z0 <= OZ) and (Z0 > OZ - TombMag(X0, Y0, 1.0)) then
    if Z0 > OZ - TombMag(X0, Y0, 0.0) then
      WriteLn('- A reszecske a tombben tartozkodik.')
    else
      WriteLn('- A reszecske a tomb hataskornyezeteben tartozkodik.')
  else
  begin
    WriteLn('- A reszecske a tombon kivul tartozkodik.');
    if UtVizsg then
      WriteLn('- A kesobbiekben meg behatol a tombbe.')
    else
      WriteLn('- A kesobbiekben sem fog behatolni a tombbe.')
  end;
  WriteLn;
  WriteLn('Nyomjon le egy billentyut...');
  ReadKey;
  grDriver := Detect;
  InitGraph(grDriver, grMode, PathToBGI);
  if GraphResult <> grOk then
  begin
    InitGraph(grDriver, grMode, '');
    if GraphResult <> grOk then
    begin
      WriteLn('Grafikus hiba:  Nem tudom inicializalni a grafikus kepernyot!');
      Halt(3);
    end;
  end;
  RajzolXZ;
  RajzolMozgo;
  ReadKey;
  CloseGraph;
  Dispose(AX);
  Dispose(AY);
  Dispose(AZ);
  WriteLn('Ok.');
end. { Foprogram }

{ ========================================================================== }
