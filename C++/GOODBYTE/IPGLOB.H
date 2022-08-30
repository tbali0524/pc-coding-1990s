// IPGLOB2.H
// Interpreter kozos deklaracioi (strukturak,konstansok,valtozok,fuggvenyek)
//===========================================================================
//
// GOOD-BYTE project
// 2.csapat (Alm.A,Visi G.,Toth B.)
// utolso modositas: V.17.
//
// T.B.
//
//======================================================================

// valtozodeklaraciok itt extern-nel, extern nelkul IPGLOB2.CPP-ben
// fuggvenytorzsek az IPGLOB2.CPP, IPRUTIN2.CPP, IPEVAL2.CPP, ... file-okban

#include <dir.h>

//======================================================================
// HIBAKEZELES
//-------------

// hibakodok
const er_none			= 0;	// nincs hiba

const er_ip_outofmemory		= 2;
const er_ip_baddosargument	= 3;
const er_ip_cannotinithardware	= 4;


// hibakodok

const er_ip_userbreak           = 100;
const er_ip_stackoverflow       = 101;

const er_ip_file                = 110;
const er_ip_openfile            = 111;
const er_ip_toolongline         = 112;

const er_ip_syntax              = 120;

const er_ip_unexpectedendoffile = 130;
const er_ip_alreadyinsketch     = 131;
const er_ip_unexpectedendsketch = 132;
const er_ip_missingsketch       = 133;

const er_ip_inexpression        = 140;

const er_ip_alreadybitmaps      = 141;
const er_ip_bitmapscount        = 142;

const er_ip_alreadyfonts        = 143;
const er_ip_fontscount          = 144;

const er_ip_reservedword        = 150;
const er_ip_builtinproc         = 151;
const er_ip_alreadyvar          = 152;

const er_ip_noleftvalue         = 160;
const er_ip_badindexofarray     = 161;
const er_ip_novar               = 162;

const er_ip_unexpecteduntil     = 170;

const er_ip_unexpectedendwhile  = 171;

const er_ip_missingto           = 172;
const er_ip_unexpectedendfor    = 173;

const er_ip_missingthen         = 174;
const er_ip_unexpectedelse      = 175;
const er_ip_unexpectedendif     = 176;

// beepitett eljarasok hibai
const er_badbmp                 = 190;
const er_badfont                = 191;
const er_noassign               = 192;
const er_baddir                 = 193;
const er_outoftable             = 194;
const er_spoutofr               = 195;

// kifejezes kiertekelo hibai
const er_ev_syntax		= 201;
const er_ev_unknownidentifier	= 202;
const er_ev_closingparentheses	= 203;
const er_ev_closingbracket	= 204;
const er_ev_openingbracket	= 205;
const er_ev_operandexpected	= 206;
const er_ev_emptyexpression	= 207;
const er_ev_indexoutofrange	= 208;
const er_ev_divisionbyzero	= 209;

// beepitett eljarasok hibai
const er_pr_openingparentheses	= 221;
const er_pr_closingparentheses	= 222;
const er_pr_paramexpected	= 223;
const er_pr_paramtypeerror	= 224;
const er_pr_intparamoutofrange	= 225;

// szimbolum- es eroforraskezelo hibai
const er_sy_cannotloadbitmap	= 231;
const er_sy_invalidbitmap	= 232;
const er_sy_cannotloadfont	= 233;
const er_sy_invalidfont		= 234;
const er_sy_toomanybitmaps	= 235;
const er_sy_toomanyfonts	= 236;
const er_sy_toomanyvars		= 237;
const er_sy_redefinevar		= 238;

extern int error_code;	// hibakod (er_XXXX konstansok)

// szoveges hibauzenetet ado fuggveny
extern char* error_text(char* dest, int error_code);

//======================================================================
// EROFORRASOK ES VALTOZOK NYILVANTARTASA
//----------------------------------------

// Eroforras- es valtozotipusokat leiro strukturak
struct bitmap_type {    // bitmap eroforras leiroja
    char* image;	// a bitmap kep tartalma
			// sorfolytonosan a szinkodok (1byte-1pixel)
    int imagesize;	// a byte-ok szama image* -ban (height*width)
    int width;		// a bitmap szelessege pixelben
    int height;		// a bitmap magassaga pixelben
    int colors;		// szinek szama
};

struct font_type {	// font eroforras leiroja
    char *image[256];	// az egyes karakterek kepei (mint bitmap image-nel)
			// ("ascii" kod szerint indexelve)
			// (NULL ha nincs ilyen kodu karakter)
    int imagesize;	// a byte-ok szama egy karakter kepeben (height*width)
    int charnum;	// karakterek szama
    int width;		// egy karakter szelessege pixelben
    int height;		// egy karakter magassaga pixelben
    int colors;		// szinek szama
};

// (az egyseges kezeles miatt kell)
struct integer_type {	// integer valtozo leiroja
    int value;		// a valtozo erteke
};

struct int_array_type {	// int_array valtozo (egesz tomb) leiroja
    char* items;	// az elemek ertekei sorban, elemenkent 2 byte
    int itemnum;	// elemek szama a tombben
};

struct string_type {	// string valtozo leiroja
    char* text;		// a sztring tartalma
    int textsize;	// text* merete zaro "0"-lal egyutt byte-ban
};

struct sprite_type {	// sprite objektum valtozo leiroja
    int bitmap;		// a tartalom bitmap azonosito szama
			// (a bitmapleirobol width, height, colors megkaphato)
    int startx;		// bal felso pont x koordinataja
    int starty;		// bal felso pont y koordinataja
    int palette[8];	// paletta a logikai -> fizikai szinkodvaltashoz
    int priority;	// prioritas (a nagyobb lefedi a kisebbet)
    int enabled;	// engedelyezve van-e a megjelenites (1=igen,0=nem)
};

struct text_type {	// text objektum valtozo leiroja
    char* text;		// a kiirando sztring
    int textsize;	// text* merete zaro "0"-lal egyutt byte-ban
    int font;		// a hasznalt font azonosito szama
			// (a fontleirobol width, height, colors megkaphato)
    int startx;		// bal felso pont x koordinataja
    int starty;		// bal felso pont y koordinataja
    int palette[8];	// paletta a logikai -> fizikai szinkodvaltashoz
    int priority;	// prioritas (a nagyobb lefedi a kisebbet)
    int enabled;	// engedelyezve van-e a megjelenites (1=igen,0=nem)
};

struct field_type {	// field objektum valtozo leiroja
    char* image;	// a mezo aktualis tartalma (mint bitmap image-nel)
    int imagesize;	// a byte-ok szama image* -ban
    int width;		// a mezo szelessege pixelben
    int height;		// a mezo magassaga pixelben
    int startx;		// bal felso pont x koordinataja
    int starty;		// bal felso pont y koordinataja
    int palette[8];	// paletta a logikai -> fizikai szinkodvaltashoz
    int enabled;	// engedelyezve van-e a megjelenites (1=igen,0=nem)
};

// valtozotipusok kodjai (szimbolumtabla (vars tomb) type mezoje)
const tc_integer   = 'I';
const tc_int_array = 'A';
const tc_string    = 'C';
const tc_sprite    = 'S';
const tc_text      = 'T';
const tc_field     = 'F';

// szimbolumtabla egy eleme
struct var_type {
    char* name;		// valtozo neve (azonositoja)
    char type;		// tipus kodja (tc_XXXX konstansok)
    void* content;	// a valtozo tartalma (mutato egy megfelelo
			// integer_type, int_array_type, string_type,
			// sprite_type, text_type vagy field_type
			// tipusu struct-ra)
};

// leiro-tablazatok max. merete
const max_bitmaps	= 100;		// bitmap eroforrasok max. szama
const max_fonts		= 20;		// font eroforrasok max. szama
const max_vars		= 100;		// valtozok max. szama
const max_priority_objects = max_vars;	// objektumok max. szama
					// (SPRITE,TEXT,FIELD)

// leiro-tablazatok aktualis merete (elemek szama)
extern int act_bitmaps;			// bitmap eroforrasok szama
extern int act_fonts;			// font eroforrasok szama
extern int act_vars;			// valtozok szama
extern int act_priority_objects;	// objektumok szama

// eroforrasok es valtozok leiro tablazatai
extern bitmap_type bitmaps[max_bitmaps];	// bitmap eroforrasok
extern font_type fonts[max_fonts];		// font eroforrasok
extern var_type vars[max_vars];			// valtozok (szimbolumtabla)
// prioritasi sor (vars tombbeli indexek)
extern int priority_objects[max_priority_objects];

// fuggvenyek:
//------------

// bitmap eroforras betoltese file-bol (IPRUTIN2.CPP)
void load_bitmap(char* filename);

// font eroforras betoltese file-bol (IPRUTIN2.CPP)
void load_font(char* filename);

// uj valtozo letrehozasa a szimbolumtablaban (IPRUTIN2.CPP)
// type: tipus kodja (tc_XXXX konstansok
// param: INTEGER eseten a kezdoertek (jol jon a beepitett valtozokhoz)
//        INT_ARRAY eseten a tomb merete (elemek szama)
//        egyebkent barmi (legyen 0)
void def_var(char* name, char type, int param);

// kereses szimbolumtablaban nev szerint (IPRUTIN2.CPP)
// eredmeny: a bejegyzes indexe a vars tombben, vagy -1 ha nincs ilyen
int get_var(char* name);

// prioritasi sor felepitese objektumokbol (IPRUTIN2.CPP)
void build_priority_objects();

//======================================================================
// PARANCSSOR PARAMETEREK
//------------------------

extern char main_hcl_file[MAXPATH];	// fo HCL forrasfajl
extern char sketch_name[MAXPATH];	// futtatando jelenetnev
					// (ha teljes musor, akkor '\0')

// hardverszimulator fizikai jellemzoi
extern int maxx;	// pixelek szama x iranyban - 1
extern int maxy;	// pixelek szama y iranyban - 1
extern int maxcol;	// szinek szama - 1

// interpreter futasi opciok (1=bekapcsolva,0=ki)
extern int option_wait;		// varakozasos mod (/W opcio)
extern int option_loop;		// vegtelenitett mod (/L opcio)
extern int option_quiet;	// csendes mod (/Q opcio)
extern int option_debug;	// hibakeresesi mod (/D opcio)

extern int quit;

// parancssor parameterek feldolgozasa (hivas: init_ip ELOTT) (IPRUTIN2.CPP)
void get_dos_args(int argc, char *argv[]);

//======================================================================
// BEEPITETT ELJARASOK KEZELESE
//------------------------------

extern char* table;	// a kijelzo tartalma a kepgeneralashoz

extern int background_col;	// hatterszin a kijelzon

// beepitett eljaras leirojanak keresese nev alapjan (IPRUTIN2.CPP)
// eredmeny: a bejegyzes indexe a proc_list tombben, -1 ha nincs ilyen
// (ezt kell exec_proc-nak atadni)
int get_proc(char* name);

// beepitett eljaras vegrehajtasa (IPRUTIN2.CPP)
// proc: az eljaras indexe a proc_list tombben
// paramstr: a parameterlista ( ) kozott
void exec_proc(int proc, char* paramstr);

void assign_sprite (struct sprite_type *obj,int bmp,int x,int y,int pri);
void make_sprite(struct sprite_type *obj,int x,int y,int w,int h,int pri);
void bitmap_sprite (struct sprite_type *obj,int bmp);
void position_sprite (struct sprite_type *obj,int x,int y);
void palette_sprite (struct sprite_type *obj,struct int_array_type *pal);
void priority_sprite (struct sprite_type *obj,int pri);
void enable_sprite (struct sprite_type *obj);
void disable_sprite (struct sprite_type *obj);
void plot_sprite(struct sprite_type *obj,int speed);
void moveto_sprite (struct sprite_type *obj,int tox,int toy,int phase);
void moverel_sprite (struct sprite_type *obj,int relx,int rely,int phase);
void animate_sprite (struct sprite_type *obj,int wait,int_array_type *pics);
void rotate_palette_sprite (struct sprite_type *obj);
void fade_sprite (struct sprite_type *obj);
void transparent_sprite(struct sprite_type *obj);

void assign_text (struct text_type *obj,char *text,int font,int x,int y,int pri);
void content_text (struct text_type *obj,char *text);
void font_text (struct text_type *obj,int font);
void position_text (struct text_type *obj,int x,int y);
void palette_text (struct text_type *obj,struct int_array_type *pal);
void priority_text (struct text_type *obj,int pri);
void enable_text (struct text_type *obj);
void disable_text (struct text_type *obj);
void moveto_text(struct text_type *obj,int tox,int toy,int phase);
void moverel_text(struct text_type *obj,int relx,int rely,int phase);
void rotate_palette_text (struct text_type *obj);
void fade_text (struct text_type *obj);

void assign_field (struct field_type *obj,int width,int height,int x,int y);
void position_field (struct field_type *obj,int x,int y);
void size_field (struct field_type *obj,int width,int height);
void palette_field (struct field_type *obj,struct int_array_type *pal);
void enable_field (struct field_type *obj);
void disable_field (struct field_type *obj);
void rotate_field(struct field_type *obj,int dir,int u=1);
void shift_field(struct field_type *obj,int dir);
void rotate_palette_field (struct field_type *obj);
void fade_field (struct field_type *obj);

void disable_all();
void enable_all();
void enable_table();
void disable_table();
void background_color(int col);
void wait(int t);

//======================================================================
// EGYEB FUGGVENYEK
//------------------

// inicializalas musor-futtatas elejen
void init_ip();

// lezaras musor-futtatas vegen
void done_ip();

// inicializalas sketch elejen
void init_sketch();

// lezaras (belso dinamikus valtozok felszabaditasa) sketch vegen
void done_sketch();

// egesz-kifejezes kiertekelese (IPEVAL2.CPP)
int eval_expr(char* expr);
