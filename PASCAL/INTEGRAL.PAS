program Integral; { Numerikus integralszamitas }

{$F+}
var
  a, b: Real;    { intervallum also es felso hatara }
  e: Real;    { pontossag }
  m: Real;    { megoldas }
  c: Char;
  nincs: Boolean;

type
  fx = function(x: Real): Real;  { fuggveny-tipus }

function fv(x: Real): Real;	  { az integralando fuggveny }
begin
  fv:= 1.0 / x;
end;

function teglany(a, b, e: real; f: fx):real;
var
  I, N: LongInt;
  S1, S, BAN: Real;
begin
  N := 1;
  S := F(A) * (B - A);
  repeat
    S1 := S;
    N := N shl 1;
    BAN := (B - A) / N;
    S:= 0;
    for I := 0 to N - 1 do
      S := S + F(A + I * BAN) * BAN;
  until Abs(S - S1) < E;
  teglany := S;
end;

function trapez(a, b, e: real; f: fx):real;
var
  I, N: LongInt;
  Jo, Ba: Real;
  S1, S, BAN: Real;
begin
  N := 1;
  S := F(A) * (B - A);
  repeat
    S1 := S;
    N := N shl 1;
    BAN := (B - A) / N;
    S:= 0;
    I := 0;
    Ba := F(A);
    repeat
      Inc(I);
      Jo := F(A + I * BAN);
      S := S + (Jo + Ba) * BAN / 2;
      Ba := Jo;
    until I = N;
  until Abs(S - S1) < E;
  trapez := S;
end;

function simpson(a, b, e: real; f: fx):real;
var
  I, N: LongInt;
  S2, S1, S, BAN: Real;
begin
  N := 1;
  S := F(A) * (B - A);
  repeat
    S1 := S;
    N := N shl 1;
    BAN := (B - A) / N;
    S:= 0;
    for I := 1 to N shr 1 - 1 do
      S := S + F(A + (I shl 1) * BAN);
    S2 := 0;
    for I := 1 to N shr 1 do
      S2 := S2 + F(A + (I shl 1 - 1) * BAN);
    S := (2 * S + 4 * S2 + F(A) + F(B)) * BAN / 3;
  until Abs(S - S1) < E;
  simpson := S;
end;

begin { foprogram }
  repeat
    Writeln('Numerikus integr l s');
    Writeln;
    Write('Als¢ hat r: ');
    Readln(a);
    Write('Fels“ hat r: ');
    Readln(b);
    Write('Pontoss g: ');
    Readln(e);
    Writeln;
    repeat
      nincs := false;
      Write('Melyik m¢dszerrel ? 1: t‚gl ny, 2: trap‚z, 3: felez“, 0: v‚ge ');
      Readln(c);
      case c of
	'1': m := teglany(a, b, e, fv);
	'2': m := trapez(a, b, e, fv);
	'3': m := simpson(a, b, e, fv);
        '0': nincs := true;
      end;
      if not nincs then
        Writeln('A megold s: ', m:10:4);
     until c = '0';
     Write('Uj adatokkal? (i/n): ');
     Readln(c);
   until (c = 'n') or (c = 'N');
end.
