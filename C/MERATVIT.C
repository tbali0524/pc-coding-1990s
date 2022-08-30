/* BME Info 3.evf.1.felev */
/* Meres 1: programozott adatatvitel (feltetel nelkuli es felteteles) */

#include <stdio.h>
#include <conio.h>
#include <dos.h>

const masodreg_iras 	  = 0x300;
const kapcsolo_olvasas    = 0x300;
const kijelzo_iras 	  = 0x301;
const szamlalo_olvasas    = 0x301;
const szamlalo_torles 	  = 0x303;
const allapot_reg_olvasas = 0x304;

void fnpa1(void)
{
  outportb(masodreg_iras, 0);
  while (!kbhit())
    outportb(kijelzo_iras, inportb(kapcsolo_olvasas));
};

void fnpa2(void)
{
  inportb(szamlalo_torles);
  outportb(masodreg_iras, 1);
  while (!kbhit()) {
    printf("%5x", inportb(szamlalo_olvasas));
    delay(20);
  };
};

void fpa1(void)
{
  int d, i, hx, sw;

  printf ("SWSTAT  HXSTAT\n");
  while(1) {
    outportb(masodreg_iras, 0);
    do {
      i = inportb(allapot_reg_olvasas);
      sw = i & 1;
      hx = (i >> 1) & 1;
    } while (!kbhit() && !sw);
    if (!sw || kbhit())
      return;
    printf("%d       %d\r", sw, hx);
    d = inportb(kapcsolo_olvasas);
    do {
      i = inportb(allapot_reg_olvasas);
      sw = i & 1;
      hx = (i >> 1) & 1;
    } while (!kbhit() && !hx);
    if (!hx || kbhit())
      return;
    printf("%d       %d\r", sw, hx);
    outportb(kijelzo_iras, d);
  };
};


void fpa2(void)
{
  int i, cnt;

  inportb(szamlalo_torles);
  outportb(masodreg_iras, 0);
  while (1) {
    do {
      i = inportb(allapot_reg_olvasas);
      cnt = (i >> 2) & 1;
    } while (!kbhit() && !cnt);
    if (!cnt || kbhit())
      return;
    printf("%5x", inportb(szamlalo_olvasas));
    delay(50);
  };
};

void main (void)
{
  int c;

  do {
    clrscr();
    printf("M‚r‚s 1: Programozott adat tvitel\n\n");
    printf("1: kapcsol¢sor -> hexa kijelz“ (felt‚tel n‚lkli)\n");
    printf("2: sz ml l¢    -> k‚perny“     (felt‚tel n‚lkli)\n");
    printf("3: kapcsol¢sor -> hexa kijelz“ (felt‚teles)\n");
    printf("4: sz ml l¢    -> k‚perny“     (felt‚teles)\n");
    printf("5: v‚ge\n");
    printf("V lassz : ");
    while (((c=getch()) > '5') || (c < '1'))
      ;
    clrscr();
    switch (c) {
      case '1': fnpa1(); break;
      case '2': fnpa2(); break;
      case '3': fpa1(); break;
      case '4': fpa2(); break;
    };
  } while (c != '5');
};
