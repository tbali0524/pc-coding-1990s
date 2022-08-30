;
; T¢th B lint
; BME, Vill. ‚s Inf. kar, M. Informatika szak, II. ‚vf. 1. f‚l‚v, 3. tank”r
; 1993. november
;
; Assembly h zi feladat (30.)
; ULINER Sz”veg-al h£z¢ program
; A parancssor param‚terk‚nt megadott bemen“ sz”vegf jlban l‚v“ mag nyos
; ".ul" sor ut ni sorokat al h£zza "-" karakterekkel, az eredm‚nyt a
; NEV.TXT f jlba teszi.
;
; ULINER.ASM - assembly forr sf jl (Turbo Assembler 3.2)
;

P8086		; proc. valasztas
DOSSEG		; DOS szegmensek
MODEL SMALL	; memoria modell

STACK 100h	; verem

; -------------------------- Adatszegmens -----------------------------------
DATASEG

 ; spec. ascii kodok
 	LF	EQU 10	; soremeles (sorveg-jel)
	CR	EQU 13
	ULChar	EQU '-'	; alahuzas
	SPACE	EQU ' ' ; szokoz

 ; sztringek
	CopyRightText DB 13,10,'ULINER - text underliner utility ' ; Prog info
		DB '(c) T¢th B lint, 1993',CR,LF,'$'
	OutFName DB 'NEV.TXT',0		; outputfile neve
	ULString DB '.ul',CR,LF		; .ul direktiva

 ; hibauzenetek:
	erNoParam  DB CR,LF,'Missing parameter (inputfilename)',CR,LF,'$'
	erOpenIn   DB CR,LF,'Cannot open inputfile',CR,LF,'$'
	erOpenOut  DB CR,LF,'Cannot open outputfile (NEV.TXT)',CR,LF,'$'
	erReadIn   DB CR,LF,'Error while reading inputfile',CR,LF,'$'
	erWriteOut DB CR,LF,'Error while writing outputfile',CR,LF,'$'
	erLongLine DB CR,LF,'Line too long in inputfile',CR,LF,'$'

 ; visszateresi kodok
	ecOk		EQU 0
	ecNoParam	EQU 1
	ecOpenIn	EQU 2
	ecOpenOut	EQU 3
	ecReadIn	EQU 4
	ecWriteOut	EQU 5
	ecLongLine	EQU 6

 ; egyeb valtozok
	EOFReached DB 0	; elertuk-e az inputfile veget
	ExCode DB ecOk	; exit code

UDATASEG	; inicializalatlan adatok
	Tmp       DW ?		; ideiglenes tarolo
	InHandle  DW ?		; inputfile handle
	OutHandle DW ?		; outputfile handle
	InFName   DB 128 DUP(?)	; inputfile neve
	MaxBufLen EQU 128	; buffer max. merete (max. sorhossz)
	BufLen    DB ?		; karakterek szama a sorbufferben
	Buffer    DB MaxBufLen + 3 DUP(?)	; sorbuffer

CODESEG		; kodszegmens
; -------------------------- Foprogram --------------------------------------
LStart:
	mov ax,@data    ; adatszegmens beallitas
	mov ds,ax
	mov dx, OFFSET CopyRightText
	mov ah,09h	; programnev kiiras
	int 21h

 ; parancssor parameter feldolgozasa
	mov ah,62h	; PSP lekerese
	int 21h
	mov es,bx	; es a PSP-re mutat
	mov al,es:0080h	; parancssor parameter hossza
	cmp al,0
	jnz LGetPar	; ha van parameter
LNoPar:	
	mov dx, OFFSET erNoParam
	mov ah,09h	; nincs parameter -> hibauzenet kiirasa
	int 21h
	mov ExCode,ecNoParam ; exit code
	jmp LExit	; kilepes
LGetPar:
	cbw		; ah <- 0
	mov cx,ax	; hany karakter
	mov si,80h	; parancsor parameterek kezdete a PSP-ben - 1
LIgnoreSPC:
	inc si		; kovetkezo karakter
	cmp BYTE PTR es:[si],SPACE	; ha szokoz, atugorjuk
	loope LIgnoreSPC
	je LNoPar	; ha nincs tobb karakter
	inc cx
	mov di, OFFSET InFName	; ide masolunk
LCopyPar:
	mov al, BYTE PTR es:[si]
	mov BYTE PTR [di],al	; parancssor parameter masolasa belso bufferbe
	inc si
	inc di
	cmp al,SPACE	; ha szokoz, kilepunk
	loopne LCopyPar
	jne @1		; ha nem szokoz volt az utolso, nem kell torolni
	dec di		; utolso karakter torlese, ha szokoz volt
@1:	mov BYTE PTR [di],0	; sztringzaro 0

 ; input megnyitasa
	mov dx, OFFSET InFName	; input filename
	mov al,0	; olvasasra
	mov ah,3dh	; input megnyitasa (Open)
	int 21h
	jnc @2		; ha nincs hiba
	mov dx, OFFSET erOpenIn
	mov ah,09h	; hibauzenet kiirasa
	int 21h
	mov ExCode,ecOpenIn	; exit code
	jmp LExit	; kilepes
@2:	mov InHandle,ax	; inputfile handle tarolasa

 ; output megnyitasa
	mov dx, OFFSET OutFName	; output filename
	mov cx,0	; normal attributum
	mov ah,3ch	; output megnyitasa (Create)
	int 21h
	jnc @3		; ha nincs hiba
	mov dx, OFFSET erOpenOut
	mov ah,09h	; hibauzenet kiirasa
	int 21h
	mov ExCode,ecOpenOut ; exit code
	jmp LCloseIn	; inputfile lezaras es kilepes
@3:	mov OutHandle,ax ; outputfile handle tarolasa

 ; fo programciklus
LUjSor:
	call ReadLine	; kovetkezo sor beolvasasa
	jnc @11
	jmp LCloseOut	; ha hiba volt a ReadLine-ban -> kilepes
@11:	cmp BYTE PTR BufLen,5
	jne LNotUL	; ha nem 5 hosszu sor -> nem lehet .ul direktiva
	mov ax,ds
	mov es,ax
	mov si, OFFSET Buffer	; mit hasonlitunk ossze
	mov di, OFFSET ULString	; mivel hasonlitjuk ossze
	cld		; irany: elore
	mov cx,5	; 5 karaktert hasonlitunk ossze
LScanUL:
	cmpsb		; sztring osszehasonlitas (Buffer==.ul ?)
	loope LScanUL
	jne LNotUL	; ha nem .ul direktiva
	cmp BYTE PTR EOFReached,0
	jne LCloseOut	; ha utolso sor volt a .ul -> kilepes
	call ReadLine	; kovetkezo sor beolvasasa (amit ala kell huzni)
	jc LCloseOut	; ha hiba volt a ReadLine-ban -> kilepes
	call WriteLine	; a sor kiirasa
	jc LCloseOut	; ha hiba volt a WriteLine-ban -> kilepes
	mov ch,0
	cmp BYTE PTR EOFReached,0
	je @12		; ha nem volt EOF
	mov BYTE PTR [Buffer],CR	; EOF volt -> soremeles is kell
	mov BYTE PTR [Buffer+1],LF	;  az alahuzas elott
	mov di, (OFFSET Buffer) + 2	; CR/LF moge masolunk
	mov cl,BufLen	; ennyi alahuzas karakter kell
	mov BYTE PTR Tmp,4	; majd BufLen + 4 db. karaktert kell kiirni
	jmp SHORT LFillUL
@12:	mov di, OFFSET Buffer	; ide masolunk
	mov cl,BufLen
	dec cl		; nem volt EOF -> volt CR/LF -> ezeket nem kell
	dec cl		;  alahuzni
	mov BYTE PTR Tmp,0	; majd BufLen + 0 db. karaktert kell kiirni
LFillUL:
	mov ax,ds
	mov es,ax
	cld		; irany: elore
	mov al,ULChar	; evvel toltjuk fel
rep	stosb		; feltoltes alahuzas karakterrel
	mov BYTE PTR [di],CR	; CR/LF az alahuzas utan
	inc di
	mov BYTE PTR [di],LF
	mov al, BYTE PTR Tmp
	add BYTE PTR BufLen,al	; BufLen beallitasa 
LNotUL:
	call WriteLine	; buffer kiirasa az outputfile-ba
	jc LCloseOut	; ha hiba volt a WriteLine-ban -> kilepes
	cmp BYTE PTR EOFReached,0
	jne LCloseOut	; ha EOF volt -> kilepes
	jmp LUjSor	; nem volt EOF -> uj sor olvasasa

 ; programlezaras
LCloseOut:
	mov bx,OutHandle
	mov ah,3eh	; outputfile lezaras (Close)
	int 21h
	cmp ExCode,0
	jz LCloseIn	; ha nem volt hiba
	mov dx, OFFSET OutFName
	mov ah,41h	; outputfile torlese
	int 21h
LCloseIn:
	mov bx,InHandle
	mov ah,3eh	; inputfile lezaras (Close)
	int 21h
LExit:
	mov al,ExCode	; exit code
	mov ah,4ch
	int 21h		; vissza dos-ba
	ret

; --------------------------- ReadLine eljaras ------------------------------
; kovetkezo sor beolvasasa a bufferbe (EOF-ig vagy CR/LF-ig) - ha hiba: Carry=1
ReadLine PROC
	mov BufLen,0	; buffer torlese
LReadChar:		; kovetkezo karakter olvasasa
	mov ax, OFFSET Buffer
	mov bl,BufLen
	mov bh,0
	add ax,bx
	mov Tmp,ax	; elmentjuk a cimet
	mov dx,ax	; buffer megfelelo helyere olvasunk
	mov bx,InHandle	; inputfilebol olvasunk
	mov cx,1	; egy karaktert olvasunk
	mov ah,3fh	; inputfile olvasasa (Read)
	int 21h	
	jnc LCmpEof	; ha nincs hiba
	mov dx, OFFSET erReadIn
	mov ah,09h	; hibauzenet kiirasa
	int 21h
	mov ExCode,ecReadIn ; exit code
	stc		; hiba volt
	ret		; kilepes az eljarasbol
LCmpEof:
	cmp ax,1
	jne LEof	; ha EOF, kilepes az eljarasbol
	cmp BYTE PTR BufLen,MaxBufLen
	jne LAdjCRLF	; ha nem telt be a buffer
	mov dx, OFFSET erLongLine
	mov ah,09h	; hibauzenet kiirasa
	int 21h
	mov ExCode,ecLongLine ; exit code
	stc		; hiba volt
	ret		; kilepes az eljarasbol
LAdjCRLF:
	inc BYTE PTR BufLen	; buffer merete valtozott
	mov bx,Tmp	; hova olvastuk be a karaktert
	cmp BYTE PTR [bx],LF	; sorveg-jel?
	jne LReadChar	; ha nem sorveg -> kovetkezo karakter olvasasa
	cmp BYTE PTR BufLen,1
	je LWriCRLF	; ha LF az elso karakter (CR/LF kell helyette)
	dec bx
	cmp BYTE PTR [bx],CR	; elozo karakter vizsgalata
	je LRetReadLine	; ha CR -> nincs teendo, kilepes	
	inc bx
LWriCRLF:
	mov BYTE PTR [bx],CR	; CR/LF beirasa
	inc bx
	mov BYTE PTR [bx],LF
	inc BYTE PTR BufLen	; sorhossz nott
	jmp SHORT LRetReadLine	; kilepes
LEof:
	mov BYTE PTR EOFReached,1 ; EOF-ot elertuk
LRetReadLine:
	clc		; nincs hiba
	ret
ENDP

; --------------------------- WriteLine eljaras -----------------------------
; Buffer kiirasa az outputfile-ba (ha hiba: Carry=1)
WriteLine PROC
	mov dx, OFFSET Buffer	; honnan irunk
	mov bx,OutHandle	; hova
	mov cl,BufLen	; hany karaktert
	mov ch,0
	mov ah,40h	; iras az outputfile-ba (Write)
	int 21h
	jc LWriErr	; ha hiba volt
	cmp al,BufLen	; hany karaktert sikerult kiirni
	je LRetWriteLine	; ha nincs hiba
LWriErr:
	mov dx, OFFSET erWriteOut
	mov ah,09h	; hibauzenet kiirasa
	int 21h
	mov ExCode,ecWriteOut ; exit code
	stc		; hiba volt
	ret
LRetWriteLine:
	clc		; nem volt hiba
	ret
ENDP

END LStart		; belepesi pont
