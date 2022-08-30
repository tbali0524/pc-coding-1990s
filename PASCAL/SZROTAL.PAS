program balirotate;

uses crt;

var  i,j,a,b  : integer;
     szoveg   : string;
     szamlalo : integer;

procedure bevitel;
  begin
    clrscr;
    write('Kerem a szoveget: ');
    read(szoveg);
    clrscr;
  end;

procedure felsosor;
  begin
    gotoXY(1, 1);
    write(szoveg);
    write(copy(szoveg,1,1));
  end;

procedure kozepe;
  begin
    gotoXY(1,b);
    write(copy(szoveg,a,1));
    gotoXY(length(szoveg) + 1, b);
    write(copy(szoveg,b,1));
    a :=a-1;
    b :=b+1;
  end;

procedure alsosor;
  begin
    gotoXY(1,length(szoveg));
    for i:= 1 to length(szoveg)+ 1 do
      begin
        write(copy(szoveg,a,1));
        a :=a-1;
        if a = 0 then a := length(szoveg);
      end;
  end;

procedure leptetszoveg;
  begin
    szoveg := concat(copy(szoveg,2,length(szoveg)-1),copy(szoveg,1,1));
  end;

begin
  bevitel;
  szamlalo:=2*length(szoveg)+2;
  repeat
    felsosor;
    a := length(szoveg);
    b := 2;
    for j:=1 to length(szoveg) - 1 do
      kozepe ;
    alsosor;
    leptetszoveg;
    delay(400);
    szamlalo := szamlalo - 1
  until szamlalo = 0
end.

