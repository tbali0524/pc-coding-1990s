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
/*    extern lock_reply reply;*/
    int limit[MAX_LOCK_SIZE + 1];
    int free, start, len, delta, i;

    if (argc != 2) {
	printf("Haszn lat: %s <szerverc¡m>\n", argv[0]);
	exit(1);
    };
    randomize();
    free = PLAYFIELD_SIZE;
    start = random(PLAYFIELD_SIZE - MAX_LOCK_SIZE);
    len = MAX_LOCK_SIZE;
    limit[0] = limit[1] = 0;
    delta = 11;
    for (i = 2; i <= MAX_LOCK_SIZE; i++)
	limit[i] = ((i - 1) * PLAYFIELD_SIZE) / i;
    DefineServer(argv[1]);
    while (!kbhit()) {
	if (abs(delta) < (PLAYFIELD_SIZE / 3))
            delta = -(delta * 3);
	else
            delta = 11;
	start = (start + len + delta + PLAYFIELD_SIZE) % PLAYFIELD_SIZE;
	while ((limit[len] > free) && (len > 1))
	    len--;
	i = lock(start, len);
        if (i >= 0)
	    free = i % PLAYFIELD_SIZE;
    };
    return(0);
};
