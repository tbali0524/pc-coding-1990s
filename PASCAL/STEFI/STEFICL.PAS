{******************************************}
{                                          }
{        S T E F I   - gr†fprogram         }
{                                          }
{   Copyright (c) 1995,96 by T¢th B†lint   }
{           Borland Pascal 7.0             }
{                                          }
{******************************************}

{ DOS command line valtozat }

{ Foprogram }
program StefiCL;

{$B-,X+}

uses GrStrukt, GrafAlg, GrSzerk, Graph;

procedure EgaVgaDriverProc; external;   { Grafikus meghajto }
{$L EGAVGA.OBJ}

{ ========================================================================== }

{ Grafika inicializalasa }
function Init: Boolean;
var
  grDriver: Integer;
  grMode: Integer;
  Ok: Boolean;
begin
  Ok := RegisterBGIDriver(@EgaVgaDriverProc) >= 0;
  if Ok then
  begin
    grDriver := VGA;
    grMode := VGAHi;
    InitGraph(grDriver, grMode, '');
    Ok := grDriver >= 0;
  end;
  Init := Ok;
end; { Init }

{ ========================================================================== }

const
  ReportFName = 'REPORT.TXT';
var
  GrafFName: String;
  G: PGraf;                             { Graf }

{ Foprogram }
begin
  if not Init then
  begin
    Writeln(TitleStr);
    Writeln('Hiba: Nem sikerÅlt a VGA grafik†t inicializ†lni.');
  end
  else
  begin
    if ParamCount > 0 then
    begin
      GrafFName := ParamStr(1);
      LoadGraf(G, GrafFName);
    end
    else
    begin
      GrafFName := '';
      New(G);
      G^ := UresGraf;
    end;
    Szerk(G);
    CloseGraph;
    WriteLn(TitleStr);
    SzamitIncM(G);
    SzamitKomp(G);
    SzamitKorM(G);
    SzamitFokLista(G);
    SzamitPruferKod(G);
    SzamitEulerUt(G);
    SzamitMinTav(G);
    SzamitExcentritas(G);
    SzamitMinFeszitoFa(G);
    SzamitTopRendezes(G);
    SzamitErosKomp(G);
    if (GrafFName <> '') and (not SaveGraf(G, GrafFName)) then
      WriteLn('Hiba: Nem sikerÅlt kimenteni a gr†fot.');
    if not Jelentes(G, ReportFName, InpAll, ResAll, RepW250, RepHungarian) then
      WriteLn('Hiba: Nem sikerÅlt jelentÇst kÇsz°teni.');
    DisposeGraf(G);
  end; { if not Init else }
end. { Foprogram }

{ ========================================================================== }
