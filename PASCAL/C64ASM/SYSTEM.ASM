; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; SYSTEM.ASM - example assembly source file
;   System declarations (no code in this file)
; ===================================================================
; Use it with .INCLUDE SYSTEM.ASM in other source files

; Special memory sections

BASICSTART= $0801
SCREENRAM = $0400
BASICROM  = $A000
SPECRAM   = $C000
VIC       = $D000
SID       = $D400
COLORRAM  = $D800
CIA1      = $DC00
CIA2      = $DD00
KERNALROM = $E000

; KERNAL routines

ACPTR   = $FFA5
CHKIN   = $FFC6
CHKOUT  = $FFC9
CHRIN   = $FFCF
CHROUT  = $FFD2
CIOUT   = $FFA8
CINT    = $FF81
CLALL   = $FFE7
CLOSE   = $FFC3
CLRCHN  = $FFCC
GETIN   = $FFE4
IOBASE  = $FFF3
IOINIT  = $FF84
LISTEN  = $FFB1
LOAD    = $FFD5
MEMBOT  = $FF9C
MEMTOP  = $FF99
OPEN    = $FFC0
PLOT    = $FFF0
RAMTAS  = $FF87
RDTIM   = $FFDE
READST  = $FFB7
RESTOR  = $FF8A
SAVE    = $FFD8
SCNKEY  = $FF9F
SCREEN  = $FFED
SECOND  = $FF93
SETLFS  = $FFBA
SETMSG  = $FF90
SETNAM  = $FFBD
SETTIM  = $FFDB
SETTMO  = $FFA2
STOP    = $FFE1
TALK    = $FFB4
TKSA    = $FF96
UDTIM   = $FFEA
UNLSN   = $FFAE
UNTLK   = $FFAB
VECTOR  = $FF8D
