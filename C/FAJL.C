/* nyomtathato karakterek szama a fajlban */

#include <stdio.h>

char *filename = "FAJL.C";

FILE *f;
int i;
long nyomt = 0;
long total = 0;

void main()
{
    printf("Vizsgalando file: %s\n", filename);
    if ((f = fopen(filename, "rt")) == NULL)
        printf("Nem tudom megnyitni!\n");
    else
    {
        while ((i = fgetc(f)) != EOF)
        {
            total++;
            if ((i > 31) && (i != 127))
               nyomt++;
        };
        fclose(f);
        printf("Osszes karakter: %ld\nEbbol nyomtathato: %ld", total, nyomt);
        if (total != 0)
            printf(" (%5.1f%%)\n", (double)nyomt / (double)total * 100);
        else
            printf("\n");
    }
}