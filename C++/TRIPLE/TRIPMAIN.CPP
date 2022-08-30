//
// T�th B�lint
// BME, Vill. �s Inf. kar, M. Informatika szak, II. �vf. 1. f�l�v, 3. tank�r
// 1993. okt�ber
//
// C++ h�zi feladat (45.)
// Tetsz�leges m�ret� lebeg�pontos sz�m �s a megfelel� m�veletek megval�s�t�sa
//
// TRIPMAIN.CPP: Triple class demonstr�l�sa (f�program)
//

#include "triple.h"
#include <iostream.h>
#include <process.h>
#include <new.h>

void OutOfMem( void )
{
    cerr << "\nError : Cannot allocate enough memory\n";
    exit(1);
};

int main( void )
{
    const char* BoolStr[] = {"FALSE", "TRUE"};
    char s[200];

    set_new_handler(OutOfMem);	// new operator hibakezeloje
  // bevitel:
    cout << "\nTriple Class Demonstration    (c) T�th B�lint, 1993\n\n" <<
	"Enter first operand (A) in scientific format: \n";
    cin >> s;
    Triple A(s);
    cout << "Enter second operand (B) in scientific format: \n";
    cin >> s;
    Triple B(s);

  // eredmenyek:
    cout << "\nA: " << A;
    cout << "\nB: " << B;
    cout << "\n(A + B)  : " << (A + B);
    cout << "\n(A - B)  : " << (A - B);
    cout << "\n(A * B)  : " << (A * B);
    cout << "\n(A / B)  : ";
    Triple C(A / B);			// konstruktor kifejezessel
    C.Draw();				// kiiras (mint << )
    cout << "\n(A == B) : " << BoolStr[A == B];
    cout << "\n(A != B) : " << BoolStr[A != B];
    cout << "\n(A <  B) : " << BoolStr[A < B];
    cout << "\n(A <= B) : " << BoolStr[A <= B];
    cout << "\n(A >  B) : " << BoolStr[A > B];
    cout << "\n(A >= B) : " << BoolStr[A >= B];
    cout << "\nabs(A)   : " << abs(A);
    cout << "\nA^9      : " << pow(A, 9);
    cout << "\nTrying to convert A to double : ";
    cout << A.GetDouble();
    A.Round(0);					// kerekites egeszekre
    cout << "\nTrying to convert A to int    : ";
    int I = A.GetInt();
    cout << I << '\n';
    if (I < 500) {
	cout << "Factor.  : ";
	cout << fact(I) << '\n';
    };
    return(0);
};
