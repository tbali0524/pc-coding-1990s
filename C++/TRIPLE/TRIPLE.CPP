//
// T�th B�lint
// BME, Vill. �s Inf. kar, M. Informatika szak, II. �vf. 1. f�l�v, 3. tank�r
// 1993. okt�ber
//
// C++ h�zi feladat (45.)
// Tetsz�leges m�ret� lebeg�pontos sz�m �s a megfelel� m�veletek megval�s�t�sa
//
// TRIPLE.CPP: Triple class member function-jait tartalmaz� file
//

#include "triple.h"
#include <iostream.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int MaxDivLen = 100;	// osztas eredmenye max. ennyi jegyu

// Error hibakodjai (0 = nincs hiba; 1 = Out of memory)
const erInitValue  = 2;
const erSelfAssign = 3;
const erNotInt     = 4;
const erNotDouble  = 5;
const erDivByZero  = 6;

// ***** private fuggvenyek **********************************************

void Triple::Error( int ErrorCode )
{
    cerr << "\nError : ";
    switch(ErrorCode) {
	case erInitValue:  cerr << "Wrong init value\n"; break;
	case erSelfAssign: cerr << "Self-assignment\n"; break;
	case erNotInt:     cerr << "Cannot convert to integer\n"; break;
	case erNotDouble:  cerr << "Cannot convert to double\n"; break;
	case erDivByZero:  cerr << "Division by zero\n"; break;
    };
    exit(ErrorCode);	// kilepes a programbol
};

void Triple::ExtractZeros( void )
{
    char* m;
    int i;

    while ((Len > 1) && (Mantissa[Len - 1] == '0'))	// zaro nullak
	Len--;
    i = 0;
    while ((Mantissa[i] == '0') && (i < Len - 1))	// kezdo nullak
	i++;
    Exponent -= i;
    Len -= i;
    m = new char[Len + 1];                              // uj mantissza
    strncpy(m, Mantissa + i, Len);
    m[Len] = '\0';
    delete(Mantissa);
    Mantissa = m;
    if (Mantissa[0] == '0') {
	Sign = +1;
	Exponent = 0;
    };
};

void Triple::Assign( const char* AString )
{
  // poziciok a sztringben
    int p1;	// egeszresz eleje
    int p2;	// egeszresz vege
    int p3;	// tortresz eleje
    int p4;	// tortresz vege

  // elojel
    p1 = 0;
    Sign = 1;
    if (AString[0] == '+')
	p1++;
    else if (AString[0] == '-') {
	Sign = -1;
	p1++;
    };
  // egeszresz
    p2 = p1;
    while ((AString[p2] >= '0') && (AString[p2] <= '9'))
	p2++;
  // tortresz
    if (AString[p2] == '.') {
	p3 = p2 + 1;
	p4 = p3;
	while ((AString[p4] >= '0') && (AString[p4] <= '9'))
	    p4++;
    }
    else
	p4 = p3 = p2;
    if (p4 == 0)
	Error(erInitValue);
  // exponens
    if ((AString[p4] == 'E') || (AString[p4] == 'e'))
	Exponent = atoi(AString + p4 + 1);
    else
	Exponent = 0;
    Exponent += p2 - p1 - 1;
  // mantissza masolas
    Len = p2 - p1 + p4 - p3;
    Mantissa = new char[Len + 1];
    strncpy(Mantissa, AString + p1, p2 - p1);
    Mantissa[p2 - p1] = '\0';
    strncat(Mantissa, AString + p3, p4 - p3);
    Mantissa[Len] = '\0';
    ExtractZeros();
};

// ***** konstruktorok ***************************************************

Triple::Triple( void )
{
    Sign = +1;
    Len = 1;
    Mantissa = new char[2];
    strcpy(Mantissa, "0");
    Exponent = 0;
};

Triple::Triple( const Triple& ATriple )
{
    Sign = ATriple.Sign;
    Len = ATriple.Len;
    Mantissa = new char[Len + 1];
    strcpy(Mantissa, ATriple.Mantissa);
    Exponent = ATriple.Exponent;
};

Triple::Triple( int ASign, const char* AMantissa, int AExponent )
{
    if (abs(ASign) != +1)
	Error(erInitValue);
    Sign = ASign;
    Len = strlen(AMantissa);
  // nem megengedett karakterek keresese
    for (int i = 0; (AMantissa[i] >= '0') && (AMantissa[i] <= '9'); i++)
	;				// ures ciklusmag
    if ((Len == 0) || (i < Len))
	Error(erInitValue);
    Mantissa = new char[Len + 1];
    strcpy(Mantissa, AMantissa);
    Exponent = AExponent;
    ExtractZeros();
};

Triple::Triple( int AInt )
{
    char s[10];

    Assign(itoa(AInt, s, 10));
};

Triple::Triple( double ADouble )
{
    char s[35];

    Assign(gcvt(ADouble, 25, s));
};

// adott helyierteku jegy elerese

int Triple::GetDigit( int AtExponent )
{
    if ((AtExponent > Exponent) || (AtExponent <= Exponent - Len))
	return(0);
    else
	return(Mantissa[Exponent - AtExponent] - '0');
};

// ***** formazott alak letrehozasa **************************************

char* Triple::GetScientific( void )
{
    char s[10];
    char* p;
    int k;	// sztring hossza, illetve aktualis pozicio

  // sztring hosszanak meghatarozasa
    k = (Sign < 0);
    if (Len > 1)
	k++;
    k += Len;
    if (Exponent != 0) {
       itoa(Exponent, s, 10);
       if (Exponent > 0)
	   k++;
       k += strlen(s) + 1;
    };
  // sztring letrehozasa
    p = new char[k + 1];
    k = 0;
    if (Sign < 0)
	p[k++] = '-';                                   // elojel
    p[k++] = Mantissa[0];                               // elso jegy
    if (Len > 1) {
	p[k++] = '.';					// tizedespont
	for (int i = 1; i < Len; i++, k++)
	    p[k] = Mantissa[i];                         // mantissza
    };
    if (Exponent != 0) {
	p[k++] = 'E';                                   // exponens
	if (Exponent > 0)
	    p[k++] = '+';
	p[k] = '\0';
	strcat(p, s);
    }
    else
	p[k] = '\0';
    return(p);
};

void Triple::Draw( void )
{
    char* m;

    m = GetScientific();
    cout << m;
    delete(m);
};

// ***** konvertalas hagyomanyos tipusokba *******************************

int Triple::GetInt( void )
{
    int i, j;

    if ((Exponent < 0) || (Exponent > 4) || (Len > (Exponent + 1)))
	Error(erNotInt);
    j = atoi(Mantissa);
    if ((j == 0) && (Exponent != 0))
	Error(erNotInt);
    for (i = 1; i <= Exponent + 1 - Len; i++)
	j *= 10;
    return(Sign * j);
};

double Triple::GetDouble( void )
{
    char s[26];

    if (abs(Exponent) >= 308)
	Error(erNotDouble);
    strncpy(s, Mantissa, 25);
    s[25] = '\0';
    return(Sign * atof(s) * pow10(Exponent + 1 - strlen(s)));
};

// ***** kerekites *******************************************************

void Triple::Round( int AtExponent )
{
    if (GetDigit(AtExponent - 1) >= 5) {
	SetManLen(Exponent - AtExponent + 1);
	Triple B(Sign, "1", AtExponent);
	operator=(operator+(B));
    }
    else
	SetManLen(Exponent - AtExponent + 1);
};

void Triple::SetManLen( int MantissaLen )
{
    char* m;

    if (MantissaLen <= 0) {
	m = new char[2];
	m[0] = '0';
	m[1] = '\0';
    }
    else {
	m = new char[MantissaLen + 1];
	strncpy(m, Mantissa, MantissaLen);
	m[MantissaLen] = '\0';
    };
    delete(Mantissa);
    Mantissa = m;
    Len = strlen(m);
    ExtractZeros();
};

// ***** ertekado operatorok *********************************************

Triple& Triple::operator=( const Triple& ATriple )
{
    if (this == &ATriple)
	Error(erSelfAssign);
    delete Mantissa;
    Sign = ATriple.Sign;
    Len = ATriple.Len;
    Mantissa = new char[Len + 1];
    strcpy(Mantissa, ATriple.Mantissa);
    Exponent = ATriple.Exponent;
    return(*this);
};

int Triple::operator=( int AInt )
{
    char s[10];

    delete Mantissa;
    Assign(itoa(AInt, s, 10));
    return(AInt);
};

double Triple::operator=( double ADouble )
{
    char s[35];

    delete Mantissa;
    Assign(gcvt(ADouble, 25, s));
    return(ADouble);
};

// ***** aritmetikai operatorok ******************************************

// segedfuggvenyek: max es min
int max(int value1, int value2)
{
   return ( (value1 > value2) ? value1 : value2);
}

int min(int value1, int value2)
{
   return ( (value1 < value2) ? value1 : value2);
}

Triple Triple::operator+( Triple& ATriple )
{
    int e1;	// ettol az exponenstol...
    int e2;	// eddig  kell osszegezni
    int carry;	// atvitel
    int newsign; // eredmeny elojele
    int mode;	// 1=azonos elojelu szamok; 0=kulonbozo elujeluek (kivonas)
    char* m;	// eredmeny mantissza
    int i, j, k;
    Triple* A;	// a tagokra mutato pointerek
    Triple* B;	//  (kivonasnal az eredeti sorrend megvaltozhat)

    if (Mantissa[0] == 0)	// ha valamelyik tag nulla, gyorsan vegzunk
	return(ATriple);	// (ha nem vizsgalnank, akkor is mukodne)
    else if (ATriple.Mantissa[0] == '0')
	return(*this);
    newsign = Sign;
    mode = (Sign == ATriple.Sign);
    if (!mode) {
	if (abs(*this) < abs(ATriple)) {   // a sorrendet meg kell cserelni
	    A = &ATriple;
	    B = this;
	    newsign = ATriple.Sign;
	}
	else {
	    A = this;
	    B = &ATriple;
	};
    }; // if !mode
    e1 = min(Exponent - Len + 1, ATriple.Exponent - ATriple.Len + 1);
    e2 = max(Exponent, ATriple.Exponent);
    m = new char[e2 - e1 + 3];
    m[e2 - e1 + 2] = '\0';
    carry = 0;
    for (i = e1, j = e2 - e1 + 1; j >= 0; i++, j--) {
	if (mode) {					// osszeadas
	    k = GetDigit(i) + ATriple.GetDigit(i) + carry;
	    m[j] = '0' + (k % 10);
	    carry = k / 10;
	}
	else  {                                         // kivonas
	    k = 10 + A->GetDigit(i) - B->GetDigit(i) - carry;
	    m[j] = '0' + (k % 10);
	    carry = k < 10;
	};
    }; // for
    Triple Sum(newsign, m, e2 + 1);
    delete(m);
    return(Sum);
};

Triple Triple::operator-( Triple& ATriple )
{
    Triple A(ATriple);
    A.Sign *= -1;
    return(operator+(A));
};

Triple Triple::operator*( const Triple& ATriple )
{
    int mul;		// a masodik tenyezo aktualis tizedes jegye
    int carry;		// atvitel a tizedes jegyek szorzasakor
    char *m;		// reszszorzat mantissza
    int i, j, k;
    Triple Sum(0);	// reszszorzatok osszegezve

    m = new char[Len + 2];
    m[Len + 1] = '\0';
    for (i = 0; i < ATriple.Len; i++) {
      // reszszorzat: elso tenyezo a masodik tenyezo i. jegyevel szorozva
	mul = ATriple.Mantissa[i] - '0';	// 2. tenyezo i. jegye
	carry = 0;
	for (j = Len; j > 0; j--) {
	    k = mul * (Mantissa[j - 1] - '0') + carry;
	    m[j] = '0' + (k % 10);
	    carry = k / 10;
	};
	m[0] = '0' + carry;
	Triple Partial(+1, m, Exponent + ATriple.Exponent + 1 - i);
	Sum = Sum + Partial;		// a reszszorzatokat osszegezzuk
    };
    delete(m);
    Sum.Sign = Sign * ATriple.Sign;	// elojel
    return(Sum);
};

Triple Triple::operator/( const Triple& ATriple )
{
    char *r;		// maradek mantisszaja
    char *m;		// eredmeny mantissza
    int resultpos = 0;	// m hanyadik jegyenel tartunk
    int nextdigit;	// m kovetkezo jegye
    int i;

    if (ATriple.Mantissa[0] == '0')	// nullaval valo osztas
	Error(erDivByZero);
    m = new char[MaxDivLen + 1];
    r = new char[ATriple.Len + 2];
    strncpy(r, Mantissa, ATriple.Len);
    r[ATriple.Len] = '\0';
    Triple Remain(+1, r, ATriple.Len - 1);	// a maradek kezdetben
    Triple Divider(+1, ATriple.Mantissa, ATriple.Len - 1);	// az oszto
    do {
       // eredmeny kovetkezo jegyenek meghatarozasa
	if (Remain < Divider)	// kovetkezo jegy nulla
	    m[resultpos++] = '0';
	else {
	    nextdigit = 0;
	    Triple MultipDivider(Divider);	// az oszto * 2, 3, ...
	    do {
		nextdigit++;
		MultipDivider = MultipDivider + Divider;
	    } while (Remain >= MultipDivider);
	    m[resultpos++] = '0' + nextdigit;
	    Remain = (Remain + Divider) - MultipDivider; // uj maradek
	}; // else
	if ((Remain.Mantissa[0] != '0') || (ATriple.Len + resultpos <= Len)) {
	   // osztando kovetkezo jegyenek lehozasa a maradekba
	    Remain.Exponent++;			// szorzas 10-zel
	    i = GetDigit(Exponent - ATriple.Len - resultpos + 1);
	    if (i != 0) {
		strcpy(r, Remain.Mantissa);
		r[Remain.Len++] = '0' + i;
		r[Remain.Len] = '\0';
		delete(Remain.Mantissa);
		Remain.Mantissa = new char[Remain.Len + 1];
		strcpy(Remain.Mantissa, r);
	    }; // if i != 0
	    Remain.ExtractZeros();
	}; // if Remain.Mantissa != '0'
    } while ((Remain.Mantissa[0] != '0') && (resultpos < MaxDivLen));
    m[resultpos] = '\0';
    delete(r);
    Triple Result(Sign * ATriple.Sign, m, Exponent - ATriple.Exponent);
    delete(m);
    return(Result);
};

// ***** relacios operatorok *********************************************

int Triple::operator==( const Triple& ATriple )
{
    return((Sign == ATriple.Sign) && (Exponent == ATriple.Exponent) &&
	!strcmp(Mantissa, ATriple.Mantissa));
};

int Triple::operator<( const Triple& ATriple )
{
    if (Sign < ATriple.Sign)
	return(1);
    else if (Sign > ATriple.Sign)
	return(0);
    else if (Exponent != ATriple.Exponent)
	return(Sign * Exponent < Sign * ATriple.Exponent);
    else
	return(strcmp(Mantissa, ATriple.Mantissa) < 0);
};

// ***** Nem member fuggvenyek ********************************************

Triple abs( const Triple& ATriple )
{
    Triple A( ATriple );
    A.Sign = +1;
    return(A);
};

Triple fact( int Base )
{
    if (Base < 0)
	return(Triple(0));
    Triple Result(1);
    for ( ; Base > 1; Base--) {
	Result *= Triple(Base);
    };
    return(Result);
};

Triple pow( const Triple& Base, int Expon )
{
    int E = abs(Expon);
    Triple Result(1);
    for ( ; E > 0; E--)
	Result *= Base;
    if (Expon < 0)
	Result = Triple(1) / Result;
    return(Result);
};

ostream& operator<<(ostream& cout, Triple& ATriple)
{
	ATriple.Draw();
	return(cout);
};
