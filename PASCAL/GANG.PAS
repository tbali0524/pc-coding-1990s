{ T¢th B†lint, 1992 }
program Gang;

{$B-}
uses Crt;
const
  Max = 40; { bñnîzìk maxim†lis sz†ma }

var
  A: Array[1..Max, 1..Max] of Boolean; { egyÅttmñkîdÇsi adatok }
  E: Array[1..Max] of Integer; { h†ny haverja van a bñnîzìknek }
  MaxBanda, { eddigi legnagyobb banda }
  Banda: Array[1..Max] of Boolean; { jelenlegi banda }
  M, { MaxBanda mÇrete }
  H, { jelenlegi banda lÇtsz†ma }
  N, { bñnîzìk sz†ma }
  I: Integer;
  S: String;
  Bill: Char;

procedure OlvasInp(Nev: String);
var
  I, J: Integer;
  S: String;
  F: Text;
begin
  Assign(F, Nev);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(1);
  end;
  WriteLn('EgyÅttmñkîdÇsi adatok:');
  N := 0;
  while (not Eof(F)) and (N < Max) do
  begin
    Inc(N);
    E[N] := 1;
    ReadLn(F, S);
    WriteLn(S);
    if (Length(S) <> N) or (S[N] <> '1') then
    begin
      WriteLn('Nem megfelelì file-form†tum!');
      Halt(2);
    end;
    for I := 1 to N - 1 do
      case S[I] of
        '1': begin
               A[N, I] := True;
               A[I, N] := True;
               Inc(E[N]);
               Inc(E[I]);
             end;
        '0': begin
               A[N, I] := False;
               A[I, N] := False;
             end;
        else
        begin
          WriteLn('Nem megfelelì file-form†tum!');
          Halt(2);
        end;
      end; { case }
  end;
  Close(F);
end; { OlvasInp }

procedure Veletlen;
var
  I, J: Integer;
  D: Real;
  S: String;
  F: Text;
begin
  Randomize;
  repeat
    Write('Bñnîzìk sz†ma? (1 - ', Max, ') ');
    ReadLn(N);
  until (N > 0) and (N <= Max);
  repeat
    Write('EgyÅttmñkîdÇs val¢sz°nñsÇge? (0 - 1) ');
    ReadLn(D);
  until (D > 0) and (D < 1);
  Assign(F, 'RNDGANG.INP');
  Rewrite(F);
  for I := 1 to N do
  begin
    S := '';
    for J := 1 to I - 1 do
      if Random(10000) < Round(D * 10000) then
        S := S + '1'
      else
        S := S + '0';
    WriteLn(F, S + '1');
  end;
  Close(F);
  OlvasInp('RNDGANG.INP');
end; { Veletlen }

procedure Rekurziv(B: Integer);
var
  I: Integer;
begin
  Inc(H);
  I := 1;
  while (I <= N) and ((not Banda[I]) or A[I, B]) do
    Inc(I);
  if I > N then
  begin
    Banda[B] := True;
    if H > M then
    begin
      MaxBanda := Banda;
      M := H;
    end;
    for I := 1 to N do
      if (not Banda[I]) and (E[I] > M) then
        Rekurziv(I);
    Banda[B] := False;
  end; { if I > N }
  Dec(H);
end; { Rekurziv }

begin { fìprogram }
  WriteLn('Gang   (c) T¢th B†lint, 1992.');
  Write('VÇletlen adatok vagy file-b¢l vegyem? [V/F] ');
  repeat
    Bill := UpCase(ReadKey);
  until Bill in ['V', 'F'];
  WriteLn(Bill);
  if Bill = 'V' then
    Veletlen
  else
  begin
    Write('FilenÇv: ');
    ReadLn(S);
    if S = '' then
      S := 'GANG.INP';
    OlvasInp(S);
  end;
  M := 0;
  H := 0;
  for I := 1 to N do
    Banda[I] := False;
  for I := 1 to N do
    Rekurziv(I);
  WriteLn('Az egyik maxim†lis lÇtsz†m£ banda:');
  for I := 1 to N do
    if MaxBanda[I] then
      Write(I, '   ');
  WriteLn;
  WriteLn('LÇtsz†m: ', M);
  Write('[Enter] ');
  ReadLn;
end.
