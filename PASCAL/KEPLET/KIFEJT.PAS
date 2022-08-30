{  K ê P L E T    Verzi¢ 2.0
  Matematikai kifejezÇs-kiÇrtÇkelÇs   (c) 1992  T¢th B†lint

  Sztring-kifejezÇs kiÇrtÇkelÇse
}
unit Kifejt;

{$B-}
interface

uses Szerk; { t†bl†zat-objektumok unitja }

const
  { beÇp°tett fÅggvÇnyek }
  MaxBeEpFv = 10;
  BeEpFv: Array[1..MaxBeEpFv] of String[6] = (
    'ABS', 'ARCTAN', 'COS', 'EXP', 'FACT', 'LN', 'INT', 'SIN', 'SGN',
    'SQRT');
  { hibaÅzenetek }
{$IFDEF ENGLISH}
  HibaUzenet: Array[1..13] of String = (
    'Division by zero',
    'Power is valid only to positive base',
    'Overflow',
    'Factorial is valid only for natural numbers',
    'Logarithm is valid only for pos. numbers',
    'Root is valid only for non-negative numbers',
    'Unclosed opening parenthesis',
    'Invalid number format',
    'Too many closing parentheses',
    'Function arguments expected',
    'Not enough function arguments',
    'Unknown identifier',
    'Operand or argument expected');
{$ELSE}
  HibaUzenet: Array[1..13] of String = (
    'Null†val val¢ oszt†s',
    'Hatv†nyoz†s csak pozit°v alapra Çrtelmezett',
    'T£lcsordul†s',
    'Faktori†lis csak term. sz†mokra Çrtelmezett',
    'Logaritmus csak poz. sz†mokra Çrtelmezett',
    'Gyîkvon†s csak nemneg. sz†mokra Çrtelmezett',
    'Lez†ratlan z†r¢jel',
    'Nem megengedett sz†mform†tum',
    'T£l sok a csuk¢ z†r¢jel',
    'FÅggvÇny-paramÇterlista hi†nyzik',
    'T£l kevÇs fÅggvÇny-paramÇter',
    'Ismeretlen azonos°t¢',
    'Operandus illetve paramÇter hi†nyzik');
{$ENDIF}

type
  PElemT = ^ElemT;
  ElemT = Record
    ZJel: Byte; { nyit¢ z†r¢jelek }
    Szam: Real; { operandus }
    Muv: Byte; { mñvelet k¢dja }
    Prev: PElemT; { elìzì elem }
  end;

  ParamT = Array[1..9] of Real; { paramÇterlista }

var
  Sz: Array[1..3] of PSzerk; { a h†rom t†bl†zat-objektum }
  HibaKod: Integer; { 0 = nincs hiba }

function Kifejez(S: String; ParamSzam: Integer; X: ParamT): Real;

implementation

const
  BeEpFvKezdet = 10; { beÇp°tett fÅggvÇnyek mñveleti k¢djainak kezdete }
  UjFvKezdet = 100; { felhaszn†l¢i fÅggvÇnyek mñveleti k¢djainak kezdete }

function Kifejez(S: String; ParamSzam: Integer; X: ParamT): Real;
var
  I: Integer; { aktu†lis poz°ci¢ a kifejezÇs-sztringben }
  P: PElemT; { legfelsì elem a l†ncolt list†ban }

function VegreHajtOp(R1, R2: Real; Muv: Byte): Real;
var
  Par: ParamT;
  R: Real;
  I: Integer;
begin
  case Muv of
    1 : VegreHajtOp := R1 + R2;
    2 : VegreHajtOp := R1 - R2;
    3 : if (R1 = 0) or (R2 = 0) then
          VegreHajtOp := 0
        else if Ln(Abs(R1)) + Ln(Abs(R2)) <= Ln(1.0E+38) then
          VegreHajtOp := R1 * R2
        else
          HibaKod := 3;
    4 : if R2 = 0 then
          HibaKod := 1
        else if R1 = 0 then
          VegreHajtOp := 0
        else if Ln(Abs(R1)) - Ln(Abs(R2)) <= Ln(1.0E+38) then
          VegreHajtOp := R1 / R2
        else
          HibaKod := 3;
    5 : if R1 <= 0 then
          HibaKod := 2
        else if Abs(R2 * Ln(R1)) <= 88 then
          VegreHajtOp := Exp(R2 * Ln(R1))
        else
          HibaKod := 3;
    11: VegreHajtOp := Abs(R2);
    12: VegreHajtOp := ArcTan(R2);
    13: VegreHajtOp := Cos(R2);
    14: if Abs(R2) <= 88 then
          VegreHajtOp := Exp(R2)
        else
          HibaKod := 3;
    15: if (R2 = Int(R2)) and (R2 >= 0) then
          if R2 <= 33 then
          begin
            R := 1;
            for I := 2 to Trunc(R2) do
              R := R * I;
            VegreHajtOp := R;
          end
          else
            HibaKod := 3
        else
          HibaKod := 4;
    16: if R2 > 0 then
          VegreHajtOp := Ln(R2)
        else
          HibaKod := 5;
    17: if R2 >= 0 then
          VegreHajtOp := Int(R2)
        else if Int(R2) = R2 then
          VegreHajtOp := R2
        else
          VegreHajtOp := -(Int(-R2) + 1);
    18: VegreHajtOp := Sin(R2);
    19: if R2 = 0 then
          VegreHajtOp := 0
        else if R2 > 0 then
          VegreHajtOp := 1
        else if R2 < 0 then
          VegreHajtOp := -1;
    20: if R2 >= 0 then
          VegreHajtOp := Sqrt(R2)
        else
          HibaKod := 6;
    else
      if (Muv > UjFvKezdet) and (Muv <= UjFvKezdet + Sz[2]^.GSorMeret)
        then
      begin
        Par[1] := R2;
        VegreHajtOp := Kifejez(Sz[2]^.GRub(Muv - UjFvKezdet, 3), 1, Par);
      end;
  end; { case }
end; { VegreHajtOp }

function NagyobbPrec(M1, M2: Byte): Boolean;
begin
  NagyobbPrec := (M1 - 1) div 2 >= (M2 - 1) div 2;
end; { NagyobbPrec }

procedure UjElem;
var
  P1: PElemT;
begin
  New(P1);
  P1^.ZJel := 0;
  P1^.Szam := 0;
  P1^.Muv := 0;
  P1^.Prev := P;
  P := P1;
end; { UjElem }

procedure GetNyZaroJel;
begin
  while (I <= Length(S)) and (S[I] = '(') do
  begin
    Inc(P^.ZJel);
    Inc(I);
  end;
  while (I <= Length(S)) and (S[I] = ' ') do
    Inc(I);
  if I > Length(S) then
    HibaKod := 7;
end; { GetNyZaroJel }

procedure GetSzam;
var
  J, K: Integer;
begin
  J := I;
  while (J <= Length(S)) and (S[J] in ['0'..'9', '+', '-', '.', 'E']) do
    Inc(J);
  Val(Copy(S, I, J - I), P^.Szam, K);
  if K > 0 then
    HibaKod := 8;
  I := J;
end; { GetSzam }

procedure GetCsZaroJel;
var
  P1: PElemT;
begin
  while (I <= Length(S)) and (S[I] = ' ') do
    Inc(I);
  while (I <= Length(S)) and (S[I] = ')') do
  begin
    if (P^.ZJel > 0) then
      Dec(P^.ZJel)
    else
    begin
      while (P^.Prev <> Nil) and (P^.ZJel = 0) do
      begin
        P1 := P^.Prev;
        P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
        if HibaKod <> 0 then
          Exit;
        P1^.Muv := P^.Muv;
        Dispose(P);
        P := P1;
      end;
      if P^.ZJel = 0 then
      begin
        HibaKod := 9;
        Exit;
      end;
      Dec(P^.ZJel);
    end;
    Inc(I);
  end;
end; { GetCsZaroJel }

procedure GetMuv;
var
  P1: PElemT;
begin
  while (I <= Length(S)) and (S[I] = ' ') do
    Inc(I);
  if I <= Length(S) then
  begin
    case S[I] of
      '+' : P^.Muv := 1;
      '-' : P^.Muv := 2;
      '*' : P^.Muv := 3;
      '/' : P^.Muv := 4;
      '^' : P^.Muv := 5;
      else
      begin
        P^.Muv := 3;
        Dec(I);
      end;
    end;
    while (P^.Prev <> Nil) and (P^.ZJel = 0) and
      NagyobbPrec(P^.Prev^.Muv, P^.Muv) do
    begin
      P1 := P^.Prev;
      P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
      if HibaKod <> 0 then
        Exit;
      P1^.Muv := P^.Muv;
      Dispose(P);
      P := P1;
    end;
    Inc(I);
  end
  else if P^.Prev <> Nil then
    while (P^.Prev <> Nil) and (P^.ZJel = 0) do
    begin
      P1 := P^.Prev;
      P1^.Szam := VegreHajtOp(P1^.Szam, P^.Szam, P1^.Muv);
      P1^.Muv := P^.Muv;
      if HibaKod <> 0 then
        Exit;
      Dispose(P);
      P := P1;
    end;
end; { GetMuv }

procedure GetAzonosito; { azonos°t¢nevek kezelÇse }
var
  J, K: Integer;
  Ertek: Boolean;
  A: String;

function KezelBeEpFv: Boolean; { beÇp°tett fÅggvÇnyek }
begin
  K := 1;
  while (K <= MaxBeEpFv) and (A <> BeEpFv[K]) do
    Inc(K);
  if K <= MaxBeEpFv then
    P^.Muv := BeEpFvKezdet + K;
  KezelBeEpFv := K <= MaxBeEpFv;
end; { KezelBeEpFv }

function KezelFelhFv: Boolean; { felhaszn†l¢i fÅggvÇnyek }
var
  Z, L, PSz, H: Integer;
  Par: ParamT;
begin
  KezelFelhFv := True;
  K := 1;
  while (K <= Sz[2]^.GSorMeret) and (A <> Sz[2]^.GRub(K, 1)) do
    Inc(K);
  if K <= Sz[2]^.GSorMeret then
    if Sz[2]^.GKar(K, 2, 1) in ['1', ' '] then
      P^.Muv := UjFvKezdet + K
    else
    begin { tîbbv†ltoz¢s fÅggvÇny }
      while (J <= Length(S)) and (S[J] = ' ') do
        Inc(J);
      if (J > Length(S)) or (S[J] <> '(') then
      begin
        HibaKod := 10;
        Exit;
      end;
      Inc(J);
      Psz := Ord(Sz[2]^.GKar(K, 2, 1)) - Ord('0');
      for L := 1 to Psz do
      begin
        Z := 0;
        I := J;
        while (I <= Length(S)) and
          not ((S[I] = ',') and (Z = 0) and (L < Psz)) and
          not ((S[I] = ')') and (Z = 0) and (L = Psz)) do
        begin
          if S[I] = '(' then
            Inc(Z)
          else if S[I] = ')' then
            Dec(Z);
          Inc(I);
        end; { while }
        if I > Length(S) then
        begin
          HibaKod := 11;
          Exit;
        end;
        Par[L] := Kifejez(Copy(S, J, I - J), ParamSzam, X);
        if HibaKod <> 0 then
          Exit;
        J := I + 1;
      end; { for }
      P^.Szam := Kifejez(Sz[2]^.GRub(K, 3), PSz, Par);
      Ertek := True;
    end; { else }
  KezelFelhFv := K <= Sz[2]^.GSorMeret;
end; { KezelFelhFv }

function KezelFelhKonst: Boolean; { felhaszn†l¢i konstansok }
begin
  K := 1;
  while (K <= Sz[3]^.GSorMeret) and (A <> Sz[3]^.GRub(K, 1)) do
    Inc(K);
  if K <= Sz[3]^.GSorMeret then
    Val(Sz[3]^.GRub(K, 2), P^.Szam, I);
  KezelFelhKonst := K <= Sz[3]^.GSorMeret;
end; { KezelFelhKonst }

procedure KezelParam; { paramÇter v†ltoz¢k Çs a PI }
begin
  if (Copy(S, I, J - I) = 'X') and (ParamSzam = 1) then
    P^.Szam := X[1]
  else if (J = I + 2) and (S[I] = 'X') and (Ord(S[I + 1]) >= Ord('1'))
    and (Ord(S[I + 1]) <= Ord('0') + ParamSzam) then
      P^.Szam := X[Ord(S[I + 1]) - Ord('0')]
  else if Copy(S, I, J - I) = 'PI' then
    P^.Szam := Pi
  else
    HibaKod := 12;
end; { KezelParam }

begin { GetAzonosito }
  Ertek := False;
  J := I;
  while (J <= Length(S)) and (S[J] in ['A'..'Z', '0'..'9']) do
    Inc(J);
  A := Copy(S, I, J - I);
  if not KezelBeEpFv then
  begin
    A := Copy(A + SPC, 1, Sz[2]^.GRubMeret(1));
    if not KezelFelhFv then
    begin
      Ertek := True;
      if not KezelFelhKonst then
        KezelParam;
    end;
  end;
  I := J;
  if Ertek and (HibaKod = 0) then
  begin
    GetCsZaroJel;
    GetMuv;
  end;
end; { GetAzonosito }

var
  P1: PElemT;

begin { Kifejez }
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  I := 1;
  P := Nil;
  while (I <= Length(S)) and (HibaKod = 0) do
  begin
    while (I <= Length(S)) and (S[I] = ' ') do
      Inc(I);
    if I <= Length(S) then
    begin
      UjElem;
      GetNyZaroJel;
      if HibaKod = 0 then
        if S[I] in ['A'..'Z'] then
          GetAzonosito
        else if S[I] = '-' then
        begin
          P^.Szam := 0;
          P^.Muv := 2;
          Inc(I);
        end
        else
        begin
          GetSzam;
          if HibaKod = 0 then
          begin
            GetCsZaroJel;
            if HibaKod = 0 then
              GetMuv;
          end;
        end; { else }
    end; { if }
  end; { while }
  Kifejez := P^.Szam;
  if P^.Muv <> 0 then
    HibaKod := 13;
  while P <> Nil do
  begin
    P1 := P^.Prev;
    Dispose(P);
    P := P1;
  end;
end; { Kifejez }

begin { unit inicializ†l†s }
  HibaKod := 0;
end.
