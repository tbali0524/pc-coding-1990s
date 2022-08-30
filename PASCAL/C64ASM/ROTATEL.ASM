; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; ROTATEL.ASM - example assembly source file
;   Cyclically rotates 8 bytes left in by one bit their places
; ===================================================================

rotatel lda #<_work
       ldy #>_work
       sta _zp
       sty _zp + 1
       ldy #_len
_loop  lda (_zp),y
       rol a
       lda (_zp),y
       rol a
       sta (_zp),y
       dey
       bpl _loop
       rts

_zp = $FD               ; zero page address for indirect indexed addressing

; the 8 bytes to rotate:
_work   .byte $F0, $80, $55, $69, $60, 0, $12, $2F
_workend                ; it'll contain the address of the last byte ($2F) + 1
_len = _workend - _work ; number of bytes
