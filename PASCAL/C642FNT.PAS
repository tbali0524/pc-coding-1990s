program C642FNT;

var
  Inp, Out: File of Byte;
  Start: LongInt;

procedure Konv(OldCode, NewCode, Len: Byte);
var
  B1, B2, B3, B4, B5: Byte;
begin
  Seek(Inp, Start + OldCode * 8);
  for B3 := NewCode to NewCode + Len - 1 do
  begin
    Write(Out, B3);
    for B4 := 1 to 8 do
    begin
      Read(Inp, B1);
      for B5 := 7 downto 0 do
      begin
        if (B1 and (1 shl B5)) <> 0 then
          B2 := 1
        else
          B2 := 127;
        Write(Out, B2);
      end;
    end;
  end;
end;

procedure Make(S: String);
var
  B1, B2, B3, B4, B5: Byte;
begin
  Assign(Out, S);
  Rewrite(Out);
  B1 := 70; { FNT }
  B2 := 78;
  B3 := 84;
  Write(Out, B1, B2, B3);
  B1 := 7;
  B2 := 7;
  B3 := 8;
  B4 := 89;
  Write(Out, B1, B2, B3, B4);

  Konv(32, 32, 32);
  Konv(0, 64, 1);
  Konv(65, 65, 26);
  Konv(27, 91, 1);
  Konv(29, 93, 2);
  Konv(64, 95, 1);
  Konv(1, 97, 26);
  Close(Out);
end;

begin
  Assign(Inp, 'romcode.c64');
  Reset(Inp);
  Start := 16384 + 2048;
  Make('C64CHAR.FNT');
  Close(Inp);
end.
