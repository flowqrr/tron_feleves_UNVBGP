
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
	
	; a leutott billentyu a space volt-e
    cmp al, 32
	jz Init
	
    ; a leutott billentyu esc volt-e
	cmp al, 27
	jz PVJump

    ; ha sem space, sem esc volt a billentyu
    jmp FoMenu

; teleport kapu a program vegehez
PVJump:
	jmp ProgramVege

Init:
	mov jatekos1x, 300 ; vizszintes koordinata
	mov jatekos1y, 180 ; fuggoleges koordinata

	mov jatekos2x, 20 ; vizszintes koordinata
	mov jatekos2y, 20 ; fuggoleges koordinata

	; 1 - jobbra
	; 2 - balra
	; 3 - fel
	; 4 - le
	mov jatekos1irany, 2
	mov jatekos2irany, 1

	; ido inicializalasa (a verembe megy a 0)
	xor dx, dx
	push dx

Valtas:
    ; valtas vga (320x200) uzemmodba
    mov ax, 13h
    int 10h

    ; kepernyo memoria beallitas
	mov ax, 0a000h   ; video kezdocime
	mov es, ax       ; extra szegmens

; pixel =  y * 320 + x
Rajz1:
	; elozo pozicio kirajzolasa sargaval
	mov ax, [jatekos1volty] ; ax-be y
	mov cx, 320				; cx-be 320
	mul cx					; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos1voltx] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 42			; az also reszebe a szint toltjuk (sarga)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	; jelenlegi pozicio kirajzolasa pirossal
	mov ax, [jatekos1y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos1x] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 4			; az also reszebe a szint toltjuk (piros)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

Rajz2:
	; elozo pozicio kirajzolasa lilaval
	mov ax, [jatekos2volty] ; ax-be y
	mov cx, 320				; cx-be 320
	mul cx					; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos2voltx] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 9			; az also reszebe a szint toltjuk (lila)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	; jelenlegi pozicio kirajzolasa kekkel
	mov ax, [jatekos2y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos2x] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 1			; az also reszebe a szint toltjuk (kek)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

Var:
	; varakozas billentyu leutesere
	mov ah, 01h
	int 16h
	jnz CheckBillentyu
	
NincsBill:
	xor ah, ah
	int 1ah		; ido beolvasasa a cx:dx-be

	pop cx		; regi ido kivetele
	push cx		; regi ido visszatetele
	mov ax, dx	; aktualis ido mentese ax-be
	sub dx, cx	; dx-ben: eltelt = aktualis - regi
	push ax		; aktualis ido a verembe

	; al-be berakjuk azt az idot, amennyi elteltevel mozogni kell
	mov al, 1
	xor ah, ah
	cmp dx, ax

	pop ax		; a verem visszaallitasa (hogy ne legyen mindig egyre tobb dolog benne)

	jc Var		; loop

	pop cx		; regi ido kivetele a verembol
	push ax		; aktualis ido elmentese

Check1:
	cmp jatekos1irany, 1
	jz Jobbra1Jump

	cmp jatekos1irany, 2
	jz Balra1Jump

	cmp jatekos1irany, 3
	jz Fel1Jump

	cmp jatekos1irany, 4
	jz Le1Jump

Check2:
	cmp jatekos2irany, 1
	jz Jobbra2Jump

	cmp jatekos2irany, 2
	jz Balra2Jump

	cmp jatekos2irany, 3
	jz Fel2Jump

	cmp jatekos2irany, 4
	jz Le2Jump

; al = lenyomott bill ascii kodja
; ah = scan code
CheckBillentyu:
	; szinkronba visszavaltas, ahol kiolvassuk a lenyomott billentyut
	mov ah, 00h
	int 16h

	; ha esc-et nyomott
	cmp al, 27
	jz VisszaJump

	; ha jobb nyilt nyomott
	cmp ah, 77
	jz Jobbra1Jump

	; ha bal nyilt nyomott
	cmp ah, 75
	jz Balra1Jump

	; ha felfele nyilt nyomott
	cmp ah, 72
	jz Fel1

	; lefele nyilt nyomott
	cmp ah, 80
	jz Le1Jump

	; ha d-t nyomott
	cmp al, 100
	jz Jobbra2Jump

	; ha a-t nyomott
	cmp al, 97
	jz Balra2Jump

	; ha w-t nyomott
	cmp al, 119
	jz Fel2Jump

	; ha s-t nyomott
	cmp al, 115
	jz Le2Jump

	; addig varunk amig valamit nem nyom
	jmp Var
	

VisszaJump:
	jmp Vissza
Jobbra1Jump:
	jmp Jobbra1
Balra1Jump:
	jmp Balra1
Fel1Jump:
	jmp Fel1
Le1Jump:
	jmp Le1
Jobbra2Jump:
	jmp Jobbra2
Balra2Jump:
	jmp Balra2
Fel2Jump:
	jmp Fel2
Le2Jump:
	jmp Le2
	

Jobbra1:
	; elozo pozicio elmentese
	mov ax, [jatekos1x]
    mov [jatekos1voltx], ax
	mov ax, [jatekos1y]
    mov [jatekos1volty], ax

	inc [jatekos1x]			; x koordinatat noveljuk
	cmp [jatekos1x], 320	; megnezzuk hogy meg a palyan van-e
	mov [jatekos1irany], 1
	jc Check2Jump			; ha kisebb jott ki mint 1 (tehat van carry - negativ - meg a palyan van), akkor ugrunk a 2. jatekos checkolasara, mert annak a koordinatait is meg kell nezni mielott rajzolunk
	dec [jatekos1x]			; kulonben noveljuk

Balra1:
	mov ax, [jatekos1x]
    mov [jatekos1voltx], ax
	mov ax, [jatekos1y]
    mov [jatekos1volty], ax

	dec [jatekos1x]
	cmp [jatekos1x], 1
	mov [jatekos1irany], 2
	jnc Check2Jump
	inc [jatekos1x]

Fel1:
	mov ax, [jatekos1x]
    mov [jatekos1voltx], ax
	mov ax, [jatekos1y]
    mov [jatekos1volty], ax

	dec [jatekos1y]
	cmp [jatekos1y], 1
	mov [jatekos1irany], 3
	jnc Check2Jump
	inc [jatekos1y]

Le1:
	mov ax, [jatekos1x]
    mov [jatekos1voltx], ax
	mov ax, [jatekos1y]
    mov [jatekos1volty], ax

	inc [jatekos1y]
	cmp [jatekos1y], 200
	mov [jatekos1irany], 4
	jc Check2Jump
	dec [jatekos1y]

Check2Jump:
	jmp Check2

Jobbra2:
	mov ax, [jatekos2x]
    mov [jatekos2voltx], ax
	mov ax, [jatekos2y]
    mov [jatekos2volty], ax

	inc [jatekos2x]
	cmp [jatekos2x], 320
	mov [jatekos2irany], 1
	jc Rajz1Jump
	dec [jatekos2x]

Balra2:
	mov ax, [jatekos2x]
    mov [jatekos2voltx], ax
	mov ax, [jatekos2y]
    mov [jatekos2volty], ax

	dec [jatekos2x]		; x koordinatat csokkentjuk
	cmp [jatekos2x], 1  ; megnezzuk hogy meg a palyan van-e
	mov [jatekos2irany], 2
	jnc Rajz1Jump			; ha NEM kisebb jott ki mint 1 (tehat meg a palyan van), akkor kirajzoljuk
	inc [jatekos2x]		; kulonben noveljuk

Fel2:
	mov ax, [jatekos2x]
    mov [jatekos2voltx], ax
	mov ax, [jatekos2y]
    mov [jatekos2volty], ax

	dec [jatekos2y]
	cmp [jatekos2y], 1
	mov [jatekos2irany], 3
	jnc Rajz1Jump
	inc [jatekos2y]

Le2:
	mov ax, [jatekos2x]
    mov [jatekos2voltx], ax
	mov ax, [jatekos2y]
    mov [jatekos2volty], ax

	inc [jatekos2y]
	cmp [jatekos2y], 200
	mov [jatekos2irany], 4
	jc Rajz1Jump
	dec [jatekos2y]

; miutan minden jatekos mozgatasa megvolt, rajzolunk
Rajz1Jump:
	jmp Rajz1

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
	; dw - define word (allocates 2 bytes)
	jatekos1x dw 0,
	jatekos1y dw 0,
	jatekos2x dw 0,
	jatekos2y dw 0,

	jatekos1irany dw 0,
	jatekos2irany dw 0,

	jatekos1voltx dw 0,
	jatekos1volty dw 0,
	jatekos2voltx dw 0,
	jatekos2volty dw 0,

Data Ends

Stack Segment

Stack Ends
	End Start
	