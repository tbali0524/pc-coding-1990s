; C64ASM  - Commodore 64 (6510) Assembler Package for PC
; Copyright (c) 1997 by B lint T¢th
;
; IFGOTO.ASM - example assembly source file
;   Demonstrates the use of .LABEL, .IF, .GOTO and .END directives
; ===================================================================

.GOTO CountDown
.LABEL A1
.GOTO Dummy
.LABEL A2
.END                    ; end of compile
.ASC "This line will never be compiled!"

; ==============================
.LABEL CountDown
; puts the $0A, $09, ... $00 sequence in the target

count := $0B            ; start value of variable
                        ; loop will work like "FOR COUNT := $0A DOWNTO 0 DO"

.LABEL loop1
count := count - 1      ; decrement variable
.BYTE count             ; put value of count in target file
.IF count .GOTO loop1   ; jump back if count > 0
.GOTO A1

; ==============================
.LABEL Dummy
; puts a dummy sequence in the target

count := $10            ; start value of variable
_max = $15              ; maximum value (a local constant)
                        ; loop will work like "FOR COUNT := 10 TO 15 DO"
temp := $D345           ; this value will be scrambled repeatedly in the loop

.LABEL loop2
temp := (temp + 23) >> 1
.WORD temp - count      ; put a value in target file
count := count + 1      ; increment variable
.IF count <= _max .GOTO loop2  ; jump back if count <= max
.GOTO A2
