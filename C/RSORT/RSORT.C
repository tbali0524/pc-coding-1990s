/* rsort.c */
/* remote sort - client program */
/* Toth Balint, Info 3.evf.3.tk., 1995.II. */

#include <stdlib.h>
#include <stdio.h>
#include <rpc\rpc.h>
#include "sort.h"

main (argc, argv)
int argc;
char *argv[];
{
    CLIENT *cl;
    char *server;
    sortstrings str_in, *str_out;
    int i;

    if (argc < 2) {
	fprintf(stderr, "usage: %s <host> <string1> ...\n", argv[0]);
	exit(1);
    };
    if (argc > (MAXSORTSIZE + 2)) {
	fprintf(stderr, "Maximal number of strings: %d\n", MAXSORTSIZE);
	exit(2);
    };
    for (i = 2; i < argc && strlen(argv[i]) <= MAXSTRINGLEN; i++)
	;
    if (i != argc)
    {
	fprintf(stderr,"Maximal length of a string: %d\n", MAXSTRINGLEN);
	exit(3);
    };
    server = argv[1];
    cl = clnt_create(server, SORTPROG, SORTVERS, "tcp");
    if (cl == NULL)
    {
	clnt_pcreateerror(server);
	exit(4);
    };
    str_in.ss.ss_len = argc - 2;
    str_in.ss.ss_val = argv + 2;
    str_out = sort_1(&str_in, cl);
    if (str_out == NULL)
    {
	clnt_perror(cl, server);
	exit(5);
    };
    for (i = 0; i < (argc - 2); i++)
	fprintf(stdout, "%s\n", str_out->ss.ss_val[i]);
    clnt_destroy(cl);
    exit(0);
};
