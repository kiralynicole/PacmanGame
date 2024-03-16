.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf:proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "PACMAN",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer
counterscor DD 0 ; numara scorul

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include picture.inc
include pacman.inc
include fantoma1.inc


;-----------START-----------
button_x equ 250
button_y equ 130
button_size equ 80

;---------------------------------declaratii variabile-----------------------------------

;CLICK
firstclick dd  0

;-----------------------------------------PACMAN---------------------------------
x_pacman dd 230
y_pacman dd 360

pacman_height equ 20
pacman_width equ 20

;-----------------------------------GHOST----------------------------------
x_fantoma1 dd 490
y_fantoma1 dd 387

x_fantoma2 dd 363
y_fantoma2 dd 176

x_fantoma3 dd 161
y_fantoma3 dd 32

fantoma1_height equ 20
fantoma1_width equ 20

;-----------------------------------contur-----------------------------------
contur_size equ 410

fantoma1_mutari dd 20 dup(0)

fantoma2_mutari dd 20 dup(0)

fantoma3_mutari dd 20 dup(0)


.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
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
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
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

make_ghost proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ;citim simbolul de afisat
	sub eax, '0'
	lea esi, fantoma1
	
	draw_text:
	mov ebx, fantoma1_width
	mul ebx
	mov ebx, fantoma1_height
	mul ebx
	mov ebx, 4
	mul ebx     
	add esi, eax   
	mov ecx, fantoma1_height
	
	bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, fantoma1_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, fantoma1_width
	
	bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	
	mov eax, dword ptr [esi]
	mov dword ptr[edi], eax
	jmp simbol_pixel_next
	
	simbol_pixel_next:
	add esi, 4
	add edi, 4
	
	loop bucla_simbol_coloane
	
	pop ecx
	
loop bucla_simbol_linii

	popa
	mov esp, ebp
	pop ebp
	ret
make_ghost endp


make_pacman proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ;citim simbolul de afisat
	sub eax, '0'
	lea esi, pacman
	
	draw_text:
	mov ebx, pacman_width
	mul ebx
	mov ebx, pacman_height
	mul ebx
	mov ebx, 4
	mul ebx     ;eax=pacman_height * pacman_width * 4
	add esi, eax    ;esi=pacman
	mov ecx, pacman_height
	
	bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, pacman_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, pacman_width
	
	bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	
	mov eax, dword ptr [esi]
	mov dword ptr[edi], eax
	jmp simbol_pixel_next
	
	simbol_pixel_next:
	add esi, 4
	add edi, 4
	
	loop bucla_simbol_coloane
	
	pop ecx
	
loop bucla_simbol_linii

	popa
	mov esp, ebp
	pop ebp
	ret
make_pacman endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_pacman_macro macro symbol , drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_pacman
	add esp, 16
endm

make_ghost_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_ghost
	add esp, 16
endm


line_horizontal macro x, y, len, color
local bucla_linie
   MOV eax, y;EAX = y*area_width
   mov ebx, area_width
   mul ebx ; eax = y *area_width
   add eax, x ;eax = y*area_width + x
   shl eax, 2 ; eax = (y *area_width + x) *4
   add eax, area
   mov ecx, len
   
 bucla_linie:
   mov dword ptr [eax], color
   add eax, 4
   loop bucla_linie
   endm
	
	
line_vertical macro x, y, len, color
local bucla_linie
   MOV eax, y  ;EAX = y*area_width
   mov ebx, area_width
   mul ebx ; eax = y *area_width
   add eax, x ;eax = y*area_width + x
   shl eax, 2 ; eax = (y *area_width + x) *4
   add eax, area
   mov ecx, len
   
 bucla_linie:
   mov dword ptr [eax], color
   add eax, area_width * 4
   loop bucla_linie
    endm
	
patrat_plin macro x, y, len, color
local bucla_linie
local eticheta
   MOV eax, y  ;EAX = y*area_width
   mov ebx, area_width
   mul ebx ; eax = y *area_width
   add eax, x ;eax = y*area_width + x
   shl eax, 2 ; eax = (y *area_width + x) *4
   add eax, area
   mov ecx, len
   mov ebx, len
   shl ebx, 2  ;ebx = 4*len
   mov edx, len
   
 eticheta:
 mov ecx, len
 
bucla_linie:
   mov dword ptr [eax], color
   add eax, 4
   loop bucla_linie
   
   sub eax, ebx
   add eax, area_width * 4 
   dec edx
   cmp edx, 0
   jne eticheta
  
endm

proc_is_safe proc
	push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_pacman
	mul ebx
	add eax, x_pacman
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0001EFFh
			je not_safe
			
			inc ecx
		cmp ecx, pacman_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, pacman_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_is_safe endp

proc_puncte proc
	push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_pacman
	mul ebx
	add eax, x_pacman
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0
			je black
			
			inc ecx
		cmp ecx, pacman_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, pacman_height
	jl loop_rows
	
	
	white:
		mov eax, 1
		jmp proc_final
	
	black:
		mov eax, 0
		
	proc_final:
	mov esp, ebp
	pop ebp
	ret
proc_puncte endp

proc_ghost proc
	push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_pacman
	mul ebx
	add eax, x_pacman
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0f44336h
			je not_safe
			
			inc ecx
		cmp ecx, pacman_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, pacman_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_ghost endp

proc_pac_1 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma1
	mul ebx
	add eax, x_fantoma1
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0ffeb3bh
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_pac_1 endp

proc_pac_2 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma2
	mul ebx
	add eax, x_fantoma2
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0ffeb3bh
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_pac_2 endp

proc_pac_3 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma3
	mul ebx
	add eax, x_fantoma3
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0ffeb3bh
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_pac_3 endp
	
proc_is_safe_1 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma1
	mul ebx
	add eax, x_fantoma1
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0001EFFh 
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_is_safe_1 endp	

proc_is_safe_2 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma2
	mul ebx
	add eax, x_fantoma2
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0001EFFh 
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_is_safe_2 endp	

proc_is_safe_3 proc
push ebp
	mov ebp, esp
	
	mov eax, area_width
	mov ebx, y_fantoma3
	mul ebx
	add eax, x_fantoma3
	shl eax, 2
	mov esi, area
	add esi, eax
	
	xor ecx, ecx
	loop_rows:
		push ecx
		push esi
		
		mov eax, area_width
		mul ecx
		shl eax, 2
		add esi, eax
		
		xor ecx, ecx
		loop_columns:
			
			lodsd
			cmp eax, 0001EFFh 
			je not_safe
			
			inc ecx
		cmp ecx, fantoma1_width
		jl loop_columns
		
		pop esi
		pop ecx
		inc ecx
	cmp ecx, fantoma1_height
	jl loop_rows
	
	
	safe:
		mov eax, 1
		jmp proc_is_safe_final
	
	not_safe:
		mov eax, 0
		
	proc_is_safe_final:
	mov esp, ebp
	pop ebp
	ret
proc_is_safe_3 endp

proc_right proc
	push ebp
	mov ebp, esp
	pusha
	
	add x_pacman, 4
	call proc_is_safe
	sub x_pacman, 4
	cmp eax, 0
	je proc_right_final
	
	add x_pacman, 4
	call proc_ghost
	sub x_pacman, 4
	cmp eax, 0
	je game_over
	
	add x_pacman, 4
	call proc_puncte
	sub x_pacman, 4
	cmp eax, 0
	jne etc_right
	inc counterscor
	cmp counterscor,179
	je win
	etc_right:
	
	
	make_pacman_macro '0', area, x_pacman, y_pacman
	add x_pacman, 4
	make_pacman_macro '1', area, x_pacman, y_pacman
	
	
	proc_right_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_right endp

proc_left proc
	push ebp
	mov ebp, esp
	pusha
	
	sub x_pacman, 4
	call proc_is_safe
	add x_pacman, 4
	cmp eax, 0
	je proc_left_final
	
	sub x_pacman, 4
	call proc_ghost
	add x_pacman, 4
	cmp eax, 0
	je game_over
	
	sub x_pacman, 4
	call proc_puncte
	add x_pacman, 4
	cmp eax, 0
	jne etc_left
     inc counterscor
	 cmp counterscor,179
	je win
	 etc_left:
	
	make_pacman_macro '0', area, x_pacman, y_pacman
	sub x_pacman, 4
	make_pacman_macro '2', area, x_pacman, y_pacman
	
	proc_left_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_left endp

proc_up proc
	push ebp
	mov ebp, esp
	pusha
	
	sub y_pacman, 4
	call proc_is_safe
	add y_pacman, 4
	cmp eax, 0
	je proc_up_final
	
	sub y_pacman, 4
	call proc_ghost
	add y_pacman, 4
	cmp eax, 0
	je game_over
	
	
	sub y_pacman, 4
	call proc_puncte
	add y_pacman, 4
	cmp eax, 0
	jne etc_up
	inc counterscor
	cmp counterscor,179
	je win
	etc_up:
	
	make_pacman_macro '0', area, x_pacman, y_pacman
	sub y_pacman, 4
	make_pacman_macro '3', area, x_pacman, y_pacman
	
	proc_up_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_up endp

proc_down proc
	push ebp
	mov ebp, esp
	pusha
	
	add y_pacman, 4
	call proc_is_safe
	sub y_pacman, 4
	cmp eax, 0
	je proc_down_final
	
	add y_pacman, 4
	call proc_ghost
	sub y_pacman, 4
	cmp eax, 0
	je game_over
	
	add y_pacman, 4
	call proc_puncte
	sub y_pacman, 4
	cmp eax, 0
	jne etc_down
	inc counterscor
	cmp counterscor,179
	je win
	etc_down:
	
	make_pacman_macro '0', area, x_pacman, y_pacman
	add y_pacman, 4
	make_pacman_macro '4', area, x_pacman, y_pacman
	
	proc_down_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_down endp






proc_right_ghost1 proc
	push ebp
	mov ebp, esp
	pusha
	
	add x_fantoma1, 4
	call proc_is_safe_1
	sub x_fantoma1, 4
	cmp eax, 0
	je proc_right_final
	
	add x_fantoma1, 4
	call proc_pac_1
	sub x_fantoma1, 4
	cmp eax, 0
	je game_over
	
	
	make_ghost_macro '0', area, x_fantoma1, y_fantoma1
	add x_fantoma1, 4
	make_ghost_macro '1', area, x_fantoma1, y_fantoma1
	
	
	proc_right_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_right_ghost1 endp

proc_left_ghost1 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub x_fantoma1, 4
	call proc_is_safe_1
	add x_fantoma1, 4
	cmp eax, 0
	je proc_left_final
	
	sub x_fantoma1, 4
	call proc_pac_1
	add x_fantoma1, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma1, y_fantoma1
	sub x_fantoma1, 4
	make_ghost_macro '1', area, x_fantoma1, y_fantoma1
	
	proc_left_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_left_ghost1 endp

proc_up_ghost1 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub y_fantoma1, 4
	call proc_is_safe_1
	add y_fantoma1, 4
	cmp eax, 0
    je proc_up_ghost1
	
	sub y_fantoma1, 4
	call proc_pac_1
	add y_fantoma1, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma1, y_fantoma1
	sub y_fantoma1, 4
	make_ghost_macro '1', area, x_fantoma1, y_fantoma1
	
	proc_up_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_up_ghost1 endp

proc_down_ghost1 proc
	push ebp
	mov ebp, esp
	pusha
	
	add y_fantoma1, 4
	call proc_is_safe_1
	sub y_fantoma1, 4
	cmp eax, 0
	je proc_down_final
	
	add y_fantoma1, 4
	call proc_pac_1
	sub y_fantoma1, 4
	cmp eax, 0
	je game_over
	
	make_ghost_macro '0', area, x_fantoma1, y_fantoma1
	add y_fantoma1, 4
	make_ghost_macro '1', area, x_fantoma1, y_fantoma1
	
	proc_down_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_down_ghost1 endp



proc_right_ghost2 proc
	push ebp
	mov ebp, esp
	pusha
	
	add x_fantoma2, 4
	call proc_is_safe_2
	sub x_fantoma2, 4
	cmp eax, 0
	je proc_right_final
	
	add x_fantoma2, 4
	call proc_pac_2
	sub x_fantoma2, 4
	cmp eax, 0
	je game_over
	
	
	make_ghost_macro '0', area, x_fantoma2, y_fantoma2
	add x_fantoma2, 4
	make_ghost_macro '1', area, x_fantoma2, y_fantoma2
	
	
	proc_right_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_right_ghost2 endp

proc_left_ghost2 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub x_fantoma2, 4
	call proc_is_safe_2
	add x_fantoma2, 4
	cmp eax, 0
	je proc_left_final
	
	sub x_fantoma2, 4
	call proc_pac_2
	add x_fantoma2, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma2, y_fantoma2
	sub x_fantoma2, 4
	make_ghost_macro '1', area, x_fantoma2, y_fantoma2
	
	proc_left_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_left_ghost2 endp

proc_up_ghost2 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub y_fantoma2, 4
	call proc_is_safe_2
	add y_fantoma2, 4
	cmp eax, 0
    je proc_up_ghost2
	
	sub y_fantoma2, 4
	call proc_pac_2
	add y_fantoma2, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma2, y_fantoma2
	sub y_fantoma2, 4
	make_ghost_macro '1', area, x_fantoma2, y_fantoma2
	
	proc_up_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_up_ghost2 endp

proc_down_ghost2 proc
	push ebp
	mov ebp, esp
	pusha
	
	add y_fantoma2, 4
	call proc_is_safe_2
	sub y_fantoma2, 4
	cmp eax, 0
	je proc_down_final
	
	add y_fantoma2, 4
	call proc_pac_2
	sub y_fantoma2, 4
	cmp eax, 0
	je game_over
	
	make_ghost_macro '0', area, x_fantoma2, y_fantoma2
	add y_fantoma2, 4
	make_ghost_macro '1', area, x_fantoma2, y_fantoma2
	
	proc_down_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_down_ghost2 endp

proc_right_ghost3 proc
	push ebp
	mov ebp, esp
	pusha
	
	add x_fantoma3, 4
	call proc_is_safe_3
	sub x_fantoma3, 4
	cmp eax, 0
	je proc_right_final
	
	add x_fantoma3, 4
	call proc_pac_3
	sub x_fantoma3, 4
	cmp eax, 0
	je game_over
	
	
	make_ghost_macro '0', area, x_fantoma3, y_fantoma3
	add x_fantoma3, 4
	make_ghost_macro '1', area, x_fantoma3, y_fantoma3
	
	
	proc_right_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_right_ghost3 endp

proc_left_ghost3 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub x_fantoma3, 4
	call proc_is_safe_3
	add x_fantoma3, 4
	cmp eax, 0
	je proc_left_final
	
	sub x_fantoma3, 4
	call proc_pac_3
	add x_fantoma3, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma3, y_fantoma3
	sub x_fantoma3, 4
	make_ghost_macro '1', area, x_fantoma3, y_fantoma3
	
	proc_left_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_left_ghost3 endp

proc_up_ghost3 proc
	push ebp
	mov ebp, esp
	pusha
	
	sub y_fantoma3, 4
	call proc_is_safe_3
	add y_fantoma3, 4
	cmp eax, 0
    je proc_up_ghost2
	
	sub y_fantoma3, 4
	call proc_pac_3
	add y_fantoma3, 4
	cmp eax, 0
	je game_over

	
	make_ghost_macro '0', area, x_fantoma3, y_fantoma3
	sub y_fantoma3, 4
	make_ghost_macro '1', area, x_fantoma3, y_fantoma3
	
	proc_up_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_up_ghost3 endp

proc_down_ghost3 proc
	push ebp
	mov ebp, esp
	pusha
	
	add y_fantoma3, 4
	call proc_is_safe_3
	sub y_fantoma3, 4
	cmp eax, 0
	je proc_down_final
	
	add y_fantoma3, 4
	call proc_pac_3
	sub y_fantoma3, 4
	cmp eax, 0
	je game_over
	
	make_ghost_macro '0', area, x_fantoma3, y_fantoma3
	add y_fantoma3, 4
	make_ghost_macro '1', area, x_fantoma3, y_fantoma3
	
	proc_down_final:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_down_ghost3 endp

 proc_move_ghost1 proc
    push ebp
	mov ebp, esp
	pusha

	mov ecx, 0
	push ecx
	add y_fantoma1,4
	call proc_is_safe_1
	pop ecx
	sub y_fantoma1, 4
	cmp eax, 0
	je skip_move_down_1
	mov [fantoma1_mutari + ecx*4], offset proc_down_ghost1
	inc ecx
	
skip_move_down_1:
	sub y_fantoma1,4
	push ecx
	call proc_is_safe_1
	pop ecx
	add y_fantoma1, 4
	cmp eax, 0
	je skip_move_up_1
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_up_ghost1
	inc ecx
	
	
skip_move_up_1:
    add x_fantoma1,4
	push ecx
	call proc_is_safe_1
	pop ecx
	sub x_fantoma1, 4
	cmp eax, 0
	je skip_move_right_1
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	mov [fantoma1_mutari + ecx*4], offset proc_right_ghost1
	inc ecx
	
skip_move_right_1:
 sub x_fantoma1,4
 push ecx
	call proc_is_safe_1
	pop ecx
	add x_fantoma1, 4
	cmp eax, 0
	je skip_move_left_1
	mov [fantoma1_mutari + ecx*4], offset proc_left_ghost1
	inc ecx
	
skip_move_left_1:
    cmp ecx,0
	je final_proc_move_ghost1
    rdtsc
	xor edx,edx
	div ecx
	call [fantoma1_mutari + edx*4]
	final_proc_move_ghost1:
    popa
	mov esp, ebp
	pop ebp
	ret
proc_move_ghost1 endp

	
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click 
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
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
	cmp eax, 3
	jz evt_keyboard   ;s-a apasat o tasta
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere
	
	
evt_click:	
	mov eax, [ebp+arg2]
	cmp eax, button_x
	jl SALT
	cmp eax, button_x + button_size
	jg SALT
	mov eax, [ebp+arg3]
	cmp eax, button_y
	jl SALT
	cmp eax, button_y + button_size
	jg SALT
	
	;s-a dat click in buton
	inc firstclick
	;stergem "start"
	make_text_macro ' ' ,area, 270, 160
	make_text_macro ' ', area, 280, 160
	make_text_macro ' ', area, 290, 160
	make_text_macro ' ', area, 300, 160
	make_text_macro ' ', area, 310, 160

	;eliminare buton
	line_horizontal button_x, button_y, button_size, 0FFFFFFh
    line_horizontal button_x, button_y + button_size, button_size, 0FFFFFFh
	line_vertical button_x, button_y, button_size, 0FFFFFFh
	line_vertical button_x + button_size, button_y, button_size, 0FFFFFFh
	
	
	SALT:
	;afisare scor pe ecran dupa disparitia startului
	make_text_macro 'S', area, 50, 80
	make_text_macro 'C', area, 60, 80
	make_text_macro 'O', area, 70, 80
	make_text_macro 'R', area , 80, 80
	
	 make_pacman_macro '1', area, x_pacman, y_pacman
	 make_ghost_macro '1', area, x_fantoma1, y_fantoma1
	 make_ghost_macro '1', area, x_fantoma2, y_fantoma2
	  make_ghost_macro '1', area, x_fantoma3, y_fantoma3

	
	
	;contur
	line_horizontal 150, 20 , 425, 0001EFFh
    line_horizontal 150, 445, 425, 0001EFFh
	line_vertical 150, 20, 425, 0001EFFh
	line_vertical 575, 20, 425, 0001EFFh
    
	;labirint
	line_horizontal 190, 60, 84, 0001EFFh
	line_horizontal 190, 144 ,84, 0001EFFh
	line_vertical 190, 60, 84, 0001EFFh
	line_vertical 274, 60, 84, 0001EFFh
	
	 line_horizontal 310, 60, 104, 0001EFFh
	 line_horizontal 310, 164, 104, 0001EFFh
	 line_vertical 310, 60, 104, 0001EFFh
	 line_vertical 414, 60, 104, 0001EFFh
	
	line_horizontal 510, 140, 24, 0001EFFh
	line_horizontal 510, 164 ,24, 0001EFFh
	line_vertical 510, 140, 24, 0001EFFh
    line_vertical 534, 140, 24, 0001EFFh
	
	line_horizontal 450, 60, 24, 0001EFFh
	line_horizontal 450, 84, 24, 0001EFFh
	line_vertical 450, 60, 24, 0001EFFh
	line_vertical 474, 60, 24, 0001EFFh
	
	line_horizontal 450,120 ,24, 0001EFFh
	line_horizontal 450, 144,24, 0001EFFh
	line_vertical 450, 120, 24, 0001EFFh
	line_vertical 474, 120, 24, 0001EFFh
	
	line_horizontal 510, 80, 24, 0001EFFh
	line_horizontal 510, 104, 24, 0001EFFh
	line_vertical 510, 80, 24, 0001EFFh
	line_vertical 534, 80,24, 0001EFFh
	
	line_horizontal 230 ,200, 208, 0001EFFh
	line_horizontal 230, 244, 208, 0001EFFh
	line_vertical 230, 200, 44, 0001EFFh
	line_vertical 438, 200, 44, 0001EFFh
	
	
	 line_horizontal 210, 280, 64, 0001EFFh
	 line_horizontal 210, 344, 64, 0001EFFh
	line_vertical 210, 280, 64, 0001EFFh
	 line_vertical 274, 280, 64, 0001EFFh
	
	line_horizontal 310, 280, 124, 0001EFFh
	line_horizontal 310, 404, 124, 0001EFFh
	line_vertical 310, 280, 124, 0001EFFh
	line_vertical 434, 280 , 124, 0001EFFh
	
	
	line_horizontal 470, 200, 63, 0001EFFh
	line_horizontal 470, 244, 63, 0001EFFh
	line_vertical 533, 200 , 44 , 0001EFFh
	line_vertical 470, 200 ,44, 0001EFFh
	
	line_horizontal 470, 280,63 ,0001EFFh
	line_horizontal 470,343,63,0001EFFh
	line_vertical   470,280 , 63,0001EFFh
	line_vertical   533, 280, 63,0001EFFh
	
	;puncte de mancat
	
	patrat_plin 190, 40, 4, 0
	patrat_plin 210, 40, 4, 0
	patrat_plin 230, 40, 4, 0
	patrat_plin 250, 40, 4, 0
	patrat_plin 270, 40, 4, 0
	patrat_plin 290, 40, 4, 0
	patrat_plin 310, 40, 4, 0
	patrat_plin 330, 40, 4, 0
	patrat_plin 350, 40, 4, 0
	patrat_plin 370, 40, 4, 0
	patrat_plin 390, 40, 4, 0
	patrat_plin 410, 40, 4, 0
	patrat_plin 430, 40, 4, 0
	patrat_plin 450, 40, 4, 0
	patrat_plin 470, 40, 4, 0
	patrat_plin 490, 40, 4, 0
	patrat_plin 510, 40, 4, 0
	patrat_plin 530, 40, 4, 0
	patrat_plin 550, 40, 4, 0
	
	patrat_plin 170, 60, 4, 0
	patrat_plin 170, 80, 4, 0
	patrat_plin 170, 100, 4, 0
	patrat_plin 170, 120, 4, 0
	patrat_plin 170, 140, 4, 0
	patrat_plin 170, 160, 4, 0
	patrat_plin 170, 180, 4, 0
	patrat_plin 170, 200, 4, 0
	patrat_plin 170, 220, 4, 0
	patrat_plin 170, 240, 4, 0
	patrat_plin 170, 260, 4, 0
	patrat_plin 170, 280, 4, 0
	patrat_plin 170, 300, 4, 0
	patrat_plin 170, 320, 4, 0
	patrat_plin 170, 340, 4, 0
	patrat_plin 170, 360, 4, 0
	patrat_plin 170, 380, 4, 0
	patrat_plin 170, 400, 4, 0
	patrat_plin 170, 420, 4, 0
	
	patrat_plin 550, 60, 4, 0
	patrat_plin 550, 80, 4, 0
	patrat_plin 550, 100, 4, 0
	patrat_plin 550, 120, 4, 0
	patrat_plin 550, 140, 4, 0
	patrat_plin 550, 160, 4, 0
	patrat_plin 550, 180, 4, 0
	patrat_plin 550, 200, 4, 0
	patrat_plin 550, 220, 4, 0
	patrat_plin 550, 240, 4, 0
	patrat_plin 550, 260, 4, 0
	patrat_plin 550, 280, 4, 0
	patrat_plin 550, 300, 4, 0
	patrat_plin 550, 320, 4, 0
	patrat_plin 550, 340, 4, 0
	patrat_plin 550, 360, 4, 0
	patrat_plin 550, 380, 4, 0
	patrat_plin 550, 400, 4, 0
	patrat_plin 550, 420, 4, 0

	patrat_plin 190, 420, 4, 0
	patrat_plin 210, 420, 4, 0
	patrat_plin 230, 420, 4, 0
	patrat_plin 250, 420, 4, 0
	patrat_plin 270, 420, 4, 0
	patrat_plin 290, 420, 4, 0
	patrat_plin 310, 420, 4, 0
	patrat_plin 330, 420, 4, 0
	patrat_plin 350, 420, 4, 0
	patrat_plin 370, 420, 4, 0
	patrat_plin 390, 420, 4, 0
	patrat_plin 410, 420, 4, 0
	patrat_plin 430, 420, 4, 0
	patrat_plin 450, 420, 4, 0
	patrat_plin 470, 420, 4, 0
	patrat_plin 490, 420, 4, 0
	patrat_plin 510, 420, 4, 0
	patrat_plin 530, 420, 4, 0
	
	patrat_plin 490, 60, 4, 0
	patrat_plin 490, 80, 4, 0
	patrat_plin 490, 100, 4, 0
	patrat_plin 490, 120, 4, 0
	patrat_plin 490, 140, 4, 0
	patrat_plin 490, 160, 4, 0

	patrat_plin 470, 100, 4, 0
	patrat_plin 450, 100, 4, 0
	patrat_plin 430, 100, 4, 0
	
	patrat_plin 430, 80, 4, 0
	patrat_plin 430, 60, 4, 0
	
	patrat_plin 430, 120, 4, 0
	patrat_plin 430, 140, 4, 0
	patrat_plin 430, 160, 4, 0
	patrat_plin 430, 180, 4, 0

	patrat_plin 510, 60, 4, 0
	patrat_plin 530, 60, 4, 0
	
	patrat_plin 290, 60, 4, 0
	patrat_plin 290, 80, 4, 0
	patrat_plin 290, 100, 4, 0
	patrat_plin 290, 120, 4, 0
	patrat_plin 290, 140, 4, 0
	patrat_plin 290, 160, 4, 0
	patrat_plin 290, 180, 4, 0
	
	patrat_plin 190, 160, 4, 0
	patrat_plin 210, 160, 4, 0
	patrat_plin 230, 160, 4, 0
	patrat_plin 250, 160, 4, 0
	patrat_plin 270, 160, 4, 0
	
	patrat_plin 190, 180, 4, 0
	patrat_plin 210, 180, 4, 0
	patrat_plin 230, 180, 4, 0
	patrat_plin 250, 180, 4, 0
	patrat_plin 270, 180, 4, 0
	
	patrat_plin 210, 200, 4, 0
	patrat_plin 210, 220, 4, 0
	patrat_plin 210, 240, 4, 0
	
	patrat_plin 190, 200, 4, 0
	patrat_plin 190, 220, 4, 0
	patrat_plin 190, 240, 4, 0
	patrat_plin 190, 260, 4, 0
	patrat_plin 190, 280, 4, 0
	patrat_plin 190, 300, 4, 0
	patrat_plin 190, 320, 4, 0
	patrat_plin 190, 340, 4, 0
	patrat_plin 190, 360, 4, 0
	patrat_plin 190, 380, 4, 0
	patrat_plin 190, 400, 4, 0
	
	patrat_plin 210, 400, 4, 0
	patrat_plin 230, 400, 4, 0
	patrat_plin 250, 400, 4, 0
	patrat_plin 270, 400, 4, 0
	patrat_plin 290, 400, 4, 0
	
	patrat_plin 510, 120, 4, 0
	patrat_plin 530, 120, 4, 0
	patrat_plin 450, 160, 4, 0
	patrat_plin 470, 160, 4, 0
	
	patrat_plin 210, 260, 4, 0
	patrat_plin 230, 260, 4, 0
	patrat_plin 250, 260, 4, 0
	patrat_plin 270, 260, 4, 0
	patrat_plin 290, 260, 4, 0
	patrat_plin 310, 260, 4, 0
	patrat_plin 330, 260, 4, 0
	patrat_plin 350, 260, 4, 0
	patrat_plin 370, 260, 4, 0
	patrat_plin 390, 260, 4, 0
	patrat_plin 410, 260, 4, 0
	patrat_plin 430, 260, 4, 0
	patrat_plin 450, 260, 4, 0
	patrat_plin 470, 260, 4, 0
	patrat_plin 490, 260, 4, 0
    patrat_plin 510, 260, 4, 0
	patrat_plin 530, 260, 4, 0
	
	patrat_plin 450, 280, 4, 0
	patrat_plin 450, 300, 4, 0
	patrat_plin 450, 320, 4, 0
	patrat_plin 450, 340, 4, 0
	patrat_plin 450, 360, 4, 0
	patrat_plin 450, 380, 4, 0
	patrat_plin 450, 400, 4, 0

	patrat_plin 290, 280, 4, 0
	patrat_plin 290, 300, 4, 0
	patrat_plin 290, 320, 4, 0
	patrat_plin 290, 340, 4, 0
	patrat_plin 290, 360, 4, 0
	patrat_plin 290, 380, 4, 0
	
	patrat_plin 310, 180, 4, 0
	patrat_plin 330, 180, 4, 0
	patrat_plin 350, 180, 4, 0
	patrat_plin 390, 180, 4, 0
	patrat_plin 410, 180, 4, 0
	
	
	patrat_plin 450, 240, 4, 0
	patrat_plin 450, 220, 4, 0
	patrat_plin 450, 200, 4, 0
	patrat_plin 450, 180, 4, 0
	
	patrat_plin 470, 180, 4,0
	patrat_plin 490, 180, 4,0
	patrat_plin 510, 180, 4,0
	patrat_plin 530, 180, 4,0

	patrat_plin 470, 360, 4,0
	patrat_plin 490, 360,4,0
	patrat_plin 510, 360, 4, 0
	patrat_plin 530, 360, 4, 0

	button_fail:
	jmp final
	
evt_timer:
	inc counter
	cmp firstclick, 0
	je afisare_litere
	
	;call proc_right_ghost3
	;call proc_left_ghost2
	
	call proc_move_ghost1
	;call proc_move_ghost2
	
	
	
    
	jmp afisare_litere
	
evt_keyboard:
;move right
;move left
;move up
;move down

 mov eax, [ebp+arg2]
 cmp eax, 'D'
 je move_right
 cmp eax, 'A'
 je move_left
 cmp eax, 'W'
 je move_up
 cmp eax, 'S'
 je move_down

 move_right:
call proc_right
jmp afisare_litere

 move_left:
call proc_left
jmp afisare_litere

 move_up:
call proc_up
jmp afisare_litere

 move_down:
call proc_down
jmp afisare_litere


afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	
	;afisare scor
	 mov ebx,10
	 mov eax, counterscor
	;cifra unitatilor
	 mov edx, 0
	 div ebx
	 add edx, '0'
	 make_text_macro edx, area, 80, 110
	; cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 110
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 60, 110
	
	cmp firstclick,0
    jne final
	
	;scriem un mesaj
	make_text_macro 'S', area, 270, 160
	make_text_macro 'T', area, 280, 160
	make_text_macro 'A', area, 290, 160
	make_text_macro 'R', area, 300, 160
	make_text_macro 'T', area, 310, 160


	line_horizontal button_x, button_y, button_size, 0
	line_horizontal button_x, button_y + button_size, button_size, 0
	line_vertical button_x, button_y, button_size, 0
	line_vertical button_x + button_size, button_y, button_size, 0
	
	final:
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp


draw2 proc
	push ebp
	mov ebp, esp
	pusha

	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere2
	
	
	afisare_litere2:
	make_text_macro 'G', area, 270, 160
	make_text_macro 'A', area, 280, 160
	make_text_macro 'M', area, 290, 160
	make_text_macro 'E', area, 300, 160
	make_text_macro ' ', area, 310, 160
	make_text_macro 'O', area, 320, 160
	make_text_macro 'V', area, 330, 160
	make_text_macro 'E', area, 340, 160
	make_text_macro 'R', area, 350, 160
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw2 endp

draw3 proc
	push ebp
	mov ebp, esp
	pusha

	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere2
	
	
	afisare_litere2:
	make_text_macro 'Y', area, 270, 160
	make_text_macro 'O', area, 280, 160
	make_text_macro 'U', area, 290, 160
	make_text_macro ' ', area, 300, 160
	make_text_macro 'W', area, 310, 160
	make_text_macro 'O', area, 320, 160
	make_text_macro 'N', area, 330, 160
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw3 endp



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
	jmp finalll
	
	game_over:
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
	push offset draw2
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	jmp finalll
	
	win:
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
	push offset draw3
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	
	finalll:
	;terminarea programului
	push 0
	call exit
end start