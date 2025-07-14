include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA
; definicion de constantes float y enteras
	_float_9999                        	DD	.9999
	_int_1                             	DD	1.0
	_int_10                            	DD	10.0
	_int_2                             	DD	2.0
	_float_2                           	DD	2.
	_float_2_5                         	DD	2.5
	_int_27                            	DD	27.0
	_int_3                             	DD	3.0
	_int_34                            	DD	34.0
	_int_5                             	DD	5.0
	_int_500                           	DD	500.0
	_float_6_0                         	DD	6.0
	_int_9                             	DD	9.0
	_float_99999_99                    	DD	99999.99

; definicion de constantes string
	_strh_3f6361cc                     	DB  "@sdADaSjfla%dfg",'$'
	s@_strh_3f6361cc                  	EQU ($ - _strh_3f6361cc)
	_strh_357861d                      	DB  "a es mas chico o igual a a1",'$'
	s@_strh_357861d                   	EQU ($ - _strh_357861d)
	_strh_e9342091                     	DB  "a es mas grande que a1",'$'
	s@_strh_e9342091                  	EQU ($ - _strh_e9342091)
	_strh_8b8f1e89                     	DB  "asldk  fh sjf",'$'
	s@_strh_8b8f1e89                  	EQU ($ - _strh_8b8f1e89)
	_strh_a17ac89f                     	DB  "d no es mas grande que c. check NOT",'$'
	s@_strh_a17ac89f                  	EQU ($ - _strh_a17ac89f)
	_strh_e04b63a7                     	DB  "muestro hasta que c sea mayor que d",'$'
	s@_strh_e04b63a7                  	EQU ($ - _strh_e04b63a7)
	_strh_52f98c3d                     	DB  "texto",'$'
	s@_strh_52f98c3d                  	EQU ($ - _strh_52f98c3d)
	_strh_b2ba1036                     	DB  "variable1 > d o c > d",'$'
	s@_strh_b2ba1036                  	EQU ($ - _strh_b2ba1036)
	_strh_ed4c6100                     	DB  "variable1 > d y c > d",'$'
	s@_strh_ed4c6100                  	EQU ($ - _strh_ed4c6100)

	@sys_RORD_159                      	DB	"[9-x,x+3,1+1]",'$'

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
	FLD _float_99999_99
	FSTP @usr_a
	FLD _float_2
	FSTP @usr_a
	FLD _float_9999
	FSTP @usr_a1
	FLD _float_6_0
	FSTP @usr_b1
	FLD _int_1
	FLD @usr_b1
	FMUL
	FLD @usr_a
	FADD
	FSTP @usr_x1
	DisplayFloat @usr_x1,2
	newLine 1
	FLD _float_2_5
	FSTP @usr_b1
	FLD _int_10
	FLD @usr_b1
	FDIV
	FLD @usr_a
	FADD
	FSTP @usr_x1
	DisplayFloat @usr_x1,2
	newLine 1
	assignToString _strh_3f6361cc, @usr_b, s@_strh_3f6361cc
	assignToString _strh_8b8f1e89, @usr_p1, s@_strh_8b8f1e89
	FLD @usr_a
	FLD @usr_a1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_48
	displayString _strh_e9342091
	newLine 1
	JMP TAG_50
TAG_48:
	displayString _strh_357861d
	newLine 1
TAG_50:
	FLD _int_5
	FSTP @usr_variable1
	FLD _int_1
	FSTP @usr_d
	FLD _int_2
	FSTP @usr_c
	FLD @usr_variable1
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_71
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_71
	displayString _strh_ed4c6100
	newLine 1
TAG_71:
	FLD _int_3
	FSTP @usr_variable1
	FLD _int_1
	FSTP @usr_d
	FLD _int_2
	FSTP @usr_c
	FLD @usr_variable1
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JA TAG_85
TAG_85:
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JBE TAG_92
	displayString _strh_b2ba1036
	newLine 1
TAG_92:
	FLD _int_1
	FSTP @usr_d
	FLD _int_2
	FSTP @usr_c
	FLD @usr_d
	FLD @usr_c
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JA TAG_105
	displayString _strh_a17ac89f
	newLine 1
TAG_105:
	FLD _int_1
	FSTP @usr_c
	FLD _int_3
	FSTP @usr_d
TAG_111:
	FLD @usr_c
	FLD @usr_d
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE TAG_126
	displayString _strh_e04b63a7
	newLine 1
	FLD @usr_c
	FLD _int_1
	FADD
	FSTP @usr_c
	JMP TAG_111
TAG_126:
	displayString _strh_52f98c3d
	newLine 1
	DisplayInteger @usr_variable1
	newLine 1
	FLD _int_27
	FLD @usr_c
	FSUB
	FSTP @usr_x
	FLD @usr_r
	FLD _int_500
	FADD
	FSTP @usr_x
	FLD _int_34
	FLD _int_3
	FMUL
	FSTP @usr_x
	FLD @usr_z
	FLD @usr_f
	FDIV
	FSTP @usr_x1
	FLD @usr_r
	FLD @usr_j
	FMUL
	FLD _int_2
	FSUB
	FSTP @usr_x
	displayString @sys_RORD_159
	newLine 1

FINAL:
	MOV ah, 1 ; pausa, espera que oprima una tecla
	INT 21h ; AH=1 es el servicio de lectura
	MOV AX, 4C00h ; Sale del Dos
	INT 21h       ; Enviamos la interripcion 21h
END START ; final del archivo.
