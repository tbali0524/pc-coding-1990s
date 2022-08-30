//
// T�th B�lint
// BME, Vill. �s Inf. kar, M. Informatika szak, II. �vf. 1. f�l�v, 3. tank�r
// 1993. okt�ber
//
// C++ h�zi feladat (45.)
// Tetsz�leges m�ret� lebeg�pontos sz�m �s a megfelel� m�veletek megval�s�t�sa
//
// TRIPLE.H: Triple class-t deklar�l� header file
//

#include <iostream>

extern int MaxDivLen;	// osztas eredmenye max. ennyi jegyu

class Triple
{
    private:
      // mezok:
	int Sign;	    // elojel: +1 vagy -1 (0-nak +1)
	char* Mantissa;     // mantissza tizedespont nelkul
	int Exponent;       // exponens
	int Len;            // mantissza sztring merete

      // private fuggvenyek:
	void Error( int ErrorCode );	// hibauzenet, kilepes
	void ExtractZeros( void );      // folos nullak kivetele
	void Assign( const char* AString );	// exp. alaku megadas

    public:
      // konstruktorok:
	Triple( void );			// ures konstruktor (0 kezdoertek)
	Triple( const Triple& ATriple ); // copy konstruktor
	Triple( int ASign, const char* AMantissa, int AExponent );
	Triple( int AInt );
	Triple( double ADouble );
	Triple( const char* AString ) { Assign(AString); };
      // destruktor
	~Triple( void ) { delete Mantissa; };
      // private mezok elerese:
	int GetSign( void ) { return(Sign); };
	char* GetMantissa( void ) { return(Mantissa); };
	int GetExponent( void ) { return(Exponent); };
	int GetDigit( int AtExponent );	// adott helyierteku jegy
      // formazott (exponencialis) alak:
	char* GetScientific( void );	// sztringbe (new-val)
	void Draw( void );		// cout-ra
      // konvertalas hagyomanyos tipusokba
	int GetInt( void );
	double GetDouble( void );
      // kerekites
	void Round( int AtExponent );	// kerekites adott helyiertekig
	void SetManLen( int MantissaLen );	// mantissza meret megadas
						// (levag, nem kerekit)
    // operatorok:
      // ertekadas:
	Triple& operator=( const Triple& ATriple );
	int operator=( int AInt );
	double operator=( double ADouble );
	Triple& operator=( const char* AString )	// exp. alaku megadas
	    { delete Mantissa; Assign(AString); return(*this); };
      // aritmetikai muveletek:
	Triple operator+( Triple& ATriple );
	Triple operator-( Triple& ATriple );
	Triple operator*( const Triple& ATriple );
	Triple operator/( const Triple& ATriple );
      // aritmetikai ertekadas
	void operator+=( Triple& ATriple )
	    { operator=(operator+(ATriple)); };
	void operator-=( Triple& ATriple )
	    { operator=(operator-(ATriple)); };
	void operator*=( const Triple& ATriple )
	    { operator=(operator*(ATriple)); };
	void operator/=( const Triple& ATriple )
	    { operator=(operator/(ATriple)); };
      // relaciok:
	int operator==( const Triple& ATriple );
	int operator<( const Triple& ATriple );
	int operator!=( const Triple& ATriple )
	    { return(!operator==(ATriple)); };
	int operator>( const Triple& ATriple )
	    { return(!operator<(ATriple) && !operator==(ATriple)); }
	int operator<=( const Triple& ATriple )
	    { return(operator<(ATriple) || operator==(ATriple)); }
	int operator>=( const Triple& ATriple )
	    { return(!operator<(ATriple)); };

      // friend fuggveny:
	friend Triple abs( const Triple& ATriple );	// abszolut ertek

};

// egyeb fuggvenyek:

Triple fact( int Base );			// faktorialis
Triple pow( const Triple& Base, int Expon );	// hatvanyozas egesz kitevore
ostream& operator<<(ostream& cout, Triple& ATriple);
