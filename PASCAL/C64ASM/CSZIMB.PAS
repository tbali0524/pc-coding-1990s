{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1993,97 by T¢th B†lint       }
{                                                }
{************************************************}

unit CSzimb; { Szimb¢lumt†bl†zat kezelÇs }

{$B-,X+}
interface

uses CGlobals, CMemTool;

const
  AzonHossz = 16;
  NONEStr =  '<none>';

type
  AzonT = String[AzonHossz];           { azonos°t¢ (szimb¢lumnÇv) }

  { A szimb¢lumt†bla egy eleme }
  PElem = ^TElem;
  TElem = Record
    Nev: AzonT;
    Tart: Word;
    LGL: Word;    { csak helyi szimb¢lumn†l: legutols¢ glob†lis cimke c°me }
    Next: PElem;
  end;

  { Szimb¢lumt†bla: cimkÇk vagy konstansok }
  PSzimb = ^TSzimb;
  TSzimb = object
    Elso: PElem;	{ elsì elem a l†ncolt list†ban }
    Meret: Word;	{ kÅlînbîzì nevñ elemek sz†ma }
    constructor Init;
    destructor Done;
    procedure Torol;
    function UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean; virtual;
    procedure Hozzafuz(ASzimb: PSzimb);
    function Keres(ANev: AzonT; ALGL: Word): PElem;
    procedure Lista(var F: Text); virtual;
  end;

  { Szimb¢lumt†bla: v†ltoz¢k }
  PValt = ^TValt;
  TValt = object(TSzimb)
    function UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean; virtual;
  end;

  { Szimb¢lumt†bla: helyi cimkÇk vagy konstansok }
  PHelyi = ^THelyi;
  THelyi = object(TSzimb)
    function UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean; virtual;
    procedure Lista(var F: Text); virtual;
  end;

  { Szimb¢lumt†bla: forr†s cimkÇk (.LABEL) }
  PSrcCimke = ^TSrcCimke;
  TSrcCimke = object(TSzimb)
    function UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean; virtual;
    procedure Lista(var F: Text); virtual;
  end;

  { Szimb¢lumt†bla: forr†s Çs bin†ris include f†jlok }
  PInclFiles = ^TInclFiles;
  TInclFiles = object(THelyi)
    procedure Lista(var F: Text); virtual;
  end;

  PIncBinFiles = ^TIncBinFiles;
  TIncBinFiles = object(TInclFiles)
    { az îrîkîlt Lista elj†r†sban itt "byte" a mÇrtÇkegysÇg }
  end;

implementation

const
   SPC: String[20] = '                     ';

{ Azonos°t¢nÇv elhelyezÇse sz¢kîzîkkel }
function IndentAzon(S: AzonT): String;
begin
  if Length(S) <= 8 then
    IndentAzon := '          ' + S + Copy(SPC, 1, 9 - Length(S))
  else
    IndentAzon := Copy(SPC, 1, 18 - Length(S)) + S + ' ';
end; { IndentAzon }

{ ================================================================== }
{ TSzimb objektum }

constructor TSzimb.Init;
begin
  Elso := Nil;
  Meret := 0;
end;

destructor TSzimb.Done;
begin
  Torol;
end;

{ ================================================================== }
{ Szimb¢lumt†bla tîrlÇse }
procedure TSzimb.Torol;
var
  P: PElem;
begin
  while Elso <> Nil do
  begin
    P := Elso^.Next;
    Dispose(Elso);
    Elso := P;
  end;
  Meret := 0;
end; { Torol }

{ ================================================================== }
{ £j elem felvÇtele a list†ba }
{ Ha m†r volt ilyen nevñ, akkor az eredmÇny False }
function TSzimb.UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean;
var
  P: PElem;
begin
  UjElem := True;
  if Elso = Nil then                   { elsì szimb¢lum }
  begin
    New(Elso);
    with Elso^ do begin
      Nev := ANev;
      Tart := ATart;
      LGL := ALGL;
      Next := Nil;
    end;
    Meret := 1;
  end { if Elso }
  else
  begin
    P := Elso;
    while (P^.Next <> Nil) and (P^.Nev <> ANev) do
      P := P^.Next;
    if P^.Nev <> ANev then             { £j szimb¢lum }
    begin
      New(P^.Next);
      with P^.Next^ do begin
        Nev := ANev;
        Tart := ATart;
        LGL := ALGL;
        Next := Nil;
      end;
      Inc(Meret);
    end
    else                               { m†r van ilyen nevñ }
      UjElem := False;
  end; { if Elso else }
end; { UjElem }

{ ================================================================== }
{ M†sik lista objektum hozz†fñzÇse a szimb¢lumlist†hoz }
{ (A m†sik lista tîrlìdik, de az objektum megmarad) }
procedure TSzimb.Hozzafuz(ASzimb: PSzimb);
var
  P: PElem;
  B: Boolean;
begin
  P := ASzimb^.Elso;
  while P <> Nil do
  begin
    B := UjElem(P^.Nev, P^.Tart, P^.LGL);
    P := P^.Next;
  end;
end; { Hozzafuz }

{ ================================================================== }
{ Elem keresÇse nÇv + LGL alapj†n a list†ban }
function TSzimb.Keres(ANev: AzonT; ALGL: Word): PElem;
var
  P: PElem;
begin
  if Elso = Nil then
    Keres := Nil
  else
  begin
    P := Elso;
    while (P <> Nil) and ((P^.Nev <> ANev) or (P^.LGL <> ALGL)) do
      P := P^.Next;
    Keres := P;
  end;
end; { Keres }

{ ================================================================== }
{ Szimb¢lumlista ki°r†sa megnyitott szîvegf†jlba }
procedure TSzimb.Lista(var F: Text);
var
  P: PElem;
  S: String;
begin
  if Elso = Nil then
    WriteLn(F, ' ' :10, NONEStr)
  else
  begin
    P := Elso;
    while P <> Nil do
    begin
      if P^.Tart < $100 then
        S := HBS(P^.Tart)
      else
        S := HWS(P^.Tart);
      WriteLn(F, IndentAzon(P^.Nev), '= $', S);
      P := P^.Next;
    end; { while }
  end; { if Elso else }
end; { Lista }

{ ================================================================== }
{ TValt objektum }

{ £j elem felvÇtele a list†ba }
{ Ha m†r volt ilyen nevñ, akkor £j ÇrtÇket kap Çs az eredmÇny False }
function TValt.UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean;
var
  P: PElem;
begin
  UjElem := True;
  if Elso = Nil then                   { elsì szimb¢lum }
  begin
    New(Elso);
    with Elso^ do begin
      Nev := ANev;
      Tart := ATart;
      LGL := ALGL;
      Next := Nil;
    end;
    Meret := 1;
  end
  else
  begin
    P := Elso;
    while (P^.Next <> Nil) and (P^.Nev <> ANev) do
      P := P^.Next;
    if P^.Nev <> ANev then             { £j szimb¢lum }
    begin
      New(P^.Next);
      with P^.Next^ do begin
        Nev := ANev;
        Tart := ATart;
        LGL := ALGL;
        Next := Nil;
      end;
      Inc(Meret);
    end
    else                               { m†r van ilyen nevñ }
    begin
      P^.Tart := ATart;
      UjElem := False;
    end; { if P^.Nev else }
  end; { if Elso else }
end; { UjElem }

{ ================================================================== }
{ THelyi objektum }

{ £j elem felvÇtele a list†ba }
{ Ha m†r volt ilyen nevñ m†s LGL-lel, akkor is felveszi }
{ Ha az LGL is stimmel, az eredmÇny False }
function THelyi.UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean;
var
  P, P1: PElem;
begin
  UjElem := True;
  New(P1);
  with P1^ do
  begin
    Nev := ANev;
    Tart := ATart;
    LGL := ALGL;
    Next := Nil;
  end;
  if Elso = Nil then                   { elsì szimb¢lum }
  begin
    Elso := P1;
    Meret := 1;
  end
  else
  begin
    P := Elso;
    while (P^.Next <> Nil) and (P^.Nev <> ANev) do
      P := P^.Next;
    if P^.Nev <> ANev then             { £j szimb¢lum }
    begin
      P^.Next := P1;
      Inc(Meret);
    end
    else                               { m†r van ilyen nevñ }
      if P^.LGL <> ALGL then
      begin
        P1^.Next := P^.Next;
        P^.Next := P1;
      end
      else
      begin
        Dispose(P1);
        UjElem := False;
      end;
  end; { if Elso else }
end; { UjElem }

{ ================================================================== }
{ Szimb¢lumlista ki°r†sa megnyitott szîvegf†jlba }
procedure THelyi.Lista(var F: Text);
var
  P: PElem;
  S: String;
  PrevNev: AzonT;
  Len: Integer;
begin
  if Elso = Nil then
    WriteLn(F, ' ' :10, NONEStr)
  else
  begin
    P := Elso;
    PrevNev := '';
    while P <> Nil do
    begin
      if P^.Tart < $100 then
        S := HBS(P^.Tart)
      else
        S := HWS(P^.Tart);
      if P^.Nev <> PrevNev then
      begin
        if P <> Elso then
          WriteLn(F);
        Write(F, IndentAzon(P^.Nev), '= $', S);
        Len := AzonHossz + 6 + Length(S);
      end
      else
      begin
        if Len > 72 then
        begin
          WriteLn(F);
          Len := AzonHossz + 6 + Length(S);
          Write(F, ' ': AzonHossz + 2, '$', S);
        end
        else
        begin
          Write(F, ', $', S);
          Inc(Len, Length(S) + 3);
        end;
      end; { if P^ else }
      PrevNev := P^.Nev;
      P := P^.Next;
    end; { while }
    WriteLn(F);
  end; { if Elso else }
end; { Lista }

{ ================================================================== }
{ TSrcCimke objektum }

{ £j elem felvÇtele a list†ba }
{ A sz†ml†l¢t friss°ti, ha t£lcsordult, az eredmÇny False }
function TSrcCimke.UjElem(ANev: AzonT; ATart: Word; ALGL: Word): Boolean;
var
  P: PElem;
begin
  UjElem := True;
  if Elso = Nil then                   { elsì szimb¢lum }
  begin
    New(Elso);
    with Elso^ do begin
      Nev := ANev;
      Tart := 1;
      LGL := ALGL;
      Next := Nil;
    end;
    Meret := 1;
  end
  else
  begin
    P := Elso;
    while (P^.Next <> Nil) and (P^.Nev <> ANev) do
      P := P^.Next;
    if P^.Nev <> ANev then             { £j szimb¢lum }
    begin
      New(P^.Next);
      with P^.Next^ do begin
        Nev := ANev;
        Tart := 1;
        LGL := ALGL;
        Next := Nil;
      end;
      Inc(Meret);
    end
    else                               { m†r van ilyen nevñ }
    begin
      P^.Tart := P^.Tart + 1;
      UjElem := P^.Tart < $FFFF;
    end; { if P^.Nev else }
  end; { if Elso else }
end; { UjElem }

{ ================================================================== }
{ Szimb¢lumlista ki°r†sa megnyitott szîvegf†jlba }
procedure TSrcCimke.Lista(var F: Text);
var
  P: PElem;
begin
  if Elso = Nil then
    WriteLn(F, ' ' :10, NONEStr)
  else
  begin
    P := Elso;
    while P <> Nil do
    begin
      WriteLn(F, IndentAzon(P^.Nev));
      P := P^.Next;
    end; { while }
  end; { if Elso else }
end; { Lista }

{ ================================================================== }
{ TInclFiles objektum }

{ Szimb¢lumlista ki°r†sa megnyitott szîvegf†jlba }
procedure TInclFiles.Lista(var F: Text);
var
  P: PElem;
  S: String;
  PrevNev: AzonT;
  Count: Integer;
  Dimension: String;
begin
  if TypeOf(Self) = TypeOf(TIncBinFiles) then
    Dimension := ' bytes'
  else
    Dimension := ' lines';
  if Elso = Nil then
    WriteLn(F, ' ' :4, NONEStr)
  else
  begin
    P := Elso;
    PrevNev := '';
    Count := 0;
    while P <> Nil do
    begin
      if P^.Nev <> PrevNev then
      begin
        if P <> Elso then
        begin
          if Count > 1 then
            WriteLn(F, ', ', Count, ' times)')
          else
            WriteLn(F, ')');
        end; { if P <> }
        Count := 0;
        Write(F, '    ', P^.Nev, ' ' : 14 - Length(P^.Nev), '(', P^.Tart,
          Dimension);
      end; { if P^.Nev }
      Inc(Count);
      PrevNev := P^.Nev;
      P := P^.Next;
    end; { while }
    if Count > 1 then
      WriteLn(F, ', ', Count, ' times)')
    else
      WriteLn(F, ')');
  end; { if Elso else }
end; { Lista }

end.