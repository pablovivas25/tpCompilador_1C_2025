%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include "y.tab.h"

#define MAX_NUM_16_BITS 65536
#define MAX_CHARACTERS  50
#define LIMIT_FLOAT_INF pow(-1.17549,-38)
#define LIMIT_FLOAT_SUP pow(3.40282,38)

FILE  *yyin;
char *yyltext;

int yyerror(void);

%}

%option noyywrap  
%option yylineno


DIGITO			[0-9]
LETRA			[a-zA-Z]
CTE		        {DIGITO}+
CARACTER        [a-z|A-Z|0-9|=|OP_MAY|OP_MEN|!|:|'|"|+|\-|*|/|@|.|%|?]
CONST_REAL      {DIGITO}+"."{DIGITO}+|{DIGITO}+"."|"."{DIGITO}+
CONST_STRING    {COMILLA}({CARACTER}+|" ")*{COMILLA}
ID			    {LETRA}({LETRA}|{DIGITO})*
OP_AS   		":="
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
PA			    "("
PC			    ")"
LA              "{"
LC              "}"
CA              "["
CC              "]"
COMILLA         ["]
DOS_PUNTOS      [:]
PYC             ";"
COMA            [,]
COMENTARIO_A    "#""+"
COMENTARIO_I    {COMENTARIO_A}({CARACTER}|" ")*{COMENTARIO_C}
COMENTARIO_C    "+""#"
WHILE           "while"|"WHILE"
IF              "IF"|"If"|"if"
ELSE            "else"|"ELSE"|"Else"
INT             "int"|"INT"
FLOAT           "float"|"FLOAT"
STRING          "string"|"STRING"
INIT            "init"|"INIT"
READ            "read"|"READ"
WRITE           "write"|"WRITE"
AND             "AND"|"and"
OR              "OR"|"or"
NOT             "not"|"NOT"
OP_MEN          "<"
OP_MAY          ">"
OP_COMP         "=="
OP_MEN_IGU      {OP_MEN}{=}
OP_MAY_IGU      {OP_MAY}{=}

REORDER					"REORDER"|"reoder"
NEGATIVECALCULATION		"NEGATIVECALCULATION"|"negativeCalculation"

%%

{INT}			{printf("\nLexico --> Int: %s\n", yytext);return INT;}
{FLOAT}         {printf("\nLexico --> Float: %s\n", yytext);return FLOAT;}
{STRING}        {printf("\nLexico --> String: %s\n", yytext);return STRING;}
{OP_SUM}		{printf("\nLexico --> Suma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nLexico --> Asignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		{printf("\nLexico --> Multiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nLexico --> Resta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nLexico --> Division: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nLexico --> ParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nLexico --> ParCierra: %s\n", yytext);return PC;}
{LA}			{printf("\nLexico --> Llave apertura: %s\n", yytext);return LA;}
{LC}			{printf("\nLexico --> Llave cierre: %s\n", yytext);return LC;}
{CA}			{printf("\nLexico --> Corchete apertura: %s\n", yytext);return CA;}
{CC}			{printf("\nLexico --> Corchete cierre: %s\n", yytext);return CC;}
{CICLO}         {printf("\nLexico --> Ciclo: %s\n", yytext);return CICLO;}
{IF}            {printf("\nLexico --> IF: %s\n", yytext);return IF;}
{ELSE}          {printf("\nLexico --> Else: %s\n", yytext);return ELSE;}
{INIT}          {printf("\nLexico --> Init: %s\n", yytext);return INIT;}
{READ}          {printf("\nLexico --> Read: %s\n", yytext);return READ;}
{WRITE}         {printf("\nLexico --> Write: %s\n", yytext);return WRITE;}
{AND}           {printf("\nLexico --> And: %s\n", yytext);return AND;}
{OR}            {printf("\nLexico --> Or: %s\n", yytext);return OR;}
{NOT}           {printf("\nLexico --> Not: %s\n", yytext);return NOT;}
{DOS_PUNTOS}    {printf("\nLexico --> Dos Puntos: %s\n", yytext);return DOS_PUNTOS;}
{COMA}          {printf("\nLexico --> Coma: %s\n", yytext);return COMA;}
{PYC}          {printf("\nLexico --> Punto y coma: %s\n", yytext);return PYC;}

{COMENTARIO_A}  {;}
{COMENTARIO_I}  {;}
{COMENTARIO_C}  {;}

{OP_MEN}        {printf("\nLexico --> Operador Menor: %s\n", yytext);return OP_MEN;}
{OP_MAY}        {printf("\nLexico --> Operador Mayor: %s\n", yytext);return OP_MAY;}
{OP_COMP}       {printf("\nLexico --> Operador Igual: %s\n", yytext);return OP_COMP;}
{OP_MEN_IGU}    {printf("\nLexico --> Operador Menor Igual: %s\n", yytext);return OP_MEN_IGU;}
{OP_MAY_IGU}    {printf("\nLexico --> Operador Mayor Igual: %s\n", yytext);return OP_MAY_IGU;}


// Agregar temas especiales


{ID}			{printf("\nLexico --> Identificador: %s\n", yytext);yylval.strVal = strdup(yytext);return ID;}
{CTE}           {printf("\nLexico --> Cte Int: %s\n", yytext);
                    int value = atoi(strdup(yytext));
                    if( value > MAX_NUM_16_BITS ) {
                        printf("\nLexico --> El entero supera los limites permitidos. \n");
                        exit(1);
                    } else {
                        yylval.strVal = strdup(yytext);
                        return CTE;} }

{CONST_REAL}    {printf("\nLexico --> Constante flotante: %s\n", yytext); 
                    if (atof(yytext) > LIMIT_FLOAT_SUP || atof(yytext) < LIMIT_FLOAT_INF){
                            printf( "\nLexico --> El real supera los limites permitidos. \n");
                            exit(1);
                    } else{
                        yylval.strVal = strdup(yytext);
                        return CONST_REAL; }}

{CONST_STRING}  {printf("\nLexico --> Constante string: %s\n", yytext);
                    if(strlen(yytext) > MAX_CHARACTERS){
                        printf( "\nLexico --> El string supera los limites permitidos. \n");
                        exit(1);
                    } else {
                        yylval.strVal = strdup(yytext);
                        return CONST_STRING; }}

{COMILLA}       {printf("\nLexico --> Comilla: %s\n", yytext); return COMILLA;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			    { printf( "\nLexico -->ERROR LEXICO : Caracter no reconocido, linea de error: %s\n", yytext, yylineno ); exit (0);}
%%