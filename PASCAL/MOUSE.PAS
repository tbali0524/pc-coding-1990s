program Mouse;

uses Crt, Dos;

var
  Regs: Registers;
  Vege: Boolean;
  C: Char;

begin
  ClrScr;
  Regs.AX := 0;
  Intr($33, Regs);
  if Regs.AX = 0 then
  begin
    WriteLn('Eg‚r nincs detekt lva!');
    Halt(1);
  end;
  Write('Karakter: ');
  Regs.AX := 1;
  Intr($33, Regs);
  Vege := False;
  repeat
    if KeyPressed then
    begin
      C := ReadKey;
      case C of
        #0:  C := ReadKey;
        ' '..'þ': begin
                    GoToXY(11, 1);
                    Write(C);
                  end;
        #27: Vege := True;
      end;
    end;
    Regs.AX := 5;
    Regs.BX := 0;
    Intr($33, Regs);
    Vege := Vege or (Regs.AX and 1 <> 0)
  until Vege;
end.
