program TesztMatrix; { Matrix unit tesztje }

uses Matrix;

var
  A1, A2, A3: MatrixT;
  So, Osz: Integer;

begin
  WriteLn;
{  So := 6;
  Osz := 6;
  Bevitel(A1, So, Osz);
}  Randomize;
  Veletlen(A1, 6, 6);
  Kiiras(A1, 6, 6);
  WriteLn;
  Veletlen(A2, 6, 6);
  Kiiras(A2, 6, 6);
  WriteLn;
{  Torles(A3, 6, 6);
  Egyseg(A3, 6);
  A3 := A1;
  SkalarSzorzas(A3, 6, 6, 2.5);
  Osszeadas(A1, A2, A3, 6, 6);
  Kivonas(A1, A2, A3, 6, 6);
  Szorzas(A1, A2, A3, 6, 6, 6);
  Hatvanyozas(A1, A3, 6, 3);
  Gauss(A3, 6, 6);
}  Inverz(A1, A3, 6);
  WriteLn(AlDeterminans(A1, 6, 1, 1));
  WriteLn(Determinans(A1, 6));
  Kiiras(A3, 6, 6);
  ReadLn;
end.
