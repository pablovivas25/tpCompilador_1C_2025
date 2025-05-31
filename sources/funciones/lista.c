#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SUCCESS 1
#define DUPLICATE 2
#define NO_MEMORY 0

typedef struct sNode
{
    char name[50];
    char dataType[50];
    char value[50];
    int  length;
    struct sNode* next;
}tNode;

typedef tNode* tList;

void createList(tList *p);
int insertOrder(tList *p, char *name, char *dataType, char *value, int length);

void createList(tList *p)
{
    *p = NULL;
}

int insertOrder(tList *p, char *name, char *dataType, char *value, int length)
{
    int result = -1;
    tNode* nue = (tNode*)malloc(sizeof(tNode));
    
    if(!nue)
        return NO_MEMORY;

    while(*p && strcmp((*p)->name, name) < 0)
        p = &(*p)->next;
    if(*p && strcmp((*p)->name, name) == 0)
        return DUPLICATE;

    strcpy(nue->name, name);
    strcpy(nue->dataType, dataType);
    strcpy(nue->value, value);
    
    nue->length = length;

    nue->next = *p;

    *p = nue;

    return SUCCESS;
}