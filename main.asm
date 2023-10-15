
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
	call Menu
	
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

; inditaskor maskepp kell kirajzolni az elozo poziciokat (hogy ne maradjanak szines pixelek az elozo jatekbol)
InitRajz:
	; zold keret kirajzolasa
	mov cx, 0		; ciklusvaltozo
	FelsoAlsoKeret:
		; felso keret
		mov di, cx		; di-be rakjuk a pixel helyet
		mov al, 2		; al-be a szint (zold)
		mov es:[di], al ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

		; also keret
		add di, 320*199 ; also reszen ugyanezen a pozicion levo pixel helyenek a kiszamitasa -> minden sorban 320 pixel, es 199 sorral lejjebb van mint az elozo
		mov es:[di], al

		; ciklus
		inc cx
		cmp cx, 320
		jl FelsoAlsoKeret

	mov cx, 0
	BalJobbKeret:
		; bal keret
		mov ax, cx		; ax-be rakjuk a ciklusvaltozot, hogy azt tudjuk megszorozni 320-al mindig
		mov bx, 320		; konstans amivel szorzunk
		mul bx			; ax erteket megszorozunk a bx-el
		mov di, ax		; di-be rakjuk a pixel helyet

		mov al, 2		; al-be rakjuk a szint
		mov es:[di], al ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

		; jobb keret
		mov ax, cx
		mov bx, 320
		mul bx
		mov di, ax
		add di, 319		; ugyanaz, csak itt meg el is toljuk jobbra a kepernyo masik szelere

		mov al, 2
		mov es:[di], al

		inc cx
		cmp cx, 200
		jl BalJobbKeret

	call Jatekos1ElozoPixelHelye	; kiszamoljuk az elozo pixel helyet -> ez a di-be kerul
	mov al, 0						; az ax also reszebe a szint toltjuk (fekete)
	mov es:[di], al     			; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	call Jatekos2ElozoPixelHelye	; kiszamoljuk az elozo pixel helyet -> ez a di-be kerul
	mov al, 0						; az ax also reszebe a szint toltjuk (fekete)
	mov es:[di], al     			; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	; kirajzoljuk a jelenlegi pixelt a megfelelo szinnel
	call Jatekos1JelenlegiPixelRajz
	call Jatekos2JelenlegiPixelRajz

	jmp Var

Rajz1:
	call Jatekos1ElozoPixelHelye	; kiszamoljuk az elozo pixel helyet -> ez a di-be kerul
	mov al, 42						; az ax also reszebe a szint toltjuk (sarga)
	mov es:[di], al    				; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	call Jatekos1JelenlegiPixelRajz	; kirajzoljuk a jelenlegi pixelt a megfelelo szinnel

Rajz2:
	call Jatekos2ElozoPixelHelye	; kiszamoljuk az elozo pixel helyet -> ez a di-be kerul
	mov al, 77						; az ax also reszebe a szint toltjuk (sarga)
	mov es:[di], al    				; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	xor ax, ax

	call Jatekos2JelenlegiPixelRajz	; kirajzoljuk a jelenlegi pixelt a megfelelo szinnel

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

	mov al, 1	; al-be berakjuk azt az idot, amennyi elteltevel mozogni kell
	xor ah, ah	; kiuritjuk az ah-t
	cmp dx, ax	; megnezzuk, hogy az eltelt ido tobb-e mint amennyi elteltevel mozogni kell

	pop ax		; a verem visszaallitasa (hogy ne legyen mindig egyre tobb dolog benne)

	jc Var		; hogyha kevesebb ido telt el (van carry mert kisebb volt), akkor tovabbra is varunk

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
	jz Fel1Jump

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

CheckUtkozes1:
	mov ax, [jatekos1y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)
	add ax, [jatekos1x] ; ax-ben levo eredmenyhez adjuk az x-et
	mov di, ax			; di-be rakjuk a kiszamolt erteket

	mov al, es:[di]  	; kiolvassuk az es szegmens di altal mutatott reszerol a pixel szint, es betoltjuk az al-be

	cmp al, 0			; ha fekete, akkor jo helyen van, tehat folytatjuk azzal hogy nezzuk hogy a masik jatekos mit nyomott
	jz Check2Jump

	cmp al, 32			; ha kek, akkor a masik fejenek ment, tehat dontetlen
	jz DontetlenJump

	jmp MasodikNyertJump ; kulonben nekiment valaminek, szoval a masik nyert

CheckUtkozes2:
	mov ax, [jatekos2y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)
	add ax, [jatekos2x] ; ax-ben levo eredmenyhez adjuk az x-et
	mov di, ax			; di-be rakjuk a kiszamolt erteket

	mov al, es:[di]  	; kiolvassuk az es szegmens di altal mutatott reszerol a pixel szint, es betoltjuk az al-be

	cmp al, 0			; ha fekete, akkor jo helyen van, tehat kirajzoljuk oket
	jz Rajz1Jump

	cmp al, 4			; ha piros, akkor a masik fejenek ment, tehat dontetlen
	jz DontetlenJump

	jmp ElsoNyertJump 	; kulonben nekiment valaminek, szoval a masik nyert

Rajz1Jump:
	jmp Rajz1
ElsoNyertJump:
	jmp ElsoNyert
MasodikNyertJump:
	jmp MasodikNyert
DontetlenJump:
	jmp DontetlenLett
Check2Jump:
	jmp Check2

; fuggveny, ami elmenti a jatekos 1 elozo poziciojat
ElozoPozicioMentes1:
	mov ax, [jatekos1x]
    mov [jatekos1voltx], ax
	mov ax, [jatekos1y]
    mov [jatekos1volty], ax
	ret

; fuggveny, ami elmenti a jatekos 2 elozo poziciojat
ElozoPozicioMentes2:
	mov ax, [jatekos2x]
    mov [jatekos2voltx], ax
	mov ax, [jatekos2y]
    mov [jatekos2volty], ax
	ret

Jobbra1:
	call ElozoPozicioMentes1 ; elmentjuk az elozo poziciot

	mov [jatekos1irany], 1	; az iranyt beallitjuk
	inc [jatekos1x]			; x koordinatat noveljuk

	cmp [jatekos1x], 320	; megnezzuk hogy meg a palyan van-e
	jc CheckUtkozes1Jump	; ha kisebb jott ki mint 1 (tehat van carry - negativ - meg a palyan van), akkor ugrunk arra, hogy megnezzuk hogy van-e utkozes -> es majd az fogja meghivni a rajzolast

	dec [jatekos1x]			; kulonben csokkentjuk
	jmp CheckUtkozes1Jump	; es ismet megnezzuk hogy igy utkozott-e

Balra1:
	call ElozoPozicioMentes1
	mov [jatekos1irany], 2
	dec [jatekos1x]
	cmp [jatekos1x], 1
	jnc CheckUtkozes1Jump
	inc [jatekos1x]
	jmp CheckUtkozes1Jump

CheckUtkozes1Jump:
	jmp CheckUtkozes1

Fel1:
	call ElozoPozicioMentes1
	mov [jatekos1irany], 3
	dec [jatekos1y]
	cmp [jatekos1y], 1
	jnc CheckUtkozes1Jump
	inc [jatekos1y]
	jmp CheckUtkozes1Jump

Le1:
	call ElozoPozicioMentes1
	mov [jatekos1irany], 4
	inc [jatekos1y]
	cmp [jatekos1y], 200
	jc CheckUtkozes1Jump
	dec [jatekos1y]
	jmp CheckUtkozes1Jump

Jobbra2:
	call ElozoPozicioMentes2
	mov [jatekos2irany], 1
	inc [jatekos2x]
	cmp [jatekos2x], 320
	jc CheckUtkozes2Jump
	dec [jatekos2x]
	jmp CheckUtkozes2Jump

Balra2:
	call ElozoPozicioMentes2
	mov [jatekos2irany], 2
	dec [jatekos2x]			; x koordinatat csokkentjuk
	cmp [jatekos2x], 1 	 	; megnezzuk hogy meg a palyan van-e
	jnc CheckUtkozes2Jump	; ha NEM kisebb jott ki mint 1 (tehat meg a palyan van), akkor kirajzoljuk
	inc [jatekos2x]			; kulonben noveljuk
	jmp CheckUtkozes2Jump

CheckUtkozes2Jump:
	jmp CheckUtkozes2

Fel2:
	call ElozoPozicioMentes2
	mov [jatekos2irany], 3
	dec [jatekos2y]
	cmp [jatekos2y], 1
	jnc CheckUtkozes2Jump
	inc [jatekos2y]
	jmp CheckUtkozes2Jump

Le2:
	call ElozoPozicioMentes2
	mov [jatekos2irany], 4
	inc [jatekos2y]
	cmp [jatekos2y], 200
	jc CheckUtkozes2Jump
	dec [jatekos2y]
	jmp CheckUtkozes2Jump

Vissza:
	; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h
	jmp ProgramVege

ElsoNyert:
    ; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h

	; kurzor pozicionalas (elsonyert kiiras)
    mov ah, 02h
	mov bh, 0       ; video lap szama
	mov dh, 9       ; sor
	mov dl, 32      ; oszlop
	int 10h
    
    mov dx, offset jatekos1nyert
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h

	jmp MenuKiiras

MasodikNyert:
    ; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h

	; kurzor pozicionalas (masodiknyert kiiras)
    mov ah, 02h
	mov bh, 0       ; video lap szama
	mov dh, 9       ; sor
	mov dl, 31      ; oszlop
	int 10h
    
    mov dx, offset jatekos2nyert
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h

	jmp MenuKiiras

DontetlenLett:
	; visszavaltas vga uzemmodrol
    mov ax, 03h
    int 10h

	; kurzor pozicionalas (dontetlen kiiras)
    mov ah, 02h
	mov bh, 0       ; video lap szama
	mov dh, 9       ; sor
	mov dl, 37      ; oszlop
	int 10h
    
    mov dx, offset dontetlen
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h

	jmp MenuKiiras

; pixel =  y * 320 + x

; fuggveny, ami kirajzolja a jatekos 1 jelenlegi poziciojat pirossal
Jatekos1JelenlegiPixelRajz:
	mov ax, [jatekos1y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos1x] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 4			; az also reszebe a szint toltjuk (piros)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	ret

; fuggveny, ami kirajzolja a jatekos 2 jelenlegi poziciojat kekkel
Jatekos2JelenlegiPixelRajz:
	mov ax, [jatekos2y] ; ax-be y
	mov cx, 320			; cx-be 320
	mul cx				; ax-ban levovel szorozzuk a 320-at (y * 320)

	add ax, [jatekos2x] ; ax-ben levo eredmenyhez adjuk az x-et

	mov di, ax			; di-be rakjuk a kiszamolt erteket
	mov al, 32			; az also reszebe a szint toltjuk (kek)
	mov es:[di], al     ; az es szegmens di altal mutatott reszet az al-ben levo szinure szinezi

	ret

; fuggveny, ami kiszamolja a jatekos 1 elozo poziciojanak a helyet a kijelzon es a di-be rakja (nem rajzolja ki mert tobb kulonbozo helyen tobb kulonbozo szinnel kell kirajzolni)
Jatekos1ElozoPixelHelye:
	mov ax, [jatekos1volty] ; ax-be y
	mov cx, 320				; cx-be 320
	mul cx					; ax-ban levovel szorozzuk a 320-at (y * 320)
	add ax, [jatekos1voltx] ; ax-ben levo eredmenyhez adjuk az x-et
	mov di, ax				; di-be rakjuk a kiszamolt erteket
	ret

; fuggveny, ami kiszamolja a jatekos 2 elozo poziciojanak a helyet a kijelzon es a di-be rakja (nem rajzolja ki mert tobb kulonbozo helyen tobb kulonbozo szinnel kell kirajzolni)
Jatekos2ElozoPixelHelye:
	mov ax, [jatekos2volty]
	mov cx, 320
	mul cx
	add ax, [jatekos2voltx]
	mov di, ax
	ret

InitJump:
	jmp Init

; fuggveny, ami kiirja a start - exit -et es varakozik egy billentyure
Menu:
	; kurzor pozicionalas (start kiiras)
    mov ah, 02h
	mov bh, 0        ; video lap szama
	mov dh, 11       ; sor
	mov dl, 31       ; oszlop
	int 10h
    
    mov dx, offset menu1
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h
	
    ; kurzor pozicionalas (exit kiiras)
	mov ah, 02h
	mov bh, 0        ; video lap szama
	mov dh, 12       ; sor
	mov dl, 36       ; oszlop
	int 10h
	
	mov dx, offset menu2
	mov ah, 09h     ; 21h tudja hogy a kepernyore kell irnia a STRINGET, ami a dl-ben van
	int 21h

	xor ax, ax     ; ax nullazasa
	int 16h        ; varakozas egy billenytu lenyomasara

	ret

MenuKiiras:
	call Menu

	; a leutott billentyu a space volt-e
    cmp al, 32
	jz InitJump
	
    ; a leutott billentyu esc volt-e
	cmp al, 27
	jz ProgramVege

	jmp MenuKiiras


ProgramVege:
	; kepernyo torles:
    mov ax, 03h
	int 10h

	pop dx

	; vezerles visszaadasa
    mov ax, 4c00h
	int 21h

	
menu1:
	db "Start Game (SPACE)$" ; hossz = 18
menu2:
	db "Exit (ESC)$" ; hossz = 10
jatekos1nyert:
	db "Red player wins!$" ; hossz = 16
jatekos2nyert:
	db "Blue player wins!$" ; hossz = 17
dontetlen:
	db "Draw!$" ; hossz = 5

Code Ends

Data Segment
	; dw - define word (allocates 2 bytes)
	jatekos1x dw 0
	jatekos1y dw 0
	jatekos2x dw 0
	jatekos2y dw 0

	jatekos1irany dw 0
	jatekos2irany dw 0

	jatekos1voltx dw 0
	jatekos1volty dw 0
	jatekos2voltx dw 0
	jatekos2volty dw 0

Data Ends

Stack Segment

Stack Ends
	End Start
	