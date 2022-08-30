{ String beolvas†sa billentyñzetrìl kurzorpozicion†l†ssal }
program ReadString;

uses Crt;

type
  ChrSetT = Set of Char;

const
  kbLeft  = #75;
  kbRight = #77;
  kbHome  = #71;
  kbEnd   = #79;
  kbCtrlEnd   = #117;
  kbIns = #82;
  kbDel = #83;
  kbAltE = #18;
  kbAltR = #19;
  kbAltY = #21;
  kbAltU = #22;
  kbAltI = #23;
  kbAltO = #24;
  kbAltA = #30;
  kbAlt1 = #120;
  kbAlt2 = #121;
  kbAlt3 = #122;
  kbAlt4 = #123;
  kbAlt5 = #124;
  kbAlt6 = #125;

  kbBackSpace = #8;
  kbEnter = #13;
  kbEsc   = #27;
  Beep     = #7;

  SPC: String[80] = '                                                    ' +
    '                            ';
  SBill: String[14] =
    kbAltA + kbAltE + kbAltI + kbAltO + kbAltU + kbAlt1 + kbAlt2 + kbAlt3 +
    kbAlt4 + kbAlt5 + kbAlt6;
  SKar: String[14] = '†Ç°¢£îÅèêôö';

procedure ReadStr(var S: String; X, Y, Meret: Integer; ChrSet: ChrSetT);

var
  Bi, SB: Char;
  BiztMas: String;
  InsMode, Vege: Boolean;
  P, I: Integer;

procedure Kiir;
begin
  S := Copy(S + SPC, 1, Meret);
  GotoXY(X, Y);
  Write(S);
end;

procedure BeirKar(Kar: Char);
begin
  if Kar in ChrSet then
  begin
    if InsMode then
    begin
      Insert(Kar, S, P);
      Kiir;
    end
    else
    begin
      S[P] := Kar;
      Write(Kar);
    end;
    if P < Meret then
      Inc(P);
  end;
end;

begin { ReadStr }
  BiztMas := S;
  InsMode := True;
  Vege := False;
  P := 1;
  Kiir;
  repeat
    GotoXY(X + P - 1, Y);
    Bi := ReadKey;
    SB := #0;
    case Bi of
      #0: begin
            SB := ReadKey;
            case SB of
              kbLeft:
                if P > 1 then
                  Dec(P);
              kbRight:
                if P < Meret then
                  Inc(P);
              kbHome:
                P := 1;
              kbEnd:
                begin
                  P := Meret;
                  while (S[P] = ' ') and (P > 1) do
                    Dec(P);
                  if (P < Meret) and (S[P] <> ' ') then
                    Inc(P);
                  if P = 1 then
                    P := Meret;
                end;
              kbCtrlEnd:
                P := Meret;
              kbAltY, kbAltR:
                begin
                  S := '';
                  P := 1;
                  Kiir;
                end;
              kbDel:
                begin
                  Delete(S, P, 1);
                  Kiir;
                end;
              kbIns:
                begin
                  InsMode := not InsMode;
                  Write(Beep);
                end;
              else
              begin
                I := Pos(SB, SBill);
                if I > 0 then
                  BeirKar(SKar[I]);
              end;
            end; { case SB }
          end; { case #0 }
      kbBackSpace:
        if P > 1 then
        begin
          Dec(P);
          Delete(S, P, 1);
          Kiir;
        end;
      kbEnter, kbEsc:
        Vege := True;
      else
        BeirKar(Bi);
    end; { case }
  until Vege;
  if Bi = kbEsc then
  begin
    S := BiztMas;
    Kiir;
    S := BiztMas;
  end;
end; { ReadStr }

var
  St: String;

begin
  ClrScr;
  Write('Pr¢ba: ');
  St := 'alapert';
  ReadStr(St, 8, 1, 15, [' '..'˛']);
  WriteLn;
  WriteLn(St);
end.