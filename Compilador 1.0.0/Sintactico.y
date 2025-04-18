// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "./funciones/funciones.c"
#include "./funciones/pila.c"

int yystopparser=0;
FILE  *yyin;

tList listaTS;
tStack pilaVariables;
tStack pilaTipoDatoVariable;

int yyerror();
int yylex();
extern char* yytext;
extern int yylineno;

%}

%union{
    char* strVal;
}
%token <strVal>CTE
%token <strVal>ID
%token BOOL
%token OP_AS
%token OP_AS_OPERACION
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token <strVal>CONST_REAL
%token <strVal>CONST_STRING
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
%token .

%%

programa:
    sentencia
    |programa sentencia;

sentencia: 
    declaracion_init
    |read
    |write
    |while
    |if
    |asignacion
    |funcion_reorder;
    
funcion_reorder:     
    REORDER PA CA lista_expresiones CC COMA BOOL COMA CTE PC {printf("Sintactico --> funcion reorder\n");};

lista_expresiones:
    lista_expresiones expresion
    |expresion;

asignacion: 
    ID OP_AS expresion {printf("ID = Expresion es ASIGNACION\n");};

declaracion_init:
    declaracion {printf("Bloque declaracion INIT\n");};

declaracion: 
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
    lista_declaracion lista_id DOS_PUNTOS tipo {pushStack(&pilaVariables,"*");}
    |lista_id DOS_PUNTOS tipo {pushStack(&pilaVariables,"*");};

lista_id:
    lista_id COMA ID {pushStack(&pilaVariables,$3);}
    |ID {pushStack(&pilaVariables,$1);};

tipo: 
    INT       {pushStack(&pilaTipoDatoVariable, "INTEGER");}
    |FLOAT    {pushStack(&pilaTipoDatoVariable, "FLOAT");}	
    |STRING   {pushStack(&pilaTipoDatoVariable, "STRING");};

read:
    READ PA ID PC {printf("Sintactico --> READ\n");};

write:
    WRITE PA ID PC {printf("Sintactico --> WRITE\n");}
    |WRITE PA CONST_STRING PC {printf("Sintactico --> WRITE\n");};

while: 
    WHILE PA condicion PC LA programa LC {printf("Sintactico --> WHILE\n");};

if:
    IF PA condicion PC LA programa LC {printf("Sintactico --> IF\n");}
    |IF PA condicion PC LA programa LC ELSE LA programa LC {printf("Sintactico --> IF\n");};

condicion:
    comparacion
    |condicion AND comparacion
    |condicion OR comparacion;
    |NOT comparacion;

comparacion:
    expresion comparador expresion;

comparador:
    OP_MEN
    |OP_MAY
    |OP_COMP
    |OP_MEN_IGU
    |OP_MAY_IGU;

expresion:
    termino {printf("Termino es Expresion\n");}
    |expresion OP_SUM termino {printf("Expresion + Termino es Expresion\n");}
    |expresion OP_RES termino {printf("Expresion - Termino es Expresion\n");};

termino: 
    factor {printf("Factor es Termino\n");}
    |termino OP_MUL factor {printf("Termino * Factor es Termino\n");}
    |termino OP_DIV factor {printf("Termino / Factor es Termino\n");};

factor: 
    ID               {printf("ID es Factor \n");}
    |CTE             {printf("CTE es Factor\n"); insertNumber(&listaTS,$1);}
    |CONST_REAL      {printf("CTE_R es Factor\n"); insertNumber(&listaTS,$1);}
    |CONST_STRING    {printf("CTE_S es Factor\n"); insertString(&listaTS, $1);}
    |PA expresion PC {printf("Expresion entre parentesis es Factor\n");};


%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);    
    }

    printf("\nINICIO DE COMPILACION\n");

    createList(&listaTS);
    createStack(&pilaVariables);
    createStack(&pilaTipoDatoVariable);
    
    yyparse();
   
    crearTS(&listaTS);
    
    printf("\nCOMPILACION EXITOSA\n");

    fclose(yyin);
    return 0;
}

int yyerror(void)
{
  printf("Error Sintactico\n");
  exit (1);
}