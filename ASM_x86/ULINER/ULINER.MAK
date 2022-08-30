#
# T¢th B lint
# BME, Vill. ‚s Inf. kar, M. Informatika szak, II. ‚vf. 1. f‚l‚v, 3. tank”r
# 1993. november
#
# Assembly hazi feladat (30.)
# ULINER Szoveg-alahuzo program
#
# ULINER.MAK - makefile (Borland MAKE.EXE 3.6)
#
# Hasznalat: MAKE -fULINER
#  Debug info-hoz:  -DDEBUG
#  Egyeb parameterek TASM-nak:  -DASMOPT=paramlist
#  Egyeb parameterek TLINK-nek: -DLINKOPT=paramlist
#  Fajlok torlese (forras kivetelevel): clean
#

!if $d(DEBUG)
F1=/c /la /x /z /zi
F2=/m /l /s /v
!endif

# compiler macros
TASM=tasm.exe
TLINK=tlink.exe

# implicit rules
.asm.obj:
  $(TASM) $(F1) $(ASMOPT) $<

.obj.exe:
  $(TLINK) $(F2) $(LINKOPT) $<

# explicit rules
all: uliner.exe

uliner.exe: uliner.obj

uliner.obj: uliner.asm

clean:
  del uliner.map
  del uliner.lst
  del uliner.obj
  del uliner.exe
