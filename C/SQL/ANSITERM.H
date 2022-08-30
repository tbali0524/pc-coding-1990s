/*----------------------------  ANSITERM.H  ---------------------------------*/




#define BEEP                           printf("\007")

    /* 800 Mz tone for 1/4 second -- same as PRINT CHR$(7) */

#define CLEARSCREEN                    printf("\033[2J")
#define CLS                            CLEARSCREEN
#define CLRSCR                 CLEARSCREEN
    /* clears the screen and positions cursor at top left corner */
    /* "\033" is Octal for "Escape" or ASCII Decimal 27  (CHR$(27)) */
    /* "Escape-[" is the lead-in for the ANSI.SYS code routines */

#define CURSPOS(x,y)                   printf("%c[%u;%uH",'\033',(x),(y))
#define GOTOXY(x,y)                    CURSPOS(x,y)
    /* positions cursor at x = row, y = column */
#define CLREOL                         printf("\033[K")

    /* erases to end of line, including cursor position */
    /* NOTE:  error in DOS documentation has 'K' lower case */
#define XYEOL(x,y)          printf("%c[%u;%uH%c[K",'\033',(x),(y),'\033')

    /* positions cursor at x,y then erases to end of line */

#define CURSUP(x)                      printf("\033[%uA",(x))
#define CURSDWN(x)                     printf("\033[%uB",(x))
    /* cursor up or down x-many lines */
#define CURSFWD(y)                     printf("\033[%uC",(y))
#define CURSBCK(y)                     printf("\033[%uD",(y))
    /* cursor forward (right) or backward (left) y-many spaces */
