include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA
; definicion de constantes float y enteras
	_9999                              	DD	.9999
	_1                                 	DD	1
	_10                                	DD	10
	_2                                 	DD	2
	_2                                 	DD	2.
	_2_5                               	DD	2.5
	_27                                	DD	27
	_3                                 	DD	3
	_34                                	DD	34
	_5                                 	DD	5
	_500                               	DD	500
	_6_0                               	DD	6.0
	_99999_99                          	DD	99999.99

; definicion de constantes string
	_sdadasjfla_dfg                                   	DB  "@sdADaSjfla%dfg",'$'
	s@_sdadasjfla_dfg                                 	EQU ($ - _sdadasjfla_dfg)
	_hola_mundo                                       	DB  "HOLA MUNDO!",'$'
	s@_hola_mundo                                     	EQU ($ - _hola_mundo)
	_a_es_mas_chico_o_igual_a_a1                      	DB  "a es mas chico o igual a a1",'$'
	s@_a_es_mas_chico_o_igual_a_a1                    	EQU ($ - _a_es_mas_chico_o_igual_a_a1)
	_a_es_mas_grande_que_a1                           	DB  "a es mas grande que a1",'$'
	s@_a_es_mas_grande_que_a1                         	EQU ($ - _a_es_mas_grande_que_a1)
	_asldk_fh_sjf                                     	DB  "asldk  fh sjf",'$'
	s@_asldk_fh_sjf                                   	EQU ($ - _asldk_fh_sjf)
	_d_no_es_mas_grande_que_c_check_not               	DB  "d no es mas grande que c. check NOT",'$'
	s@_d_no_es_mas_grande_que_c_check_not             	EQU ($ - _d_no_es_mas_grande_que_c_check_not)
	_muestro_hasta_que_c_sea_mayor_que_d              	DB  "muestro hasta que c sea mayor que d",'$'
	s@_muestro_hasta_que_c_sea_mayor_que_d            	EQU ($ - _muestro_hasta_que_c_sea_mayor_que_d)
	_var1_grande_que_d_o_c_mas_grande_d               	DB  "var1 grande que d o c mas grande d",'$'
	s@_var1_grande_que_d_o_c_mas_grande_d             	EQU ($ - _var1_grande_que_d_o_c_mas_grande_d)
	_variable1_y_c_son_mas_grandes_que_d              	DB  "variable1 y c son mas grandes que d",'$'
	s@_variable1_y_c_son_mas_grandes_que_d            	EQU ($ - _variable1_y_c_son_mas_grandes_que_d)

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
	FLD _99999_99
	FSTP @usr_a
	FLD _2
	FSTP @usr_a
	FLD _9999
	FSTP @usr_a1
	FLD _6_0
	FSTP @usr_b1
	FLD _1
	FLD @usr_b1
	FMUL
	FLD @usr_a
	FADD
	FSTP @usr_x1
	DisplayFloat @usr_x1,2
	newLine 1
	FLD _2_5
	FSTP @usr_b1
	FLD _10
	FLD @usr_b1
	FDIV
	FLD @usr_a
	FADD
	FSTP @usr_x1
	DisplayFloat @usr_x1,2
	newLine 1
	assignToString _sdadasjfla_dfg, @usr_b, s@_sdadasjfla_dfg
	assignToString _asldk_fh_sjf, @usr_p1, s@_asldk_fh_sjf
	displayString _hola_mundo
	newLine 1
	displayString _a_es_mas_chico_o_igual_a_a1
	newLine 1
	FLD @usr_a
	FLD @usr_a1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_52
	displayString _a_es_mas_grande_que_a1
	newLine 1
	JMP TAG_54
TAG_52:
	displayString _a_es_mas_chico_o_igual_a_a1
	newLine 1
TAG_54:
	FLD _5
	FSTP @usr_variable1
	FLD _1
	FSTP @usr_d
	FLD _2
	FSTP @usr_c
	FLD @usr_variable1
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_75
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_75
	displayString _variable1_y_c_son_mas_grandes_que_d
	newLine 1
TAG_75:
	FLD _3
	FSTP @usr_variable1
	FLD _1
	FSTP @usr_d
	FLD _2
	FSTP @usr_c
	FLD @usr_variable1
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JA TAG_89
TAG_89:
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_96
	displayString _var1_grande_que_d_o_c_mas_grande_d
	newLine 1
TAG_96:
	FLD _1
	FSTP @usr_d
	FLD _2
	FSTP @usr_c
	FLD @usr_d
	FLD @usr_c
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JA TAG_109
	displayString _d_no_es_mas_grande_que_c_check_not
	newLine 1
TAG_109:
	FLD _1
	FSTP @usr_c
	FLD _3
	FSTP @usr_d
TAG_115:
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE TAG_130
	displayString _muestro_hasta_que_c_sea_mayor_que_d
	newLine 1
	FLD @usr_c
	FLD _1
	FADD
	FSTP @usr_c
	JMP TAG_115
TAG_130:
	FLD _27
	FLD @usr_c
	FSUB
	FSTP @usr_x
	FLD @usr_r
	FLD _500
	FADD
	FSTP @usr_x
	FLD _34
	FLD _3
	FMUL
	FSTP @usr_x
	FLD @usr_z
	FLD @usr_f
	FDIV
	FSTP @usr_x1
	FLD @usr_r
	FLD @usr_j
	FMUL
	FLD _2
	FSUB
	FSTP @usr_x

FINAL:
	MOV ah, 1 ; pausa, espera que oprima una tecla
	INT 21h ; AH=1 es el servicio de lectura
	MOV AX, 4C00h ; Sale del Dos
	INT 21h       ; Enviamos la interripcion 21h
END START ; final del archivo.
