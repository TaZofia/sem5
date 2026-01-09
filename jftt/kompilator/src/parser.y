// na razie value jest tylko stringiem trzeba potem poprawić żeby mogło być też liczbą. 
// Trzeba stworzyć odpowiedni własny typ

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "types.h"


FILE *out;
extern FILE *yyin;
int yylex(void);


typedef struct {
    char name[64];
    int address;
} Symbol;

Symbol symbols[1024];
int symbol_count = 0;


typedef struct {
    char name[64];
    int start_line;       // linia, od której zaczyna się procedura (CALL tu skacze)
    int return_addr_loc;  // adres w pamięci na przechowanie adresu powrotu
} Procedure;

Procedure procedures[256];
int procedure_count = 0;

char current_proc_name[64] = "";
int main_jump_pos = -1;            // pozycja maina

/* Funkcja do szukania procedury */
int find_procedure(const char* name) {
    for (int i = 0; i < procedure_count; i++) {
        if (strcmp(procedures[i].name, name) == 0)
            return i;
    }
    return -1;
}




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
    {
        // Skok nad wszystkie procedury do main
        main_jump_pos = emit_jump_placeholder("JUMP");
    }
    procedures main
    ;

procedures:
    procedures PROCEDURE proc_head IS declarations IN commands END {
        int index = find_procedure(current_proc_name);
        if (index < 0) {
            fprintf(stderr, "[ERROR] Unknown procedure '%s' at end.\n", current_proc_name);
            exit(1);
        }
        emit("LOAD %d\n", procedures[index].return_addr_loc);
        emit("RTRN\n");
        current_proc_name[0] = '\0';
    }
    | procedures PROCEDURE proc_head IS IN commands END {
        int index = find_procedure(current_proc_name);
        if (index < 0) {
            fprintf(stderr, "[ERROR] Unknown procedure '%s' at end.\n", current_proc_name);
            exit(1);
        }
        emit("LOAD %d\n", procedures[index].return_addr_loc);
        emit("RTRN\n");
        current_proc_name[0] = '\0';
    }
    | ;

main:
    PROGRAM IS declarations IN {
        // Łatamy początkowy skok nad procedurami
        if (main_jump_pos >= 0) {
            patch_jump(main_jump_pos, line);
        }
        current_proc_name[0] = '\0';
    } commands END 
    | PROGRAM IS IN {
        if (main_jump_pos >= 0) {
            patch_jump(main_jump_pos, line);
        }
        current_proc_name[0] = '\0';
    } commands END 
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
    | proc_call ';'
    ;

proc_head:
    PIDENTIFIER '(' args_decl ')' {
        char* name = $1;

        if (find_procedure(name) != -1) {
            fprintf(stderr, "[ERROR] Redefinition of procedure '%s'.\n", name);
            exit(1);
        }

        // Rejestrujemy procedurę
        Procedure *p = &procedures[procedure_count++];
        strcpy(p->name, name);
        p->start_line = line;   // CALL będzie skakał tutaj

        // Alokujemy komórkę na adres powrotu
        char ret_name[80];
        snprintf(ret_name, sizeof(ret_name), "__ret_%s", name);
        p->return_addr_loc = add_symbol(ret_name);

        // Po CALL w rejestrze (np. ra) jest adres powrotu – zapisujemy go
        emit("STORE %d\n", p->return_addr_loc);

        strcpy(current_proc_name, name);
        free(name);
    }
    ;

proc_call:
    PIDENTIFIER '(' args ')'{
        char* name_of_called_proc = $1;
        int idx = find_procedure(name_of_called_proc);
        if (idx < 0) {
            fprintf(stderr, "[ERROR] Call to undefined procedure '%s'.\n", name_of_called_proc);
            exit(1);
        }
        if (current_proc_name[0] != '\0' && strcmp(name_of_called_proc, current_proc_name) == 0) {
            fprintf(stderr, "[ERROR] Recursive call of procedure '%s'.\n", name_of_called_proc);
            exit(1);
        }

        

        // TODO: obsługa parametrów (IN-OUT, tablice)
        // ale samo wywołanie procedury to:
        emit("CALL %d\n", procedures[idx].start_line);

        free($1);
    }
    ;

declarations:
    declarations ',' PIDENTIFIER                            { add_symbol($3); }
    | declarations ',' PIDENTIFIER '[' NUM ':' NUM ']'
    | PIDENTIFIER                                           { add_symbol($1); }
    | PIDENTIFIER '[' NUM ':' NUM ']'
    ;

args_decl:
    args_decl ',' type PIDENTIFIER
    | type PIDENTIFIER
    |
    ;

type:
    T
    | I
    | O
    ;

args:
    args ',' PIDENTIFIER
    | PIDENTIFIER
    | ;

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
        emit("SWP b\n"); 
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

/* Funkcja odpowiedzialna za mnożenie dwóch liczb. */
void gen_mul() {
    emit("RST c\n"); 

    int start = line; 
    emit("JZERO 0\n"); 
    emit("SWP d\n"); 
    emit("RST a\n"); 
    emit("ADD d\n"); 
    emit("SHR a\n"); 
    emit("SHL a\n"); 
    emit("SWP d\n"); 
    emit("SUB d\n");

    int even = line; 
    emit("JZERO 0\n"); 
    emit("SWP c\n"); 
    emit("ADD b\n"); 
    emit("SWP c\n");

    patch_jump_zero(even, line);

    emit("SWP b\n"); 
    emit("SHL a\n"); 
    emit("SWP b\n"); 
    emit("RST a\n"); 
    emit("ADD d\n");
    emit("SHR a\n");

    emit("JUMP %d\n", start);

    patch_jump_zero(start, line);

    emit("RST a\n");
    emit("ADD c\n");
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

