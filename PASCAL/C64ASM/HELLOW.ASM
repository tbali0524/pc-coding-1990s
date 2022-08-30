; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; HELLOW.ASM - example assembly source file
;   Prints "Hello World!" message using KERNAL routine
; ===================================================================

* = 16500               ; start address (use SYS16500 to start)

; main program: simply calls "print"

hellow	lda #<_text
	ldy #>_text
	jsr print       ; the print routine itself is in an include file
	rts

; the text to be printed:
_text   .TEXT "Hello World!" ; This will be all upcase in PET-ASCII!
        .BYTE 0

.INCLUDE PRINT.ASM      ; include the print routine
