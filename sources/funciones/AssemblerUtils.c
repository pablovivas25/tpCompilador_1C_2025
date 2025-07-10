#include <stdio.h>
#include <string.h>   // For strstr, strlen, strncpy
#include <stdlib.h>   // For malloc, realloc, free
#include <stdlib.h> // Para EXIT_FAILURE
#include <ctype.h> // Para isalnum, isalpha
#include "PilaEstaticaASM.h"
#include "AssemblerUtils.h"
#include "funciones.h"

// --- Función de Hashing: DJB2 ---
// Fuente: http://www.cse.yorku.ca/~oz/hash.html
unsigned long hash_string_djb2(const char *str) {
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    return hash;
}

/**
 * @brief Estandariza un nombre de variable para ser compatible con la sintaxis de etiquetas de ensamblador.
 *
 * Reemplaza caracteres no alfanuméricos (excepto el guion bajo) por guiones bajos.
 * Asegura que el nombre no empiece con un dígito.
 * Convierte el nombre a minúsculas (opcional, pero buena práctica para consistencia).
 *
 * @param nombre_original El nombre de la variable a estandarizar.
 * @param tipo El tipo de variable a estandarizar.
 * @return Un nuevo string con el nombre estandarizado. Debe ser liberado con free() por el llamador.
 * Retorna NULL si hay un error de asignación de memoria.
 */
char* estandarizar_nombre_ensamblador(const char* nombre_original, VariableType tipo) {
    // Manejo de nombres nulos o vacíos
    if (nombre_original == NULL || strlen(nombre_original) == 0) {
        char* empty_name_prefix;
        if (tipo == TYPE_INT) {
            empty_name_prefix = "_int_empty";
        } else if (tipo == TYPE_FLOAT) {
            empty_name_prefix = "_float_empty";
        } else if (tipo == TYPE_STRING) {
            empty_name_prefix = "_strh_empty"; // Para string vacío o nulo
        } else {
            empty_name_prefix = "_empty_var";
        }
        char* new_name = strdup(empty_name_prefix);
        if (new_name == NULL) {
            perror("Error de asignacion de memoria para nombre de variable vacia");
        }
        return new_name;
    }

    // Si es un STRING, generamos un nombre basado en el hash
    if (tipo == TYPE_STRING) {
        unsigned long hashed_value = hash_string_djb2(nombre_original);
        // buffer_size: "_strh_" + 16 chars para hash hex (max de unsigned long) + '\0'
        // Un unsigned long es 64 bits, por lo que 16 caracteres hexadecimales.
        size_t buffer_size = strlen("_strh_") + 16 + 1;
        char* hashed_name = (char*)malloc(buffer_size);
        if (hashed_name == NULL) {
            perror("Error de asignacion de memoria para nombre hasheado");
            return NULL;
        }
        // Usamos snprintf para formatear el prefijo y el valor hexadecimal del hash
        snprintf(hashed_name, buffer_size, "_strh_%lx", hashed_value);
        return hashed_name; // Retornamos el nombre hasheado directamente
    }

    // --- Lógica de estandarización original para INT, FLOAT y UNKNOWN ---
    // (Asegurarse que este tamaño sea suficiente para los prefijos y la estandarización)
    // Longitud original + posible prefijo (_int_, _float_) + posible '_' + '\0'
    size_t prefijo_len = 0;
    if (tipo == TYPE_INT) {
        prefijo_len = strlen("_int_");
    } else if (tipo == TYPE_FLOAT) {
        prefijo_len = strlen("_float_");
    }

    // Un tamaño generoso para la mayoría de los casos de estandarización.
    // +2 para '_' inicial + '\0' o similar
    char* nombre_estandarizado = (char*)malloc(strlen(nombre_original) + prefijo_len + 5);
    if (nombre_estandarizado == NULL) {
        perror("Error de asignacion de memoria para el nombre estandarizado");
        return NULL;
    }

    int j = 0; // Índice para nombre_estandarizado

    // --- Agregar prefijo basado en el tipo (solo INT y FLOAT aquí) ---
    if (tipo == TYPE_INT) {
        strcpy(&nombre_estandarizado[j], "_int_");
        j += strlen("_int_");
    } else if (tipo == TYPE_FLOAT) {
        strcpy(&nombre_estandarizado[j], "_float_");
        j += strlen("_float_");
    }

    // --- Lógica de estandarización de caracteres ---
    int i = 0;
    /** Si la cadena original comienza con un dígito o un carácter no alfanumérico/guion_bajo,
     * añadir un '_' inicial (solo si no hay prefijo de tipo ya). isalpha controla si un char es [a-zA-Z]
     * isdigit si un char es [0-9] */
    if (j == 0 && (isdigit(nombre_original[0]) || (!isalpha(nombre_original[0]) && nombre_original[0] != '_'))) {
        nombre_estandarizado[j++] = '_';
    }

    for (i = 0; nombre_original[i] != '\0'; i++) {
        char c = nombre_original[i];
        if (isalnum(c) || c == '_') { // isalnum devuelve 0 si c es [a-zA-Z0-9]
            nombre_estandarizado[j++] = tolower(c);
        } else {
            // Reemplazar caracteres no válidos con un guion bajo,
            // evitando guiones bajos consecutivos si ya hay uno.
            if (j > 0 && nombre_estandarizado[j-1] != '_') {
                nombre_estandarizado[j++] = '_';
            }
        }
    }

    // Eliminar guiones bajos finales
    while (j > 0 && nombre_estandarizado[j-1] == '_') {
        j--;
    }
    nombre_estandarizado[j] = '\0'; // Asegurar terminador nulo

    // Manejar caso de nombre resultante solo con "_"
    if (strcmp(nombre_estandarizado, "_") == 0 && strlen(nombre_original) > 0) {
        free(nombre_estandarizado);
        if (tipo == TYPE_INT) {
            return strdup("_int_renamed_var");
        } else if (tipo == TYPE_FLOAT) {
            return strdup("_float_renamed_var");
        } else { // Para UNKNOWN (STRING ya se maneja arriba)
            return strdup("_renamed_var");
        }
    }
    return nombre_estandarizado;
}

// Función para verificar si un string comienza con un prefijo
int startsWith(const char *str, const char *prefix) {
    // 1. Obtener la longitud del prefijo
    size_t prefix_len = strlen(prefix);
    // 2. Obtener la longitud de la cadena principal
    size_t str_len = strlen(str);

    // 3. Si la cadena principal es más corta que el prefijo,
    //    es imposible que comience con ese prefijo.
    if (str_len < prefix_len) {
        return 0; // Falso
    }

    // 4. Comparar los primeros 'prefix_len' caracteres
    //    Si son idénticos, strncmp devuelve 0.
    if (strncmp(str, prefix, prefix_len) == 0) {
        return 1; // Verdadero
    } else {
        return 0; // Falso
    }
}

int es_operador(char* elemento) {
	if (strcmp(elemento, "+")==0) {
		return 1;
	} else if (strcmp(elemento, "-")==0) {
		return 2;
	} else if (strcmp(elemento, "*")==0) {
		return 3;
	} else if (strcmp(elemento, "/")==0) {
		return 4;
	} else if (strcmp(elemento, "=:")==0) {
		return 5;
	} else if (strcmp(elemento, "write")==0) {
        return 6;
	} else if (strcmp(elemento, "CMP")==0) {
        return 6;
	}
	return 0;
}

VariableType get_std_type(const char* type_in_str) {
    if (strcmp(type_in_str, "CTE_STRING")==0) {
        return TYPE_STRING;
    } else if (strcmp(type_in_str, "CTE_FLOAT")==0) {
        return TYPE_FLOAT;
    } else if (strcmp(type_in_str, "CTE_INTEGER")==0) {
        return TYPE_INT;
    }
    return TYPE_UNKNOWN;
}

char* get_jump(char* operador) {
	if (strcmp(operador, "BLT")==0) {
        return ("JB");
    } else if (strcmp(operador, "BLE")==0) {
        return ("JBE");
    } else if (strcmp(operador, "BGT")==0) {
        return ("JA");
    } else if (strcmp(operador, "BGE")==0) {
        return ("JAE");
    } else if (strcmp(operador, "BEQ")==0) {
        return ("JE");
    } else if (strcmp(operador, "BNE")==0) {
        return ("JNE");
    }
    return NULL;
}

void agregar_operando(FILE* archivo, tList *ptrTS, const char* operando) {
    if (startsWith(get_type_in_ts(ptrTS,operando), "CTE_")==0) { //FALSO
        fprintf(archivo, "\tFLD @usr_%s\n",operando);
    } else {
        fprintf(archivo, "\tFLD %s\n",estandarizar_nombre_ensamblador(operando, get_std_type(get_type_in_ts(ptrTS,operando))));
    }
}

int generar_assembler(tList *ptrTS, char **polaca, int rpn_size) {
    if (rpn_size>0) {
        printf("La polaca tiene %d ELEMENTOS\n\n",rpn_size);
    } else {
        printf("La polaca NO tiene ELEMENTOS: size %d\n\n",rpn_size);
        return EXIT_FAILURE;
    }

    const char *nombre_archivo = "asm/Final.asm";
    printf("Intentando abrir/crear y limpiar el archivo '%s'...\n", nombre_archivo);

    // Abrir el archivo en modo "w" (write)
    // "w" crea el archivo si no existe, o lo trunca si existe.
    FILE* archivo = fopen(nombre_archivo, "w");

    // Verificar si el archivo se abrió/creó correctamente
    if (archivo == NULL) {
        perror("Error al abrir o crear el archivo"); // Muestra un mensaje de error del sistema
        return EXIT_FAILURE; // Sale del programa con un código de error
    }

    /** BEGIN HEADER DE PROGRAMA */
    fprintf(archivo, "include macros2.asm\n"
					 "include number.asm\n\n"
					 ".MODEL  LARGE\n"
					 ".386\n"
					 ".STACK 200h\n\n"
					 "MAXTEXTSIZE equ 50\n\n"
					 ".DATA\n");

    /** CARGAR LA DEFINICION DE DATOS - SE LEE DESDE LA TS - TABLA DE SIMBOLOS */
    fprintf(archivo, "; definicion de constantes float y enteras\n");
    tList *tmpTS = ptrTS;
    while (*tmpTS) {
        if (strcmp((*tmpTS)->dataType, "CTE_FLOAT")==0) {
#ifdef DEBUG_MODE
        printf("DEBUG: GENERADO %s value(%s), type(%s)\n", (*tmpTS)->name, (*tmpTS)->value, (*tmpTS)->dataType);
#endif // DEBUG_MODE
            
            fprintf(archivo, "\t%-35s	DD	%s\n", estandarizar_nombre_ensamblador((*tmpTS)->value, TYPE_FLOAT),(*tmpTS)->value);
        } else if (strcmp((*tmpTS)->dataType, "CTE_INTEGER")==0) {
#ifdef DEBUG_MODE
        printf("DEBUG: GENERADO %s value(%s), type(%s)\n", (*tmpTS)->name, (*tmpTS)->value, (*tmpTS)->dataType);
#endif // DEBUG_MODE
            fprintf(archivo, "\t%-35s	DD	%s.0\n", estandarizar_nombre_ensamblador((*tmpTS)->value, TYPE_INT),(*tmpTS)->value);
        }
        tmpTS = &(*tmpTS)->next;
    }
    fprintf(archivo, "\n"); // FIN DE CONSTANTES ENTERAS Y FLOTANTES

    /** CONSTANTES STRING */
    fprintf(archivo, "; definicion de constantes string\n");
    tmpTS = ptrTS;
    char *tmpVar;
    char varName[80] = "";
    while (*tmpTS) {
        
        if (strcmp((*tmpTS)->dataType, "CTE_STRING")==0) {  
#ifdef DEBUG_MODE
        printf("DEBUG: ESTE ES %s value(%s), type(%s)\n", (*tmpTS)->name, (*tmpTS)->value, (*tmpTS)->dataType);
#endif // DEBUG_MODE

            varName[0]='"';
            varName[1]='\0';
            strcat(varName, (*tmpTS)->value);
            strcat(varName, "\"");
            tmpVar=estandarizar_nombre_ensamblador(varName, TYPE_STRING);
            fprintf(archivo, "\t%-35s\tDB  %s,'$'\n", tmpVar, varName);
            fprintf(archivo, "\ts@%-32s\tEQU ($ - %s)\n", tmpVar, tmpVar);
        } 
        tmpTS = &(*tmpTS)->next;
    }
    fprintf(archivo, "\n"); // FIN DE CONSTANTES STRING

    fprintf(archivo, "; definicion de variables\n");
    tmpTS = ptrTS;
    while (*tmpTS) {
        if (strcmp((*tmpTS)->dataType, "STRING")==0) {           
#ifdef DEBUG_MODE
        printf("DEBUG: ESTa ES %s type(%s)\n", (*tmpTS)->name, (*tmpTS)->dataType);
#endif // DEBUG_MODE
            fprintf(archivo, "\t@usr_%-30s\tDB	MAXTEXTSIZE dup (?),'$'\n", (*tmpTS)->name); /** DECLARACIÓN DE Asignación a STRING*/
        } else if (strcmp((*tmpTS)->dataType, "FLOAT")==0 || strcmp((*tmpTS)->dataType, "INTEGER")==0) {
#ifdef DEBUG_MODE
        printf("DEBUG: ESTa ES %s type(%s)\n", (*tmpTS)->name, (*tmpTS)->dataType);
#endif // DEBUG_MODE
            fprintf(archivo, "\t@usr_%-30s\tDD  ?\n", (*tmpTS)->name);
        }
        tmpTS = &(*tmpTS)->next;
    }

    /** ############################################################ */
    PilaEstatica pilaASM;
    int capacidad_pila = 1000; // Definimos una capacidad fija de 1000 elementos

    inicializarPila(&pilaASM, capacidad_pila);
    /** Empezar a trabajar sobre la polaca */
    fprintf(archivo, "\n.CODE\n");
    fprintf(archivo, "START:\n"
            "\tMOV AX,@DATA\n"
            "\tMOV DS,AX\n"
            "\tMOV ES,AX\n"
            "\tFINIT; Inicializa el coprocesador\n");
	int salto=-1;
	int codeOperador;
    int i;
    tmpTS = ptrTS;
    for (i=0; i<rpn_size; i++) {
        // Escribir algo en el archivo
		if (salto==i) {
			fprintf(archivo, "TAG_%d:\n",i);
			salto=-1;
		}
		codeOperador=es_operador(polaca[i]);
        if (codeOperador) {
			char *priOp;
			char *segOp;
			if (codeOperador == 5) { // operador de asignación '=:'
				priOp=pop(&pilaASM);
				segOp=pop(&pilaASM);
				if (strcmp(get_type_in_ts(tmpTS,priOp), "STRING")==0) {
                    /** Forma de asignar una constante a una variabla
                      * assignToString _cte_str, @usr_b, s@_cte_str: macro en macros2.asm
                      * _cte_str: constante declarada en el espacio de datos
                      * @usr_b: variable de usuario a la que se asigna el string
                      * s@_cte_str: size de la constante string, necesario para realizar la asignacion. */
                    tmpVar=estandarizar_nombre_ensamblador(segOp, get_std_type(get_type_in_ts(tmpTS,segOp)));
                    fprintf(archivo, "\tassignToString %s, @usr_%s, s@%s\n",tmpVar,priOp,tmpVar);
				} else {
				    if (strcmp(segOp, "@tmp")==0) {
                        fprintf(archivo, "\tFSTP @usr_%s\n",priOp);
				    } else {
                        fprintf(archivo, "\tFLD %s\n",estandarizar_nombre_ensamblador(segOp,get_std_type(get_type_in_ts(tmpTS,segOp))));
                        fprintf(archivo, "\tFSTP @usr_%s\n",priOp);
                        // fprintf(archivo, "\tFFREE\n"); // no es necesario
				    }
				}
			} else if (codeOperador>=1&&codeOperador<=4) { // si son los operadores '+', '-', '*' y '/'
			    segOp=pop(&pilaASM);
			    priOp=pop(&pilaASM);
			    if (strcmp(priOp, "@tmp")==0) {
                    //fprintf(archivo, "\tFLD @usr_%s\n",segOp);
                    agregar_operando(archivo, tmpTS, segOp);
			    } else {
                    //fprintf(archivo, "\tFLD @usr_%s\n",priOp);
                    //fprintf(archivo, "\tFLD @usr_%s\n",segOp);
                    agregar_operando(archivo, tmpTS, priOp);
                    agregar_operando(archivo, tmpTS, segOp);
			    }
			    switch(codeOperador) {
                    case 1: fprintf(archivo, "\tFADD\n"); break;
                    case 2: fprintf(archivo, "\tFSUB\n"); break;
                    case 3: fprintf(archivo, "\tFMUL\n"); break;
                    case 4: fprintf(archivo, "\tFDIV\n"); break;
                    default:
                        printf("operación desconocida!");
                        exit(1);
                }
                push(&pilaASM, "@tmp");
			} else if (strcmp(polaca[i], "write")==0) {
				priOp=pop(&pilaASM);
				char *var_type=get_type_in_ts(tmpTS,priOp);
                //printf("obtuve (%s) para la variable %s\n", var_type, priOp);
				if (strcmp(var_type, "STRING")==0) {
                    fprintf(archivo, "\tdisplayString @usr_%s\n\tnewLine 1\n",priOp);	// standardize var.
				} else if (strcmp(var_type, "FLOAT")==0) {
                    fprintf(archivo, "\tDisplayFloat @usr_%s,2\n\tnewLine 1\n",priOp);	// standardize var.
				} else if (strcmp(var_type, "INTEGER")==0) {
                    fprintf(archivo, "\tDisplayInteger @usr_%s\n\tnewLine 1\n",priOp);	// standardize var.
				} else {
                    fprintf(archivo, "\tdisplayString %s\n\tnewLine 1\n",estandarizar_nombre_ensamblador(priOp, get_std_type(get_type_in_ts(tmpTS,priOp))));	// standardize var.
				}

			} else if (strcmp(polaca[i], "CMP")==0) {
			    segOp=pop(&pilaASM);
			    priOp=pop(&pilaASM);
			    /** ; OPERACIONES AL LEER CMP
                FLD	x	; ST(0) = x
                FLD y	; ST(0) = y ST(1) = X

                FXCH	; intercambio 0 y 1
                FCOM	; compara ST(0) con ST(1)
                FSTSW AX	; mueve los bits c3 y c0 a FLAGS
                SAHF*/
                agregar_operando(archivo, tmpTS, priOp);
                agregar_operando(archivo, tmpTS, segOp);

				fprintf(archivo, "\tFXCH\n\tFCOM\n\tFSTSW AX\n\tSAHF\n");
				i++; // me posiciono en el siguiente elemento
				char* tipo_salto = get_jump(polaca[i]);
				i++;
				fprintf(archivo, "\t%s TAG_%s\n",tipo_salto,polaca[i]);
				salto=atoi(polaca[i]);
			} else {
				priOp=pop(&pilaASM);
				segOp=pop(&pilaASM);
				fprintf(archivo, "\t%s\n",priOp);
			}
            fflush(archivo);
        } else if (strcmp(polaca[i], "BI")==0) {
			i++;
			fprintf(archivo, "\tJMP TAG_%s\n",polaca[i]);
			salto=atoi(polaca[i]);
			fprintf(archivo, "TAG_%d:\n",i+1);
		} else if (strcmp(polaca[i], "ET")==0) {
            fprintf(archivo, "TAG_%d:\n",i);
        } else {
            push(&pilaASM, polaca[i]);
        }
    }
    if (salto==i) {
        fprintf(archivo, "TAG_%d:\n",i);
        salto=-1;
    }

    fprintf(archivo,"\nFINAL:\n"
                    "\tMOV ah, 1 ; pausa, espera que oprima una tecla\n"
                    "\tINT 21h ; AH=1 es el servicio de lectura\n"
                    "\tMOV AX, 4C00h ; Sale del Dos\n"
                    "\tINT 21h       ; Enviamos la interripcion 21h\n"
                    "END START ; final del archivo.\n");

    printf("Ensamble Completo generado exitosamente en '%s'.\n", nombre_archivo);

    // Es crucial cerrar el archivo para guardar los cambios y liberar recursos
    fclose(archivo);
    printf("Archivo cerrado. Puedes verificar su contenido.\n");
    return EXIT_SUCCESS;
}