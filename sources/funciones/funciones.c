#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista.h"
#include "funciones.h"

int insertNumber(tList *p, char *lex) 
{
    int result = -1;
    char name[100];

    strcpy(name, "_");
    strcat(name, lex); 

    if(strrchr (lex, '.')) {
        result = insertOrder(p, name, "CTE_FLOAT", lex, 0);
    }
    result = insertOrder(p, name, "CTE_INTEGER", lex, 0);

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

void recorrerTS(tList *p) {
    while(*p)
    {
        printf("|%-25s|%-14s|%-25s|%-10d|\n", (*p)->name, (*p)->dataType, (*p)->value, (*p)->length);
        p = &(*p)->next;
    }
}

/**
 * @brief Busqueda de tipo para validar la compatibilidad de operaciones.
 * Se puede utilizar en cualquier ambito de validación de tipo.
 * @param p Puntero a la estructura de la lista.
 * @param nombreVar Puntero al nombre de la variable que busco.
 */
const char* getTipoDatoVariable(tList *p, const char* nombreVar) {

    char nombreCTE[100];
    strcpy(nombreCTE, "_");
    strcat(nombreCTE, nombreVar); // si nombreVar, _cte(str|float|integer)

    char *dataType;
    while (*p) {
        if (strcmp((*p)->name, nombreVar) == 0 || strcmp((*p)->name, nombreCTE) == 0) {
            // generar equivalencias entre tipos de datos
            if (strcmp((*p)->dataType, "FLOAT") == 0 || strcmp((*p)->dataType, "CTE_FLOAT") == 0)
            {
                return("FLOAT");
            }
            else if (strcmp((*p)->dataType,"INTEGER") == 0 || strcmp((*p)->dataType,"CTE_INTEGER") == 0)
            {
                return("INTEGER");
            }
            else if (strcmp((*p)->dataType,"STRING") == 0 || strcmp((*p)->dataType,"CTE_STRING") == 0)
            {
                return("STRING");
            }
        }
        p = &(*p)->next;
    }
    printf("El parametro no está registrada en TS: %s\n", nombreVar);
    return NULL; // no encontrado
}

/**
 * @brief Busqueda de tipo generar el codigo asm.
 * Se puede llamar en cualquier ambito para obtener el tipo. Devuelve STRING, INTEGER, FLOAT.
 * CTE_STRING, CTE_FLOAT y CTE_INTEGER.
 * @param p Puntero a la estructura de la lista.
 * @param nombreVar Puntero al nombre de la variable que busco.
 */
char* get_type_in_ts(tList *p, const char* nombreVar) {

    char nombreCTE[100];
    char *tmpVarName = strdup(nombreVar);
    strcpy(nombreCTE, "_");
    strcat(nombreCTE, deleteCharacter(tmpVarName));
    // busco la variable para determinar el tipo. pregunto por nombreVar||_cte(str|float|integer)
    while (*p) {
        if (strcmp((*p)->name, tmpVarName) == 0 || strcmp((*p)->name, nombreCTE) == 0) { 
            return (*p)->dataType;
        }
        p = &(*p)->next;
    }
    printf("El parametro no está registrada en TS: %s\n", nombreVar);
    return NULL; // no encontrado
}

char* resolverTipoOperacion(const char* tipo1, const char* tipo2, const char* op) {
    if (strcmp(tipo1, "STRING") == 0 || strcmp(tipo2, "STRING") == 0) {
        printf("ERROR: Operacion %s invalida entre STRING y %s.\n", op,
               strcmp(tipo1, "STRING") == 0 ? tipo2 : tipo1);
        exit(1);
    }

    // Si alguno de los dos es FLOAT, el resultado es FLOAT
    if (strcmp(tipo1, "FLOAT") == 0 || strcmp(tipo2, "FLOAT") == 0)
        return strdup("FLOAT");

    // Ambos int
    return strdup("INTEGER");
}