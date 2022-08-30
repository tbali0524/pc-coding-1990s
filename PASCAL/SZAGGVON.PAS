program SzaggatottVonal;

uses
  Crt, Graph;

var
  Szin : 0..1;
  Gr, Gm, I : integer;
  C, Dx, Dy, X, Y,
  Kx, Vx, Ky, Vy, H : real;

procedure Bevitel;
begin
  ClrScr;
  repeat
    WriteLn('Kezdopont X, Y, Vegpont X, Y, Szakaszhossz : ');
    Read(Kx);
    Read(Ky);
    Read(Vx);
    Read(Vy);
    Read(H);
  until (730 > Kx) and (Kx >= 0) and
        (730 > Vx) and (Vx >= 0) and
        (340 > Ky) and (Ky >= 0) and
        (340 > Vy) and (Vy >= 0);
end;

begin { Program }
  Bevitel;
  DetectGraph(Gr, Gm);
  InitGraph(Gr, Gm, 'C:\BP\BGI');
  C := (Vx - Kx) / (Vy - Ky);
  Dy := Sqrt(H * H / (1 + C * C));
  if Ky > Vy then
    Dy := -Dy;
  Dx := Dy * C;
  X := Kx;
  Y := Ky;
  Szin := 1;
  for I := 1 to Trunc(Sqrt( (Vx - Kx) * (Vx - Kx) +
                            (Vy - Ky) * (Vy - Ky)  ) / H) do
  begin
    SetColor(Szin);
    Line(Trunc(X), Trunc(Y), Trunc(X + Dx), Trunc(Y + Dy));
    X := X + Dx;
    Y := Y + Dy;
    Szin := 1 - Szin;
  end;
  SetColor(Szin);
  Line(Trunc(X), Trunc(Y), Trunc(Vx), Trunc(Vy));
  repeat
  until KeyPressed;
  CloseGraph;
end.