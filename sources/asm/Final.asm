include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA
; definicion de constantes float y enteras
	_float_n_1_5                       	DD	-1.5
	_float_n_2_0                       	DD	-2.0
	_float_n_3_0                       	DD	-3.0
	_float_p_0_0                       	DD	0.0
	_float_p_1_0                       	DD	1.0
	_float_p_2_0                       	DD	2.0
	_float_p_3_5                       	DD	3.5
	_float_p_4_1                       	DD	4.1

; definicion de constantes string


; definicion de variables
	@usr_a                             	DD  ?
	@usr_a1                            	DD  ?
	@usr_b                             	DD  ?
	@usr_b1                            	DD  ?
	@usr_c                             	DD  ?
	@usr_x                             	DD  ?

; definicion de variables NCALC
	@aux                               	DD  ?
	@sumaNeg                           	DD  ?
	@multNeg                           	DD  ?
	@contArgCALNEG                     	DD  ?


.CODE
START:
	MOV AX,@DATA
	MOV DS,AX
	MOV ES,AX
	FINIT; Inicializa el coprocesador
	FLD _float_p_4_1
	FSTP @usr_a
	FLD _float_n_1_5
	FSTP @usr_b
TAG_
	FLD _float_p_0_0
	FSTP @sumaNeg
	FLD _float_p_0_0
	FSTP @contArgCALNEG
	FLD _float_p_1_0
	FSTP @multNeg
	FLD _float_n_2_0
	FLD @sumaNeg
	FADD
	FSTP @sumaNeg
	FLD _float_n_2_0
	FLD @multNeg
	FMUL
	FSTP @multNeg
	FLD @contArgCALNEG
	FLD _float_p_1_0
	FADD
	FSTP @contArgCALNEG
	FLD @usr_a
	FLD _float_p_0_0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE TAG_51
	FLD @usr_a
	FLD @sumaNeg
	FADD
	FSTP @sumaNeg
	FLD @usr_a
	FLD @multNeg
	FMUL
	FSTP @multNeg
	FLD @contArgCALNEG
	FLD _float_p_1_0
	FADD
	FSTP @contArgCALNEG
TAG_51:
	FLD @usr_b
	FLD _float_p_0_0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE TAG_71
	FLD @usr_b
	FLD @sumaNeg
	FADD
	FSTP @sumaNeg
	FLD @usr_b
	FLD @multNeg
	FMUL
	FSTP @multNeg
	FLD @contArgCALNEG
	FLD _float_p_1_0
	FADD
	FSTP @contArgCALNEG
TAG_71:
	FLD _float_n_3_0
	FLD @sumaNeg
	FADD
	FSTP @sumaNeg
	FLD _float_n_3_0
	FLD @multNeg
	FMUL
	FSTP @multNeg
	FLD @contArgCALNEG
	FLD _float_p_1_0
	FADD
	FSTP @contArgCALNEG
	FLD @contArgCALNEG
	FLD _float_p_2_0
	FXCH ST(1)
	FPREM
	FSTP @aux
	FLD @aux
	FLD _float_p_0_0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE TAG_101
	FSTP @sumNeg
	FSTP @usr_x
	JMP TAG_104
TAG_101:
	FSTP @multNeg
	FSTP @usr_x
TAG_104:

FINAL:
	MOV ah, 1 ; pausa, espera que oprima una tecla
	INT 21h ; AH=1 es el servicio de lectura
	MOV AX, 4C00h ; Sale del Dos
	INT 21h       ; Enviamos la interripcion 21h
END START ; final del archivo.
