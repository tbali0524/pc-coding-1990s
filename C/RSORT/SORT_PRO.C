/* sort_pro.c */
/* remote sort - server procedure */
/* Toth Balint, Info 3.evf.3.tk., 1995.II. */

#include <string.h>
#include <rpc\rpc.h>
#include "sort.h"

sortstrings *sort_1(sortstrings *str_in)
{
    static char strings[MAXSORTSIZE][MAXSTRINGLEN + 1];
    static char *pstrings[MAXSORTSIZE];
    static sortstrings str_out;
    int i, j, k;
    int len;
    int index[MAXSORTSIZE];

    for (i = 0; i < MAXSORTSIZE; i++)
	index[i] = i;
    len = str_in->ss.ss_len;
    for (i = len - 1; i > 0; i--)
	for (j = 0; j < i; j++)
	    if (strcmp(str_in->ss.ss_val[index[j]],
		       str_in->ss.ss_val[index[j+1]]) > 0)
	    {
		k = index[j + 1];
		index[j + 1] = index[j];
		index[j] = k;
	    };
    for (i = 0; i < len; i++)
    {
	strcpy(strings[i], str_in->ss.ss_val[index[i]]);
	pstrings[i]=strings[i];
    };
    for (i = len; i < MAXSORTSIZE; i++)
    {
	strings[i][0]=0;
	pstrings[i]=strings[i];
    };
    str_out.ss.ss_len = len;
    str_out.ss.ss_val = pstrings;
    return (&str_out);
};
