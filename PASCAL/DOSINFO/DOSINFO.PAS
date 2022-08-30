{ DosInfo V1.3 - DOS informaciok parancssor-parameterekkel vezerelve
  Copyright (c) 1991,95  T¢th B lint
}
program DosInfo;

{$M 4096,0,655360}
uses Dos, Crt, Graph;

const
  CText: String[80] =
    'DOSINFO  V1.3  Copyright (c) 1991,95  B lint T¢th  - This program is FREEWARE!';
  HoNev: Array[1..12] of String[10] =
    ('January', 'February', 'March', 'April', 'May', 'June', 'July',
     'August', 'September', 'October', 'November', 'December');
  NapNev : Array[0..6] of String[9] =
    ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
     'Saturday');
  GrDrivers : Array[1..10] of String[13] =
    ('CGA' , 'MCGA', 'EGA', 'EGA 64k', 'EGA Mono', 'IBM 8514',
     'Hercules Mono', 'AT&T 400', 'VGA', 'PC 3270');
  SPC: String[70] = '                                                    ';

var
  N:    Word;
  Di:   DirStr;
  Na:   NameStr;
  Ex:   ExtStr;
  St:   String;
  OutFileName: String;
  OutFile    : Text;

procedure Segitseg;
begin
  WriteLn('Usage:  DOSINFO  [outputfile[.TXT]] [options]');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  /h , /?       shows this help screen');
  WriteLn('  /v            DOS version');
  WriteLn('  /e            list of environment variables');
  WriteLn('  /k            settings of DOS-switches ( BREAK, VERIFY )');
  WriteLn('  /d            current date');
  WriteLn('  /t            current time');
  WriteLn('  /m            free conventional memory');
  WriteLn('  /g            graphic driver and current mode');
  WriteLn('  /s[drive]     total space on drive');
  WriteLn('  /f[drive]     free space on drive');
  WriteLn('  /c[drive]     current directory on drive');
  WriteLn('  /a            size information about all hard drives');
  WriteLn;
  WriteLn('If output is to file, its name must be before all other options.');
  WriteLn('Invoking DOSINFO without any options equals to "DOSINFO /vdtkgmc /a"');
  Halt;
end; { Segitseg }

function KetJegyu(Szam: Word) : String;
var
  S1: String[5];
begin
  Str(Szam, S1);
  if Length(S1) = 1 then
    S1 := '0' + S1;
  KetJegyu := S1;
end; { KetJegyu }

function Meghajto(MNev: Char): Byte;
begin
  Meghajto := Ord(UpCase(MNev)) - Ord('A') + 1;
end; { Meghajto }

function BajtKiir(Bajt: Longint) : String;
var
  S1, S2, S3: String;
begin
  Str(Bajt, S1);
  S1 := S1 + ' byte';
  if Bajt >= 1024 then
  begin
    Str(Bajt div 1024, S2);
    S1 := S1 + ' (=' + S2 + 'KB';
    if Bajt >= 1024*1024 then
    begin
      Str(Bajt div (1024*1024), S2);
      Str((Bajt and $000FFFFF) div 104857, S3);
      S1 := S1 + '=' + S2 + '.' + S3 + 'MB';
    end;
    S1 := S1 + ')';
  end;
  BajtKiir := S1;
end; { BajtKiir }

procedure Opcio(Param: String);
var
  I, J, K,
  A, B, C, D: Word;
  GD, GM:     Integer;
  S:          String;
  Kapcs:      Boolean;

function Elerheto : Boolean;
begin
  Inc(J);
  Write(OutFile, 'Drive ', UpCase(Param[J]), ':');
  if DiskSize(Meghajto(Param[J])) < 0 then
  begin
    WriteLn(OutFile, ' is unavailable.');
    Elerheto := false;
  end
  else
    Elerheto := true;
end; { Elerheto }

begin
  if Param[1] in ['-', '/'] then
  begin
    J := 2;
    while J <= Length(Param) do
    begin
      case UpCase(Param[J]) of
        'H', '?' : Segitseg;
        'V' : WriteLn(OutFile, 'DOS version: ', Lo(DosVersion), '.',
                KetJegyu(Hi(DosVersion)));
        'E' : begin
                WriteLn(OutFile, 'Environment variables:');
                if EnvCount = 0 then
                  WriteLn(OutFile, '  none');
                for K := 1 to EnvCount do
                  WriteLn(OutFile, '  ', EnvStr(K));
              end;
        'K' : begin
                GetCBreak(Kapcs);
                Write(OutFile, 'BREAK-key monitoring is ');
                case Kapcs of
                  true  : Write(OutFile, 'ON, ');
                  false : Write(OutFile, 'OFF, ');
                end; { case }
                GetVerify(Kapcs);
                Write(OutFile, 'disk VERIFY is ');
                case Kapcs of
                  true  : WriteLn(OutFile, 'ON.');
                  false : WriteLn(OutFile, 'OFF.');
                end; { case }
              end;
        'D' : begin
                GetDate(A, B, C, D);
                WriteLn(OutFile, 'Current date is ', C, ' ', HoNev[B], ', ', A, '  ',
                        NapNev[D]);
              end;
        'T' : begin
                GetTime(A, B, C, D);
                WriteLn(OutFile, 'Current time is ', A, ':', KetJegyu(B), ':',
                  KetJegyu(C), '.', KetJegyu(D));
              end;
        'M' : WriteLn(OutFile, 'Free conventional memory: ', BajtKiIr(MaxAvail +
                (Seg(HeapEnd) - PrefixSeg) shl 4));
        'G' : begin
                DetectGraph(GD, GM);
                WriteLn(OutFile, 'Graphics drive: ', GrDrivers[GD], ' , Mode: ',
                  Lo(WindMax) + 1, ' x ', Hi(WindMax) + 1, ' (text)');
              end;
        'S' : if J = Length(Param) then
                WriteLn(OutFile, 'Size of current drive: ',
                  BajtKiir(DiskSize(0)))
              else
                if Elerheto then
                  WriteLn(OutFile, ' total size: ',
                    BajtKiIr(DiskSize(Meghajto(Param[J]))));
        'F' : if J = Length(Param) then
                WriteLn(OutFile, 'Free space on current drive: ',
                  BajtKiIr(DiskFree(0)))
              else
                if Elerheto then
                  WriteLn(OutFile, ' free space: ',
                    BajtKiIr(DiskFree(Meghajto(Param[J]))));
        'C' : if J = Length(Param) then
                WriteLn(OutFile, 'Current drive and directory is: ',
                  FExpand('.'))
              else
                if Elerheto then
                begin
                  GetDir(Meghajto(Param[J]), S);
                  WriteLn(OutFile, ' current directory is ', S);
                end;
        'A' : begin
                WriteLn(OutFile, 'Drive  Total space                           Free space');
                for I := 3 to 26 do
                  if DiskSize(I) >= 0 then
                  begin
                    S := BajtKiir(DiskSize(I));
                    WriteLn(OutFile, '  ', Chr(Ord('A') + I - 1), ':   ', S,
                      Copy(SPC, 1, 38 - Length(S)), BajtKiir(DiskFree(I)));
                  end;
              end;
        else { case }
          Segitseg;
      end; { case }
      Inc(J);
    end; { while }
  end { then }
  else
    Segitseg;
end; { Opcio }

begin { program }
  if WhereX > 1 then
    WriteLn;
  WriteLn(CText);
  WriteLn;
  OutFileName := '';
  if ParamCount = 0 then
  begin
    AssignCrt(OutFile);
    ReWrite(OutFile);
    Opcio('/vdtkgmc');
    Opcio('/a');
    WriteLn(OutFile);
    WriteLn(OutFile, 'Use DOSINFO /? for help on options');
  end
  else
  begin
    St := ParamStr(1);
    if not (St[1] in ['/', '-']) then
    begin
      FSplit(St, Di, Na, Ex);
      if Ex = '' then
        Ex := '.TXT';
      OutFileName := Di + Na + Ex;
      Assign(OutFile, OutFileName);
      ReWrite(OutFile);
      WriteLn(OutFile, CText);
      WriteLn(OutFile);
      if ParamCount = 1 then
      begin
        Opcio('/vdtkgmc');
        Opcio('/a');
      end
      else
        for N := 2 to ParamCount do
          Opcio(ParamStr(N));
    end { if not S[1] }
    else
    begin
      AssignCrt(OutFile);
      ReWrite(OutFile);
      for N := 1 to ParamCount do
        Opcio(ParamStr(N));
    end;
  end; { if ParamCount else }
  Close(OutFile);
end. { Program }
