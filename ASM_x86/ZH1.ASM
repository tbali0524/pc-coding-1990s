;/*========================================================================
;3. Irjon i80286 g‚pi k¢d£ programot, amely echo-za a klaviat£ra billenty–ket
;‚s ezalatt az EGA k‚perny“ bal sark ban minden 10. ¢ra IT -ben (8. vektor)
;tov bb forgat egy vonalat, azaz ciklikusan a \ | / - karaktereket jeleniti meg.
;Az EGA k‚perny“ bal fels“ sark nak cime: b800:0000, egy helyet k‚t byte ir le;az alacsonyabb helyi‚rt‚k– a karakter k¢dot, a magasabb helyi‚rt‚k– az
;attrib£tumot tartalmazza.
;15 PONT =================================================================*/

; NEM MUKODIK!

.286

TIME_IT EQU 08h

SET_IT MACRO    IT_NUM, FUNCTION
    push    ax          ; regiszter ment
    push    bx
    push    es
    mov     ax, 0       ; IT t bla megfelel“ bejegyz‚s‚nek cime es:bx
    mov     es, ax
    mov     bx, 4 * (IT_NUM)
    cli                 ; IT tilt
    mov     ax, OFFSET FUNCTION ;t bla kit”lt‚s
    mov     WORD PTR es:[bx], ax
    mov     ax, SEG FUNCTION
    mov     WORD PTR es:[bx+2], ax
    sti                 ; IT enged‚lyez‚s
    pop     es          ; regiszter vissza
    pop     bx
    pop     ax
ENDM

SAVE_IT MACRO    IT_NUM, SAVE_AREA
    push    ax          ; regiszter ment
    push    bx
    push    es
    mov     ax, 0       ; IT t bla megfelel“ bejegyz‚s‚nek cime es:bx
    mov     es, ax
    mov     bx, 4 * (IT_NUM)
    mov     ax, WORD PTR es:[bx]
    mov     WORD PTR cs:SAVE_AREA, ax
    mov     ax, WORD PTR es:[bx+2]
    mov     WORD PTR cs:SAVE_AREA[2], ax
    pop     es          ; regiszter vissza
    pop     bx
    pop     ax
ENDM

RESTORE_IT MACRO    IT_NUM, SAVE_AREA
    push    ax          ; regiszter ment
    push    bx
    push    es
    mov     ax, 0       ; IT t bla megfelel“ bejegyz‚s‚nek cime es:bx
    mov     es, ax
    mov     bx, 4 * (IT_NUM)
    cli                 ; IT tilt
    mov     ax, WORD PTR cs:SAVE_AREA
    mov     WORD PTR es:[bx], ax
    mov     ax, WORD PTR cs:SAVE_AREA[2]
    mov     WORD PTR es:[bx+2], ax
    sti                 ; IT enged‚lyez‚s
    pop     es          ; regiszter vissza
    pop     bx
    pop     ax
ENDM

stack SEGMENT WORD STACK 'STACK'
ASSUME SS: stack
DW 2048 DUP(?)
stack ENDS

data SEGMENT WORD STACK 'DATA'
ASSUME DS: data
ITCount DB 10
Phase DB 1
PrintChars DB '|\-/'
data ENDS

code SEGMENT PUBLIC 'CODE'
ASSUME CS: code

itsave DD ?	; it vector save area

newit PROC NEAR
	push ax
	push ds
	mov ax,data
	mov ds,ax
	mov ah,0
	mov al,BYTE PTR ITCount
	dec ax
	mov BYTE PTR ITCount,al
	cmp ax,0
	jne Exit
	mov al,10
	mov BYTE PTR ITCount,al
	push bx
	push es
	mov bh,0
	mov bl,BYTE PTR Phase
	mov ax,0b800h
        mov es,ax
	mov al, BYTE PTR [PrintChars+bx]
	mov ah,1
	mov [es:0000h],ax
	mov ah,0
	mov al,BYTE PTR Phase
	cmp ax,0
	jne @5
	mov al,4
@5:	dec al
	mov BYTE PTR Phase,al
	pop es
	pop bx
Exit:	pop ds
	pop ax
	jmp DWORD PTR itsave
newit ENDP

start:
	mov ax,data
	mov ds,ax
	SAVE_IT TIME_IT,itsave
	SET_IT TIME_IT,newit
getch:	mov ax,0
	int 16h
	cmp al,0
	jne @1
	mov ax,0
	int 16h
	jmp SHORT getch
@1:     cmp al,27
	je @2
	mov ah,0eh
	mov bl,1
	mov bh,3
	int 10h
	jmp SHORT getch
@2:
RESTORE_IT TIME_IT,itsave
	mov al,0
	mov ah,4ch
	int 21h
code ENDS

END start
