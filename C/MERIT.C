/* BME Info 3.evf.1.felev */
/* Meres 2: megszakitas kezeles */

#include <stdio.h>
#include <conio.h>
#include <dos.h>

const masodreg_iras 	  = 0x300;
const kapcsolo_olvasas    = 0x300;
const kijelzo_iras 	  = 0x301;
const szamlalo_olvasas    = 0x301;
const tc_tarolo_torles 	  = 0x302;
const szamlalo_torles 	  = 0x303;
const allapot_reg_olvasas = 0x304;

#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif

void interrupt (*old_kapcsolo_handler)(__CPPARGS);

void interrupt kapcsolo_handler(__CPPARGS)
{
  disable();
  outportb(kijelzo_iras, inportb(kapcsolo_olvasas));
  outportb(0x20, 0x20);		// nem-specif. eoi
  enable();
};

void it1 (void)
{
  int i, s;

  disable();
  old_kapcsolo_handler = _dos_getvect(11);
  _dos_setvect(11, kapcsolo_handler);
  outportb(masodreg_iras, 8);		// kapcsolo es it engedelyezes
  s = inportb(0x21);
  outportb(0x21, s & 0xf7);		// ocw1
  inportb(kapcsolo_olvasas);
  enable();

  i = 0;
  while (!kbhit()) {
    i = (++i) % 1000;
    printf("%-5d\r", i);
    delay(50);
  };

  disable();
//  outportb(masodreg_iras, 0);
  outportb(0x21, s);			// ocw1
  _dos_setvect(11, old_kapcsolo_handler);
  enable();
};

//===============================================================

void interrupt (*old_szamlalo_handler)(__CPPARGS);

int tomb[300];
int count;

void interrupt szamlalo_handler(__CPPARGS)
{
  disable();
  inportb(tc_tarolo_torles);
  if (count < 288)
    tomb[count++] = inportb(szamlalo_olvasas);
  outportb(0x20, 0x20);	 	      // nem-specif. eoi
  enable();
};

void it2 (void)
{
  int i, s;

  count = 0;

  disable();
  old_szamlalo_handler = _dos_getvect(11);
  _dos_setvect(11, szamlalo_handler);
  s = inportb(0x21);
  outportb(0x21,s & 0xf7);	// ocw1
  outportb(masodreg_iras, 32);		// szamlalo it engedelyezes
  inportb(szamlalo_torles);
  inportb(tc_tarolo_torles);
  inportb(szamlalo_olvasas);
  enable();

  while ((!kbhit()) && (count < 288))
    printf("%-5d\r  ", count);

  disable();
  outportb(0x21, s );		// ocw1
//  outportb(masodreg_iras, 0);
  _dos_setvect(11, old_szamlalo_handler);
  enable();
  if (count < 288)
    return;
  printf("\n\nAdatatvitel vege.\n");
  getch();
  for (i = 0; i < 288; i++)
    printf("%-5x", tomb[i]);
  getch();
};

//===============================================================

void interrupt kapcsolo_handler3(__CPPARGS)
{
  enable();
  outportb(kijelzo_iras, inportb(kapcsolo_olvasas));
  outportb(0x20, 0x20);		// nem-specif. eoi
};

void interrupt tc_handler3(__CPPARGS)
{
  disable();
  outportb(masodreg_iras, 8);		// tc it tiltas
  inportb(tc_tarolo_torles);
  outportb(kijelzo_iras, 0xCC);
  outportb(masodreg_iras, 8 + 2);	// tc it engedelyezes
  outportb(0x20, 0x20);	 		// nem-specif. eoi
  enable();
};

void it3 (void)
{
  int i, s;

  const kapcsit = 11;		// kapcsolo: IRQ3-nal 11, IRQ7-nel 15
  const ocwmaszk = 0xd7;	// IRQ3-nal 0xd7, IRQ7-nel 0x5f

  disable();
  old_kapcsolo_handler = _dos_getvect(kapcsit);
  old_szamlalo_handler = _dos_getvect(13);
  _dos_setvect(kapcsit, kapcsolo_handler3);
  _dos_setvect(13, tc_handler3);
  s = inportb(0x21);
  outportb(0x21,s & ocwmaszk);		// ocw1
  outportb(masodreg_iras, 8 + 2);	// kapcsolo es tc it engedelyezes
  inportb(szamlalo_torles);
  inportb(tc_tarolo_torles);
  inportb(szamlalo_olvasas);
  enable();

  i = 0;
  while (!kbhit()) {
    i = (++i) % 1000;
    printf("%-5d\r", i);
    delay(50);
  };

  disable();
  outportb(0x21, s);
  _dos_setvect(kapcsit, old_kapcsolo_handler);
  _dos_setvect(13, old_szamlalo_handler);
  enable();
};

void main (void)
{
  int c;

  do {
    clrscr();
    printf("M‚r‚s 2: interrupt kezel‚s\n\n");
    printf("1: kapcsol¢sor -> hexa kijelz“ (megszak¡t s)\n");
    printf("2: sz ml l¢    -> k‚perny“     (megszak¡t s)\n");
    printf("3: egym sba  gyazott megszak¡t sok\n");
    printf("4: v‚ge\n");
    printf("V lassz : ");
    while (((c=getch()) > '4') || (c < '1'))
      ;
    clrscr();
    switch (c) {
      case '1': it1(); break;
      case '2': it2(); break;
      case '3': it3(); break;
    };
  } while (c != '4');
};
