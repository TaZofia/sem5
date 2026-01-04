#ifndef TYPES_H
#define TYPES_H

typedef struct {
    int is_num;     // 1 = liczba, 0 = zmienna
    long long num;
    char* idn;
} Val;

#endif
