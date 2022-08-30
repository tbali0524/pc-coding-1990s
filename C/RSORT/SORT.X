/* sort.x */
/* Toth Balint, Info 3.evf. 3.tk. */
/* remote sort - RPC definitions */

const MAXSORTSIZE  = 64;
const MAXSTRINGLEN = 64;

typedef string str<MAXSTRINGLEN>;

struct sortstrings {
    str ss<MAXSORTSIZE>;
};
/*typedef str sortstrings<MAXSORTSIZE>;
*/
program SORTPROG {
    version SORTVERS {
	sortstrings SORT(sortstrings) = 1;
    } = 1;
} = 22855;
