/* LOCKPLAY.C jatekos (kliens oldali) foprogram
  Toth Balint, Info, 3.evf. 3.tk
  SzamGep labor, H2 tema (konkurrens filekezeles)
*/

#include "lock.h"
#include "lockdef.h"
#include <time.h>
#include <stdlib.h>
#include <conio.h>

int main(int argc, char *argv[])
{
    extern lock_reply reply;
    int limit[MAX_LOCK_SIZE + 1];
    int free, start, len, i;

    if (argc != 2) {
	printf("Haszn lat: %s <szerverc¡m>\n", argv[0]);
        exit(1);
    };
    DefineServer(argv[1]);
    randomize();
    free = PLAYFIELD_SIZE;
    start = random(PLAYFIELD_SIZE - MAX_LOCK_SIZE);
    len = MAX_LOCK_SIZE;
    limit[0] = limit[1] = 0;
    for (i = 2; i <= MAX_LOCK_SIZE; i++)
	limit[i] = ((i - 1) * PLAYFIELD_SIZE) / i;
    while (!kbhit()) {
	start = (start + len) % (PLAYFIELD_SIZE - 1 - len);
	while ((limit[len] > free) && (len > 1))
	    len--;
	lock(start, len);
	if (reply >= 0)
	    free = reply % PLAYFIELD_SIZE;
    };
    return(0);
};
