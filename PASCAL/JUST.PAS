program Justify;
var
  F: Text;
  S, T, V: String;
  R: Real;
  I, J, K, L, M, N, O: Integer;
  A: Array[0..80] of Integer;
begin
  ReadLn(S);
  Assign(F, S);
  Reset(F);
  K := 0;
  N := 0;
  T := '';
  A[0] := 0;
  while not Eof(F) do
  begin
    ReadLn(F, S);
    while S <> '' do
    begin
      while S[1] = ' ' do
        Delete(S, 1, 1);
      I := 1;
      while (I <= Length(S)) and (S[I] <> ' ') do
        Inc(I);
      if (K + I) > 79 then
      begin
        K := 79 - K;
        V := '';
        O := 1;
        M := 0;
        R := 0;
        for J := 1 to Length(T) do
        begin
          V := V + T[J];
          if J = A[O] then
          begin
            L := Round(R + K / (N - 1)) - Round(R);
            if M + L > K then
              Dec(L);
            if O = (N - 1) then
              L := K - M
            else if O = N then
              L := 0;
            R := R + K / (N - 1);
            M := M + L;
            V := V + Copy('                                               ' +
              '                                                           ',
              1, L);
            Inc(O);
          end;
        end;
        WriteLn(V);
        T := '';
        K := 0;
        N := 0;
        A[0] := 0;
      end;
      T := T + Copy(S, 1, I - 1) + ' ';
      Inc(N);
      A[N] := A[N - 1] + I;
      Delete(S, 1, I - 1);
      K := K + I;
    end;
  end;
  Close(F);
end.
