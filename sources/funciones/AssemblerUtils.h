#ifndef ASSEMBLERUTILS_H_INCLUDED
#define ASSEMBLERUTILS_H_INCLUDED
#include "lista.h"

// --- Nueva enumeración para Tipos de Variable ---
typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_UNKNOWN
} VariableType;

int generar_assembler(tList *ptrTS, char **polaca, int rpn_size);

#endif // ASSEMBLERUTILS_H_INCLUDED
