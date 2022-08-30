{ DosInfo V1.1 - DOS informaciok parancssor-parameterekkel vezerelve
  Copyright (c) 1991  T¢th B lint
}
program DosInfo;

{$M 4096,0,655360}
uses Dos, Crt, Graph;

const
  HoNev : array[1..12] of string[10] =
    ('janu r', 'febru r', 'm rcius', ' prilis', 'm jus', 'j£nius', 'j£lius',
     'augusztus', 'szeptember', 'okt¢ber', 'november', 'december');
  NapNev : array[0..6] of string[9] =
    ('vas rnap', 'h‚tf“', 'kedd', 'szerda', 'cst”rt”k', 'p‚ntek',
     'szombat');
  GrDrivers : array[1..10] of string[13] =
    ('CGA' , 'MCGA', 'EGA', 'EGA 64k', 'EGA Mono', 'IBM 8514',
     'Hercules Mono', 'AT&T 400', 'VGA', 'PC 3270');

var
  I, J, K,
  A, B, C, D : word;
  GD, GM     : integer;
  Param, S   : string;
  Kapcs      : boolean;

procedure Segitseg;
begin
  WriteLn('Haszn lat:  DOSINFO  opci¢k');
  WriteLn;
  Writeln('Opci¢k:');
  WriteLn('  /h            megjelen¡ti ezt a seg¡ts‚get');
  WriteLn('  /v            Dos verzi¢sz m');
  WriteLn('  /e            k”rnyezet-le¡r¢ v ltoz¢k list ja');
  WriteLn('  /k            Dos-kapcsol¢k  ll sa ( BREAK, VERIFY )');
  WriteLn('  /d            mai d tum');
  WriteLn('  /t            pontos id“');
  WriteLn('  /m            szabad mem¢ria');
  WriteLn('  /g            grafikus vez‚rl“ ‚s aktu lis zemm¢d');
  WriteLn('  /s[meghajt¢]  a meghajt¢ m‚rete');
  WriteLn('  /f[meghajt¢]  szabad hely a meghajt¢n');
  WriteLn('  /a[meghajt¢]  aktu lis k”nyvt r a meghajt¢n');
  Halt;
end; { Segitseg }

function KetJegyu(Szam : word) : string;

var S1 : string[5];

begin
  Str(Szam, S1);
  if Length(S1) = 1 then
    S1 := '0' + S1;
  KetJegyu := S1;
end; { KetJegyu }

function Meghajto(MNev : char) : byte;
begin
  Meghajto := Ord(UpCase(MNev)) - Ord('A') + 1;
end; { Meghajto }

function BajtKiir(Bajt : longint) : string;

var S1, S2 : string;

begin
  Str(Bajt, S1);
  S1 := S1 + ' byte';
  if Bajt > 1023 then
  begin
    Str(Bajt div 1024, S2);
    S1 := S1 + ' ( ' + S2 + ' Kbyte )';
  end;
  BajtKiir := S1;
end; { BajtKiir }

function Elerheto : boolean;
begin
  Inc(J);
  Write('A(z) ', UpCase(Param[J]), ': meghajt¢');
  if DiskSize(Meghajto(Param[J])) < 0 then
  begin
    WriteLn(' nem el‚rhet“.');
    Elerheto := false;
  end
  else
    Elerheto := true;
end; { Elerheto }

begin { program }
  if WhereX > 1 then
    WriteLn;
  WriteLn('DOSINFO  Version 1.1  Copyright (c) 1991  T¢th B lint');
  WriteLn;
  if ParamCount = 0 then
    Segitseg;
  for I := 1 to ParamCount do
  begin
    Param := ParamStr(I);
    if Param[1] in ['-', '/'] then
    begin
      J := 2;
      while J <= Length(Param) do
      begin
        case UpCase(Param[J]) of
          'H', '?' : Segitseg;
          'V' : WriteLn('Dos verzi¢: ', Lo(DosVersion), '.',
                  KetJegyu(Hi(DosVersion)));
          'E' : begin
                  WriteLn('K”rnyezet-le¡r¢ v ltoz¢k:');
                  if EnvCount = 0 then
                    WriteLn('  nincsenek.');
                  for K := 1 to EnvCount do
                    WriteLn('  ', EnvStr(K));
                end;
          'K' : begin
                  GetCBreak(Kapcs);
                  Write('Megszak¡t sbillenty– figyel‚se: ');
                  case Kapcs of
                    true  : WriteLn('bekapcsolva ( BREAK ON )');
                    false : WriteLn('nincs bekapcsolva ( BREAK OFF )');
                  end; { case }
                  GetVerify(Kapcs);
                  Write('Ellen“rz‚s lemezm–veletekn‚l: ');
                  case Kapcs of
                    true  : WriteLn('bekapcsolva ( VERIFY ON )');
                    false : WriteLn('nincs bekapcsolva ( VERIFY OFF )');
                  end; { case }
                end;
          'D' : begin
                  GetDate(A, B, C, D);
                  WriteLn('A mai d tum: ', A, '. ', HoNev[B], ' ', C, '.  ',
                          NapNev[D]);
                end;
          'T' : begin
                  GetTime(A, B, C, D);
                  WriteLn('A pontos id“: ', A, ':', KetJegyu(B), ':',
                    KetJegyu(C), '.', KetJegyu(D));
                end;
          'M' : WriteLn('A szabad mem¢ria: ', BajtKiIr(MaxAvail +
                  (Seg(HeapEnd) - PrefixSeg) shl 4));
          'G' : begin
                  DetectGraph(GD, GM);
                  WriteLn('Grafikus vez‚rl“: ', GrDrivers[GD], ' , šzemm¢d: ',
                    Lo(WindMax) + 1, ' x ', Hi(WindMax) + 1, ' (sz”veges)');
                end;
          'S' : if J = Length(Param) then
                  WriteLn('Az aktu lis meghajt¢ m‚rete: ',
                    BajtKiir(DiskSize(0)))
                else
                  if Elerheto then
                    WriteLn(' m‚rete: ',
                      BajtKiIr(DiskSize(Meghajto(Param[J]))));
          'F' : if J = Length(Param) then
                  WriteLn('Szabad hely az aktu lis meghajt¢n: ',
                    BajtKiIr(DiskFree(0)))
                else
                  if Elerheto then
                    WriteLn('n l‚v“ szabad hely: ',
                      BajtKiIr(DiskFree(Meghajto(Param[J]))));
          'A' : if J = Length(Param) then
                  WriteLn('Az aktu lis meghajt¢ ‚s k”nyvt r: ',
                    FExpand('.'))
                else
                  if Elerheto then
                  begin
                    GetDir(Meghajto(Param[J]), S);
                    WriteLn('n az aktu lis k”nyvt r: ', S);
                  end;
          else { case }
            Segitseg;
        end; { case }
        Inc(J);
      end; { while }
    end { then }
    else
      Segitseg;
  end; { for }
end. { Program }
