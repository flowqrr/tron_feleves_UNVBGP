
Code Segment
	assume CS:Code, DS:Data, SS:Stack

Start:
	; inicializalas:
	mov ax, Code
	mov ds, ax
	
    ; kepernyo torles:
    mov ax, 03h
	int 10h

FoMenu:
	; kurzor pozicionalas (start kiiras)
    mov ah, 02h
	mov bh, 0       ; video lap szama
	mov dh, 11       ; kurzor a 12. sorba
	mov dl, 31       ; kurzor a 32. oszlopba
	int 10h
    
    mov dx, offset menu1
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h
	
    ; kurzor pozicionalas (exit kiiras)
	mov ah, 02h
	mov bh, 0       ; video lap szama
	mov dh, 12       ; kurzor a 13. sorba
	mov dl, 36       ; kurzor a 35. oszlopba
	int 10h
	
	mov dx, offset menu2
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h

	xor ax, ax     ; ax nullazasa
	int 16h        ; varakozas egy billenytu lenyomasara
	
    ; beadott billentyu eltarolasa
	mov bx, ax
	mov ax, 03h
	int 10h
	mov ax, bx
	
	; a leutott billentyu a space volt-e
    cmp al, 32
	jz Init
	
    ; a leutott billentyu esc volt-e
	cmp al, 27
	jz PVJump

    ; ha sem space, sem esc volt a billentyu
    jmp FoMenu

Init:
	mov jatekos1x, 10 ; x koordinata
	mov jatekos1y, 10 ; y koordinata

Valtas:
    ; valtas vga (320x200) uzemmodba
    mov ax, 13h
    int 10h

    ; kepernyo memoria beallitas
	mov ax, 0a000h   ; video kezdocime
	mov es, ax       ; extra szegmens

; pixel =  y * 320 + x
Szamol1:
	mov ax, [jatekos1y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos1x] ; ax-ben levo eredmenyhez adjuk az x-et

Pixel1:
	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 4			; az also reszebe a szint toltjuk (piros)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

Var:
	; varakozas billentyu leutesere
	xor ah, ah
	int 16h

	; ha esc-et nyomott
	cmp al, 27
	jz Vissza

	; ha bal nyilt nyomott
	cmp ah, 75
	jz Balra1

	; ha jobb nyilt nyomott
	cmp ah, 77
	jz Jobbra1

	; ha felfele nyilt nyomott
	cmp ah, 72
	jz Fel1

	; lefele nyilt nyomott
	cmp ah, 80
	jz Le1

	; addig varunk amig valamit nem nyom
	jmp Var

; teleport kapu a program vegehez
PVJump:
	jmp ProgramVege

Balra1:
	dec [jatekos1x]		; x koordinatat csokkentjuk
	cmp [jatekos1x], 1  ; megnezzuk hogy meg a palyan van-e
	jnc Szamol1			; ha NEM kisebb jott ki mint 1 (tehat meg a palyan van), akkor kirajzoljuk
	inc [jatekos1x]		; kulonben noveljuk
	jmp Szamol1			; es akkor rajzoljuk ki

Jobbra1:
	inc [jatekos1x]
	cmp [jatekos1x], 320
	jc Szamol1
	dec [jatekos1x]
	jmp Szamol1

Fel1:
	dec [jatekos1y]
	cmp [jatekos1y], 1
	jnc Szamol1
	inc [jatekos1y]
	jmp Szamol1

Le1:
	inc [jatekos1y]
	cmp [jatekos1y], 200
	jc Szamol1
	dec [jatekos1y]
	jmp Szamol1

Vissza:
    ; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h

ProgramVege:
	pop dx

	; vezerles visszaadasa
    mov ax, 4c00h
	int 21h

	
menu1:
	db "Start Game (SPACE)$" ; hossz = 18
menu2:
	db "Exit (ESC)$" ; hossz = 10

Code Ends

Data Segment
	jatekos1x dw 0,
	jatekos1y dw 0,
	jatekos2x dw 0,
	jatekos2y dw 0,

Data Ends

Stack Segment

Stack Ends
	End Start
	