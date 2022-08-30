program Bali3143;

uses Crt;

var i,eredmeny : integer;

begin
  eredmeny := 0;
  for i := 10 to 99 do
  begin
    eredmeny := eredmeny + 1;               { ketjegyuek }
    eredmeny := eredmeny + (  9 div i) + 1; { haromjegyuek }
    eredmeny := eredmeny + ( 99 div i) + 1; { negyjegyuek }
    eredmeny := eredmeny + (999 div i) + 1; { otjegyuek }
  end;
  ClrScr;
  WriteLn('Azon legfeljebb otjegyu szamok szama, melyek elso ket jegyebol');
  Write('alkotott szam osztoja az eredeti szamnak: ');
  WriteLn(eredmeny);
  repeat
  until KeyPressed;
end.
