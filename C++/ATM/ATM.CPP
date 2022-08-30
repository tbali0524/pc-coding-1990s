//                   ASCII TEXTFILE MASTER (ATM)
//                           T¢th B†lint
//   BME VillamosmÇrnîki Çs Informatika Kar, Mñszaki Informatika Szak
//                I. Çvfolyam, 2. fÇlÇv, 3. tankîr
//                  Sz†m°t¢gÇp labor h†zi feladat
//                       1993. †prilis-m†jus
//
// SzÅksÇges ford°t¢: Turbo C++
// (nem objektum-orient†lt, de C++ ford°t¢ m¢d kell)
//
// Felhaszn†l¢i le°r†s ATM.DOC f†jlban
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dir.h>
#include <dos.h>
#include <ctype.h>

#define MAXSTR 255
#define FORMFEED '\f'

//
// Globalis valtozok
//======================================================================
char inputfilename[MAXPATH] = "";       // bemeneti szovegfile neve
char outputfilename[MAXPATH] = "";      // kimenete szovegfile neve
char datafilename[MAXPATH] = "";        // adatfile neve
int printmergeon = 0;                   // print merge funkcio
int justifyon = 0;                      // ket szelre igazitas
int PL = 60;                            // laphossz
int PW = 79;                            // lapszelesseg
int MT = 0;                             // felso margo
int MB = 0;                             // also margo
int ML = 0;                             // bal margo
int MR = 0;                             // jobb margo
FILE *out;                              // kimeneti fajl
int page;                               // lap sz†ma (kimeneten)
int linenum;                            // sor sz†ma (kimeneten)
char puf[MAXSTR];                       // kimeneti sor
int puflen;                             // kimeneti sor hossza
char footpuf[MAXSTR];                   // fejlec puffer (kiertekeleshez)
int footpuflen;                         // fejlec puffer hossza

//
// Definiciolista
//======================================================================
#define MAXDEFSCOUNT 100        // elemek max. szama
int defscount = 0;              // elemek szama
struct defitemtype {
   char *name;                  // nev
   char *value;                 // tartalom
} defs[MAXDEFSCOUNT];           // definiciok tombje

//
// Adatfile referencianevek
//======================================================================
#define MAXREFSCOUNT 50         // elemek max. szama
int refscount = 0;              // elemek szama
char *refname[MAXREFSCOUNT];    // referencianevek tombje
#define MAXRECORD 99            // rekordok max. szama
int recordcount = 0;            // rekordok szama

//
// Hibakezeles
//======================================================================
#define erOpenData    1
#define erDataFile    2
#define erNoRecord    3
#define erMuchRecord  4
#define erFewData     5
#define erNoData      6
#define erDefine      7
#define erUndef       8
#define erOpenInclude 9
#define erOpenInput   10
#define erOpenOutput  11
#define erInclude     12
#define erSyntax      13
#define erSymbol      14

const char hibauzenet[14][36] =
   {"Cannot open datafile ",
    "Syntax error in datafile:\n",
    "Record not found in datafile\n",
    "Too much record in datafile\n",
    "Not enough data in datafile\n",
    "Symbol names not found in datafile\n",
    "Syntax error in definition:\n",
    "Syntax error in #undef command\n",
    "Cannot open include file: ",
    "Cannot open input file: ",
    "Cannot create output file: ",
    "Syntax error in include file:\n",
    "Syntax error in input file:\n",
    "Undefined symbol: "};

void error( int errorcode, const char *s )
{
   printf("%s", hibauzenet[errorcode - 1]);
   if (s != NULL)
      puts(s);
   exit(errorcode);
}; // error

//
// Elem hozzafuzese a definiciolistahoz
//======================================================================
void adddefsitem( const char *aname, const char *avalue )
{
   char s[MAXSTR];
   int i = 0;

   strupr(strcpy(s, aname));
   while((i < defscount) && strcmp(defs[i].name, s))
      i++;
   if (i == defscount) {
      defs[i].name = strdup(s);
      defs[i].value = strdup(avalue);
      defscount++;
   }
   else {
      free(defs[i].value);
      defs[i].value = strdup(avalue);
   };
}; // adddefsitem

//
// Elem keresese definiciolistaban
//======================================================================
char *getdefsitem( const char *aname )
{
   char s[MAXSTR];
   int i = 0;

   strupr(strcpy(s, aname));
   while((i < defscount) && strcmp(defs[i].name, s))
      i++;
   if (i == defscount)
      return(NULL);
   else
      return(defs[i].value);
}; // getdefsitem

//
// Elem kivetele definiciolistabol
//======================================================================
void freedefsitem( const char *aname )
{
   char s[MAXSTR];
   int i = 0;

   strupr(strcpy(s, aname));
   while((i < defscount) && strcmp(defs[i].name, s))
      i++;
   if (i < defscount) {
      free(defs[i].name);
      free(defs[i].value);
      defscount--;
      while (i < defscount) {
         defs[i] = defs[i + 1];
         i++;
      }; // while
   }; // if
}; // freedefsitem

//
// Sztringzaro CR kivetele
//======================================================================
void NOCR( char *str )
{
   if (str[strlen(str) - 1] == '\n')
      str[strlen(str) - 1] = '\0';
}; // NOCR

//
// Szokoz es tab atugrasa
//    str: sztringre mutato pointer masolat (modosul!)
//======================================================================
#define IGNOREWS(str) while ((str[0] == ' ') || (str[0] == '\t')) str++;

//
// Betu vagy szam-e (ekezetes is lehet)
//======================================================================
int isalnumh( char c )
{
   return(isalnum(c) || (c == '_') || ((c >= 'Å') && (c <= '•')));
}; // isalnumh

//
// Elso szo keresese sztringben
//    word: az elso szo ide masolodik
//    line: pointer masolat cime a sztringrol
//       ( *line az elso szo utani karakterre all )
//======================================================================
char *getword( char *word, char **line )
{
   char *start = *line;

   while (isalnumh(**line))
      (*line)++;
   strncpy(word, start, *line - start);
   word[*line - start] = '\0';
   return(word);
}; // getword

// fuggveny prototipus
int processincludeline( const char * );

//
// Include file feldolgozasa
//======================================================================
void processincludefile( const char *filename )
{
   FILE *f;
   char s[MAXSTR];

   if (!(f = fopen(filename, "rt")))
      error(erOpenInclude, filename);
   while ((fgets(s, MAXSTR, f)) != NULL) {
      NOCR(s);
      if (!processincludeline(s))
         error(erInclude, s);
   }
   fclose(f);
}; // processincludefile

//
// #include, #define, #undef, #rem feldolgozasa (1 = sikerult)
//======================================================================
int processincludeline( const char *line )
{
   char s[MAXSTR];
   char *o;
   char command[MAXSTR];

   o = strcpy(s, line);
   IGNOREWS(o);
   if (o[0] == '#') {
      o++;
      getword(command, &o);
      strupr(command);
      if (!strcmp(command, "INCLUDE")) {
         IGNOREWS(o);
         processincludefile(o);
         return(1);
      }
      else if (!strcmp(command, "DEFINE")) {
         IGNOREWS(o);
         getword(command, &o);
         IGNOREWS(o);
         adddefsitem(command, o);
         return(1);
      }
      else if (!strcmp(command, "UNDEF")) {
         IGNOREWS(o);
         getword(command, &o);
         if (!command[0])
           error(erUndef, s);
         freedefsitem(command);
         return(1);
      }
      else
         return(!strcmp(command, "REM"));
   }
   else
      return (!o[0]);
}; // processincludeline

//
// Referencianevek meghatarozasa adatfilebol
//======================================================================
void getrefnames()
{
   FILE *f;
   char s[MAXSTR];
   char *o;
   char firstword[MAXSTR];
   int vanmeg = 1;

   if ((f = fopen(datafilename, "rt")) == NULL)
      error(erOpenData, datafilename);
   while (vanmeg && (fgets(s, MAXSTR, f) != NULL)) {
      NOCR(s);
      o = s;
      IGNOREWS(o);
      strupr(o);
      if (o[0] == '#') {                        // #... direktiva
         if (!(vanmeg = strncmp(o, "#ITEM", 5)))
            recordcount++;
         if (vanmeg && !processincludeline(o))
            error(erDataFile, s);
      }
      else if (*o != '\0') {                    // referencia nev
         getword(firstword, &o);
         refname[refscount++] = strdup(firstword);
      }; // else
   }; // while
   while ((fgets(s, MAXSTR, f)) != NULL) {      // rekordok megszamolasa
      o = s;
      IGNOREWS(o);
      if (!strncmp(strupr(o), "#ITEM", 5))
         recordcount++;
   };
   fclose(f);
   if (!recordcount)
      error(erNoRecord, NULL);
   if (recordcount > MAXRECORD)
      error(erMuchRecord, NULL);
   if (!refscount)
      error(erNoData, NULL);
}; // getrefnames

//
// Kovetkezo (itemnum-adik) rekord feldolgozasa az adatfilebol
//======================================================================
void getdata( const int itemnum )
{
   FILE *f;
   char s[MAXSTR];
   char *o;
   char p[MAXSTR];
   int record = 0;
   int data = 0;

   if ((f = fopen(datafilename, "rt")) == NULL)
      error(erOpenData, datafilename);
   while ((itemnum != record) && (fgets(s, MAXSTR, f) != NULL)) {
      o = s;
      IGNOREWS(o);
      if (!strncmp(strupr(o), "#ITEM", 5))
         record++;
   };
   while ((itemnum == record) && (fgets(s, MAXSTR, f) != NULL)) {
      NOCR(s);
      o = s;
      IGNOREWS(o);
      if (!processincludeline(o) || (*o == '\0')) {
         strcpy(p, o);
         if (!strncmp(strupr(p), "#ITEM", 5))
            record++;
         else {
            if (data == refscount)
               error(erDataFile, s);
            adddefsitem(refname[data++], s);
         }; // else
      }; // if !process
   }; // while
   if (data < refscount)
      error(erFewData, NULL);
   fclose(f);
}; // getdata

//
// Datum sztring (@DATE@)
//======================================================================
char *getdatestr( char *s )
{
   const static char honapnev[12][11] =
   {"janu†r", "febru†r", "m†rcius", "†prilis", "m†jus", "j£nius",
    "j£lius", "augusztus", "szeptember", "okt¢ber", "november", "december"};
   struct date d;

   getdate(&d);
   sprintf(s, "%u. %s %u.", d.da_year, honapnev[d.da_mon - 1], d.da_day);
   return(s);
}; // getdatestr

//
// Ido sztring (@TIME@)
//======================================================================
char *gettimestr( char *s )
{
   struct time t;

   gettime(&t);
   sprintf(s, "%u:%02u", t.ti_hour, t.ti_min);
   return(s);
}; // gettimestr

//
// Sorpuffer torlese
//======================================================================
void clearpuf()
{
   int i;

   for (i = 0; i < MAXSTR; i++)
      puf[i] = '\0';
   puflen = 0;
}; // clearpuf

//
// Fejlec sorpuffer torlese
//======================================================================
void clearfootpuf()
{
   int i;

   for (i = 0; i < MAXSTR; i++)
      footpuf[i] = '\0';
   footpuflen = 0;
}; // clearpuf

//
// Fejlec/lablec szoveg feldolgozasa (szimbolum behelyettesites)
//   (Csak egy sornyi lehet)
//======================================================================
void processfooterstring( char *s )
{
   char szimb[MAXSTR];
   char *tart;
   char *o;
   int i, j;

   o = s;
   while ((*o != '\0') && (footpuflen < PW - ML - MR)) {
      while ((*o != '\0') && (*o != '@') && (footpuflen < PW - ML - MR)) {
         if (*o == '\t') {                              // TAB
            for (i = 0; (i < 8) && (footpuflen < PW - ML - MR); i++)
               footpuf[footpuflen++] = ' ';
         }
         else if (*o != FORMFEED)
            footpuf[footpuflen++] = *o;
         o++;
      }; // while
      if ((*o == '@') && (footpuflen < PW - ML - MR)) {
         i = 1;
         while (isalnumh(o[i]))                 // szo vegenek keresese
            i++;
         if (o[i] != '@')
            error(erSymbol, o);
         if (i == 1) {                          // @@ = @
            footpuf[footpuflen++] = '@';
         } // if i
         else {
            strncpy(szimb, o + 1, i - 1);
            szimb[i - 1] = '\0';
            if ((tart = getdefsitem(szimb)) == NULL) {
               strupr(szimb);
               if (!strcmp(szimb, "HASH"))
                  processfooterstring("#");
               else if (!strcmp(szimb, "DATE"))
                  processfooterstring(getdatestr(szimb));
               else if (!strcmp(szimb, "TIME"))
                  processfooterstring(gettimestr(szimb));
               else if (!strcmp(szimb, "FILENAME"))
                  processfooterstring(inputfilename);
               else if (!strcmp(szimb, "PAGE"))
                  processfooterstring(itoa(page, szimb, 10));
               else if (!strncmp(szimb, "SPC", 3)) {
                  if (((j = atoi(szimb + 3)) > 0) && (j < MAXSTR)) {
                     for (j--; (j >= 0) && (footpuflen < PW - ML - MR); j--)
                        footpuf[footpuflen++] = ' ';
                  }
                  else
                     error(erSymbol, o);
               } // if !strncmp
               else
                  error(erSymbol, o);
            } // if tart =
            else                                // felhasznaloi szimbolum
               processfooterstring(tart);
         }; // if i else
         o += i + 1;
      }; // if o[0]
   }; // while o[0]
}; // processfooterstring

//
// Lablec kirakasa lap aljara (szoveg o-ban)
//======================================================================
void writefooter( char *o )
{
   int i;

   if (o != NULL) {
      while (linenum < PL - 2) {                        // also margo
         putc('\n', out);
         linenum++;
      };
      putc('\n', out);
      clearfootpuf();
      processfooterstring(o);
      for (i = 0; i < ((PW - MR - ML - footpuflen) / 2 + ML); i++)
         putc(' ', out);                                // kozepre rendez
      fputs(footpuf, out);
      putc('\n', out);
   }; // if o
}; // writefooter

//
// Ket szelre igazitas
//======================================================================
void justify()
{
   int i, j;
   int curpos;
   int availpos[MAXSTR];                  // poziciok, ahova kerulhet szokoz
   int availposnum = 0;                      // hany helyre kerulhet szokoz
   int neededspace = PW - ML - MR - puflen;  // hany szokoz kell

   for (i = 0; i < puflen; i++) {
      if (puf[i] == ' ')
         availpos[availposnum++] = i;
   };
   if ((neededspace > 0) && (availposnum > 0)) {
      for (i = 1; i <= neededspace; i++) {
         if ((curpos = i * availposnum / (neededspace + 1)) == availposnum)
            curpos--;
         curpos = availpos[curpos];
         for (j = puflen; j >= curpos + i; j--)
            puf[j] = puf[j - 1];
         puf[++puflen] = '\0';
      }; // for i
   }; // if neededspace
}; // justify

//
// Sorpuffer kiirasa ( just = 1, ha lehet ket szelre igazitas
//======================================================================
void writeline(int just)
{
   char *o;
   int i;

   if (linenum == 0) {                                  // uj lap
      page++;
      if ((o = getdefsitem("HEADER")) != NULL) {        // fejlec
         clearfootpuf();
         processfooterstring(o);
         for (i = 0; i < ((PW - MR - ML - footpuflen) / 2 + ML); i++)
            putc(' ', out);                             // kozepre rendez
         fputs(footpuf, out);
         fputs("\n\n", out);
         linenum = 2;
      };
      while (linenum < MT) {                    // felso margo
         putc('\n', out);
         linenum++;
      };
   }; // if linenum

   if (puflen != 0) {
      if ((puf[0] == ' ') && (puf[1] != ' ')) {
         for (i = 0; i < puflen; i++)
            puf[i] = puf[i + 1];
         puflen--;
      };
      if (just && justifyon) {
         if ((puf[puflen - 1] == ' ') && (puflen > 1) &&
            (puf[puflen - 2] != ' '))
               puf[--puflen] = '\0';
         justify();
      };
      if (puflen != 0) {
         while (puf[puflen - 1] == ' ')         // zaro szokozok kivetele
            puf[--puflen] = '\0';
         if (puflen != 0) {
            for (i = 0; i < ML; i++)            // bal margo
               putc(' ', out);
            fputs(puf, out);
         };
      }; // if puflen
      clearpuf();
   }; // if puflen
   putc('\n', out);
   linenum++;

   o = getdefsitem("FOOTER");                   // lablec
   if ((linenum >= PL - MB) || ((linenum == PL - 2) && (o != NULL))) {
      writefooter(o);
      putc(FORMFEED, out);
      linenum = 0;
   }; // if linenum
}; // writeline

//
// Sztring feldolgozasa (szimbolumok behelyettesitese)
//======================================================================
void processstring( char *s )
{
   char szimb[MAXSTR];
   char *tart;
   char *o;
   int i, j;

   o = s;
   while (*o != '\0') {
      while ((*o != '\0') && !isalnumh(*o) && (*o != '@')) {
         if (*o == '\t') {                            // TAB
            for (i = 0; (i < 8) && (puflen < PW - ML - MR); i++)
               puf[puflen++] = ' ';
         }
         else if (*o == FORMFEED) {             // lapdobas
            writeline(0);
            if (linenum != 0) {
               writefooter(getdefsitem("FOOTER"));
               putc(FORMFEED, out);
               linenum = 0;
            }; // if linenum
         } // else if
         else
            puf[puflen++] = o[0];
         if (puflen == PW - ML - MR)
            writeline(1);
         o++;
      }; // while
      if (*o != '\0') {
         i = (o[0] == '@');
         while (isalnumh(o[i]))                 // szo vegenek keresese
            i++;
         if (o[0] == '@') {                     // szimbolumnev
            if (o[i] != '@')
               error(erSymbol, o);
            if (i == 1) {                       // @@ = @
               puf[puflen++] = '@';
               if (puflen == PW - ML - MR)
                  writeline(1);
            } // if i
            else {
               strncpy(szimb, o + 1, i - 1);
               szimb[i - 1] = '\0';
               if ((tart = getdefsitem(szimb)) == NULL) {
                  strupr(szimb);
                  if (!strcmp(szimb, "NEWPAGE")) {
                     writeline(0);
                     if (linenum != 0) {
                        writefooter(getdefsitem("FOOTER"));
                        putc(FORMFEED, out);
                        linenum = 0;
                     };
                  } // if NEWPAGE
                  else if (!strcmp(szimb, "HASH"))
                     processstring("#");
                  else if (!strcmp(szimb, "DATE"))
                     processstring(getdatestr(szimb));
                  else if (!strcmp(szimb, "TIME"))
                     processstring(gettimestr(szimb));
                  else if (!strcmp(szimb, "FILENAME"))
                     processstring(inputfilename);
                  else if (!strcmp(szimb, "PAGE"))
                     processstring(itoa(page, szimb, 10));
                  else if (!strncmp(szimb, "SPC", 3)) {
                     if (((j = atoi(szimb + 3)) > 0) && (j < MAXSTR)) {
                        szimb[j] = '\0';
                        for (j--; j >= 0; j--)
                           szimb[j] = ' ';
                        processstring(szimb);
                     } // if j
                     else
                        error(erSymbol, o);
                  } // if SPC
                  else if (!strncmp(szimb, "CR", 2)) {
                     if ((i == 3) || ((j = atoi(szimb + 2)) > 0) &&
                           (j < MAXSTR)) {
                        if (i == 3)
                           j = 1;
                        for (j--; j >= 0; j--)
                           writeline(0);
                     } // if j
                     else
                        error(erSymbol, o);
                  } // if CR
                  else
                     error(erSymbol, o);
               } // if tart =
               else
                  processstring(tart);          // felhasznaloi szimbolum
            }; // if i else
            o += i + 1;
         } // if o[0]
         else {
            if (puflen + i > PW - ML - MR)
               writeline(1);                    // puffer uritese
            for (j = 0; j < i; j++)
               puf[puflen++] = o[j];
            if (puflen >= PW - ML - MR)
               writeline(1);
            o += i;
         }; // if o[0] else
      }; // if *0 != '\0'
   }; // while o[0]
}; // processstring

//
// Forrasfajl feldolgozasa
//======================================================================
void processfile()
{
   FILE *in;
   char s[MAXSTR];
   char *o;

   page = linenum = 0;
   clearpuf();
   if ((in = fopen(inputfilename, "rt")) == NULL)
      error(erOpenInput, inputfilename);
   if ((out = fopen(outputfilename, "wt")) == NULL)
      error(erOpenOutput, outputfilename);
   while (fgets(s, MAXSTR, in) != NULL) {
      NOCR(s);
      o = s;
      IGNOREWS(o);
      if (*o == '#') {                          // #... direktivak
         if (!processincludeline(o))
            error(erSyntax, s);
      }
      else {
         switch(s[0]) {
            case ' ':
            case '\t':
               if (puflen != 0)
                  writeline(0);                 // puffer urites
               processstring(s);
               if (puflen != 0)
                  writeline(0);                 // sor kiiras
               break;
            case '\0':
               if (puflen != 0)
                  writeline(0);                 // puffer urites
               writeline(0);                    // ures sor
               break;
            default:
               if ((puflen != 0) && (puf[puflen - 1] != ' ')) {
                  puf[puflen++] = ' ';
                  if (puflen == PW - ML - MR)
                     writeline(1);
               }; // if puflen != 0
               processstring(s);
         }; // switch
      }; // else
   }; // while
   if (puflen != 0)
      writeline(0);
   if (linenum != 0)
      writefooter(getdefsitem("FOOTER"));
   fclose(out);
   fclose(in);
}; // processfile

//
// Help kepernyo
//======================================================================
void helpscreen()               
{
   puts("Usage:  ATM  inputfilename[.TXT] [outputfilename] [options]\n");
   puts("Options:");
   puts("   /D[datafilename[.DAT]]   print merge from datafile");
   puts("   /J                       justify output text");
   puts("   /PLn                     page length   = n lines");
   puts("   /PWn                     page width    = n chars");
   puts("   /MTn                     top margin    = n lines");
   puts("   /MBn                     bottom margin = n lines");
   puts("   /MLn                     left margin   = n chars");
   puts("   /MRn                     right margin  = n chars\n");
   puts("See ATM.DOC for more information");
   exit(-1);
}; // helpscreen

//
// Parancssor parameterek feldolgozasa
//======================================================================
void getparams(int argc, char *argv[])
{
   char drive[MAXDRIVE];
   char dir[MAXDIR];
   char file[MAXFILE];
   char ext[MAXEXT];
   char s[MAXSTR];
   char *o;
   int i;

   for (i = 1; i < argc; i++) {
      strcpy(s, argv[i]);
      o = strupr(s);
      if ((o[0] == '/') || (o[0] == '-')) {
         switch (o[1]) {
            case 'D':
               strcpy(datafilename, o + 2);
               printmergeon = 1;
               break;
            case 'J':
               justifyon = 1;
               break;
            case 'P':
               switch (o[2]) {
                  case 'L':
                     if ((sscanf(o + 3, "%u", &PL) != 1) || (PL < 5))
                        helpscreen();
                     break;
                  case 'W':
                     if ((sscanf(o + 3, "%u", &PW) != 1) || (PW >= MAXSTR))
                        helpscreen();
                     break;
                  default:
                     helpscreen();
               }; // switch o[2]
               break;
            case 'M':
               switch(o[2]) {
                  case 'T':
                     if (sscanf(o + 3, "%u", &MT) != 1)
                        helpscreen();
                     break;
                  case 'B':
                     if (sscanf(o + 3, "%u", &MB) != 1)
                        helpscreen();
                     break;
                  case 'L':
                     if (sscanf(o + 3, "%u", &ML) != 1)
                        helpscreen();
                     break;
                  case 'R':
                     if (sscanf(o + 3, "%u", &MR) != 1)
                        helpscreen();
                     break;
                  default:
                     helpscreen();
               }; // switch o[2]
               break;
            default:
               helpscreen();
         }; // switch o[1]
      } // if o[0]
      else if (!inputfilename[0])
         strcpy(inputfilename, o);
      else if (!outputfilename[0])
         strcpy(outputfilename, o);
      else
         helpscreen();
   }; // for
   if ((!inputfilename[0]) || (ML + MR >= PW) || (MT + MB >= PL))
      helpscreen();
   fnsplit(inputfilename, drive, dir, file, ext);
   if (!ext[0]) {
      strcpy(ext, ".TXT");
      fnmerge(inputfilename, drive, dir, file, ext);
   };
   if (!outputfilename[0]) {
      strcpy(ext, ".OUT");
      fnmerge(outputfilename, drive, dir, file, ext);
   };
   if (printmergeon) {
      if (!datafilename[0]) {
         strcpy(ext, ".DAT");
         fnmerge(datafilename, drive, dir, file, ext);
      }
      else {
         fnsplit(datafilename, drive, dir, file, ext);
         if (!ext[0]) {
            strcpy(ext, ".DAT");
            fnmerge(datafilename, drive, dir, file, ext);
         }; // if !ext
      }; // if !data else
   }; // if printmergeon
}; // getparams

//
// Foprogram
//======================================================================
int main(int argc, char *argv[])
{
   char drive[MAXDRIVE];
   char dir[MAXDIR];
   char file[MAXFILE];
   char ext[MAXEXT];
   int i;

   puts("Ascii TextFile Master   (c) T¢th B†lint, 1993\n");
   getparams(argc, argv);
   if (printmergeon) {
      getrefnames();
      for (i = 1; i <= recordcount; i++) {
         getdata(i);
         fnsplit(outputfilename, drive, dir, file, ext);
         ext[0] = '.';
         ext[1] = 'O';
         ext[2] = '0' + (char)(i / 10);
         ext[3] = '0' + (char)(i % 10);
         ext[4] = '\0';
         fnmerge(outputfilename, drive, dir, file, ext);
         processfile();
      }; // for
   } // if
   else
      processfile();
   exit(0);
}; // main
