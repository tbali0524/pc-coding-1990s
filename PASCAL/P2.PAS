{ T¢th B lint, 1992 }
program P2; { Maximal Subsequence }

const
  Max = 250; { sorozat max. hossza }
var
  Inp, Out: Text; { bemenet ‚s kimenet }
  S: String; { Inp aktu lis sora }
  CsupaNeg: Boolean; { True, ha a sorozat csupa negativ elemb“l  ll }
  A: Array[1..Max + 1] of Integer; { egy sorozat }
  N, { a sorozat hossza }
  I, Kod: Integer;

function KeresMaxSub: Integer;
{ Veszi az ”sszes pozitiv sz mmal kezd“d“ r‚szsorozatot A[N]-ben ‚s
  megkeresi a legnagyobb ”sszeget. ( Ha a sorozat csupa negativ elemb“l  ll,
  akkor az ”sszes r‚szsorozatot n‚zi.)
}
var
  O, { az aktu lis ”sszeg }
  M, { az eddigi maximum }
  I, J, K: Integer;
begin
  M := A[1];
  for I:= 1 to N do { a r‚szsorozat els“ eleme }
    if (A[I] > 0) or CsupaNeg then
    begin
      O := 0;
      for J := I to N do { a r‚szsorozat utols¢ eleme }
      begin
        O := O + A[J];
        if O > M then
          M := O;
      end;
    end;
  KeresMaxSub := M;
end; { KeresMaxSub }

{ f“program: sorozatok kiolvas sa Inp-b“l, feldolgoz s KeresMaxSub-bal }
begin
  WriteLn('Legnagyobb r‚szsorozat   (c) T¢th B lint, 1992.');
  Assign(Inp, 'P2.INP');
  Assign(Out, 'P2.OUT');
  {$I-}
  Reset(Inp);
  Rewrite(Out);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn('I/O hiba!');
    Halt(1);
  end;
  N := 0;
  CsupaNeg := True;
  while not Eof(Inp) do
  begin
    ReadLn(Inp, S);
    while S <> '' do
    begin
      while S[1] = ' ' do { elv laszt¢ sz¢k”z”k kiv‚tele }
        Delete(S, 1, 1);
      I := 1;
      while (I <= Length(S)) and (S[I] <> ' ') do
        Inc(I);
      Val(Copy(S, 1, I - 1), A[N + 1], Kod);
      if (Kod > 0) or (N = Max) then
      begin
        WriteLn('Bemeneti file nem megfelel“!');
        Close(Inp);
        Close(Out);
        Halt(2);
      end;
      Delete(S, 1, I - 1);
      if A[N + 1] = 0 then { sorozat v‚ge }
      begin
        if N > 0 then
          WriteLn(Out, KeresMaxSub);
        N := 0;
        CsupaNeg := True;
      end
      else
      begin
        Inc(N);
        if A[N] > 0 then
          CsupaNeg := False;
      end;
    end; { while S }
  end; { while not Eof }
  Close(Inp);
  Close(Out);
  WriteLn('Ok');
end.

{ Megjegyz‚s:
    Nem kell minden sorozatnak £j sorban kezd“dnie.
    A sz mok k”z”tt b rmennyi sz¢k”z ‚s CR lehet, m s nem.
    Ha az utols¢ sorozat nincs 0-lal lez rva, akkor azt nem dolgozza fel.
}