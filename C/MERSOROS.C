/* BME Info 3.evf.1.felev */
/* Meres 4: soros kommunikacio */

#include <stdio.h>
#include <conio.h>
#include <dos.h>

const ASN_BAS = 0x03F8; // bazis
const ASN_THR = 0x3F8; // kuldo adatreg.
const ASN_RBR = 0x3F8; // fogado adatreg.
const ASN_DLL = 0x3F8; // baud-rate oszto LSB
const ASN_DLM = 0x3F8 + 1; // baud-rate oszto MSB
const ASN_IER = 0x3F8 + 1; // interrupt reg.
const ASN_IIT = 0x3F8 + 2; // IT azonosito reg.
const ASN_LCR = 0x3F8 + 3; // vonalvezerlo reg.
const ASN_MCR = 0x3F8 + 4; // modemvezerlo reg.
const ASN_LSR = 0x3F8 + 5; // vonalstatusz reg.
const ASN_MSR = 0x3F8 + 6; // modemstatusz reg.

const BAUDRATE = 48;         // baud rate oszto erteke (2400 bps)
const itnum = 12;            // it szama
const kbESC = 27;

#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif

int rcvpos, rcv;

void interrupt (*old_rcv_handler)(__CPPARGS);

void interrupt rcv_handler(__CPPARGS)
{
  int i;

  enable();
  if (inportb(ASN_LSR) & 1) {
    rcv = inportb(ASN_RBR);
      switch (rcv) {
        case 13 : rcvpos = ((rcvpos / 160 + 1) * 160) % (8 * 160);
		  for (i = 0; i < 80; i++)
		    poke(0xB864, rcvpos + (i << 1), 0x0720);
		  break;
	case 8: if ((rcvpos % 160) > 1) 
                     rcvpos -= 2;
		   poke(0xB864, rcvpos, 0x0720);
                   break;
	case 9: rcvpos = 0;
		    for (i = 0; i < 8 * 80; i++)
		      poke(0xB864, rcvpos + i << 1, 0x0720);
		    break;
	default:  poke(0xB864, rcvpos, rcv + 0x0700);
		  rcvpos = (rcvpos + 2) % (8 * 160);
      };
  };
  outportb(0x20, 0x20);	 		// nem-specif. eoi
};

void soros (int loopon)
{
  int s, snd, sndpos, i;

  outportb(ASN_LCR, 0x80);              // sebesseg beallitas
  outportb(ASN_DLL, BAUDRATE && 0xFF);
  outportb(ASN_DLM, BAUDRATE >> 8);
  outportb(ASN_LCR, 3);                 // 8 bit, 1 stop bit, 0 paritas
  rcvpos = 0;
  sndpos = 0;
  disable();
  old_rcv_handler = _dos_getvect(itnum);
  _dos_setvect(itnum, rcv_handler);
  s = inportb(0x21);
  outportb(0x21, s & 0xEF);		// ocw1
  outportb(ASN_IER, 1);
  outportb(ASN_MCR, (0x10 * loopon) + 8);
  enable();

  do {
    while (!kbhit())
      ;
    snd = getch();

    if (snd == 0)
      getch();
    if (((snd >= 32) && (snd < 128)) || (snd == 13) || (snd == 8)
        || (snd == 9)) {
      while ((inportb(ASN_LSR) & 0x20) == 0)
	;
      outportb(ASN_THR, snd);
      switch (snd) {
        case 13 : sndpos = ((sndpos / 160 + 1) * 160) % (8 * 160);
		  for (i = 0; i < 80; i++)
		    poke(0xB800, sndpos + (i << 1), 0x0720);
		  break;
	case 8: if ((sndpos % 160) > 1) 
                     sndpos -= 2;
		   poke(0xB800, sndpos, 0x0720);
                   break;
	case 9: sndpos = 0;
		    for (i = 0; i < 8 * 80; i++)
		      poke(0xB800, sndpos + i << 1, 0x0720);
		    break;
	default:  poke(0xB800, sndpos, snd + 0x0700);
		  sndpos = (sndpos + 2) % (8 * 160);
      };
    };
  } while (snd != kbESC);			// ESC-re kilep

  disable();
  outportb(ASN_IER, 0);
  outportb(ASN_MCR, 0);
  _dos_setvect(itnum, old_rcv_handler);
  outportb(0x21, s);
  enable();
};

//===============================================================

void main (void)
{
  int c;

  do {
    clrscr();
    printf("Meres 4: Soros kommunikacio\n\n");
    printf("1: teljes duplex soros kommunikacio 2 PC kozott\n");
    printf("2: visszakotott uzemmod\n");
    printf("3: vege\n");
    printf("V lassz : ");
    while (((c = getch()) > '3') || (c < '1'))
      ;
    clrscr();
    switch (c) {
      case '1': soros(0); break;
      case '2': soros(1); break;
    };
  } while (c != '3');
};
