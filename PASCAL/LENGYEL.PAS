{ Veremkezel?s ?s ford?tott lengyel form?tum }
{ Copyright (c) 1992  T?th B?lint }
program Lengyel;

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,655360}
uses Crt;

const
  Max = 30;
  Tab = #8;
  ElvalKar: set of Char = [' ', ',', ';', Tab];

var
  Stack: array[1..Max] of Real;
  SP, I: Integer;
  Sor, S: String;
  Fajl: Boolean;
  F: Text;

procedure Push(Elem: Real);
begin
  if SP < Max then
  begin
    Inc(SP);
    Stack[SP] := Elem;
  end
end;

function Pop: Real;
begin
  if SP > 0 then
  begin
    Pop := Stack[SP];
    Dec(SP);
  end;
end;

procedure Kiir;
var
  I: Integer;
begin
  ClrScr;
  GoToXY(20, 1);
  WriteLn('VEREMKEZEL?S ?S FORDITOTT LENGYEL FORM?TUM');
  GoToXY(32, 2);
  WriteLn('T?th B?lint, 1992                 Seg?ts?g: HELP');
  WriteLn('Kifejez?s vagy parancs: ');
  WriteLn('A verem:');
  I := SP;
  while (I > 0) and (I > SP - Hi(WindMax) + 4) do
  begin
    WriteLn(I : 3, '. :  ', Stack[I]);
    Dec(I);
  end;
  if SP = 0 then
    WriteLn('  ?res.')
  else if SP = Max then
    Write('Verem megtelt.');
  GoToXY(25, 3);
end; { Kiir }

procedure Segit;
begin
  ClrScr;
  WriteLn('Seg?ts?g');
  WriteLn('--------');
  WriteLn;
  WriteLn(' Uj sz?m berak?sa a verembe:');
  WriteLn('   g?pelj?k be a sz?mot! ( Pl. -3.265436E+18 )');
  WriteLn('   be?p?tett konstans: Pi');
  WriteLn(' M?veletek:');
  WriteLn('   +  -  *  /  ^');
  WriteLn(' F?ggv?nyek:');
  WriteLn('   Abs, ArcTan, Cos, Exp, Frac, Ln, Int, Sin, Sqr, Sqrt, Min, ' +
    'Max, Minus');
  WriteLn(' Parancsok:');
  WriteLn('   DUP, -DUP   legfels? elem megkett?z?se (-DUP: csak ha nem nulla)');
  WriteLn('   OVER        legfels? alatti elemet a verem tetej?re m?solja');
  WriteLn('   ROT         legfels? h?rom elem ciklikus cser?je');
  WriteLn('   DEL         legfels? elem t?rl?se');
  WriteLn('   RESET       verem t?rl?se');
  WriteLn('   GET         sz?m bek?r?se a verembe  (csak programb?l)');
  WriteLn('   WAIT        fut?s felf?ggeszt?se  (csak programb?l)');
  WriteLn('   RUNfilen?v  program futtat?sa  (egybe?rva)');
  WriteLn('   BYE         kil?p?s');
  WriteLn;
  WriteLn(' Kifejez?sek: ford?tott lengyel form?tumban  (elv?laszt' +
    '?s: sz?k?z , ; )');
  WriteLn('   P?lda:   3.1 4.6 + -6.8 4.6 - * dup,SQR ln;over 3 ^');
  WriteLn;
  Write('Nyomjon ENTER-t! ');
  ReadLn;
end; { Segit }

procedure Futtat(FNev: String);
begin
  Assign(F, FNev);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    ClrScr;
    Write('I/O hiba! ', FNev, ' nem futtathat?! [Enter] ');
    ReadLn;
    Fajl := False;
  end
  else
    Fajl := True;
  Sor := '';
end;

procedure VegreHajt(var S: String);
var
  A, B, C: Real;
  I: Integer;
begin
  Val(S, A, I);
  if (I = 0) and (SP < Max) then
    Push(A)
  else if (S = 'PI') and (SP < Max) then
    Push(Pi)
  else if (S = 'GET') and (SP < Max) and Fajl then
  begin
    ClrScr;
    Write('Bevitel: ');
    ReadLn(A);
    Push(A);
    Kiir;
    Write(Sor);
  end
  else if S = 'HELP' then
  begin
    Segit;
    Kiir;
    Write(Sor);
  end
  else if (S = 'WAIT') and Fajl then
  begin
    Kiir;
    Write(Sor);
    GoToXY(25, 4);
    Write('Nyomjon ENTER-t! ');
    ReadLn;
    Kiir;
    Write(Sor);
  end
  else if Copy(S, 1, 3) = 'RUN' then
  begin
    if Length(S) = 3 then
    begin
      ClrScr;
      Write('F?jln?v: ');
      ReadLn(S);
      S := '   ' + S;
    end;
    if Fajl then
      Close(F);
    Futtat(Copy(S, 4, Length(S)));
  end
  else if S = 'RESET' then
    SP := 0
  else if SP > 0 then
    if S = 'DEL' then
      A := Pop
    else if S = 'ABS' then
      Push(Abs(Pop))
    else if S = 'ARCTAN' then
      Push(ArcTan(Pop))
    else if S = 'COS' then
      Push(Cos(Pop))
    else if S = 'EXP' then
      Push(Exp(Pop))
    else if S = 'FRAC' then
      Push(Frac(Pop))
    else if (S = 'LN') and (Stack[SP] > 0) then
      Push(Ln(Pop))
    else if S = 'INT' then
      Push(Int(Pop))
    else if S = 'SIN' then
      Push(Sin(Pop))
    else if S = 'SQR' then
      Push(Sqr(Pop))
    else if (S = 'SQRT') and (Stack[SP] > 0) then
      Push(Sqrt(Pop))
    else if S = 'MINUS' then
      Push(-Pop)
    else if (S = 'DUP') and (SP < Max) then
      Push(Stack[SP])
    else if (S = '-DUP') and (SP < Max) and (Stack[SP] <> 0) then
      Push(Stack[SP])
    else if (S = 'ROT') and (SP < Max) and (SP > 2) then
    begin
      A := Pop;
      B := Pop;
      C := Pop;
      Push(B);
      Push(A);
      Push(C);
    end
    else if SP > 1 then
      if S = 'SWAP' then
      begin
        A := Pop;
        B := Pop;
        Push(A);
        Push(B);
      end
      else if S = 'MIN' then
      begin
        A := Pop;
        B := Pop;
        if A < B then
          Push(A)
        else
          Push(B);
      end
      else if S = 'MAX' then
      begin
        A := Pop;
        B := Pop;
        if A > B then
          Push(A)
        else
          Push(B);
      end
      else if (S = 'OVER') and (SP < Max) then
        Push(Stack[SP - 1])
      else if Length(S) = 1 then
        case S[1] of
          '+' : Push(Pop + Pop);
          '-' : begin
                  A := Pop;
                  Push(Pop - A);
                end;
          '*' : Push(Pop * Pop);
          '/' : if Stack[SP] <> 0 then
                begin
                  A := Pop;
                  Push(Pop / A);
                end;
          '^' : if Stack[SP - 1] > 0 then
                begin
                  A := Pop;
                  Push(Exp(A*Ln(Pop)));
                end;
        end { case }
end; { VegreHajt }

begin { program }
  SP := 0;
  Fajl := False;
  if ParamCount <> 0 then
    Futtat(ParamStr(1));
  repeat
    Kiir;
    if Fajl then
      if Eof(F) then
      begin
        Close(F);
        Sor := '';
        Fajl := False;
      end
      else
      begin
        ReadLn(F, Sor);
        WriteLn(Sor);
      end
    else
      ReadLn(Sor);
    for I := 1 to Length(Sor) do
      Sor[I] := Upcase(Sor[I]);
    S := '';
    while (Sor <> '') and (S <> 'QUIT') do
    begin
      I := 1;
      while (I <= Length(Sor)) and (not (Sor[I] in ElvalKar)) do
        Inc(I);
      S := Copy(Sor, 1, I - 1);
      Delete(Sor, 1, I);
      VegreHajt(S);
    end; { while }
  until S = 'BYE';
  if Fajl then
    Close(F);
  ClrScr;
end. { program }
