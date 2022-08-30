// IPRUTIN2.CPP
// Interpreter nehany segedfuggvenye
//======================================================================
//
// GOOD-BYTE project
// 2.csapat (Alm.A,Visi G.,Toth B.)
// utolso modositas: V.17.
//
// Toth Balint
//
//======================================================================

// public fuggvenyek (deklaracio IPGLOB2.H-ban):
//-----------------------------------------------
// void load_bitmap(char* filename)
// void load_font(char* filename)
// void def_var(char* name, char type, int param)
// int get_var(char* name)
// void build_priority_objects()
// void get_dos_args(int argc, char *argv[])
// int get_proc(char* name)
// void exec_proc(int proc, char* paramstr)

//======================================================================

#include "ipglob.h"
#include <string.h>
#include <dir.h>
#include <stdio.h>
#include <conio.h>
#include <process.h>
#include <graphics.h>

const TAB = 9;	// tabulator karakter

//======================================================================
// EROFORRASOK ES VALTOZOK NYILVANTARTASA
//----------------------------------------

// bitmap eroforras betoltese file-bol
void load_bitmap(char* filename)
{
    FILE* f;
    int x, y, c, i;

    if (act_bitmaps == max_bitmaps) {
	error_code = er_sy_toomanybitmaps;
	return;
    }
    else if (!(f = fopen(filename, "rb")))
	error_code = er_sy_cannotloadbitmap;
    else if ((fgetc(f) != 'B') || (fgetc(f) != 'I') || (fgetc(f) != 'T'))
	error_code = er_sy_invalidbitmap;
    else {
	x = fgetc(f) + 1;
	y = fgetc(f) + 1;
	c = fgetc(f);
	i = getw(f);
	if ((c < 2) || (c > 8) || (c % 2 != 0) || (i != x * y))
	    error_code = er_sy_invalidbitmap;
	else {
	    bitmaps[act_bitmaps].width = x;
	    bitmaps[act_bitmaps].height = y;
	    bitmaps[act_bitmaps].colors = c;
	    bitmaps[act_bitmaps].imagesize = i;
	    bitmaps[act_bitmaps].image = new char[i];
	    if (fread(bitmaps[act_bitmaps].image, 1, i, f) != i)
		error_code = er_sy_cannotloadbitmap;
	    act_bitmaps++;
	}; // if c else
    }; // if !BMP else
    fclose(f);
}; // load_bitmap

//----------------------------------------------------------------------

// font eroforras betoltese file-bol
void load_font(char* filename)
{
    FILE* f;
    int x, y, c, n, l, i, j;

    if (act_fonts == max_fonts) {
	error_code = er_sy_toomanyfonts;
	return;
    }
    else if (!(f = fopen(filename, "rb")))
	error_code = er_sy_cannotloadfont;
    else if ((fgetc(f) != 'F') || (fgetc(f) != 'N') || (fgetc(f) != 'T'))
	error_code = er_sy_invalidfont;
    else {
	x = fgetc(f) + 1;
	y = fgetc(f) + 1;
	c = fgetc(f);
	n = fgetc(f);
	if ((c < 2) || (c > 8) || (c % 2 != 0))
	    error_code = er_sy_invalidfont;
	else {
	    for (i = 0; i < 256; i++)
		fonts[act_fonts].image[i] = NULL;
	    l = x * y;
	    for (i = 0; i < n; i++) {
		j = fgetc(f);
		fonts[act_fonts].image[j] = new char[l];
		if (fread(fonts[act_fonts].image[j], 1, l, f) != l)
		    error_code = er_sy_cannotloadfont;
	    };
	    fonts[act_fonts].width = x;
	    fonts[act_fonts].height = y;
	    fonts[act_fonts].colors = c;
	    fonts[act_fonts].charnum = n;
	    fonts[act_fonts].imagesize = l;
	    act_fonts++;
	}; // if c else
    }; // if !FNT else
    fclose(f);
}; // load_font

//----------------------------------------------------------------------

// valtozo-leirok kezdeti ertekei
const sprite_type default_sprite =
{
    -1,				// bitmap
    0,				// startx
    0,				// starty
    {0, 1, 2, 3, 4, 5, 6, 7},	// palette
    0,				// priority
    0				// enabled
};

const text_type default_text =
{
    NULL,			// text (letre kell hozni '\0'-lal )
    1,				// textsize (1 a zaro \0 miatt)
    -1,				// font
    0,				// startx
    0,				// starty
    {0, 1, 2, 3, 4, 5, 6, 7},	// palette
    0,				// priority
    0				// enabled
};

const field_type default_field =
{
    NULL,			// image (letre kell hozni imagesize=0-ra is)
    0,				// imagesize
    0,				// width
    0,				// height
    0,				// startx
    0,				// starty
    {0, 1, 2, 3, 4, 5, 6, 7},	// palette
    0				// enabled
};

//----------------------------------------------------------------------

// uj valtozo letrehozasa a szimbolumtablaban
// type: tipus kodja (tc_XXXX konstansok
// param: INTEGER eseten a kezdoertek (jol jon a beepitett valtozokhoz)
//        INT_ARRAY eseten a tomb merete (elemek szama)
//        egyebkent barmi (legyen 0)
void def_var(char* name, char type, int param)
{
    int i;

    if (act_vars == max_vars)
	error_code = er_sy_toomanyvars;
    else if (get_var(name) >= 0)
	error_code = er_sy_redefinevar;
    else {
	vars[act_vars].name = new char[strlen(name) + 1];
	strcpy(vars[act_vars].name, name);
	vars[act_vars].type = type;
	switch(type) {
	    case tc_integer:
		vars[act_vars].content = new integer_type;
		((integer_type *)vars[act_vars].content)->value = param;
		break;
	    case tc_int_array:
		vars[act_vars].content = new int_array_type;
		((int_array_type *)vars[act_vars].content)->itemnum = param;
		if (param < 1) {
		    param = 0;
		    error_code = er_ev_indexoutofrange;
		};
		((int_array_type *)vars[act_vars].content)->items =
		    new char[param * 2];
		for (i = 0; i < 2 * param; i++)
		    ((int_array_type *)vars[act_vars].content)->items[i] = 0;
		break;
	    case tc_string:
		vars[act_vars].content = new string_type;
		((string_type *)vars[act_vars].content)->textsize = 1;
		((string_type *)vars[act_vars].content)->text = new char[1];
		strcpy(((string_type *)vars[act_vars].content)->text, "");
		break;
	    case tc_sprite :
		vars[act_vars].content = new sprite_type;
		*((sprite_type *)vars[act_vars].content) = default_sprite;
		break;
	    case tc_text :
		vars[act_vars].content = new text_type;
		*((text_type *)vars[act_vars].content) = default_text;
		((text_type *)vars[act_vars].content)->text = new char[1];
		strcpy(((text_type *)vars[act_vars].content)->text, "");
		break;
	    case tc_field :
		vars[act_vars].content = new field_type;
		*((field_type *)vars[act_vars].content) = default_field;
		((field_type *)vars[act_vars].content)->image = new char[0];
		break;
	}; // switch
	act_vars++;
    }; // else
}; // def_var

//----------------------------------------------------------------------

// kereses szimbolumtablaban nev szerint
// eredmeny: a bejegyzes indexe a vars tombben, vagy -1 ha nincs ilyen
int get_var(char* name)
{
    int i = 0;

    while ((i < act_vars) && strcmpi(vars[i].name, name))
	i++;
    return((i < act_vars) ? i : -1);
}; // get_var

//----------------------------------------------------------------------

// segedfuggveny qsort_priority-hez:
// prioritasi lista i. elemenek prioritasa
int get_priority(int index)
{
    if (vars[priority_objects[index]].type == tc_sprite)
	return(((sprite_type *)vars[priority_objects[index]].content)
		->priority);
    else
	return(((text_type *)vars[priority_objects[index]].content)
		->priority);
}; // get_priority

// segedfuggveny build_priority_objects-hex:
// prioritasi lista rendezese (novekvo prioritas szerint) qsort-tal
void qsort_priority(int l, int r)
{
    int i, j, x, y;

    i = l;
    j = r;
    x = get_priority((l + r) / 2);
    do {
	while (get_priority(i) < x)
	    i++;
	while (x < get_priority(j))
	    j--;
	if (i <= j) {
	    y = priority_objects[i];
	    priority_objects[i] = priority_objects[j];
	    priority_objects[j] = y;
	    i++;
	    j--;
	}; // if
    } while (i <= j);
    if (l < j)
	qsort_priority(l, j);
    if (i < r)
	qsort_priority(i, r);
}; // qsort_priority

// prioritasi sor felepitese
void build_priority_objects()
{
    int i;

    act_priority_objects = 0;
    for (i = 0; i < act_vars; i++)
	if ((vars[i].type == tc_sprite) || (vars[i].type == tc_text))
	    priority_objects[act_priority_objects++] = i;
    if (act_priority_objects > 0)
	qsort_priority(0, act_priority_objects - 1);
    for (i = 0; i < act_vars; i++)
	if ((vars[i].type == tc_field) && (((field_type*)vars[i].content)->enabled))
	    priority_objects[act_priority_objects++] = i;
}; // build_priority_objects

//======================================================================
// PARANCSSOR PARAMETEREK
//------------------------

// segedeljaras get_dos_args-nak: help kepernyo
void help_screen()
{
    char s[128];

    error_code = er_ip_baddosargument;
    if (!option_quiet) {
	puts("HCLIP  Hirdet“t bla Command Language Interpreter  (c) 1994 by Good-Byte team\n");
	puts("Usage:");
	puts(" HCLIP.EXE sourcefile.[HCL] [sketchname] [options]\n");
	puts("Options:");
	puts("  /X=xsize    Set horizontal table size");
	puts("                (32 < xsize< 256; xsize modulo 8 = 0; default is 128)");
	puts("  /Y=ysize    Set vertical table size");
	puts("                (8 < ysize< 64; ysize modulo 8 = 0; default is 64)");
	puts("  /C=colors   Set number of colors (colors=2,4,6,8; default is 8)");
	puts("  /W          Wait mode (wait for keypress after commands)");
	puts("  /L          Loop mode (restart after finished)");
	puts("  /Q          Quiet mode (no error messages)");
	puts("  /D          Debug mode (show current line while running)\n");
	puts("Sourcefile must be given, others are optional.");
	puts("If sketchname is given, than only that sketch will be played");
	puts("otherwise the whole sourcefile.\n");
	printf("%s\n", error_text(s, error_code));
    }; // if
    exit(error_code);
}; // help_screen

// parancssor parameterek feldolgozasa (hivas: init_ip ELOTT)
void get_dos_args(int argc, char *argv[])
{
    char drive[MAXDRIVE];
    char dir[MAXDIR];
    char file[MAXFILE];
    char ext[MAXEXT];

    char s[MAXPATH];
    int i;

    main_hcl_file[0] = '\0';
    sketch_name[0] = '\0';
    for (i = 1; i < argc; i++) {
	strcpy(s, argv[i]);
	strupr(s);
	if ((s[0] == '/') || (s[0] == '-'))
	    switch (s[1]) {
	       case 'X': if ((s[2] != '=')
			   || (sscanf(s + 3, "%u", &maxx) != 1))
			     help_screen();
			 break;
	       case 'Y': if ((s[2] != '=')
			   || (sscanf(s + 3, "%u", &maxy) != 1))
			     help_screen();
			 break;
	       case 'C': if ((s[2] != '=')
			   || (sscanf(s + 3, "%u", &maxcol) != 1))
			     help_screen();
			 break;
	       case 'W': option_wait = 1; break;
	       case 'L': option_loop = 1; break;
	       case 'Q': option_quiet = 1; break;
	       case 'D': option_debug = 1; break;
	       default:  help_screen();
	    } // switch
	else if (main_hcl_file[0] == '\0') {
	    strcpy(main_hcl_file, s);
	} else if (sketch_name[0] == '\0')
	    strcpy(sketch_name, s);
	else
	    help_screen();
    }; // for
    if (maxx == 0)
        maxx = 128;
    if (maxy == 0)
        maxy = 64;
    if (maxcol == 0)
        maxcol = 8;
    if ((main_hcl_file[0] == '\0')
	|| (maxx < 32) || (maxx > 256) || (maxx % 8 != 0)
	|| (maxy < 8) || (maxy > 64) || (maxy % 8 != 0)
	|| (maxcol < 2) || (maxcol > 8) || (maxcol % 2 != 0))
      help_screen();
    maxx--;
    maxy--;
    maxcol--;
    fnsplit(main_hcl_file, drive, dir, file, ext);
    if (ext[0] == '\0') {
       strcpy(ext, ".HCL");
       fnmerge(main_hcl_file, drive, dir, file, ext);
    };
    if (option_debug)
	option_wait = 0;
}; // get_dos_args

//======================================================================
// BEEPITETT ELJARASOK KEZELESE
//------------------------------

// beepitett eljarasok jellemzoi
const max_params	= 10;	// parameterek max. szama beepitett eljarasban
const max_procs		= 43;	// beepitett eljarasok szama

struct proc_list_item {
    char* name;
    int modify_screen;		// modositja-e a kijelzot (1=igen) (WAIT-hez)
    int paramnum;		// parameterek szama
    char params[max_params + 1]; // az egyes parameterek tipusai (tc_XXXX)
};

const proc_list_item proc_list[max_procs] =
{
    {
	"ASSIGN_SPRITE",
	1,
	5,
	"SIIII     "
    },
    {
	"BITMAP_SPRITE",
	1,
	2,
	"SI        "
    },
    {
	"POSITION_SPRITE",
	1,
	3,
	"SII       "
    },
    {
	"PALETTE_SPRITE",
	1,
	2,
	"SA        "
    },
    {
	"PRIORITY_SPRITE",
	1,
	2,
	"SI        "
    },
    {
	"ENABLE_SPRITE",
	1,
	1,
	"S         "
    },
    {
	"DISABLE_SPRITE",
	1,
	1,
	"S         "
    },
    {
	"MOVETO_SPRITE",
	1,
	4,
	"SIII      "
    },
    {
	"MOVEREL_SPRITE",
	1,
	4,
	"SIII      "
    },
    {
	"ANIMATE_SPRITE",
	1,
	3,
	"SIA       "
    },
    {
	"ROTATE_PALETTE_SPRITE",
	1,
	1,
	"S         "
    },
    {
	"FADE_SPRITE",
	1,
	1,
	"S         "
    },
    {
	"ASSIGN_TEXT",
	1,
	6,
	"TCIIII    "
    },
    {
	"CONTENT_TEXT",
	1,
	2,
	"TC        "
    },
    {
	"FONT_TEXT",
	1,
	2,
	"TI        "
    },
    {
	"POSITION_TEXT",
	1,
	3,
	"TII       "
    },
    {
	"PALETTE_TEXT",
	1,
	2,
	"TA        "
    },
    {
	"PRIORITY_TEXT",
	1,
	2,
	"TI        "
    },
    {
	"ENABLE_TEXT",
	1,
	1,
	"T         "
    },
    {
	"DISABLE_TEXT",
	1,
	1,
	"T         "
    },
    {
	"MOVETO_TEXT",
	1,
	4,
	"TIII      "
    },
    {
	"MOVEREL_TEXT",
	1,
	4,
	"TIII      "
    },
    {
	"ROTATE_PALETTE_TEXT",
	1,
	1,
	"T         "
    },
    {
	"FADE_TEXT",
	1,
	1,
	"T         "
    },
    {
	"ASSIGN_FIELD",
	1,
	5,
	"FIIII     "
    },
    {
	"POSITION_FIELD",
	1,
	3,
	"FII       "
    },
    {
	"SIZE_FIELD",
	1,
	3,
	"FII       "
    },
    {
	"PALETTE_FIELD",
	1,
	2,
	"FA        "
    },
    {
	"ENABLE_FIELD",
	1,
	1,
	"F         "
    },
    {
	"DISABLE_FIELD",
	1,
	1,
	"F         "
    },
    {
	"ROTATE_FIELD",
	1,
	2,
	"FI        "
    },
    {
	"SHIFT_FIELD",
	1,
	2,
	"FI        "
    },
    {
	"ROTATE_PALETTE_FIELD",
	1,
	1,
	"F         "
    },
    {
	"FADE_FIELD",
	1,
	1,
	"F         "
    },
    {	"WAIT",
	0,
	1,
	"I         "
    },
    {	"BACKGROUND_COLOR",
	1,
	1,
	"I         "
    },
    {	"ENABLE_ALL",
	1,
	0,
	"          "
    },
    {	"DISABLE_ALL",
	1,
	0,
	"          "
    },
    {	"MAKE_SPRITE",
	1,
	6,
	"SIIIII    "
    },
    {	"TRANSPARENT_SPRITE",
	1,
	1,
	"S         "
    },
    {	"ENABLE_TABLE",
	1,
	0,
	"          "
    },
    {	"DISABLE_TABLE",
	1,
	0,
	"          "
    },
    {	"PLOT_SPRITE",
	1,
	2,
	"SI        "
    }
};

//----------------------------------------------------------------------

// beepitett eljaras leirojanak keresese nev alapjan
// eredmeny: a bejegyzes indexe a proc_list tombben, -1 ha nincs ilyen
// (ezt kell exec_proc-nak atadni)
int get_proc(char* name)
{
    int i = 0;

    while ((i < max_procs) && strcmpi(proc_list[i].name, name))
	i++;
    return((i < max_procs) ? i : -1);
}; // get_proc

//----------------------------------------------------------------------

// beepitett eljaras vegrehajtasa
// proc: az eljaras indexe a proc_list tombben
// paramstr: a parameterlista ( ) kozott
void exec_proc(int proc, char* paramstr)
{
  // parameterek
    int int_param_num = 0;		// egesz parameterek szama eddig
    int int_p[max_params];		// egesz parameterek
    int_array_type* int_array_param = NULL;
    char string_param[128];
    sprite_type* sprite_param = NULL;
    text_type* text_param = NULL;
    field_type* field_param = NULL;

    char buf[128];	// ideiglenes tarolo parameternek
    char* pos;		// aktualis parameter kezdete paramstr-ben
    char* bufstart;	// elso nem szokoz karakter buf-ban
    int i;		// parameter sorszama
    int j;		// akt. pozicio pos-hoz kepest
    int idezojel = 0;	// 1 = paratlan sok idezojel volt
    int k;

  // parameterlista feldolgozasa
    pos = paramstr;
    while ((*pos == ' ') || (*pos == TAB))
	pos++;
    if (*pos != '(') {
	error_code = er_pr_openingparentheses;
	return;
    };
    pos++;
    for (i = 0; i < proc_list[proc].paramnum; i++) {
	j = 0;
	while ((pos[j] != '\0') && (idezojel || (pos[j] != ','))) {
	   if (pos[j] == '"')
	       idezojel = !idezojel;
	   j++;
	}; // while
	if (pos[j] == '\0') {
	    if (i == (proc_list[proc].paramnum - 1)) {
		j--;
		while ((pos[j] == ' ') || (pos[j] == TAB))
		    j--;
		if (pos[j] != ')') {
		    error_code = er_pr_closingparentheses;
		    return;
		};
	    } // if i
	    else {
		error_code = er_pr_paramexpected;
		return;
	    };
	} // if pos[j]
	else {
	    if (i == (proc_list[proc].paramnum - 1)) {
		error_code = er_pr_closingparentheses;
		return;
	    };
	}; // if pos[j] else
	strncpy(buf, pos, j);
	buf[j] = '\0';
	k = j - 1;
	while ((k >= 0) && ((buf[k] == ' ') || (buf[k] == TAB)))
	    buf[k--] = '\0';
	bufstart = buf;
	while ((*bufstart == ' ') || (*bufstart == TAB))
	    bufstart++;
	switch (proc_list[proc].params[i]) {
	    case tc_integer:
		int_p[int_param_num++] = eval_expr(bufstart);
		break;
	    case tc_int_array:
		k = get_var(bufstart);
		if ((k >= 0) && (vars[k].type == proc_list[proc].params[i]))
		    int_array_param = (int_array_type *)(vars[k].content);
		else
		    error_code = er_pr_paramtypeerror;
		break;
	    case tc_string:
		k = get_var(bufstart);
		if (k >= 0) {
		    if (vars[k].type == proc_list[proc].params[i])
			strcpy(string_param, ((string_type *)vars[k].content)
			       ->text);
		    else
			error_code = er_pr_paramtypeerror;
		}
		else if ((strlen(bufstart) > 1) && (*bufstart == '"')
			&& (bufstart[strlen(bufstart) - 1] == '"')) {
		    bufstart[strlen(bufstart) - 1] = '\0';
		    bufstart++;
		    strcpy(string_param, bufstart);
		}
		else
		    error_code = er_pr_paramtypeerror;
		break;
	    case tc_sprite:
		k = get_var(bufstart);
		if ((k >= 0) && (vars[k].type == proc_list[proc].params[i]))
		    sprite_param = (sprite_type *)(vars[k].content);
		else
		    error_code = er_pr_paramtypeerror;
		break;
	    case tc_text:
		k = get_var(bufstart);
		if ((k >= 0) && (vars[k].type == proc_list[proc].params[i]))
		    text_param = (text_type *)(vars[k].content);
		else
		    error_code = er_pr_paramtypeerror;
		break;
	    case tc_field:
		k = get_var(bufstart);
		if ((k >= 0) && (vars[k].type == proc_list[proc].params[i]))
		    field_param = (field_type *)(vars[k].content);
		else
		    error_code = er_pr_paramtypeerror;
		break;
	}; // switch
	pos += j + 1;
	if (error_code != er_none)
	    return;
    }; // for i

  // az egyes eljarasok kezeloinek hivasa
    switch(proc) {
	case  0: assign_sprite(sprite_param, int_p[0], int_p[1], int_p[2], int_p[3]); break;
	case  1: bitmap_sprite(sprite_param, int_p[0]); break;
	case  2: position_sprite(sprite_param, int_p[0], int_p[1]); break;
	case  3: palette_sprite(sprite_param, int_array_param); break;
	case  4: priority_sprite(sprite_param, int_p[0]); break;
	case  5: enable_sprite(sprite_param); break;
	case  6: disable_sprite(sprite_param); break;
	case  7: moveto_sprite(sprite_param, int_p[0], int_p[1], int_p[2]); break;
	case  8: moverel_sprite(sprite_param, int_p[0], int_p[1], int_p[2]); break;
	case  9: animate_sprite(sprite_param, int_p[0], int_array_param); break;
	case 10: rotate_palette_sprite(sprite_param); break;
	case 11: fade_sprite(sprite_param); break;

	case 12: assign_text(text_param, string_param, int_p[0], int_p[1], int_p[2], int_p[3]); break;
	case 13: content_text(text_param, string_param); break;
	case 14: font_text(text_param, int_p[0]); break;
	case 15: position_text(text_param, int_p[0], int_p[1]); break;
	case 16: palette_text(text_param, int_array_param); break;
	case 17: priority_text(text_param, int_p[0]); break;
	case 18: enable_text(text_param); break;
	case 19: disable_text(text_param); break;
	case 20: moveto_text(text_param, int_p[0], int_p[1], int_p[2]); break;
	case 21: moverel_text(text_param, int_p[0], int_p[1], int_p[2]); break;
	case 22: rotate_palette_text(text_param); break;
	case 23: fade_text(text_param); break;

	case 24: assign_field(field_param, int_p[0], int_p[1], int_p[2], int_p[3]); break;
	case 25: position_field(field_param, int_p[0], int_p[1]); break;
	case 26: size_field(field_param, int_p[0], int_p[1]); break;
	case 27: palette_field(field_param, int_array_param); break;
	case 28: enable_field(field_param); break;
	case 29: disable_field(field_param); break;
	case 30: rotate_field(field_param, int_p[0]); break;
	case 31: shift_field(field_param, int_p[0]); break;
	case 32: rotate_palette_field(field_param); break;
	case 33: fade_field(field_param); break;

	case 34: wait(int_p[0]); break;
	case 35: background_color(int_p[0]); break;
	case 36: enable_all(); break;
	case 37: disable_all(); break;
        case 38: make_sprite(sprite_param,int_p[0],int_p[1],int_p[2],int_p[3],int_p[4]);break;
        case 39: transparent_sprite(sprite_param);break;
        case 40: enable_table(); break;
        case 41: disable_table(); break;
	case 42: plot_sprite(sprite_param,int_p[0]); break;
    }; // switch
  // WAIT mode kezelese:
    if (option_wait && proc_list[proc].modify_screen) {
        const ax = 2;
        const ay = 442;
        const bx = 637;
        const by = ay + 22;

        setfillstyle(SOLID_FILL, 0);
        setviewport(0, 0, getmaxx(), getmaxy(), 0);
        bar(ax, ay, bx, by);
        setviewport(ax + 2, ay + 2, bx - 2, by - 2, 1);
        outtextxy(0, 0, "Press any key to next procedure, Enter to run, Esc to exit");
	k = getch();
        setfillstyle(LTSLASH_FILL, getmaxcolor());
        setviewport(0, 0, getmaxx(), getmaxy(), 0);
        bar(ax, ay, bx, by);
	if (k == 27)
            quit = 1;
        else if (k == 13) option_wait = 0;
	else if (k == 0)
	    getch();
    };
}; // exec_proc

//----------------------------------------------------------------------
