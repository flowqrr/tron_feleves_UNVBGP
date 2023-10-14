
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
	mov dl, 100 ; x koordinata
	mov dh, 100 ; y koordinata
	push dx

Valtas:
    ; valtas vga (320x200) uzemmodba
    mov ax, 13h
    int 10h

    ; kepernyo memoria beallitas
	mov ax, 0a000h   ; video kezdocime
	mov es, ax       ; extra szegmens

	; pixel =  y * 320 + x

Rajz:
	pop dx		; dx-ben vannak a koordinatak (dl: x, dh: y)
	xor ah, ah  ; kiuritjuk az ah-t
	
	mov al, dh  ; az al-be toltjuk az y koordinatat
	push dx		; a dx-et verembe rakjuk, mert abban van meg az x (es a mul felul fogja irni)

	mov bx, 320 ; bx-be 320
	mul bx		; y * 320 (az ax-ben levo dologgal szorozza meg a bx-et, ami most 320-szor az al-ben levo y koordinata)
	
	pop dx		; elovesszuk a verembol a koordinatakat (dl: x, dh: y)
	add al, dl  ; hozzaadjuk az x koordinatat az al-hez

	jnc Pixel
	inc ah

Pixel:
	push dx
	mov di, ax
	mov al, 4		; beallitjuk a pixel szinet
	mov es:[di], al ; al tartalmanak a betoltese az extra szegmensnek a di altal mutatott helyere

Var:
	; varakozas billentyu leutesere
	xor ah, ah
	int 16h

	; ha esc-et nyomott
	cmp al, 27
	jz Vissza

	; ha bal nyilt nyomott
	cmp ah, 75
	jz Balra

	; ha jobb nyilt nyomott
	cmp ah, 77
	jz Jobbra

	; ha felfele nyilt nyomott
	cmp ah, 72
	jz Felfele

	; lefele nyilt nyomott
	cmp ah, 80
	jz Lefele

	; addig varunk amig valamit nem nyom
	jmp Var

; teleport kapu a program vegehez
PVJump:
	jmp ProgramVege

Balra:
	pop dx
	dec dl
	cmp dl, 1
	jnc Tarol
	inc dl
	jmp Tarol

Jobbra:
	pop dx
	inc dl
	cmp dl, 250
	jc Tarol
	dec dl
	jmp Tarol

Felfele:
	pop dx
	dec dh
	cmp dh, 1
	jnc Tarol
	inc dh
	jmp Tarol

Lefele:
	pop dx
	inc dh
	cmp dh, 200
	jc Tarol
	dec dh
	jmp Tarol

Tarol:
	push dx
	jmp Rajz

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

Data Ends

Stack Segment

Stack Ends
	End Start
	