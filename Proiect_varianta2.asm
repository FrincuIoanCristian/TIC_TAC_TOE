.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
extern rand: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiect X si 0, varianta 2",0
area_width EQU 600
area_height EQU 400
area DD 0

counter DD 0 ; numara evenimentele de tip timer
culoare DD 0
start_OK dd 0
mod_joc dd 0 ; memorez stilul de joc, 1vs1 / 1vscomp
scor_0 dd 0
scor_X dd 0
ordine dd 0
vector db 9 dup(0)
aux dd 0
nr_random dd 0
ok_verificare dd 0
linie_castigatoare dd 0
x_y dd 0

format db "%d", 0
;coordonate buton start
start_x equ 250
start_y equ 170
start_size_x equ 100
start_size_y equ 60
;coordonate buton play again
again_x equ 400
again_y equ 200
again_size_x equ 120
again_size_y equ 40
;coordonate buton player vs player
buton1_x equ 200
buton1_y equ 140
buton1_size_x equ 200
buton1_size_y equ 40
;cooedonate buton restart
restart_x equ 400
restart_y equ 260
restart_size_x equ 120
restart_size_y equ 40
;coordonate buton player vs calculator
buton2_x equ 200
buton2_y equ 220
buton2_size_x equ 200
buton2_size_y equ 40
;coordonate tabla de joc
tabla_x equ 200
tabla_y equ 100
tabla_size equ 165

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
dimensiune_X_0 EQU 45
include digits.inc
include letters.inc
include X_si_O.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

;MACROURI
;linie orizontala
line_horizontal macro x, y, len, color
local bucla_linie
	mov eax, y ; EAX = y
	mov ebx, area_width
	mul ebx ; EAX = y * area_width
	add eax, x ; EAX = y * area_width + x
	shl eax, 2 ; EAX = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_linie
endm

;linie verticala
line_vertical macro x, y, len, color
local bucla_linie
	mov eax, y 
	mov ebx, area_width
	mul ebx 
	add eax, x 
	shl eax, 2 
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_linie
endm

;linie oblica pentru diagonala principala
line_oblica1 macro x, y, len, color
local bucla_linie
	mov eax, y 
	mov ebx, area_width
	mul ebx 
	add eax, x 
	shl eax, 2 
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, area_width * 4 + 4
	loop bucla_linie
endm

;linie oblica pentru diagonala secundara
line_oblica2 macro x, y, len, color
local bucla_linie
	mov eax, y 
	mov ebx, area_width
	mul ebx 
	add eax, x 
	shl eax, 2 
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, area_width * 4 - 4
	loop bucla_linie
endm

creeaza_buton_start macro
	line_horizontal start_x, start_y, start_size_x, 0FFFFFFh
	line_horizontal start_x, start_y+1, start_size_x, 0FFFFFFh
	line_horizontal start_x, start_y+2, start_size_x, 0FFFFFFh
	line_horizontal start_x, start_y + start_size_y, start_size_x, 0FFFFFFh
	line_horizontal start_x, start_y + start_size_y-1, start_size_x, 0FFFFFFh
	line_horizontal start_x, start_y + start_size_y-2, start_size_x, 0FFFFFFh
	line_vertical start_x, start_y, start_size_y, 0FFFFFFh
	line_vertical start_x+1, start_y, start_size_y, 0FFFFFFh
	line_vertical start_x+2, start_y, start_size_y, 0FFFFFFh
	line_vertical start_x + start_size_x, start_y, start_size_y, 0FFFFFFh
	line_vertical start_x + start_size_x-1, start_y, start_size_y, 0FFFFFFh
	line_vertical start_x + start_size_x-2, start_y, start_size_y, 0FFFFFFh
	make_text_macro 'S', area, 275, 180
	make_text_macro 'T', area, 285, 180
	make_text_macro 'A', area, 295, 180
	make_text_macro 'R', area, 305, 180
	make_text_macro 'T', area, 315, 180
	make_text_macro 'G', area, 280, 200
	make_text_macro 'A', area, 290, 200
	make_text_macro 'M', area, 300, 200
	make_text_macro 'E', area, 310, 200
endm

creeaza_butoane macro
	;creez butonul player vs player
	line_horizontal buton1_x, buton1_y, buton1_size_x, 0FFFFFFh
	line_horizontal buton1_x, buton1_y+1, buton1_size_x, 0FFFFFFh
	line_horizontal buton1_x, buton1_y+2, buton1_size_x, 0FFFFFFh
	line_horizontal buton1_x, buton1_y+buton1_size_y, buton1_size_x, 0FFFFFFh
	line_horizontal buton1_x, buton1_y+buton1_size_Y-1, buton1_size_x, 0FFFFFFh
	line_horizontal buton1_x, buton1_y+buton1_size_y-2, buton1_size_x, 0FFFFFFh
	line_vertical buton1_x, buton1_y, buton1_size_y, 0FFFFFFh
	line_vertical buton1_x+1, buton1_y, buton1_size_y, 0FFFFFFh
	line_vertical buton1_x+2, buton1_y, buton1_size_y, 0FFFFFFh
	line_vertical buton1_x+buton1_size_x, buton1_y, buton1_size_y, 0FFFFFFh
	line_vertical buton1_x+buton1_size_x-1, buton1_y, buton1_size_y, 0FFFFFFh
	line_vertical buton1_x+buton1_size_x-2, buton1_y, buton1_size_y, 0FFFFFFh
	make_text_macro 'P', area, 220, 150
	make_text_macro 'L', area, 230, 150
	make_text_macro 'A', area, 240, 150
	make_text_macro 'Y', area, 250, 150
	make_text_macro 'E', area, 260, 150
	make_text_macro 'R', area, 270, 150
	make_text_macro 'V', area, 290, 150
	make_text_macro 'S', area, 300, 150
	make_text_macro 'P', area, 320, 150
	make_text_macro 'L', area, 330, 150
	make_text_macro 'A', area, 340, 150
	make_text_macro 'Y', area, 350, 150
	make_text_macro 'E', area, 360, 150
	make_text_macro 'R', area, 370, 150
	
	;creeaz butonul player vs computer
	line_horizontal buton2_x, buton2_y, buton2_size_x, 0FFFFFFh
	line_horizontal buton2_x, buton2_y+1, buton2_size_x, 0FFFFFFh
	line_horizontal buton2_x, buton2_y+2, buton2_size_x, 0FFFFFFh
	line_horizontal buton2_x, buton2_y+buton2_size_y, buton2_size_x, 0FFFFFFh
	line_horizontal buton2_x, buton2_y+buton2_size_y-1, buton2_size_x, 0FFFFFFh
	line_horizontal buton2_x, buton2_y+buton2_size_y-2, buton2_size_x, 0FFFFFFh
	line_vertical buton2_x, buton2_y, buton2_size_y, 0FFFFFFh
	line_vertical buton2_x+1, buton2_y, buton2_size_y, 0FFFFFFh
	line_vertical buton2_x+2, buton2_y, buton2_size_y, 0FFFFFFh
	line_vertical buton2_x+buton2_size_x, buton2_y, buton2_size_y, 0FFFFFFh
	line_vertical buton2_x+buton2_size_x-1, buton2_y, buton2_size_y, 0FFFFFFh
	line_vertical buton2_x+buton2_size_x-2, buton2_y, buton2_size_y, 0FFFFFFh
	make_text_macro 'P', area, 215, 230
	make_text_macro 'L', area, 225, 230
	make_text_macro 'A', area, 235, 230
	make_text_macro 'Y', area, 245, 230
	make_text_macro 'E', area, 255, 230
	make_text_macro 'R', area, 265, 230
	make_text_macro 'V', area, 285, 230
	make_text_macro 'S', area, 295, 230
	make_text_macro 'C', area, 315, 230
	make_text_macro 'O', area, 325, 230
	make_text_macro 'M', area, 335, 230
	make_text_macro 'P', area, 345, 230
	make_text_macro 'U', area, 355, 230
	make_text_macro 'T', area, 365, 230
	make_text_macro 'E', area, 375, 230
	make_text_macro 'R', area, 385, 230
endm

creeaza_tabla_de_joc macro
	line_horizontal tabla_x-10, tabla_y-10, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-9, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-8, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-7, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-6, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-5, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-4, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-3, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-2, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y-1, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+45, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+46, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+47, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+48, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+49, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+95, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+96, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+97, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+98, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+99, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+145, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+146, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+147, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+148, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+149, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+150, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+151, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+152, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+153, tabla_size, 0FFFFFFh
	line_horizontal tabla_x-10, tabla_y+154, tabla_size, 0FFFFFFh
	line_vertical tabla_x-10, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-9, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-8, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-7, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-6, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-5, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-4, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-3, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-2, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x-1, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+45, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+46, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+47, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+48, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+49, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+95, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+96, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+97, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+98, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+99, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+145, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+146, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+147, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+148, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+149, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+150, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+151, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+152, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+153, tabla_y-10, tabla_size, 0FFFFFFh
	line_vertical tabla_x+154, tabla_y-10, tabla_size, 0FFFFFFh	
endm

creeaza_butoane_again_restart macro 
	;creez butonul play again
    line_horizontal again_x, again_y, again_size_x, 0FFFFFFh
	line_horizontal again_x, again_y+1, again_size_x, 0FFFFFFh
	line_horizontal again_x, again_y+2, again_size_x, 0FFFFFFh
	line_horizontal again_x, again_y + again_size_y, again_size_x, 0FFFFFFh
	line_horizontal again_x, again_y + again_size_y-1, again_size_x, 0FFFFFFh
	line_horizontal again_x, again_y + again_size_y-2, again_size_x, 0FFFFFFh
	line_vertical again_x, again_y, again_size_y, 0FFFFFFh
	line_vertical again_x+1, again_y, again_size_y, 0FFFFFFh
	line_vertical again_x+2, again_y, again_size_y, 0FFFFFFh
	line_vertical again_x+again_size_x, again_y, again_size_y, 0FFFFFFh
	line_vertical again_x+again_size_x-1, again_y, again_size_y, 0FFFFFFh
	line_vertical again_x+again_size_x-2, again_y, again_size_y, 0FFFFFFh
	make_text_macro 'P', area, 410 , 210
	make_text_macro 'L', area, 420 , 210
	make_text_macro 'A', area, 430 , 210
	make_text_macro 'Y', area, 440 , 210
	make_text_macro 'A', area, 460 , 210
	make_text_macro 'G', area, 470 , 210
	make_text_macro 'A', area, 480 , 210
	make_text_macro 'I', area, 490 , 210
	make_text_macro 'N', area, 500 , 210
	
	;creeaz butonul restart
	line_horizontal restart_x, restart_y, restart_size_x, 0FFFFFFh
	line_horizontal restart_x, restart_y+1, restart_size_x, 0FFFFFFh
	line_horizontal restart_x, restart_y+2, restart_size_x, 0FFFFFFh
	line_horizontal restart_x, restart_y + restart_size_y, restart_size_x, 0FFFFFFh
	line_horizontal restart_x, restart_y + restart_size_y-1, restart_size_x, 0FFFFFFh
	line_horizontal restart_x, restart_y + restart_size_y-2, restart_size_x, 0FFFFFFh
	line_vertical restart_x, restart_y, restart_size_y, 0FFFFFFh
	line_vertical restart_x+1, restart_y, restart_size_y, 0FFFFFFh
	line_vertical restart_x+2, restart_y, restart_size_y, 0FFFFFFh
	line_vertical restart_x+restart_size_x, restart_y, restart_size_y, 0FFFFFFh
	line_vertical restart_x+restart_size_x-1, restart_y, restart_size_y, 0FFFFFFh
	line_vertical restart_x+restart_size_x-2, restart_y, restart_size_y, 0FFFFFFh
	make_text_macro 'R', area, 420 , 270
	make_text_macro 'E', area, 430 , 270
	make_text_macro 'S', area, 440 , 270
	make_text_macro 'T', area, 450 , 270
	make_text_macro 'A', area, 460 , 270
	make_text_macro 'R', area, 470 , 270
	make_text_macro 'T', area, 480 , 270
endm

;generare numar random pentu cazul player vs computer
genereaza_random macro 
local aici
aici:
    call rand 
	xor edx, edx
	mov ecx, 9
	div ecx
	cmp vector[edx], 0
	jne aici
	inc edx
	mov nr_random, edx
endm

;PROCEDURI
make_text proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

;procedura pentru desenarea X si 0
my_function proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, [ebp + arg1] ;memoram simbolul de afisat
	lea edi, X_si_O ;pointer la matricea X_si_O
	cmp esi, 'X'
	je am_x
	mov esi, 1
	mov culoare, 00000FFh ;alegem culoarea albastra pentru 0
	jmp incepe 
am_x:	
	mov esi, 0
	mov culoare, 0FF0000h ;alegem culoarea rosu pentru X
	incepe:
	mov eax, esi
	mov ebx, dimensiune_X_0
	mul ebx
	mul ebx
	add edi, eax ;edi este pointer la primul element element al matrici pentru x/0
	xor eax, eax
	mov eax, [ebp + arg3] ;coordonata y
	mov ebx, area_width
	mul ebx
	mov ebx, [ebp + arg2] ;coordonata x
	add eax, ebx
	shl eax, 2
	mov x_y, eax ;x_y = (y * area_width + x) * 4
	xor ebx, ebx
	;parcurgem matricea cu elementul x/0 si in acelasi timp coloram pixeli
	linii:
		cmp ebx, dimensiune_X_0
		je final
		mov esi, area ;pointer la arena noastra
		mov eax, area_width
		mul ebx
		shl eax, 2
		mov ecx, x_y
		add esi, ecx
		add esi, eax ;
		xor ecx, ecx
		coloane:
			cmp ecx, dimensiune_X_0
			je afara
			cmp byte ptr [edi], 0
			je pixel_negru
			mov eax, culoare
			mov dword ptr [esi], eax ;desenam pixelul simbolului in culoarea respectiva
			jmp final_pixel
			pixel_negru:
			mov dword ptr [esi], 0 ;desenam pixelul de fundal in negru
			final_pixel:
			inc edi
			add esi, 4
			inc ecx
			jmp coloane
		afara:	
		inc ebx
		jmp linii	
	final:	
	popa
	mov esp, ebp
	pop ebp
	ret
my_function endp
;macro pentru afisarea simbolurilor
macro_my_function macro simbol, x, y 
	push y
	push x
	push simbol
	call my_function
	add esp, 12
endm

;procedura de aflare daca s-a dat click intr-un patratel si daca s-a dat returneaza numarul patratelului
afla_patratel proc
	push ebp
	mov ebp, esp
	sub esp, 8
	mov ebx, [ebp + 8]
	mov ecx, [ebp + 12]
	xor eax, eax
	cmp ecx, tabla_y
	jl fail
	cmp ecx, tabla_y + 45
	jg linie_2
	cmp ebx, tabla_x
	jl fail
	cmp ebx, tabla_x + 45
	jg _2
	cmp vector[0],0
	jne fail
	mov eax, 1
	jmp final
_2:
	cmp ebx, tabla_x + 95
	jg _3
	cmp vector[1],0
	jne fail
	mov eax, 2
	jmp final
_3:
	cmp ebx, tabla_x + 145
	jg fail
	cmp vector[2],0
	jne fail
	mov eax, 3
	jmp final
linie_2:
	cmp ecx, tabla_y + 95
	jg linie_3
	cmp ebx, tabla_x
	jl fail
	cmp ebx, tabla_x + 45
	jg _5
	cmp vector[3],0
	jne fail
	mov eax, 4
	jmp final
_5:
	cmp ebx, tabla_x + 95
	jg _6
	cmp vector[4],0
	jne fail
	mov eax, 5
	jmp final
_6:
	cmp ebx, tabla_x + 145
	jg fail
	cmp vector[5],0
	jne fail
	mov eax, 6
	jmp final
linie_3:
	cmp ecx, tabla_y + 145
	jg fail
	cmp ebx, tabla_x
	jl fail
	cmp ebx, tabla_x +45
	jg _8
	cmp vector[6],0
	jne fail
	mov eax, 7
	jmp final
_8:
	cmp ebx, tabla_x + 95
	jg _9
	cmp vector[7],0
	jne fail
	mov eax, 8
	jmp final
_9:
	cmp ebx, tabla_x + 145
	jg fail
	cmp vector[8],0
	jne fail
	mov eax, 9
	jmp final
fail:
	mov eax, -1
final:
	mov esp, ebp
	pop ebp
	ret 
afla_patratel endp

reseteaza_arena proc
	push ebp
	mov ebp, esp
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0  ;culoare fundal
	push area
	call memset
	add esp, 12
	mov esp, ebp
	pop ebp
	ret
reseteaza_arena endp

afiseaza_scor proc
	push ebp
	mov ebp, esp
	make_text_macro 'P', area, 200, 280
	make_text_macro 'L', area, 210, 280
	make_text_macro 'A', area, 220, 280
	make_text_macro 'Y', area, 230, 280 
	make_text_macro 'E', area, 240, 280 
	make_text_macro 'R', area, 250, 280 
	make_text_macro 'X', area, 270, 280 
	make_text_macro ':', area, 280, 280 
	mov ecx, scor_X
	add ecx, '0'
	make_text_macro ecx ,area, 290, 280
	make_text_macro 'P', area, 200, 300
	make_text_macro 'L', area, 210, 300
	make_text_macro 'A', area, 220, 300
	make_text_macro 'Y', area, 230, 300 
	make_text_macro 'E', area, 240, 300 
	make_text_macro 'R', area, 250, 300 
	make_text_macro '0', area, 270, 300 
	make_text_macro ':', area, 280, 300
	mov edx, scor_0
	add edx, '0'
	make_text_macro edx, area, 290, 300
	mov esp, ebp
	pop ebp
	ret
afiseaza_scor endp

reseteaza_matrice proc
	push ebp
	mov ebp, esp
	mov ecx, 9
	reset:
		mov eax, ecx
		dec eax
		mov vector[eax], 0 ;reseteaza array la 0
	loop reset
	mov esp, ebp
	pop ebp
	ret
reseteaza_matrice endp

verificare_castigator proc
	push ebp
	mov ebp, esp
	pusha
;verificare pe linii
	xor esi, esi
	xor edi, edi
	for1:
		cmp esi, 3
		je afara1
		mov eax, esi
		mov ebx, 3
		mul ebx
		mov edi, eax
		xor edx, edx
		xor ecx, ecx
		mov al, vector[edi]
		cmp eax, 0
		je afara_for2
		cmp eax, 1
		je avem_x
		mov ok_verificare, 2
		jmp for2
		avem_x:
		mov ok_verificare, 1
		for2:
			cmp edx, 3
			je afara_for2
			mov cl, vector[edi]
			cmp eax, ecx
			je bun
			mov ok_verificare, 0
			jmp afara_for2
			bun:
			inc edx
			inc edi
			jmp for2
		afara_for2:	
		inc esi
		cmp ok_verificare ,0
		jne afara1	
		jmp for1
	afara1:
	cmp ok_verificare, 0
	je verif_coloane
	mov linie_castigatoare, esi
	cmp ok_verificare, 1
	je castigator_X
	cmp ok_verificare, 2
	je castigator_0
	;verificare pe coloane
	verif_coloane:
	xor esi, esi
	for3:
		cmp esi, 3
		je afara2
		xor eax, eax
		xor edx, edx
		xor ecx, ecx
		mov edi, esi
		mov al, vector[esi]
		cmp eax, 0
		je afara_for4
		cmp eax, 1
		je avem_x2
		mov ok_verificare, 2
		jmp for4
		avem_x2:
		mov ok_verificare, 1
		for4:
			cmp edx, 3
			je afara_for4
			mov cl, vector[edi]
			cmp ecx, eax
			je bun2
			mov ok_verificare, 0
			jmp afara_for4
			bun2:
			inc edx
			mov ecx, 3
			add edi, ecx
			jmp for4
		afara_for4:
		inc esi
		cmp ok_verificare ,0
		jne afara2	
		jmp for3	
	afara2:
	cmp ok_verificare, 0
	je diagonala_1
	add esi, 3
	mov linie_castigatoare, esi
	cmp ok_verificare, 1
	je castigator_X
	cmp ok_verificare, 2
	je castigator_0
	;verificam pe diagonala principala	
	diagonala_1:
	xor esi, esi
	xor edx, edx
	mov edi, 0
	xor eax, eax
	mov al, vector[0]
	cmp eax, 0
	je diagonala_2
	cmp eax, 1
	je avem_x3
	mov ok_verificare, 2
	jmp bucla_diagonala1
	avem_x3:
	mov ok_verificare, 1
	bucla_diagonala1:
		cmp edx, 3
		je afara3
		mov cl, vector[esi]
		cmp eax, ecx
		je bun3
		mov ok_verificare, 0
		jmp diagonala_2
		bun3:
		inc edx
		add esi, 4
		jmp bucla_diagonala1
	afara3:
	mov linie_castigatoare, 7
	cmp ok_verificare, 1
	je castigator_X
	cmp ok_verificare, 2
	je castigator_0	
	;verificam pe diagonala secundare				
	diagonala_2:
	xor edx, edx
	mov esi, 2
	xor eax, eax
	mov al, vector[2]
	cmp eax, 0
	je final
	cmp eax, 1
	je avem_x4
	mov ok_verificare, 2
	jmp bucla_diagonala2
	avem_x4:
	mov ok_verificare, 1
	bucla_diagonala2:
		cmp edx, 3
		je afara4
		mov cl, vector[esi]
		cmp eax, ecx
		je bun4
		mov ok_verificare, 0
		jmp final
		bun4:
		inc edx
		add esi, 2
		jmp bucla_diagonala2
	afara4:
	mov linie_castigatoare, 8
	cmp ok_verificare, 1
	je castigator_X
	cmp ok_verificare, 2
	je castigator_0
	castigator_X:
	make_text_macro 'P', area, 400, 160
	make_text_macro 'L', area, 410, 160
	make_text_macro 'A', area, 420, 160
	make_text_macro 'Y', area, 430, 160 
	make_text_macro 'E', area, 440, 160 
	make_text_macro 'R', area, 450, 160 
	make_text_macro 'X', area, 470, 160
	make_text_macro 'W', area, 490, 160
	make_text_macro 'I', area, 500, 160
	make_text_macro 'N', area, 510, 160
	inc scor_X
	jmp final
	castigator_0:
	make_text_macro 'P', area, 400, 160
	make_text_macro 'L', area, 410, 160
	make_text_macro 'A', area, 420, 160
	make_text_macro 'Y', area, 430, 160 
	make_text_macro 'E', area, 440, 160 
	make_text_macro 'R', area, 450, 160 
	make_text_macro '0', area, 470, 160
	make_text_macro 'W', area, 490, 160
	make_text_macro 'I', area, 500, 160
	make_text_macro 'N', area, 510, 160
	inc scor_0
	final:
	cmp ok_verificare, 0
	jne sari_peste
	cmp ordine, 9
	jne sari_peste
	make_text_macro 'E', area, 400, 160
	make_text_macro 'G', area, 410, 160
	make_text_macro 'A', area, 420, 160
	make_text_macro 'L', area, 430, 160
	make_text_macro 'I', area, 440, 160
	make_text_macro 'T', area, 450, 160
	make_text_macro 'A', area, 460, 160
	make_text_macro 'T', area, 470, 160
	make_text_macro 'E', area, 480, 160
	sari_peste:
	cmp linie_castigatoare, 0
	je sfarsit
	cmp linie_castigatoare, 1
	je _1
	cmp linie_castigatoare, 2
	je _2
	cmp linie_castigatoare, 3
	je _3
	cmp linie_castigatoare, 4
	je _4
	cmp linie_castigatoare, 5
	je _5
	cmp linie_castigatoare, 6
	je _6
	cmp linie_castigatoare, 7
	je _7
	cmp linie_castigatoare, 8
	je _8
	_1:
	line_horizontal 205, 122, 135, 0FFFFFFh
	line_horizontal 205, 123, 135, 0FFFFFFh
	line_horizontal 205, 124, 135, 0FFFFFFh
	jmp sfarsit
	_2:
	line_horizontal 205, 172, 135, 0FFFFFFh
	line_horizontal 205, 173, 135, 0FFFFFFh
	line_horizontal 205, 174, 135, 0FFFFFFh
	jmp sfarsit
	_3:
	line_horizontal 205, 222, 135, 0FFFFFFh
	line_horizontal 205, 223, 135, 0FFFFFFh
	line_horizontal 205, 224, 135, 0FFFFFFh
	jmp sfarsit
	_4:
	line_vertical 222, 105, 135, 0FFFFFFh
	line_vertical 223, 105, 135, 0FFFFFFh
	line_vertical 224, 105, 135, 0FFFFFFh
	jmp sfarsit
	_5:
	line_vertical 272, 105, 135, 0FFFFFFh
	line_vertical 273, 105, 135, 0FFFFFFh
	line_vertical 274, 105, 135, 0FFFFFFh
	jmp sfarsit
	_6:
	line_vertical 322, 105, 135, 0FFFFFFh
	line_vertical 323, 105, 135, 0FFFFFFh
	line_vertical 324, 105, 135, 0FFFFFFh
	jmp sfarsit
	_7:
	line_oblica1 206, 105, 135, 0FFFFFFh
	line_oblica1 205, 105, 135, 0FFFFFFh
	line_oblica1 205, 106, 135, 0FFFFFFh
	jmp sfarsit
	_8:
	line_oblica2 340, 106, 135, 0FFFFFFh
	line_oblica2 340, 105, 135, 0FFFFFFh
	line_oblica2 339, 105, 135, 0FFFFFFh
	sfarsit:
	popa
	mov esp, ebp
	pop ebp
	ret
verificare_castigator endp	
	
pune_X_O proc
	push ebp
	mov ebp, esp
	sub esp, 4
	mov eax, [ebp + 8]
	dec eax
	cmp vector[eax], 0
	jne fin
	xor edx, edx
	mov aux, eax 
	mov ebx, 3
	div ebx
	mov edi, edx
	xor edx, edx
	mov ebx, 50
	mul ebx
	mov esi, eax
	mov eax, edi
	xor edx, edx
	mul ebx
	mov edi, eax
	add edi, tabla_x
	add esi, tabla_y
	xor edx, edx
	mov eax, ordine
	mov ebx, 2
	div ebx
	mov eax, aux
	cmp edx, 1
	je pune_x
	macro_my_function 'O', edi, esi
	mov vector[eax], 2
	jmp fin
	pune_x:
	macro_my_function 'X', edi, esi
	mov vector[eax], 1
	fin:
	mov esp, ebp
	pop ebp
	ret
pune_X_O endp

play_again proc
	push ebp
	mov ebp, esp
	call reseteaza_arena
	creeaza_tabla_de_joc
	mov ordine, 0
	call reseteaza_matrice
	mov ok_verificare, 0
	mov linie_castigatoare, 0
	mov esp, ebp
	pop ebp
	ret
play_again endp

restart_game proc
	push ebp
	mov ebp, esp
	call reseteaza_arena
	call reseteaza_matrice
	mov ordine, 0
	mov ok_verificare, 0
	mov linie_castigatoare, 0
	mov mod_joc, 0
	mov scor_0, 0
	mov scor_X, 0
	creeaza_butoane
	mov esp, ebp
	pop ebp
	ret
restart_game endp	
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
evt_click:
	cmp start_OK, 0
	jne butoane
	mov esi, [ebp+arg2]
	cmp esi, start_x
	jl afisare_litere
	cmp esi, start_x+start_size_x
	jg afisare_litere
	mov edi, [ebp+arg3]
	cmp edi, start_y
	jl afisare_litere
	cmp edi, start_y+start_size_y
	jg afisare_litere
	mov start_OK, 1
	call reseteaza_arena
	creeaza_butoane
butoane:
	cmp mod_joc, 0
	jne salt
	mov esi, [ebp+arg2]
	cmp esi, buton1_x
	jl buton2
	cmp esi, buton1_x+buton1_size_x
	jg buton2
	mov edi, [ebp+arg3]
	cmp edi, buton1_y
	jl buton2
	cmp edi, buton1_y+buton1_size_y
	jg buton2
	mov mod_joc, 1
	jmp aici
buton2:
	mov esi, [ebp+arg2]
	cmp esi, buton2_x
	jl aici
	cmp esi, buton2_x+buton2_size_x
	jg aici
	mov edi, [ebp+arg3]
	cmp edi, buton2_y
	jl aici
	cmp edi, buton2_y+buton2_size_y
	jg aici
	mov mod_joc, 2
aici:
	cmp mod_joc, 0
	je afisare_litere
	call reseteaza_arena
	creeaza_tabla_de_joc
	jmp afisare_litere
salt:
	cmp ordine, 9
	je verif_again
	cmp ok_verificare, 0
	jne verif_again
	jmp continuare
verif_again:
	mov esi, [ebp+arg2]
	cmp esi, again_x
	jl verif_restart
	cmp esi, again_x+again_size_x
	jg verif_restart
	mov edi, [ebp+arg3]
	cmp edi, again_y
	jl verif_restart
	cmp edi, again_y+again_size_y
	jg verif_restart
	call play_again
verif_restart:
	mov esi, [ebp+arg2]
	cmp esi, restart_x
	jl afisare_litere
	cmp esi, restart_x+restart_size_x
	jg afisare_litere
	mov edi, [ebp+arg3]
	cmp edi, restart_y
	jl afisare_litere
	cmp edi, restart_y+restart_size_y
	jg afisare_litere
	call restart_game
continuare:
	cmp mod_joc, 1
	je cazul_1 
	mov eax, ordine
	xor edx, edx
	mov ecx, 2
	div ecx
	push [ebp+arg3]
	push [ebp+arg2]
	call afla_patratel
	add esp, 8
	cmp eax, -1
	je afisare_litere
	push eax
	call pune_X_O
	add esp, 4
	call verificare_castigator
	inc ordine
	jmp afisare_litere
cazul_1:
	push [ebp+arg3]
	push [ebp+arg2]
	call afla_patratel
	add esp, 8
	cmp eax, -1
	je afisare_litere
	inc ordine
	push eax
	call pune_X_O
	add esp, 4
	call verificare_castigator
	cmp ordine, 9
	jne afisare_litere
	creeaza_butoane_again_restart
	jmp afisare_litere
evt_timer:
	inc counter
	cmp ok_verificare, 0
	jne afisare_litere
	cmp mod_joc, 2
	jne afisare_litere
	cmp ordine, 9
	jg afisare_litere
	mov eax, ordine
	xor edx, edx
	mov ecx, 2
	div ecx
	cmp edx, 1
	je afisare_litere
	genereaza_random
	push nr_random
	call pune_X_O
	add esp, 4
	inc ordine
	call verificare_castigator
	cmp ordine, 9
	jne afisare_litere
	creeaza_butoane_again_restart
	jmp afisare_litere
afisare_litere:
	cmp ok_verificare, 0
	je ok
	creeaza_butoane_again_restart
	ok:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	; cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	; cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	; cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	;afiseaza nume
	make_text_macro 'F', area, 30 , 100
	make_text_macro 'R', area, 40 , 100
	make_text_macro 'I', area, 50 , 100
	make_text_macro 'N', area, 60 , 100
	make_text_macro 'C', area, 70 , 100
	make_text_macro 'U', area, 80 , 100
	make_text_macro 'I', area, 40 , 120
	make_text_macro 'O', area, 50 , 120
	make_text_macro 'A', area, 60 , 120
	make_text_macro 'N', area, 70 , 120
	make_text_macro 'C', area, 20 , 140
	make_text_macro 'R', area, 30 , 140
	make_text_macro 'I', area, 40 , 140
	make_text_macro 'S', area, 50 , 140
	make_text_macro 'T', area, 60 , 140
	make_text_macro 'I', area, 70 , 140
	make_text_macro 'A', area, 80 , 140
	make_text_macro 'N', area, 90 , 140
	;afisare nume joc
	make_text_macro 'T', area, 220, 30
	make_text_macro 'I', area, 230, 30
	make_text_macro 'C', area, 240, 30
	make_text_macro 'T', area, 260, 30
	make_text_macro 'A', area, 270, 30
	make_text_macro 'C', area, 280, 30
	make_text_macro 'T', area, 300, 30
	make_text_macro 'O', area, 310, 30
	make_text_macro 'E', area, 320, 30

	cmp mod_joc, 1
	jne verif2
	make_text_macro 'P', area, 400, 60
	make_text_macro 'L', area, 410, 60
	make_text_macro 'A', area, 420, 60
	make_text_macro 'Y', area, 430, 60
	make_text_macro 'E', area, 440, 60
	make_text_macro 'R', area, 450, 60
	make_text_macro 'V', area, 470, 60
	make_text_macro 'S', area, 480, 60
	make_text_macro 'P', area, 420, 80
	make_text_macro 'L', area, 430, 80
	make_text_macro 'A', area, 440, 80
	make_text_macro 'Y', area, 450, 80
	make_text_macro 'E', area, 460, 80
	make_text_macro 'R', area, 470, 80
	verif2:
	cmp mod_joc, 2
	jne continue
	make_text_macro 'P', area, 400, 60
	make_text_macro 'L', area, 410, 60
	make_text_macro 'A', area, 420, 60
	make_text_macro 'Y', area, 430, 60
	make_text_macro 'E', area, 440, 60
	make_text_macro 'R', area, 450, 60
	make_text_macro 'V', area, 470, 60
	make_text_macro 'S', area, 480, 60
	make_text_macro 'C', area, 420, 80
	make_text_macro 'O', area, 430, 80
	make_text_macro 'M', area, 440, 80
	make_text_macro 'P', area, 450, 80
	make_text_macro 'U', area, 460, 80
	make_text_macro 'T', area, 470, 80
	make_text_macro 'E', area, 480, 80
	make_text_macro 'R', area, 490, 80
	continue:
	cmp mod_joc, 0
	je sari
	call afiseaza_scor
sari:
	cmp counter, 5
	jne final_draw
	creeaza_buton_start
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start
