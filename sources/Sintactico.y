// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "./funciones/funciones.c"
#include "./funciones/pila.c"
#include "./funciones/RPN.c"
#include "./funciones/AssemblerUtils.h"

enum CLAUSE_LIST {
    IF_CLAUSE,
    WHILE_CLAUSE,
    NOT_CONDITION,
    OR_CONDITION
};

int yystopparser=0;
FILE  *yyin;

tList listaTS;
tStack pilaVariables;
tStack pilaTipoDatoVariable;

char cmpToken[4];
int tmpIndex, tmpIndex2;
int contAND=0, contOR=0;
int contArgREORDER=0;
int contArgCALNEG=0;
int primerNeg=0;
enum CLAUSE_LIST clauseType;

int yyerror();
int yylex();    
extern char* yytext;
extern int yylineno;

int verificar_y_contar_negs(char *);
%}

%union{
    char* strVal;
}
%token <strVal>CTE_INTEGER
%token <strVal>ID
%token <strVal>BOOL
%token OP_AS
%token OP_AS_OPE_ARIT
%token OP_AS_NEG_CALC
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token <strVal>CTE_FLOAT
%token <strVal>CTE_STRING
%token LA
%token LC
%token CA
%token CC
%token COMILLA
%token DOS_PUNTOS
%token COMA
%token PYC
%token COMENTARIO_A
%token COMENTARIO_C
%token COMENTARIO_I
%token WHILE
%token IF
%token ELSE
%token INT
%token FLOAT
%token STRING
%token INIT
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token OP_MEN
%token OP_MAY
%token OP_COMP
%token OP_MEN_IGU
%token OP_MAY_IGU
%token REORDER
%token NEGATIVECALCULATION
%type  <strVal> factor
%type  <strVal> termino
%type  <strVal> expresion
%token .

%%

programa:
    sentencias { 
        crearTS(&listaTS);
        printf("\n################ Reverse Polish Notation ################\n");
        mostrar_polaca();
        printf("#########################################################\n");
        printf(" INICIANDO GENERACIÓN ASM \n");
        generar_assembler(rpn->vector_elements, rpn->vector_index); 
    }
    ;

sentencias:
    sentencia
    | programa sentencia;

sentencia: 
    declaracion
    | read { insertar_en_polaca("read"); }
    | write { insertar_en_polaca("write"); }
    | while
    | seleccion
    | asignacion
    | asignacion_operacion_aritmetica
    | asignacion_negativeCalculation
    | funcion_reorder;

declaracion:
    declaracion_init { printf("Bloque declaracion INIT\n"); };

declaracion_init: 
    INIT LA lista_declaracion LC {
        char dataType[100];
        char variable[100];
        while(!emptyStack(&pilaVariables))
        {
            popStack(&pilaVariables,variable); 
            if(strcmp(variable,"*") == 0)
            {
                popStack(&pilaTipoDatoVariable,dataType);
                popStack(&pilaVariables,variable); 
            }
            insertVariable(&listaTS,variable,dataType);
        }
    };

lista_declaracion: 
    lista_declaracion lista_id DOS_PUNTOS tipo { pushStack(&pilaVariables,"*");}
    | lista_id DOS_PUNTOS tipo { pushStack(&pilaVariables,"*");};

lista_id:
    lista_id COMA ID { pushStack(&pilaVariables,$3);}
    | ID { pushStack(&pilaVariables,$1);};

tipo: 
    INT        { pushStack(&pilaTipoDatoVariable, "INTEGER");}
    | FLOAT    { pushStack(&pilaTipoDatoVariable, "FLOAT");}	
    | STRING   { pushStack(&pilaTipoDatoVariable, "STRING");};

read:
    READ PA ID PC { insertar_en_polaca($3); };

write:
    WRITE PA ID PC { insertar_en_polaca($3); }
    | WRITE PA CTE_STRING PC { insertar_en_polaca($3); };

while:
    WHILE 
    {
        clauseType=WHILE_CLAUSE; 
        tmpIndex=posicion_polaca_actual();
        apilar_indice(tmpIndex);
        insertar_en_polaca("ET");
    }
    PA condicion PC
    LA programa LC 
    {
        insertar_en_polaca("BI"); 
        if (!contAND && !contOR) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 1);
        }

        int i;
        if (contAND>0) {
            for (i=0; i<=contAND;i++) {
                desapilar_indice(&tmpIndex);
                actualizar_polaca(tmpIndex, 1);
            }
        } 
        if (contOR>0) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 1);
            contOR--;
            int offset;
            for (i=0; i<=contOR;i++) {
                desapilar_indice(&tmpIndex);
                // calculo el offset negativo para el salto a la siguiente posición
                offset=tmpIndex-posicion_polaca_actual()+1; 
                actualizar_polaca(tmpIndex, offset);
                invertir_condicion(tmpIndex-1);
            }
        }

        desapilar_indice(&tmpIndex2);   // desapilo la pos salto a ET
        char jumpPos[4];
        sprintf(jumpPos,"%d",tmpIndex2); 
        insertar_en_polaca(jumpPos);
        printf("Sintactico --> WHILE\n");
    };

seleccion:
    IF { clauseType=IF_CLAUSE; contAND=0; contOR=0; }  
    PA condicion PC
    bloque_seleccion;
    

bloque_seleccion: 
    LA programa LC
    {
        if (!contAND && !contOR) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 0);
        }
        
        int i;
        if (contAND>0) {
            for (i=0; i<=contAND;i++) {
                desapilar_indice(&tmpIndex);
                actualizar_polaca(tmpIndex, 0);
            }
        } 
        if (contOR>0) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 0);
            contOR--;
            int offset;
            for (i=0; i<=contOR;i++) {
                desapilar_indice(&tmpIndex);
                // calculo el offset negativo para el salto a la siguiente posición
                offset=tmpIndex-posicion_polaca_actual()+1; 
                actualizar_polaca(tmpIndex, offset);
                invertir_condicion(tmpIndex-1);
            }
        }
        printf("Sintactico --> IF\n");
    }
    | LA programa LC 
    {
        int jumpBI=insertar_en_polaca("BI"); 

        if (!contAND && !contOR) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 1);
        }

        int i;
        if (contAND>0) {
            for (i=0; i<=contAND;i++) {
                desapilar_indice(&tmpIndex);
                actualizar_polaca(tmpIndex, 1);
            }
        } 
        if (contOR>0) {
            desapilar_indice(&tmpIndex);
            actualizar_polaca(tmpIndex, 1);
            contOR--;
            int offset;
            for (i=0; i<=contOR;i++) {
                desapilar_indice(&tmpIndex);
                // calculo el offset negativo para el salto a la siguiente posición
                offset=tmpIndex-posicion_polaca_actual()+1; 
                actualizar_polaca(tmpIndex, offset);
                invertir_condicion(tmpIndex-1);
            }
        }
        
        apilar_indice(jumpBI);
        avanzar_polaca();
    }
    bloque_else
    ;

bloque_else: 
    ELSE LA programa LC
    {
        desapilar_indice(&tmpIndex);
        actualizar_polaca(tmpIndex, 0); 
        printf("Sintactico --> IF-ELSE\n");
    };

condicion:
    comparacion 
    {
        insertar_en_polaca("CMP");
        tmpIndex=insertar_en_polaca(cmpToken);
        apilar_indice(tmpIndex);
        avanzar_polaca();
    }
    | condicion AND comparacion 
    {
        insertar_en_polaca("CMP");
        tmpIndex=insertar_en_polaca(cmpToken);
        apilar_indice(tmpIndex);
        avanzar_polaca();
        contAND++;
    }
    | condicion OR comparacion 
    {
        if (clauseType==IF_CLAUSE) {
            insertar_en_polaca("CMP");
            tmpIndex=insertar_en_polaca(cmpToken);
            apilar_indice(tmpIndex);
            avanzar_polaca();
            contOR++;
        } 
    }
    | { clauseType=NOT_CONDITION; } NOT comparacion
    {
        insertar_en_polaca("CMP");
        tmpIndex=insertar_en_polaca(cmpToken);
        apilar_indice(tmpIndex);
        avanzar_polaca();
    };

comparacion:
    expresion comparador expresion;

comparador:
    OP_MEN       
    {
        if (clauseType==NOT_CONDITION) {
            strcpy(cmpToken,"BLT"); 
        } else {
            strcpy(cmpToken,"BGE");
        }
    }
    | OP_MAY     
    { 
        if (clauseType==NOT_CONDITION) {
            strcpy(cmpToken,"BGT"); 
        } else {
            strcpy(cmpToken,"BLE");
        }
    }
    | OP_COMP    
    {
        if (clauseType==NOT_CONDITION) {
            strcpy(cmpToken,"BEQ"); 
        } else {
            strcpy(cmpToken,"BNE");
        }
    }
    | OP_MEN_IGU 
    {
        if (clauseType==NOT_CONDITION) {
            strcpy(cmpToken,"BLE"); 
        } else {
            strcpy(cmpToken,"BGT");
        }
    }
    | OP_MAY_IGU 
    {
        if (clauseType==NOT_CONDITION) {
            strcpy(cmpToken,"BGE"); 
        } else {
            strcpy(cmpToken,"BLT");
        }
    };

expresion:
    termino {
        $$ = strdup($1);
        printf("Termino es Expresion\n");        
    }
    | expresion OP_SUM termino {
        insertar_en_polaca("+");
        printf("Expresion + Termino es Expresion\n");
        $$ = resolverTipoOperacion($1, $3, "+");
        free($1); free($3);
    }
    | expresion OP_RES termino {
        insertar_en_polaca("-");
        printf("Expresion - Termino es Expresion\n");
        $$ = resolverTipoOperacion($1, $3, "-");
        free($1); free($3);
    };

termino:
    factor {
        $$ = strdup($1);
        printf("Factor es Termino\n");
    }
    | PA expresion PC { printf("Expresion entre parentesis es Factor\n"); }
    | termino OP_MUL factor {
        insertar_en_polaca("*");        
        printf("Termino * Factor es Termino\n");
        $$ = resolverTipoOperacion($1, $3, "*");
        free($1); free($3);
    }
    | termino OP_DIV factor {
        insertar_en_polaca("/");
        printf("Termino / Factor es Termino\n");
        $$ = resolverTipoOperacion($1, $3, "/");
        free($1); free($3);
    };

factor:
    ID
    { 
        insertar_en_polaca($1);
        printf("ID es Factor \n");
        const char* tipo = getTipoDatoVariable(&listaTS, $1);
        if (!tipo) {
            printf("ERROR: Variable '%s' no fue declarada\n", $1);
            exit(1);
        } else {
            $$ = strdup(tipo);
        }
    }
    | CTE_INTEGER
    {
        insertar_en_polaca($1); 
        insertNumber(&listaTS,$1);
        printf("CTE_INTEGER es Factor\n");
        $$ = strdup($1);  // retorno el valor de la constante
    }
    | CTE_FLOAT      
    {
        insertar_en_polaca($1);
        insertNumber(&listaTS,$1);
        printf("CTE_FLOAT es Factor\n");
        $$ = strdup($1); 
    }
    | CTE_STRING
    {
        insertar_en_polaca($1); 
        insertString(&listaTS, $1); 
        printf("CTE_STRING es Factor\n");
        $$ = strdup($1); 
    };
    
asignacion:
    ID OP_AS factor { 
        //recorrerTS(&listaTS);
        
        const char* tipoID = getTipoDatoVariable(&listaTS, $1);
        const char* tipoFactor = getTipoDatoVariable(&listaTS, $3);

        if (tipoID == NULL) {
            printf("ERROR: La variable '%s' no fue declarada.\n", $1);
            exit(1);
        } else if (tipoFactor == NULL) {
            //Si no puedo obtener tipo de dato al procesar el factor quiere decir que es una variable y no fue declarada
            printf("ERROR: El factor '%s' no fue declarado.\n", $3);
            exit(1);
        }
        
        if (tipoID != NULL && tipoFactor != NULL && strcmp(tipoID, tipoFactor) != 0) {
            printf("ERROR: Tipos incompatibles en asignacion: '%s' es %s y '%s' es %s\n", $1, tipoID, $3, tipoFactor);
            exit(1);
        }                
                
        insertar_en_polaca($1);
        insertar_en_polaca("=:");
        printf("ID = factor es ASIGNACION\n");
        free($3);
    };

asignacion_operacion_aritmetica:
    ID OP_AS_OPE_ARIT expresion {

        const char* tipoID = getTipoDatoVariable(&listaTS, $1);
        const char* tipoExpr = $3;

        if (!tipoID) {
            printf("ERROR: La variable '%s' no fue declarada.\n", $1);
            exit(1);
        }

        if (strcmp(tipoID, "STRING") == 0) {
            printf("Asignacion no permitida para el tipo STRING.\n", $1);
            exit(1);
        }
        
        if (strcmp(tipoID, tipoExpr) != 0) {
            printf("ERROR: Tipos incompatibles: '%s' es %s y la expresion es %s\n", $1, tipoID, tipoExpr);
            exit(1);
        }

        insertar_en_polaca($1);
        insertar_en_polaca("=:");
        printf("ID =: expresion es ASIGNACION\n");

        free($3);
    };

asignacion_negativeCalculation:
    ID OP_AS_NEG_CALC NEGATIVECALCULATION 
    { contArgCALNEG=0; primerNeg=0; insertar_en_polaca("NCALC"); }
    PA lista_params PC 
    {
        const char* tipoID = getTipoDatoVariable(&listaTS, $1);
        const char* tipoResultado = (contArgCALNEG % 2 == 0) ? "FLOAT" : "INTEGER";

        char operador[2];
        if (contArgCALNEG%2==0) {
            strcpy(operador, "+");
        } else {
            strcpy(operador, "*");
        }
        contArgCALNEG--;
        while(contArgCALNEG>0) {
            desapilar_indice(&tmpIndex);
            actualizar_elemento_en_polaca(tmpIndex, operador);
            contArgCALNEG--;
        }

        if (!tipoID) {
            printf("ERROR: Variable '%s' no fue declarada.\n", $1);
            exit(1);
        } else if (strcmp(tipoID, tipoResultado) != 0 && !(strcmp(tipoID, "FLOAT") == 0 && strcmp(tipoResultado, "INTEGER") == 0)) {
            printf("ERROR: Tipos incompatibles: '%s' es %s y el resultado es %s\n", $1, tipoID, tipoResultado);
            exit(1);
        }

        insertar_en_polaca($1);
        insertar_en_polaca("=");
        printf("Sintactico --> funcion negativeCalculation\n");
    };

lista_params:
    lista_params COMA CTE_INTEGER 
    | lista_params COMA CTE_FLOAT 
    {
        if (verificar_y_contar_negs($3)) {
            tmpIndex=posicion_polaca_actual();
            if (primerNeg) {
                apilar_indice(tmpIndex); 
                avanzar_polaca();
            } else {
                primerNeg=1;
            }
        }
    }
    | lista_params COMA ID 
    {
        char *value=buscar_en_polaca($3);
        if (verificar_y_contar_negs(value)) {
            tmpIndex=posicion_polaca_actual();
            if (primerNeg) {
                apilar_indice(tmpIndex); 
                avanzar_polaca();
            } else {
                primerNeg=1;
            }
        }
    }
    | CTE_INTEGER
    | CTE_FLOAT 
    { 
        if(verificar_y_contar_negs($1)) {
            primerNeg=1;
        } 
    }
    | ID 
    {
        char *value=buscar_en_polaca($1);
        if(verificar_y_contar_negs(value)) {
            primerNeg=1;
        }
    };

funcion_reorder:     
    REORDER PA 
    {
        insertar_en_polaca("RORD");
        contArgREORDER=0;
        tmpIndex=posicion_polaca_actual();
        apilar_indice(tmpIndex);  
    } CA lista_expresiones CC { eliminar_ultimo_de_polaca();}
    COMA BOOL COMA CTE_INTEGER PC 
    { 
        int sentido; //devuelve 1
        if (strcmp($9,"true")==0) {
            sentido=1;
        } else if (strcmp($9,"false")==0) {
            sentido=0;
        } 

        int posPIVOT=atoi($11);
        if (posPIVOT>contArgREORDER) {
            printf("ERROR en REORDER: EL posición PIVOT no puede exeder la cantidad de ARGUMENTOS!!!\n ");
            exit(1);
        }
        //actualizar_elemento_en_polaca(posPIVOT,"FIN REORD");
        reordenar_polaca(posPIVOT, contArgREORDER, sentido);
        printf("Sintactico --> funcion reorder\n");
    };



lista_expresiones:
    lista_expresiones COMA expresion 
    { 
        contArgREORDER++; 
        tmpIndex=posicion_polaca_actual();
        apilar_indice(tmpIndex);
        if(contArgREORDER!=1)
         insertar_en_polaca(",");
    }
    | expresion 
    { 
        tmpIndex=posicion_polaca_actual();
        apilar_indice(tmpIndex); 
        if(contArgREORDER!=1)
          insertar_en_polaca(",");
    };
    
%%

int verificar_y_contar_negs(char *arg) {
    int floatNegativo=0;
    if (arg[0]=='-') {
        contArgCALNEG++;
        insertar_en_polaca(arg);
        floatNegativo=1;
    }
    return floatNegativo;
}

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        exit (1);
    }

    printf("\nINICIO DE COMPILACION\n");

    init_polaca();

    createList(&listaTS);
    createStack(&pilaVariables);
    createStack(&pilaTipoDatoVariable);
    
    yyparse();
    
    printf("\nCOMPILACION EXITOSA\n");

    fclose(yyin);
    return 0;
}

int yyerror(void)
{
  printf("Error Sintactico\n");
  exit (1);
}