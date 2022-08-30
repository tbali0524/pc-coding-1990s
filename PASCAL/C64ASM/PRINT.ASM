; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; PRINT.ASM - example assembly source file
;   Prints a null terminated string to screen whose address is in A/Y
; ===================================================================

.INCLUDE SYSTEM.ASM     ; include system declarations
                        ; (only the CHROUT routine is really used)

; print subroutine prints a 0 ended string whose address comes from A/Y regs

print   sta _zp
	sty _zp + 1
	ldy #0
	sty _tmp
_loop	lda (_zp),y
	beq _quit
	jsr chrout
	inc _tmp
	ldy _tmp
	bne _loop
	inc _zp + 1
	bne _loop
_quit   rts

_zp = $FD                ; zero page address for indirect indexed addressing
_tmp    * = * + 1        ; temporary storage
