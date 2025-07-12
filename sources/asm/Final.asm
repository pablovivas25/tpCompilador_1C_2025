include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA
; definicion de constantes float y enteras
	_int_1                             	DD	1.0
	_int_2                             	DD	2.0
	_int_3                             	DD	3.0
	_int_9                             	DD	9.0

; definicion de constantes string

	@sys_RORD_0                        	DB	"[9-x,x+3,1+1]",'$'
	@sys_RORD_13                       	DB	"[x+3,1+1,9-x]",'$'
	@sys_RORD_26                       	DB	"[1+1,x+3,9-x]",'$'
	@sys_RORD_39                       	DB	"[r*j-2,+3,-x,+1]",'$'
	@sys_RORD_58                       	DB	"[r*j-2,+3,+1,-x]",'$'
	@sys_RORD_77                       	DB	"[x+3,1+1,9-x,r*j-2]",'$'

; definicion de variables
	@usr_a                             	DD  ?
	@usr_a1                            	DD  ?
	@usr_b                             	DB	MAXTEXTSIZE dup (?),'$'
	@usr_b1                            	DD  ?
	@usr_c                             	DD  ?
	@usr_d                             	DD  ?
	@usr_f                             	DD  ?
	@usr_j                             	DD  ?
	@usr_p1                            	DB	MAXTEXTSIZE dup (?),'$'
	@usr_p2                            	DB	MAXTEXTSIZE dup (?),'$'
	@usr_p3                            	DB	MAXTEXTSIZE dup (?),'$'
	@usr_r                             	DD  ?
	@usr_variable1                     	DD  ?
	@usr_x                             	DD  ?
	@usr_x1                            	DD  ?
	@usr_z                             	DD  ?

.CODE
START:
	MOV AX,@DATA
	MOV DS,AX
	MOV ES,AX
	FINIT; Inicializa el coprocesador
	displayString @sys_RORD_0
	newLine 1
	displayString @sys_RORD_13
	newLine 1
	displayString @sys_RORD_26
	newLine 1
	displayString @sys_RORD_39
	newLine 1
	displayString @sys_RORD_58
	newLine 1
	displayString @sys_RORD_77
	newLine 1

FINAL:
	MOV ah, 1 ; pausa, espera que oprima una tecla
	INT 21h ; AH=1 es el servicio de lectura
	MOV AX, 4C00h ; Sale del Dos
	INT 21h       ; Enviamos la interripcion 21h
END START ; final del archivo.
