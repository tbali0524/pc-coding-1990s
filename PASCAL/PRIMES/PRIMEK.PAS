program Primek;

const
  NMax        = 60000;
  JegyekSzama = 5;
  OszlSzel    = 13;

var
  PFile, Ffile       : text;
  Param,
  PFileNev, FFileNev : string;
  PKell, FKell       : boolean;
  Prim               : array[1..NMax] of boolean;
  N, I, J, K         : word;

procedure Segitseg;
begin
  WriteLn;
  WriteLn('Hasznalat:  PRIMEK  opciok');
  WriteLn;
  Writeln('Opciok:');
  WriteLn('  /h            megjeleniti ezt a segitseget');
  WriteLn('  /n:szam       N megadasa ( 1 < N < ', NMax,
          ' )  alapertelmezes 100');
  WriteLn('  /p            primszamok listaja N-ig a PRIMLIST.TXT ',
          'nevu fajlba');
  WriteLn('  /p:filespec   primszamok listaja N-ig a "filespec" ',
          'nevu fajlba');
  WriteLn('  /f            elso N szam primtenyezos felbontasa FELBONT.TXT ',
          'nevu fajlba');
  WriteLn('  /f:filespec   elso N szam primtenyezos felbontasa "filespec" ',
          'nevu fajlba');
  WriteLn;
  Halt;
end; { Segitseg }

procedure Parameter;
begin
  if ParamCount = 0 then
    Segitseg;
  PKell := false;
  PFileNev := 'PRIMLIST.TXT';
  FKell := false;
  FFileNev := 'FELBONT.TXT';
  N := 1000;
  for I := 1 to ParamCount do
  begin
    Param := Copy(ParamStr(I), 1, 255);
    if Param[1] in ['-', '/', '\'] then
      case UpCase(Param[2]) of
        'H', '?' : Segitseg;
        'N'      : begin
                     if Param[3] <> ':' then
                       Segitseg;
                     Val(Copy(Param, 4, JegyekSzama), N, J);
                     if (J <> 0) or (N < 2) or (N > NMax) then
                       Segitseg;
                   end;
        'P'      : begin
                     PKell := true;
                     if Length(Param) > 2 then
                       if Param[3] = ':' then
                         PFileNev := Copy(Param, 4, 252)
                       else
                         Segitseg;
                   end;
        'F'      : begin
                     FKell := true;
                     if Length(Param) > 2 then
                       if Param[3] = ':' then
                         FFileNev := Copy(Param, 4, 252)
                       else
                         Segitseg;
                   end;
        else { case }
          Segitseg;
      end { case }
    else { if }
      Segitseg;
  end; { for }
  if not (PKell or FKell) then
    Segitseg;
end; { Parameter }

procedure Szita;
begin
  Prim[1] := false;
  for I := 2 to N do
    Prim[I] := true;
  for I := 2 to (Round(Sqrt(N)) + 1) do
    if Prim[I] then
    begin
      J := I + I;
      repeat
        Prim[J] := false;
        Inc(J, I);
      until J > N;
    end;
end; { Szita }

procedure PrimLista;
begin
  Assign(PFile, PFileNev);
  {$I-}
  Rewrite(PFile);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    RunError(1);
  end;
  WriteLn(PFile, 'A primszamok ', N, '-ig:');
  WriteLn(PFile);
  J := 0;
  for I := 1 to N do
    if Prim[I] then
    begin
      Inc(J);
      Write(PFile, I : JegyekSzama, ',');
      if (J mod OszlSzel) = 0 then
        WriteLn(PFile);
    end;
  WriteLn(PFile);
  Close(PFile);
end; { PrimLista }

procedure Felbontas;
begin
  WriteLn(FFile, 'A szamok primtenyezos felbontasa ', N, '-ig:');
  WriteLn(FFile, 1 : JegyekSzama);
  for I := 2 to N do
  begin
    Write(FFile, I : JegyekSzama);
    if Prim[I] then
      WriteLn(FFile, ' : prim')
    else
    begin
      Write(FFile, ' = ');
      J := I;
      K := 2;
      repeat
        if (J mod K) = 0 then
        begin
          if J <> I then
            Write(FFile, ' * ');
          Write(FFile, K);
          J := J div K;
        end { if }
        else
          repeat
            Inc(K);
          until Prim[K] or (K = J);
      until J = 1;
      WriteLn(FFile);
    end; { else }
  end; { for }
end; { Felbontas }

begin { program }
  WriteLn('PRIMEK   Copyright (c) 1991 Toth Balint');
  Parameter;
  Szita;
  if PKell then
    PrimLista;
  if FKell then
  begin
    Assign(FFile, FFileNev);
    {$I-}
    Rewrite(FFile);
    {$I+}
    if IOResult <> 0 then
    begin
      WriteLn('I/O hiba!');
      RunError(1);
    end;
    Felbontas;
    Close(FFile);
  end;
end.
