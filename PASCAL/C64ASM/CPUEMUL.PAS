{ MCS6510 MikroProcesszor Emul tor }
{         F“Program                }
{ Copyright (c) 1991  T¢th B lint  }

program CPUEmul;

uses Crt, Emul6510, Mon6510;

var Bill : char;

procedure KiIrMenu;
begin
  ClrScr;
  GoToXY(13, 1);
  Write('M C S   6 5 1 0   -   C P U   E M U L A T O R');
  GoToXY(17, 3);
  Write('(c) Copyright  1991  T¢th B lint');
  GoToXY(30, 7);
  Write('E - Execute');
  GoToXY(30, 8);
  Write('T - Trace');
  GoToXY(30, 9);
  Write('M - Monitor');
  GoToXY(30, 10);
  Write('D - Disassembler');
  GoToXY(30, 11);
  Write('A - Assembler');
  GoToXY(30, 12);
  Write('L - Load');
  GoToXY(30, 13);
  Write('S - Save');
  GoToXY(30, 14);
  Write('F - Fill');
  GoToXY(30, 15);
  Write('C - Copy');
  GoToXY(30, 16);
  Write('P - Compare');
  GoToXY(30, 17);
  Write('H - Hunt');
  GoToXY(30, 18);
  Write('R - Registers');
  GoToXY(30, 20);
  Write('Q - Quit');
  GoToXY(28, 24);
  Write('Select option!');
end; { KiIrMenu }

begin { program }
  if ParamCount > 0 then
    Tolt(ParamStr(1));
  repeat
    KiIrMenu;
    repeat
      Bill := UpCase(ReadKey);
    until Bill in ['E', 'T', 'M', 'D', 'A', 'L', 'S', 'F',
                   'C', 'P', 'H', 'R', 'Q', 'X', Esc];
    case Bill of
      'E' : MExecute;
      'T' : MTrace;
      'M' : Monitor;
      'D' : DisAssembler;
      'A' : Assembler;
      'L' : MLoad;
      'S' : MSave;
      'F' : MFill;
      'C' : MCopy;
      'P' : MCompare;
      'H' : MHunt;
      'R' : MRegisters;
    end; { case }
  until Bill in ['Q', 'X', Esc];
  ClrScr;
  Close6510;
end. { program }