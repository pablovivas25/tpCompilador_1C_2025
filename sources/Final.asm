include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA
	_99999_99                          	DD	99999.99
	_99                                	DD	99.
	_9999                              	DD	.9999
	_1                                 	DD	1
	_2                                 	DD	2
	_3                                 	DD	3
	_5                                 	DD	5

	_sdadasjfla_dfg                    	DB  "@sdADaSjfla%dfg",'$'
	s@_sdadasjfla_dfg                 	EQU ($ - _sdadasjfla_dfg)
	_asldk_fh_sjf                      	DB	"asldk  fh sjf",'$'
	s@_asldk_fh_sjf                   	EQU ($ - _asldk_fh_sjf)
	_a_es_mas_grande_que_a1            	DB	"a es mas grande que a1",'$'
	s@_a_es_mas_grande_que_a1         	EQU ($ - _a_es_mas_grande_que_a1)
	_a_es_mas_chico_o_igual_a_a1       	DB	"a es mas chico o igual a a1",'$'
	s@_a_es_mas_chico_o_igual_a_a1    	EQU ($ - _a_es_mas_chico_o_igual_a_a1)
	_variable1_es_mas_grande_que_d_y_c_es_mas_grande_que_d      	DB	"variable1 es mas grande que d y c es mas grande que d",'$'
	s@_variable1_es_mas_grande_que_d_y_c_es_mas_grande_que_d    	EQU ($ - _variable1_es_mas_grande_que_d_y_c_es_mas_grande_que_d)
	_variable1_es_mas_grande_que_d_o_c_es_mas_grande_que_d      	DB	"variable1 es mas grande que d o c es mas grande que d",'$'
	s@_variable1_es_mas_grande_que_d_o_c_es_mas_grande_que_d    	EQU ($ - _variable1_es_mas_grande_que_d_o_c_es_mas_grande_que_d)
	_d_no_es_mas_grande_que_c_check_not                         	DB	"d no es mas grande que c. check NOT",'$'
	s@_d_no_es_mas_grande_que_c_check_not                       	EQU ($ - _d_no_es_mas_grande_que_c_check_not)
	_muestro_hasta_que_c_sea_mayor_que_d                        	DB	"muestro hasta que c sea mayor que d",'$'
	s@_muestro_hasta_que_c_sea_mayor_que_d                      	EQU ($ - _muestro_hasta_que_c_sea_mayor_que_d)

	@usr_a                             	DD  ?
	@usr_b                             	DB	MAXTEXTSIZE dup (?),'$'
	@usr_a1                            	DD  ?
	@usr_c                             	DD  ?
	@usr_d                             	DD  ?
	@usr_variable1                     	DD  ?
	@usr_s1                            	DB	MAXTEXTSIZE dup (?),'$'
	@usr_p1                            	DB  MAXTEXTSIZE dup (?),'$'

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

FINAL:
	MOV ah, 1 ; pausa, espera que oprima una tecla
	INT 21h ; AH=1 es el servicio de lectura
	MOV AX, 4C00h ; Sale del Dos
	INT 21h       ; Enviamos la interripcion 21h
END START ; final del archivo.
