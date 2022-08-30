// IPGLOB2.CPP
// Interpreter kozos deklaracioi (valtozok,fuggvenytorzsek)
//======================================================================
//
// GOOD-BYTE project
// 2.csapat (Alm.A,Visi G.,Toth B.)
// utolso modositas: V.17.
//
// T.B.
//
//======================================================================

#include "ipglob.h"
#include "hws.h"
#include <string.h>
#include <stdio.h>
#include <dir.h>
#include <new.h>
#include <process.h>

//======================================================================
// HIBAKEZELES
//-------------

int error_code = er_none;	// hibakod (er_XXXX konstansok)

// szoveges hibauzenetet ado fuggveny
char* error_text(char* dest, int error_code)
{
    if (error_code == er_none)
	    strcpy(dest, "OK");
    else {
	sprintf(dest, "Error #%d: ", error_code);
	switch(error_code) {

	    case er_ip_outofmemory:
		strcat(dest, "Out of memory"); break;
	    case er_ip_baddosargument:
		strcat(dest, "Bad or missing argument"); break;
	    case er_ip_cannotinithardware:
		strcat(dest, "Cannot initialize hardware simulator"); break;

	// kifejezes kiertekelo hibai
	    case er_ev_syntax:
		strcat(dest, "Syntax error in expression"); break;
	    case er_ev_unknownidentifier:
		strcat(dest, "Unknown identifier"); break;
	    case er_ev_closingparentheses:
		strcat(dest, "Closing parentheses expected"); break;
	    case er_ev_closingbracket:
		strcat(dest, "Closing bracket expected"); break;
	    case er_ev_openingbracket:
		strcat(dest, "Array index expected"); break;
	    case er_ev_operandexpected:
		strcat(dest, "Operand expected"); break;
	    case er_ev_emptyexpression:
		strcat(dest, "Integer expression expected"); break;
	    case er_ev_indexoutofrange:
		strcat(dest, "Array index out of range"); break;
	    case er_ev_divisionbyzero:
		strcat(dest, "Division by zero"); break;

	// beepitett eljarasok hibai
	    case er_pr_openingparentheses:
		strcat(dest, "Opening parentheses expected for parameterlist");
		break;
	    case er_pr_closingparentheses:
		strcat(dest, "Closing parentheses expexted"); break;
	    case er_pr_paramexpected:
		strcat(dest, "Parameter expected for built-in procedure"); break;
	    case er_pr_paramtypeerror:
		strcat(dest, "Type mismatch in parameterlist"); break;
	    case er_pr_intparamoutofrange:
		strcat(dest, "Integer parameter out of range"); break;

            case er_badbmp:
                 strcat(dest,"Invalid bitmap reference");break;
            case er_badfont:
                 strcat(dest,"Invalid font reference");break;
            case er_noassign:
                 strcat(dest,"No bitmap or font is assigned yet");break;
            case er_baddir:
                 strcat(dest,"Invalid shift direction");break;
            case er_outoftable:
                 strcat(dest,"Make_sprite field is out of table");break;
            case er_spoutofr:
                 strcat(dest,"Plot_sprite speed is out of range");break;

	// szimbolum- es eroforraskezelo hibai
	    case er_sy_cannotloadbitmap:
		strcat(dest, "Cannot load bitmap file"); break;
	    case er_sy_invalidbitmap:
		strcat(dest, "Invalid bitmap file"); break;
	    case er_sy_cannotloadfont:
		strcat(dest, "Cannot load font file"); break;
	    case er_sy_invalidfont:
		strcat(dest, "Invalid font file"); break;
	    case er_sy_toomanybitmaps:
		strcat(dest, "Too many bitmaps"); break;
	    case er_sy_toomanyfonts:
		strcat(dest, "Too many fonts"); break;
	    case er_sy_toomanyvars:
		strcat(dest, "Too many variables"); break;
	    case er_sy_redefinevar:
		strcat(dest, "Redefined variable"); break;

            // interpreter hibai

            case er_ip_userbreak:
		strcat(dest, "User break"); break;
            case er_ip_stackoverflow:
		strcat(dest, "Instruction stack overflow"); break;

            case er_ip_file:
		strcat(dest, "File operation"); break;
            case er_ip_openfile:
		strcat(dest, "Open file"); break;
            case er_ip_toolongline:
		strcat(dest, "Too long line"); break;

            case er_ip_syntax:
		strcat(dest, "Syntax error"); break;
            case er_ip_unexpectedendoffile:
		strcat(dest, "Unexpected end of file"); break;
            case er_ip_alreadyinsketch:
		strcat(dest, "Already in sketch"); break;
            case er_ip_unexpectedendsketch:
		strcat(dest, "Unexpected END_SKETCH"); break;
            case er_ip_missingsketch:
		strcat(dest, "Missing begin of sketch"); break;

            case er_ip_inexpression:
		strcat(dest, "BITMAPS, FONTS or VARS in expression"); break;

            case er_ip_alreadybitmaps:
		strcat(dest, "BITMAPS already declared"); break;
            case er_ip_bitmapscount:
		strcat(dest, "Mismatch BITMAPS count"); break;

            case er_ip_alreadyfonts:
		strcat(dest, "FONTS already declared"); break;
            case er_ip_fontscount:
		strcat(dest, "Mismatch BITMAPS count"); break;

            case er_ip_reservedword:
		strcat(dest, "Reserved word"); break;
            case er_ip_builtinproc:
		strcat(dest, "Built-in procedure name"); break;
            case er_ip_alreadyvar:
		strcat(dest, "Already variable name"); break;

            case er_ip_noleftvalue:
		strcat(dest, "No left-value in assign"); break;
            case er_ip_badindexofarray:
		strcat(dest, "Bad index of array"); break;
            case er_ip_novar:
		strcat(dest, "No variable"); break;

            case er_ip_unexpecteduntil:
		strcat(dest, "Unexpected UNTIL"); break;

            case er_ip_unexpectedendwhile:
		strcat(dest, "Unexpected END_WHILE"); break;

            case er_ip_missingto:
		strcat(dest, "Missing TO"); break;
            case er_ip_unexpectedendfor:
		strcat(dest, "Unexpected END_FOR"); break;

            case er_ip_missingthen:
		strcat(dest, "Missing THEN"); break;
            case er_ip_unexpectedelse:
		strcat(dest, "Unexpected ELSE"); break;
            case er_ip_unexpectedendif:
		strcat(dest, "Unexpected END_IF"); break;

	    default:
		strcat(dest, "(no text)");
	}; // switch
    }; // else
    return(dest);
}; // error_text

//======================================================================
// EROFORRASOK ES VALTOZOK NYILVANTARTASA
//----------------------------------------

// leiro-tablazatok aktualis merete (elemek szama)
int act_bitmaps = 0;		// bitmap eroforrasok szama
int act_fonts = 0;		// font eroforrasok szama
int act_vars = 0;		// valtozok szama
int act_priority_objects = 0;	// SPRITE/TEXT/FIELD objektumok szama

// nyelvi objektumok leiro tablazatai
bitmap_type bitmaps[max_bitmaps];	// bitmap eroforrasok
font_type fonts[max_fonts];		// font eroforrasok
var_type vars[max_vars];		// valtozok (szimbolumtabla)
int priority_objects[max_priority_objects];	// prioritasi sor

//======================================================================
// PARANCSSOR PARAMETEREK
//------------------------

char main_hcl_file[MAXPATH];	// fo HCL forrasfajl
char sketch_name[MAXPATH];	// futtatando jelenetnev
				// (ha teljes musor, akkor '\0')

// hardverszimulator fizikai jellemzoi
int maxx = 0;	// pixelek szama x iranyban
int maxy = 0;	// pixelek szama y iranyban
int maxcol = 0;	// szinek szama

// interpreter futasi opciok (1=bekapcsolva,0=ki)
int option_wait = 0;	// varakozasos mod (/W opcio)
int option_loop = 0;	// vegtelenitett mod (/L opcio)
int option_quiet = 0;	// csendes mod (/Q opcio)
int option_debug = 0;	// hibakeresesi mod (/D opcio)

int quit         = 0;

//======================================================================
// BEEPITETT ELJARASOK KEZELESE
//------------------------------

char* table = NULL;	// a kijelzo tartalma a kepgeneralashoz

int background_col;	// hatterszin a kijelzon


//======================================================================
// FUGGVENYEK
//------------

void OutNewHandler()
{
    char s[128];

    error_code = er_ip_outofmemory;
    closetable();
    printf("%s\n", error_text(s, error_code));
    exit(error_code);
};

// inicializalas musor-futtatas elejen
void init_ip()
{
    set_new_handler(OutNewHandler);
    if (error_code == er_none)
	table = new char[(maxx + 1) * (maxy + 1)];
    if (inittable(maxx + 1, maxy + 1, maxcol + 1) != HWS_INITOK)
	error_code = er_ip_cannotinithardware;
}; // init_ip

//----------------------------------------------------------------------

// lezaras musor-futtatas vegen
void done_ip()
{
    closetable();
    if (table != NULL)
	delete(table);
}; // done_ip

//----------------------------------------------------------------------

// inicializalas sketch elejen
void init_sketch()
{
    background_col = 0;
    filltable(background_col);
    enabletable();
    def_var("MAXX", tc_integer, maxx);
    def_var("MAXY", tc_integer, maxy);
    def_var("MAXCOL", tc_integer, maxcol);
}; // init_sketch

//----------------------------------------------------------------------

// lezaras (belso dinamikus valtozok felszabaditasa) sketch vegen
void done_sketch()
{
    int i, j;

    for (i = 0; i < act_bitmaps; i++)
	delete(bitmaps[i].image);
    for (i = 0; i < act_fonts; i++)
	for (j = 0; j < 256; j++)
	    if (fonts[i].image[j] != NULL)
		delete(fonts[i].image[j]);
    for (i = 0; i < act_vars; i++) {
	delete(vars[i].name);
	switch(vars[i].type) {
	    tc_integer:
		delete((integer_type *)vars[i].content);
		break;
	    tc_int_array:
		delete(((int_array_type *)vars[i].content)->items);
		delete((int_array_type *)vars[i].content);
		break;
	    tc_string:
		delete(((string_type *)vars[i].content)->text);
		delete((string_type *)vars[i].content);
		break;
	    tc_sprite:
		delete((sprite_type *)vars[i].content);
		break;
	    tc_text:
		delete(((text_type *)vars[i].content)->text);
		delete((text_type *)vars[i].content);
		break;
	    tc_field:
		if (((field_type *)vars[i].content)->image != NULL)
		    delete(((field_type *)vars[i].content)->image);
		delete((field_type *)vars[i].content);
		break;
	}; // switch
    }; // for
    act_bitmaps = 0;
    act_fonts = 0;
    act_vars = 0;
    act_priority_objects = 0;
}; // done_sketch

//----------------------------------------------------------------------
