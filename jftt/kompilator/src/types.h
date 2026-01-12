#ifndef TYPES_H
#define TYPES_H


/* Struktura przekazywana z leksera do parsera dla identyfikatorów */
/* Pozwala obsłużyć x, tab[5] oraz tab[i] w jednolity sposób */
typedef struct {
    char name[64];
    int access_type;       // 0=zmienna, 1=tab[stała], 2=tab[zmienna]
    long long idx_const;   // dla tab[5]
    char idx_var[64];      // dla tab[i]
} IdInfo;

typedef struct {
    int is_num;     // 1 = liczba, 0 = zmienna
    long long num;
    IdInfo* id_info;
} Val;


#endif
