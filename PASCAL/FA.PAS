program Fa;
const
  N = 971;
type
  PFaT= ^FaT;
  FaT= Record
    Sz: Integer;
    B, J: PFaT;
  end;

var
  F: FaT;
  Max, M, I, L: Integer;

procedure Berak(var Fa: FaT; S: Integer);
begin
  Inc(M);
  if M > Max then
    Max := M;
  if S < Fa.Sz then
  begin
    if Fa.B = Nil then
    begin
      if Fa.J = Nil then
        Dec(L);
      New(Fa.B);
      with Fa.B^ do
      begin
        Sz := S;
        B := Nil;
        J := Nil;
      end;
      Inc(L);
    end
    else
      Berak(Fa.B^, S)
  end
  else if S > Fa.Sz then
    if Fa.J = Nil then
    begin
      if Fa.B = Nil then
        Dec(L);
      New(Fa.J);
      with Fa.J^ do
      begin
        Sz := S;
        B := Nil;
        J := Nil;
      end;
      Inc(L);
    end
    else
      Berak(Fa.J^, S);
  Dec(M);
end;

begin
  RandSeed := 0;
  F.B := Nil;
  F.J := Nil;
  F.Sz := 0;
  Max := 0;
  L := 1;
  for I := 1 to N do
  begin
    M := 0;
    Berak(F, Random(1000) + 1);
  end;
  WriteLn(Max);
  Writeln(L);
end.
