// IPEVAL2.CPP
// Interpreter: egesz-kifejezes kiertekelo
//======================================================================
//
// GOOD-BYTE project
// 2.csapat (Alm.A,Visi G.,Toth B.)
// utolso modositas: V.17.
//
// Toth Balint
//
//======================================================================

// public fuggveny: (deklaracio IPGLOB2.H-ban)
//--------------------------------------------
//int eval_expr(char* expr);

//----------------------------------------------------------------------

#include "ipglob.h"
#include <string.h>
#include <stdlib.h>

const TAB = 9;	// tabulator karakter

// muvelet kodok:
const mc_none	= '0';	// nincs muvelet
const mc_not	= '!';
const mc_neg	= 'n';
const mc_szor	= '*';
const mc_per	= '/';
const mc_mod	= '%';
const mc_plusz	= '+';
const mc_minusz = '-';
const mc_kisebb	= '<';
const mc_kisebbegyenlo	= 'K';
const mc_nagyobb	= '>';
const mc_nagyobbegyenlo	= 'N';
const mc_egyenlo	= '=';
const mc_nemegyenlo	= 'e';
const mc_and	= '&';
const mc_or	= '|';

struct elem_type {	// egy elem a kifejezest tarolo listaban
    int szam;		// operandus
    char muv;		// operandus utani muvelet kodja
    elem_type* prev;	// elozo elem a listaban
};

//----------------------------------------------------------------------

// muvelet precedenciaszintjet adja meg (magasabb prec. elobb vegzendo el)
int get_prec(char muv)
{
    switch(muv) {
	case mc_not:
	case mc_neg:		return(7);
	case mc_szor:
	case mc_per:
	case mc_mod:		return(6);
	case mc_plusz:
	case mc_minusz:		return(5);
	case mc_kisebb:
	case mc_kisebbegyenlo:
	case mc_nagyobb:
	case mc_nagyobbegyenlo:	return(4);
	case mc_egyenlo:
	case mc_nemegyenlo:	return(3);
	case mc_and:		return(2);
	case mc_or:		return(1);
	default:		return(0);
    }; // switch
}; // get_prec

//----------------------------------------------------------------------

// muvelet vegrehajtasa op1, op2 operandusokon
int vegez_muv(char muv, int op1, int op2)
{
    switch(muv) {
	case mc_not:            return(!op2);
	case mc_neg:		return(-op2);
	case mc_szor:		return(op1 * op2);
	case mc_per:            if (op2 == 0) {
				    error_code = er_ev_divisionbyzero;
				    return(0);
				}
				else
				   return(op1 / op2);
	case mc_mod:		if (op2 == 0) {
				    error_code = er_ev_divisionbyzero;
				    return(0);
				}
				else
				   return(op1 % op2);
	case mc_plusz:		return(op1 + op2);
	case mc_minusz:		return(op1 - op2);
	case mc_kisebb:         return(op1 < op2);
	case mc_kisebbegyenlo:  return(op1 <= op2);
	case mc_nagyobb:	return(op1 > op2);
	case mc_nagyobbegyenlo:	return(op1 >= op2);
	case mc_egyenlo:        return(op1 == op2);
	case mc_nemegyenlo:	return(op1 != op2);
	case mc_and:		return(op1 && op2);
	case mc_or:		return(op1 || op2);
	default:		return(0);
    }; // switch
}; // vegez_muv

//----------------------------------------------------------------------

// uj elem a kifejezes-listaban; hasznalat: lista = uj_elem(lista);
elem_type* uj_elem(elem_type* lista) {
    elem_type* p;

    p = new(elem_type);
    p->szam = 0;
    p->muv = mc_none;
    p->prev = lista;
    return(p);
}; // uj_elem

//----------------------------------------------------------------------

// azonosito kimasolasa (*src)-bol dest-be
int get_azon(char* dest, char** src)
{
    int i = 0;

    if ((**src >= 'A') && (**src <= 'Z')) {
	while (((**src >= 'A') && (**src <= 'Z')) ||
	       ((**src >= '0') && (**src <= '9')) || (**src == '_'))
	    dest[i++] = *((*src)++);
	dest[i] = '\0';
    };
    return(i > 0);
}; // get_azon

//----------------------------------------------------------------------

// szam kimasolasa (*src)-bol dest-be
int get_konst(char* dest, char** src)
{
    int i = 0;

    if ((**src >= '0') && (**src <= '9')) {
	while ((**src >= '0') && (**src <= '9'))
	    dest[i++] = *((*src)++);
	dest[i] = '\0';
    };
    return(i > 0);
}; // get_konst

//----------------------------------------------------------------------

// operator olvasasa, tarolas kifejezes-listaban
// *pos : pozicio a kifejezes-sztringben (modosul!)
void get_operator(char** pos, elem_type* lista)
{
    switch (**pos) {
	case '*': 	lista->muv = mc_szor;		break;
	case '/': 	lista->muv = mc_per; 		break;
	case '%': 	lista->muv = mc_mod; 		break;
	case '+': 	lista->muv = mc_plusz; 		break;
	case '-': 	lista->muv = mc_minusz; 	break;
	case '=': 	lista->muv = mc_egyenlo; 	break;
	case '<': 	if (*(*pos + 1) == '=') {
			    lista->muv = mc_kisebbegyenlo;
			    (*pos)++;
			}
			else if (*(*pos + 1) == '>') {
			    lista->muv = mc_nemegyenlo;
			    (*pos)++;
			} else
			    lista->muv = mc_kisebb;
			break;
	case '>': 	if (*(*pos + 1) == '=') {
			    lista->muv = mc_nagyobbegyenlo;
			    (*pos)++;
			} else
			    lista->muv = mc_nagyobb;
			break;
	case 'A':	if ((*(*pos + 1) == 'N') && (*(*pos + 2) == 'D')) {
			    lista->muv = mc_and;
			    *pos = *pos + 2;
			}
			else
			    error_code = er_ev_syntax;
			break;
	case 'O':	if (*(*pos + 1) == 'R') {
			    lista->muv = mc_or;
			    (*pos)++;
			}
			else
			    error_code = er_ev_syntax;
			break;
	default:	error_code = er_ev_syntax;
    }; // switch
    (*pos)++;
}; // get_operator

//----------------------------------------------------------------------

// kifejezes lista egyszerusitese: muveletvegrehajtas, amig lehet
void simplify(elem_type** lista)
{
    elem_type* p;

    while ((error_code == er_none) && ((*lista)->prev != NULL) &&
	    get_prec((*lista)->prev->muv) >= get_prec((*lista)->muv)) {
	p = (*lista)->prev;
	p->szam = vegez_muv(p->muv, p->szam, (*lista)->szam);
	p->muv = (*lista)->muv;
	delete(*lista);
	(*lista) = p;
    }; // while
}; // simplify

//----------------------------------------------------------------------

// zarojeles kifejezes kiertekelese
// *pos : pozicio a kifejezes-sztringben (modosul!)
int get_zarojelkif(char** pos)
{
   char s[128];
   int zarojel = 1;
   int i = 0;

   (*pos)++;
   while ((zarojel > 0) && (**pos != '\0')) {
       if (**pos == '(')
	   zarojel++;
       else if (**pos == ')')
	   zarojel--;
       s[i++] = *((*pos)++);
   };
   if (zarojel == 0) {
       s[i - 1] = '\0';
       return(eval_expr(s));
   }
   else {
       error_code = er_ev_closingparentheses;
       return(0);
   };
}; // get_zarojelkif

//----------------------------------------------------------------------

// szogletes zarojelben levo kifejezes (tombindex) kiertekelese
// *pos : pozicio a kifejezes-sztringben (modosul!)
int get_szoglzarojelkif(char** pos)
{
   char s[128];
   int zarojel = 1;
   int i = 0;

   (*pos)++;
   while ((zarojel > 0) && (**pos != '\0')) {
       if (**pos == '[')
	   zarojel++;
       else if (**pos == ']')
	   zarojel--;
       s[i++] = *((*pos)++);
   };
   if (zarojel == 0) {
       s[i - 1] = '\0';
       return(eval_expr(s));
   }
   else {
       error_code = er_ev_closingbracket;
       return(0);
   };
}; // get_szoglzarojelkif

//----------------------------------------------------------------------

// valtozo (INTEGER vagy INT_ARRAY elem) ertekenek meghatarozasa
// *pos : pozicio a kifejezes-sztringben (modosul!)
// index a VARS tombre vonatkozik
int get_valtozo(char** pos, int index)
{
    int i;

    if (index < 0)
	error_code = er_ev_unknownidentifier;
    else if (vars[index].type == tc_integer)
	return(((integer_type *)vars[index].content)->value);
    else if (vars[index].type == tc_int_array) {
	while ((**pos == ' ') || (**pos == TAB))
	    (*pos)++;
	if (**pos == '[') {
	    i = get_szoglzarojelkif(pos);
	    if ((i < ((int_array_type *)vars[index].content)->itemnum)
		    && (i >= 0)) {
		return(*(int *)(&(((int_array_type *)
			vars[index].content)->items[i * 2])));
	    }
	    else
		error_code = er_ev_indexoutofrange;
	} // if [ else
	else
	    error_code = er_ev_openingbracket;
    } // if tc_int_array
    else
	error_code = er_ev_unknownidentifier;
    return(0);
}; // get_valtozo

//----------------------------------------------------------------------

// kifejezes kiertekelo
int eval_expr(char* expr)
{
    char kifstr[128];	// kifejezes string
    char azon[128];	// talalt azonosito vagy szam-konstans
    char* actpos;	// aktualis pozicio kifstr-ben
    elem_type* lista;	// kifejezes-lista

    elem_type* p;
    int i;

    strcpy(kifstr, expr);
    lista = NULL;
    actpos = kifstr;
    while ((*actpos != '\0') && (error_code == er_none)) {
	while ((*actpos == ' ') || (*actpos == TAB))
	    actpos++;
	if (*actpos != '\0') {
	    lista = uj_elem(lista);
	    if (*actpos == '-') {
		lista->muv = mc_neg;
		lista->szam = 0;
		actpos++;
	    }
	    else {
		i = get_azon(azon, &actpos);
		if ((i > 0) && (strcmp(azon, "NOT") == 0)) {
		    lista->muv = mc_not;
		    lista->szam = 0;
		}
		else {
		    if ((i > 0) && (strcmp(azon, "NOT") != 0)) {
			lista->szam = get_valtozo(&actpos,
				get_var(azon));
		    } else if (*actpos == '(')
			lista->szam = get_zarojelkif(&actpos);
		    else if (get_konst(azon, &actpos))
			lista->szam = atoi(azon);
		    else
			error_code = er_ev_syntax;
		    while ((*actpos == ' ') || (*actpos == TAB))
			actpos++;
		    if ((error_code == er_none) && (*actpos != '\0')
			    && (lista->muv == mc_none)) {
			// muveleti kod jon
			get_operator(&actpos, lista);
			simplify(&lista);
		    };
		}; // if NOT else
	    }; // if - else
	}; // if
    }; // while

    if (error_code == er_none)
	if (lista == NULL) {
	    error_code = er_ev_emptyexpression;
	    return(0);
	}
	else if (lista->muv == mc_none)
	    simplify(&lista);
	else
	    error_code = er_ev_operandexpected;
    i = lista->szam;
    while (lista != NULL) {
	p = lista->prev;
	delete lista;
	lista = p;
    };
    return(i);
}; // eval_expr

//----------------------------------------------------------------------
