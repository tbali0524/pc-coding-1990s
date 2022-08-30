; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; MIRROR.ASM - example assembly source file
;   Mirrors 8 bytes in their places (MSB <--> LSB)
; ===================================================================

mirror lda #<_work
       ldy #>_work
       sta _zp
       sty _zp + 1
       ldy #_len
_loop  lda #7            ; number of bits - 1
       sta _tmp
       lda (_zp),y
_newbit asl a
       pha
       txa
       ror a
       tax
       pla
       dec _tmp
       bpl _newbit
       txa
       sta (_zp),y
       dey
       bpl _loop
       rts

_zp = $FD               ; zero page address for indirect indexed addressing
_tmp   * = * + 1        ; temporary storage

; the 8 bytes to mirror:
_work  .byte $F0, $80, $55, $69, $60, 0, $12, $2F
_workend                ; it'll contain the address of the last byte ($2F) + 1
_len = _workend - _work ; the number of bytes
