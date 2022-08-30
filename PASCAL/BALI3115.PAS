program bali3115;

uses Crt;

const
  n = 20;

var
  i,eredmeny : integer;
  a          : array [1..n] of integer;
  nulla      : boolean;

procedure amegadas;
begin
  Randomize;
  for i:=1 to n do
    a [i]:=Random(5)-2;
end;

procedure akiiras;
begin
  ClrScr;
  WriteLn('Az A (N) vektor:');
  for i:=1 to n do
    WriteLn(a[i]);
end;

procedure nullkereses;
begin
  i:=1;
  nulla:=false;
  repeat
    if a[i]=0 then
      nulla:=true;
    i:=i+1;
  until (i>n) or nulla
end;

procedure negativszamolas;
begin
  eredmeny:=0;
  while i<=n do
  begin
    if a[i]<0 then
      eredmeny:=eredmeny+1;
    i:=i+1;
  end;
end;

procedure eredmenykiiras;
begin
  Write('Az elso nulla utani negativ elemek szama: ');
  WriteLn(eredmeny);
  repeat
  until KeyPressed;
end;

begin { program }
  amegadas;
  akiiras;
  nullkereses;
  negativszamolas;
  eredmenykiiras;
end.
