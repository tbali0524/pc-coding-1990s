program keresztrejtveny;

uses Crt;

const
  n = 14;
  m = 24;

var
  i,j,szamlalo : integer;
  k            : array [0..n+1,0..m+1] of integer;

begin
  for i:=0 to n+1 do
  begin
    k [i,0]:=-1;
    k [i,m+1]:=-1;
  end;
  for i:=1 to m do
  begin
    k [0,i]:=-1;
    k [n+1,i]:=-1;
  end;
  for i:=1 to n do
    for j:=1 to m do
      if Random(10)=0
      then
        k [i,j]:=-1
      else
        k [i,j]:=0;
  szamlalo:=1;
  for i:=1 to n do
  begin
    for j:= 1 to m do
    begin
      if k [i,j] = 0 then
        if (k [i,j-1] = -1) and (k [i,j+1] = 0) then
        begin
          k [i,j]:=szamlalo;
          szamlalo:=szamlalo+1;
        end
        else
          if (k [i-1,j] = -1) and (k [i+1,j] = 0) then
          begin
            k [i,j]:=szamlalo;
            szamlalo:=szamlalo+1;
          end;
    end; { for j }
  end; { for i}
  ClrScr;
  GoToXY(25,2);
  TextColor(Green);
  Writeln('KERESZTREJTVENY SZAMOZO PROGRAM');
  GoToXY(15,4);
  TextColor(Cyan);
  Writeln('(c) Copyright: 1990. SztranyÖk ZoltÖn & T¢th BÖlint');
  for i:= 0 to n+1 do
  begin
    WriteLn;
    for j := 0 to m+1 do
      case k [i,j] of
        -1 : begin
               TextColor(Blue);
               Write('€€€');
               TextColor(White);
             end;
         0 : Write('   ');
        else Write(k [i,j]:3);
      end;
  end;
  GoToXY(24,23);
  TextColor(Yellow);
  Write('KÇrem nyomjon meg egy billentyÅt!');
  repeat
  until KeyPressed;
end.
