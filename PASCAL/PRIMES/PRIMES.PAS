{ PRIMEK LISTAJA ES PRIMTENYEZOS FELBONTAS
  (c) 1991 by T¢th B lint

  ENGLISH LANGUAGE EXTENSIONS: T¢th B lint, 1995
}
program Primes;

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
  WriteLn('Usage:  PRIMES  options');
  WriteLn;
  Writeln('Options:');
  WriteLn('  /?            shows this help');
  WriteLn('  /n:number     greatest examined number ( 1 < N < ', NMax,
          ' )  default is 1000');
  WriteLn('  /p            list of the prime numbers between 1 and N');
  WriteLn('                    to the file PRIMES.TXT');
  WriteLn('  /p:filename   same as /p but to the file "filename"');
  WriteLn('  /f            prime factorization of the numbers between 1 and N');
  WriteLn('                    to the file FACTOR.TXT');
  WriteLn('  /f:filename   same as /f but to the file "filename"');
  WriteLn;
  Halt(1);
end; { Segitseg }

procedure Parameter;
begin
  if ParamCount = 0 then
    Segitseg;
  PKell := false;
  PFileNev := 'PRIMES.TXT';
  FKell := false;
  FFileNev := 'FACTOR.TXT';
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
    WriteLn('I/O Error!');
    Halt(2);
  end;
  WriteLn(PFile, 'PRIMES   by B lint T¢th, 1991,95   - This program is FREEWARE!');
  WriteLn(PFile);
  WriteLn(PFile, 'The prime numbers between 1 and ', N, ':');
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
  WriteLn(FFile, 'PRIMES   by B lint T¢th, 1991,95   - This program is FREEWARE!');
  WriteLn(FFile);
  WriteLn(FFile, 'Prime factorization of the numbers between 1 and ', N, ':');
  WriteLn(FFile, 1 : JegyekSzama);
  for I := 2 to N do
  begin
    Write(FFile, I : JegyekSzama);
    if Prim[I] then
      WriteLn(FFile, ' : prime')
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
  WriteLn('PRIMES   Copyright (c) 1991,95  B lint T¢th  - This program is FREEWARE!');
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
      WriteLn('I/O Error!');
      Halt(2);
    end;
    Felbontas;
    Close(FFile);
  end;
end.
