/* BME Info 3.evf.1.felev */
/* Meres 3: dma kezeles */

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

const status  = 0x08;
const mask    = 0x0a;
const mode    = 0x0b;
const clearFF = 0x0c;
const address = 0x02;
const lenght  = 0x03;
const page    = 0x83;

#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif

unsigned long addr;
unsigned int seg, offset;

void dma1 (void)
{
  unsigned long addr;
  unsigned int seg, offset;
  unsigned char tomb[16];
  int i, j;

  for (i = 0; i <= 16; i++)
    tomb[i] = 0x80 + i;
  outportb(mask, 5);		// channel 1 maszkolasa
  outportb(mode, 0x49);		// channel 1: single mode, read
  addr = (unsigned long)tomb;
  offset = (unsigned int)(addr & 0xFFFF);
  seg = (unsigned int)(addr >> 16);
  addr = (((unsigned long)seg) << 4) + offset;
  outportb(page,(char)(addr >> 16));
  outportb(clearFF, 0);		// Byte Pointer Flip-Flop torlese
  outportb(address,(char)(addr & 0xFF));
  outportb(address,(char)((addr & 0xFFFF) >> 8));
  outportb(lenght, 15);		// hossz: 16 byte
  outportb(lenght, 0);
  outportb(mask, 1);		// channel 1 maszk torlese
  outportb(masodreg_iras, 16);	// HXDRQE: kijelzo dma engedelyezve

  i = 0;
  while (!kbhit() && ((j = (inportb(status) & 2)) == 0)) {
    i = (++i) % 1000;
    printf("%-5d\r", i);
    delay(50);
  };
  if (j != 0)
    printf("\n\nAdatatvitel vege.\n");

  outportb(masodreg_iras, 0);
  outportb(mask, 5);		// channel 1 maszkolasa
  getch();
};

//===============================================================

void dma2 (void)
{
  unsigned long addr;
  unsigned int seg, offset;
  unsigned char tomb[300];
  int i, j;

  outportb(mask, 5);		// channel 1 maszkolasa
  outportb(mode, 0x45);		// channel 1: single mode, write
  addr = (unsigned long)tomb;
  offset = (unsigned int)(addr & 0xFFFF);
  seg = (unsigned int)(addr >> 16);
  addr = (((unsigned long)seg) << 4) + offset;
  outportb(page,(char)(addr >> 16));
  outportb(clearFF, 0);		// Byte Pointer Flip-Flop torlese
  outportb(address,(char)(addr & 0xFF));
  outportb(address,(char)((addr & 0xFFFF) >> 8));
  outportb(lenght, 287 & 0xFF);	// hossz: 288 byte
  outportb(lenght, 287 >> 8);
  outportb(masodreg_iras, 32);	// CNTRQE: szamlalo dma engedelyezve
  inportb(szamlalo_torles);
  inportb(tc_tarolo_torles);
  inportb(szamlalo_olvasas);
  outportb(mask, 1);		// channel 1 maszk torlese

  i = 0;
  while (!kbhit() && ((j = (inportb(status) & 2)) == 0)) {
    i = (++i) % 1000;
    printf("%-5d\r", i);
  };

  outportb(masodreg_iras, 0);
  outportb(mask, 5);		// channel 1 maszkolasa
  if (j == 0)
    return;
  printf("\n\nAdatatvitel vege.\n");
  getch();
  for (i = 0; i < 288; i++)
    printf("%-5x", tomb[i]);
  getch();
};

//===============================================================

void interrupt (*old_tc_handler)(__CPPARGS);

int done;

void interrupt tc_handler(__CPPARGS)
{
  disable();
  inportb(tc_tarolo_torles);
  done = 1;
  outportb(0x20, 0x20);	 		// nem-specif. eoi
  enable();
};

void dma3 (void)
{
  unsigned long addr;
  unsigned int seg, offset;
  unsigned char tomb[300];
  int i, s;

  done = 0;
  outportb(mask, 5);		// channel 1 maszkolasa
  outportb(mode, 0x45);		// channel 1: single mode, write
  addr = (unsigned long)tomb;
  offset = (unsigned int)(addr & 0xFFFF);
  seg = (unsigned int)(addr >> 16);
  addr = (((unsigned long)seg) << 4) + offset;
  outportb(page,(char)(addr >> 16));
  outportb(clearFF, 0);		// Byte Pointer Flip-Flop torlese
  outportb(address,(char)(addr & 0xFF));
  outportb(address,(char)((addr & 0xFFFF) >> 8));
  outportb(lenght, 287 & 0xFF);	// hossz: 288 byte
  outportb(lenght, 287 >> 8);
  disable();
  old_tc_handler = _dos_getvect(13);
  _dos_setvect(13, tc_handler);
  s = inportb(0x21);
  outportb(0x21, s & 0xdf);	// ocw1: IRQ5 maszk torlese
  outportb(masodreg_iras, 32 + 2); // CNTRQE + TCIRQE
  inportb(szamlalo_torles);
  inportb(tc_tarolo_torles);
  inportb(szamlalo_olvasas);
  outportb(mask, 1);		// channel 1 maszk torlese
  enable();

  i = 0;
  while (!kbhit() && !done) {
    i = (++i) % 1000;
    printf("%-5d\r", i);
  };

  disable();
  outportb(mask, 5);		// channel 1 maszkolasa
  outportb(masodreg_iras, 0);
  outportb(0x21, s);
  _dos_setvect(13, old_tc_handler);
  enable();
  if (!done)
    return;
  printf("\n\nAdatatvitel vege.\n");
  getch();
  for (i = 0; i < 288; i++)
    printf("%-5x", tomb[i]);
  getch();
};

//===============================================================

void main (void)
{
  int c;

  do {
    clrscr();
    printf("M‚r‚s 3: DMA kezel‚s\n\n");
    printf("1: mem¢ria     -> hexa kijelz“ (dma)\n");
    printf("2: sz ml l¢    -> k‚perny“     (dma)\n");
    printf("3: sz ml l¢    -> k‚perny“     (dma + v‚gjelz‚s: megszak¡t s)\n");
    printf("4: v‚ge\n");
    printf("V lassz : ");
    while (((c=getch()) > '4') || (c < '1'))
      ;
    clrscr();
    switch (c) {
      case '1': dma1(); break;
      case '2': dma2(); break;
      case '3': dma3(); break;
    };
  } while (c != '4');
};
