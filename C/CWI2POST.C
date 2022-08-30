/* CWI -> "postekezetes" konverzio */

#include <stdio.h>

char *inpfname = "INPUT.TXT";
char *outfname = "OUTPUT.TXT";

#define BETUSZAM 13

const char cwi[] =   {'†', 'Ç', '°', '¢', 'î', 'ì', '£', 'Å', 'ñ',
                      'è', 'ê', 'ô', 'ö'};
const char post1[] = {'a', 'e', 'i', 'o', 'o', 'o', 'u', 'u', 'u',
                      'A', 'E', 'O', 'U'};
const char post2[] = {'\'','\'','\'','\'',':', '\"','\'',':', '\"',
                      '\'','\'',':', '\"'};

FILE *inpf;
FILE *outf;
int i, j;

void main()
{
    printf("Konvertalando file: %s\n", inpfname);
    if ((inpf = fopen(inpfname, "rt")) == NULL)
        printf("Nem tudom megnyitni!\n");
    else
    {
        if ((outf = fopen(outfname, "wt")) == NULL)
            printf("Nem tudom megnyitni a kimenetet!\n");
        else
        {
            while ((i = fgetc(inpf)) != EOF)
            {
                for (j = 0; (j < BETUSZAM) && ((char)i != cwi[j]); j++)
                    ;
                if (j < BETUSZAM)
                {
                    fputc(post1[j], outf);
                    fputc(post2[j], outf);
                }
                else
                    fputc(i, outf);
            }
            fclose(outf);
            printf("Ok\n");
         }
         fclose(inpf);
    }
}