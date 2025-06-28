#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista.c"

#define SUCCESS 1
#define DUPLICATE 2
#define NO_MEMORY 0

int insertVariable(tList *p, char *name, char *dataType); 
int insertString(tList *p, char *name);
char *deleteCharacter(char *lex);
int insertNumber(tList *p, char *lex);
void crearTS(tList *p);

int insertNumber(tList *p, char *lex) 
{
    int result = -1;
    char name[100];

    strcpy(name, "_");
    strcat(name, lex); 

    if(strrchr (lex, '.')) {
        result = insertOrder(p, name, "CTE_FLOAT", lex, 0);
    }
    result = insertOrder(p, name, "CTE_INT", lex, 0);

    if(result == DUPLICATE){
        //printf("Lexema %s ya se ingreso en la tabla de simbolos\n",lex);
        return DUPLICATE;
    }

    return SUCCESS;
}

int insertString(tList *p, char *lex)
{
    int result = -1;
    char name[100];

    char* newName = deleteCharacter(lex);

    strcpy(name, "_");
    strcat(name, newName);

    result = insertOrder(p, name, "CTE_STRING", newName, strlen(newName));

    if(result == DUPLICATE){
        //printf("Lexema %s ya se ingreso en la tabla de simbolos\n",lex);
        return DUPLICATE;
    }

    return SUCCESS;
}

char *deleteCharacter(char *lex)
{
    char* cad = lex;
    char* cadIni = cad;
    while(*lex)
    {
        if(*lex != '"')
        {
            (*cad) = (*lex);
            cad++;
        }
        lex++;
    }
    *cad = '\0';
    return cadIni;
}

int insertVariable(tList *p, char *lex, char *dataType)
{
    int result = -1;

    result = insertOrder(p, lex, dataType, " ", 0);
    if(result == DUPLICATE){
        //printf("Lexema %s ya se ingreso en la tabla de simbolos\n",lex);
        return DUPLICATE;
    }

    return SUCCESS;
}

void crearTS(tList *p)
{
    FILE *pTable = fopen("tabla_de_simbolos.txt", "w+");
    if(!pTable) {
        printf("No se pudo abrir el archivo tabla_de_simbolos.txt \n");
        return;
    }

    printf("_______________________________________________________________________________\n");
    printf("|%-25s|%-14s|%-25s|%-10s|\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");
    printf("_______________________________________________________________________________\n");

    fprintf(pTable, "_______________________________________________________________________________\n");
    fprintf(pTable, "|%-25s|%-14s|%-25s|%-10s|\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");
    fprintf(pTable, "_______________________________________________________________________________\n");

    while(*p)
    {
        printf("|%-25s|%-14s|%-25s|%-10d|\n", (*p)->name, (*p)->dataType, (*p)->value, (*p)->length);
        fprintf(pTable, "|%-25s|%-14s|%-25s|%-10d|\n", (*p)->name, (*p)->dataType, (*p)->value, (*p)->length);
        p = &(*p)->next;
    }

    printf("_______________________________________________________________________________\n");
    fprintf(pTable, "_______________________________________________________________________________\n");
    fclose(pTable);
}