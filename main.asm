
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
	jz Valtas
	
    ; a leutott billentyu esc volt-e
	cmp al, 27
	jz ProgramVege

    ; ha sem 1, sem esc volt a billentyu
    jmp FoMenu

Valtas:
    ; valtas vga (320x200) uzemmodba
    mov ax, 13h
    int 10h

    mov ah, 0ch ; column = 160
    mov cx, 100
    mov dx, 100
    mov al, 48 ; color = red
    int 10h

    ; wait for key press
    mov ah, 00h
    int 16h

    ; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h

ProgramVege:
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
	