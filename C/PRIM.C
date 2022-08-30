/* Eratosztenesz szitaja es primtenyezos felbontas */
/* Szatm ry Zolt n & T¢th B lint */

#include <stdio.h>
#include <conio.h>
#include <math.h>

#define maxi 25

int a[maxi], i, j, k;

void szita() {  
  for (i=0; i<maxi; a[i++]=1);
  j=2;
  while (j<sqrt(maxi)) { 
    for (i=2*j; i<maxi; i+=j)
      a[i]=0;
    j++;
    while ((a[j]==0) && (j<maxi))
      j++;
    }
}

void felbont() {
  for (i=2; i<maxi; i++) {
    printf("%3d", i);
    if (a[i] == 1)
      printf(" : prim\n");
    else {
      printf(" = ");
      j=i;
      k=2;
      while (j>1)
        if ((j%k)==0) {
          if (j!=i)
            printf(" * ");
          printf("%d", k);
          j=j/k;
          }
        else {
          k++;
          while ((a[k]!=1)&&(k!=j))
            k++;
          }
      printf("\n");
      }
    }
}

void main() {
  clrscr();
  szita();
  felbont();
}