{ DARABJEGYZ?K NYILV?NTART? ?S FELDOLGOZ? PROGRAM
  Verzi?: 1.1 (Kiadva: 1991. november 15.)
  Copyright (c) 1991  T?th B?lint
  Eredeti (Commodore 128 BASIC) v?ltozat: N?meth Ferenc & T?th J?zsef (1988)

F?program ( Turbo Pascal 6.0 )
}
program DarabJegyzek;

uses Crt, Dos, DJ1Dolg, DJ1Szerk;

procedure KiIrMenu;
begin
  ClrScr;
  GoToXY(18, 2);
  Write('DARABJEGYZ?K NYILV?NTART? ?S FELDOLGOZ? PROGRAM');
  GoToXY(21, 3);
  Write('Verzi?: 1.1 (Kiadva: 1991. november 15.)');
  GoToXY(18, 4);
  Write('K?sz?tett?k: T?th B?lint (IBM PC v?ltozat),');
  GoToXY(9, 5);
  Write('N?meth Ferenc ?s T?th J?zsef (eredeti, Commodore 128 v?ltozat)');
  GoToXY(11, 7);
  Write('Jogosult felhaszn?l?: GANZ DANUBIUS  Kaz?n- ?s G?pgy?rt? RT');
  GoToXY(23, 10);
  Write('D - Darabjegyz?k szerkeszt?s');
  GoToXY(23, 12);
  Write('A - Anyagjegyz?k rajzv?laszt?ssal');
  GoToXY(23, 14);
  Write('T - Anyagjegyz?k t?r?s szerint');
  GoToXY(23, 16);
  Write('R - Rajzjegyz?k t?r?s szerint');
  GoToXY(23, 18);
  Write('K - Szabv?nyk?nyvt?r nyomtat?s');
  GoToXY(23, 20);
  Write('U - ?j meghajt? vagy directory');
  GoToXY(23, 22);
  Write('V - V?ge');
  GoToXY(32, 24);
  Write('K?rem v?lasszon! ');
end; { KiIrMenu }

begin { FoProgram }
  Ut := FExpand('.');
  if Ut[Length(Ut)] <> '\' then
    Ut := Ut + '\';
  repeat
    KiIrMenu;
    repeat
      MBill := UpCase(ReadKey);
    until MBill in ['D', 'A', 'T', 'R', 'K', 'U', 'V', Esc, AltX];
    ClrScr;
    case MBill of
      'D' : DarabJSZ;
      'A' : AnyagJR;
      'T' : AnyagJT;
      'R' : RajzJT;
      'K' : AnyagKonyvTarNy;
      'U' : UjMD;
    end; { case }
  until MBill in ['V', Esc, AltX];
end. { FoProgram }