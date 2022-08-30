; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; MAIN.ASM - example assembly source file
;   Includes all other example source files
; ===================================================================

* = $4000               ; start address (use SYS16384 to start)
                        ; (use LOAD"",1,1 to load the compiled program)

.INCLUDE SYSTEM.ASM

start			; an alternative label for "main"
main    jsr hellow      ; prints Hello World!
        jsr mirror      ; no visible result, just changing some bytes in memory
        jsr rotatel     ;   -- " --
        rts

; now include all the invoked routines:

.INCLUDE MIRROR.ASM
.INCLUDE ROTATEL.ASM
.INCLUDE HELLOW.ASM    ; this also includes SYSTEM.ASM, but no problem
                       ; it compiles from *=16500 so it will leave some gap
                       ;  after ROTATEL.ASM
.INCLUDE IFGOTO.ASM    ; no code just some dummy data not used anywhere
