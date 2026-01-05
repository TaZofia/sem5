// na razie value jest tylko stringiem trzeba potem poprawić żeby mogło być też liczbą. 
// Trzeba stworzyć odpowiedni własny typ

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "types.h"

 // tymczasowy adres do pamięci  
 // będzie symulował komórkę w pamięci przeznaczoną na chwilowe zapisywanie tam stanu obliczeń 
 // musi być po zmiennych
int TMP_ADDR = -1;     
int TMP2_ADDR = -1;


FILE *out;
extern FILE *yyin;
int yylex(void);


typedef struct {
    char name[64];
    int address;
} Symbol;

Symbol symbols[1024];
int symbol_count = 0;

int add_symbol(const char *name) {
    if (symbol_count >= 1024) {
        fprintf(stderr, "[ERROR] Too many variables(symbols).\n");
        exit(1);
    }
    strcpy(symbols[symbol_count].name, name);
    symbols[symbol_count].address = symbol_count;
    return symbol_count++;
}
int get_symbol(const char* name) {
    for(int i=0; i < symbol_count; i++){
        if (strcmp(symbols[i].name, name) == 0) {
            return symbols[i].address;
        }
    }
    fprintf(stderr, "[ERROR] Undeclared variable.");
    exit(1);
}


void manage_value(Val v);

void gen_this_number(long long n);


/* Cała logika odpowiedzialna za liczenie linii generowanego kodu i bezpieczne wykonywanie Jump'ów. */
int line = 0;
char* program[200000];

void emit(const char* fmt, ...) {
    char buf[256];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);

    program[line] = strdup(buf);
    line++;
}

int emit_jump_placeholder(const char* instr) {
    int pos = line;
    emit("%s 0\n", instr);
    return pos;
}

void patch_jump(int pos, int target) {
    char buf[256];
    snprintf(buf, sizeof(buf), "JUMP %d\n", target);
    free(program[pos]);
    program[pos] = strdup(buf);
}

void patch_jump_zero(int pos, int target) {
    char buf[256];
    snprintf(buf, sizeof(buf), "JZERO %d\n", target);
    free(program[pos]);
    program[pos] = strdup(buf);
}

void patch_jump_pos(int pos, int target) {
    char buf[256];
    snprintf(buf, sizeof(buf), "JPOS %d\n", target);
    free(program[pos]);
    program[pos] = strdup(buf);
}



void yyerror(const char *s) {
    fprintf(stderr, "Bison error: %s\n", s);
}
%}


%union {
    char* str;
    long long num;
    Val val;
}

%token WRITE
%token READ
%token <str> PIDENTIFIER
%token <num> NUM
%token PROGRAM
%token IS
%token IN
%token END
%token PROCEDURE
%token IF
%token THEN
%token ELSE
%token ENDIF
%token WHILE
%token DO
%token ENDWHILE
%token REPEAT
%token UNTIL
%token FOR
%token FROM
%token TO
%token ENDFOR
%token DOWNTO


%token T
%token I
%token O

%token ASSIGN

%token PLUS
%token MINUS
%token TIMES
%token DIV
%token MOD

%token EQ
%token NEQ
%token GT
%token LT
%token GE
%token LE

%type <val> value
%type <str> identifier
%type <val> expression

%%

program_all:
    procedures main
    ;

procedures:
      /* puste */
    ;

main:
    PROGRAM IS declarations IN commands END 
    | PROGRAM IS IN commands END 
    ;

commands:
    commands command
    | command
    ;
command:
    identifier ASSIGN expression ';' {
        int addr = get_symbol($1);
        emit("STORE %d\n", addr);
    }
    | READ identifier ';' {
        int addr = get_symbol($2);
        emit("READ\n");
        emit("STORE %d\n", addr);
    }   
    | WRITE value ';'   {                      /* TO DO obsłużyć WRITE kiedy value to liczba a nie pidentifier */
        manage_value($2);
        emit("WRITE\n"); 
    }
    ;

declarations:
    declarations ',' PIDENTIFIER                            { add_symbol($3); }
    | declarations ',' PIDENTIFIER '[' NUM ':' NUM ']'
    | PIDENTIFIER                                           { add_symbol($1); }
    | PIDENTIFIER '[' NUM ':' NUM ']'
    ;

expression:
    value {
        manage_value($1);
    }
    | value PLUS value {
        manage_value($1);
        emit("SWP b\n");         /* wrzucamy pierwsze value do rejestru b*/
        manage_value($3);
        emit("ADD b\n");            /* dodajemy do rejestru a to co mamy w b */

        $$.is_num = 0;              /* bo wynik na razie jest w rejestrze, czyli jest tymczasowy */
        $$.idn = NULL;
    }
    | value MINUS value {
        manage_value($3);
        emit("SWP b\n");
        manage_value($1);
        emit("SUB b\n"); 

        $$.is_num = 0;
        $$.idn = NULL;
    }
    | value TIMES value {
        manage_value($1);               // ra = 1
        emit("SWP b\n");                // rb = 1
        manage_value($3);               // ra = 3
        emit("SWP b\n");                // ra = 1, rb = 3
        gen_mul();          // odpowiednie liczby już są w odpowiednich rejestrach

        $$.is_num = 0;
        $$.idn = NULL;
    }
    | value DIV value {
        manage_value($1);               
        emit("SWP b\n"); 
        manage_value($3);   
        gen_divmod(0);     // - 0 bo nie chcemy mieć reszty   

        $$.is_num = 0;
        $$.idn = NULL;
    }
    | value MOD value {
        manage_value($1);       
        emit("SWP b\n");               
        manage_value($3);               
        gen_divmod(1);        

        $$.is_num = 0;
        $$.idn = NULL;
    }
    ;

value:
    NUM {
        $$.is_num = 1;
        $$.num = $1;
        $$.idn = NULL;
    }
    | identifier {
        $$.is_num = 0;
        $$.idn = $1;
    }
    ;

identifier:
    PIDENTIFIER    { $$ = $1; }
    ;
%%


/* Funkcja ma na celu zapisanie w rejestrze ra wartości równej n*/
void gen_this_number(long long n) {
    if (n < 0) {
        fprintf(stderr, "[ERROR] Negative constants not supported: %lld\n", n);
        exit(1);
    }

    emit("RST c\n");      

    for (long long i = 0; i < n; i++) {
        emit("INC c\n");  
    }

    emit("SWP c\n");     
}

/* funkcja odpowiedzialna za załadowanie liczby/wartości zmiennej do rejestru ra */
void manage_value(Val v) {
    if(v.is_num) {
        gen_this_number(v.num);
    } else {
        int addr = get_symbol(v.idn);
        emit("LOAD %d\n", addr);
    }
} 

/* Funkcja odpowiedzialna za mnożenie dwóch liczb. Zakładamy, że jedna jest w ra oraz druga jest w rb. */
void gen_mul() {
    /* Wejście: ra = a, rb = b
       Wyjście: ra = a * b
    */
    TMP_ADDR = symbol_count;

    /* rc = wynik = 0 */
    emit("RST c\n");

    /* rd = a (kopiujemy a z ra do rd) */
    emit("SWP d\n");     /* rd = a, ra = stare d */

    /* przenosimy b do pamięci TMP, rb po tym nie jest już potrzebne */
    emit("SWP b\n");                     /* ra = b */
    emit("STORE %d\n", TMP_ADDR);        /* p[TMP_ADDR] = b */

    int loop_start = line;

    /* ładowanie b z pamięci i sprawdzenie, czy b == 0 */
    emit("LOAD %d\n", TMP_ADDR);         /* ra = b */
    int jump_end = emit_jump_placeholder("JZERO");  /* jeśli b == 0 → koniec */

    /* teraz w ra mamy b > 0 */

    /* obliczamy floor(b/2) i parity(b):

       Krok 1: ra zawiera b.
       SHR a: ra = floor(b/2)
       SWP e: re = floor(b/2)
       LOAD TMP: ra = b
       SHL e: re = 2 * floor(b/2)
       SUB e: ra = b - 2*floor(b/2) ∈ {0,1}  (parity)
    */

    emit("SHR a\n");                     /* ra = floor(b/2) */
    emit("SWP e\n");                     /* re = floor(b/2), ra = stare e */

    emit("LOAD %d\n", TMP_ADDR);         /* ra = b */
    emit("SHL e\n");                     /* re = 2 * floor(b/2) */
    emit("SUB e\n");                     /* ra = parity(b) (0 lub 1) */

    /* Teraz:
       ra = parity(b)
       re = 2*floor(b/2)
       floor(b/2) jeszcze znamy tylko pośrednio,
       ale możemy go odzyskać:

       re = 2*floor(b/2)
       SHR e: re = floor(b/2)

       Potem chcemy:
         p[TMP_ADDR] = floor(b/2)  (nowe b)
         ra = parity(b)            (do JZERO)
    */

    emit("SHR e\n");                     /* re = floor(b/2) */

    /* zamieniamy, żeby zapisać floor(b/2) do pamięci */
    emit("SWP e\n");                     /* ra = floor(b/2), re = parity(b) */
    emit("STORE %d\n", TMP_ADDR);        /* p[TMP_ADDR] = floor(b/2) (nowe b) */
    emit("SWP e\n");                     /* ra = parity(b), re = b/2 (niepotrzebne dalej) */

    /* jeśli parity(b) == 0 → pomijamy dodawanie */
    int jump_skip_add = emit_jump_placeholder("JZERO");

    /* jeśli parity(b) == 1 → dodajemy a do wyniku:
         rc = rc + a

       Mamy:
         rd = a
         rc = wynik
         ra = 1 (parity != 0)
    */

    emit("SWP c\n");                     /* ra = rc, rc = parity(b) (1) */
    emit("ADD d\n");                     /* ra = rc + a */
    emit("SWP c\n");                     /* rc = nowy wynik, ra = 1 (nieistotne) */

    /* miejsce, gdzie lądujemy, jeśli parity(b) == 0 (skip add) */
    patch_jump_zero(jump_skip_add, line);

    /* a = 2*a → rd = 2 * rd */
    emit("SHL d\n");

    /* skok na początek pętli */
    emit("JUMP %d\n", loop_start);

    /* koniec mnożenia: b == 0 */
    patch_jump_zero(jump_end, line);

    /* wynik w rc przenosimy do ra */
    emit("SWP c\n");                     /* ra = wynik */
}


void gen_divmod(int want_mod) {
    //want_mod = 1 - tak, chcemy resztę, 0 - nie
    int zero = line; 
    emit("JZERO 0\n"); 
    emit("RST c\n"); 
    emit("SWP d\n"); 
    emit("RST e\n"); 
    emit("INC e\n");   

    int as = line; 
    emit("RST a\n"); 
    emit("ADD d\n"); 
    emit("SUB b\n"); 

    int aj = line; 
    emit("JPOS 0\n"); 

    emit("SWP d\n"); 
    emit("SHL a\n"); 
    emit("SWP d\n"); 
    emit("SWP e\n"); 
    emit("SHL a\n"); 
    emit("SWP e\n"); 
    emit("JUMP %d\n", as);

    patch_jump_pos(aj, line);

    int cs = line; 
    emit("RST a\n"); 
    emit("ADD e\n");

    int ce = line; 
    emit("JZERO 0\n");

    emit("RST a\n"); 
    emit("ADD d\n"); 
    emit("SUB b\n");

    int ss = line; 
    emit("JPOS 0\n"); 

    emit("SWP b\n"); 
    emit("SUB d\n"); 
    emit("SWP b\n"); 
    emit("SWP c\n"); 
    emit("ADD e\n"); 
    emit("SWP c\n");

    patch_jump_pos(ss, line);

    emit("SWP d\n"); 
    emit("SHR a\n"); 
    emit("SWP d\n"); 
    emit("SWP e\n"); 
    emit("SHR a\n"); 
    emit("SWP e\n"); 
    emit("JUMP %d\n", cs);

    patch_jump_zero(ce, line); 
    patch_jump_zero(zero, line); 

    emit("RST a\n"); 
    emit("ADD c\n");

    if(want_mod) {
        emit("SWP b\n");
    }
}




int main(int argc, char **argv) {

    if (argc != 3) {
        fprintf(stderr, "[Error]: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("[ERROR] Can't open input_file");
        return 1;
    }

    out = fopen(argv[2], "w");
    if (!out) {
        perror("[ERROR] Can't open output_file");
        return 1;
    }

    yyparse();

    for (int i = 0; i < line; i++)
        fprintf(out, "%s", program[i]);

    
    fprintf(out, "HALT\n");

    fclose(yyin);
    fclose(out);

    return 0;
}

