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


// flagi odpowiadające typom 

#define F_NONE  0
#define F_ARRAY 1  // T
#define F_CONST 2  // I (Input/Const)
#define F_OUT   4  // O (Output)


typedef struct {
    char name[64];
    int address;
    int is_ref;         // 0 - zwykła zmienna, 1 - referencja
    int flags;
    long long low;
    long long high;
    int is_init;       // 1 = zainicjalizowana (ważne dla O)
} Symbol;

Symbol symbols[1024];
int symbol_count = 0;
int memory_ptr = 0;     // pierwszy wolny adres w pamięci



typedef struct {
    char name[64];
    int start_line;              // linia, od której zaczyna się procedura (CALL tu skacze)
    int return_addr_loc;         // adres w pamięci na przechowanie adresu powrotu

    int param_count;             // licznik przekazywanych parametrów
    char param_names[16][24];
    int param_locs[16];       // indeksy w symbols, przechowują adresy przekazywanych parametrów
    int param_flags[16];      // typy parametrów 
} Procedure;

Procedure procedures[256];
int procedure_count = 0;

char current_proc_name[64] = "";
int main_jump_pos = -1;            // pozycja maina


void manage_value(Val v);
void gen_this_number(long long n);
void gen_mul(void);
void gen_divmod(int want_mod);

/* Funkcja do szukania procedury */
int find_procedure(const char* name) {
    for (int i = 0; i < procedure_count; i++) {
        if (strcmp(procedures[i].name, name) == 0)
            return i;
    }
    return -1;
}

/* Dodaje symbol, obługuje odpowiednio prefiksy dla zmiennych lokalnych, formalnych i referencji 
oraz dba o odpowiednią logikę dla tablic. Funckja ta zwraca indeks.
*/
int add_symbol(const char *name, int is_ref, int flags, long long low, long long high) {
    if (symbol_count >= 1024) {
        fprintf(stderr, "[ERROR] Too many variables(symbols).\n");
        exit(1);
    }

    char scoped_name[128];
    if (current_proc_name[0] && !is_ref) { 
        // Zmienna lokalna (nie parametr)
        snprintf(scoped_name, 128, "%s_%s", current_proc_name, name);
    } else if (current_proc_name[0] && is_ref) {
        // Parametr funkcji (wewnętrzna nazwa referencji)
        snprintf(scoped_name, 128, "__ref_%s_%s", current_proc_name, name);
    } else {
        // Globalna
        strcpy(scoped_name, name);
    }

    for(int i=0; i<symbol_count; i++) {
        if(strcmp(symbols[i].name, scoped_name) == 0) {
            fprintf(stderr, "[ERROR] Redefinition of '%s'\n", name); exit(1);
        }
    }

    Symbol *s = &symbols[symbol_count];
    strcpy(s->name, scoped_name);
    s->flags = flags;
    s->is_ref = is_ref;
    s->low = low;
    s->high = high;

    if (flags & F_OUT) s->is_init = 0; else s->is_init = 1;     

    s->address = memory_ptr;
    if (flags & F_ARRAY && !is_ref) {
        if (low > high) { fprintf(stderr, "[ERROR] Array range error.\n"); exit(1); }
        memory_ptr += (high - low + 1);     // rezerwujemy miejsce na całą tablicę 
    } else {
        // Zmienna lub referencja - zajmuje 1 komórkę
        memory_ptr++;
    }

    return symbol_count++;
}

Symbol* get_symbol_record(const char* name) {
    
    // Najpierw sprawdzamy czy mamy zmienną lokalną (priorytet)
    if (current_proc_name[0] != '\0') {
        char local_var_name[128];
        snprintf(local_var_name, sizeof(local_var_name), "%s_%s", current_proc_name, name);
        
        for(int i = 0; i < symbol_count; i++) {
            if (strcmp(symbols[i].name, local_var_name) == 0) {
                return &symbols[i];
            }
        }
    }

    // Potem sprawdzamy czy jest to referencja
    if (current_proc_name[0] != '\0') {
        char ref_name[128];
        snprintf(ref_name, sizeof(ref_name), "__ref_%s_%s", current_proc_name, name);
        
        for(int i = 0; i < symbol_count; i++) {
            if (strcmp(symbols[i].name, ref_name) == 0) {
                return &symbols[i];
            }
        }
    }

    // Następnie zmienne globalne
    for(int i = 0; i < symbol_count; i++){
        if (strcmp(symbols[i].name, name) == 0) {
            return &symbols[i];
        }
    }

    fprintf(stderr, "[ERROR] Undeclared variable '%s' (Context: %s).\n", 
            name, current_proc_name[0] ? current_proc_name : "MAIN");
    exit(1);
}


/* Zwraca sam adres */
int get_symbol_addr(const char* name) {
    return get_symbol_record(name)->address;
}

void gen_addr(IdInfo *info) {
    Symbol* s = get_symbol_record(info->name); 

    if (s->is_ref) {
        // jeśli referencja to adresem jest wartość zapisana w komórce
        emit("LOAD %d\n", s->address);
    } else {
        // Zmienna zwykła/tablica - adres jest stałą
        gen_this_number(s->address); 
    }

    // Jeśli zmienna - adres jest już w ra. Koniec.
    if (info->access_type == 0) return;


    if (!(s->flags & F_ARRAY)) {
        fprintf(stderr, "[ERROR]: %s ia not an array!\n", s->name); exit(1);
    }

    emit("SWP h\n");    // Baza tablicy do rh

    if (info->access_type == 1) { 
        // tab[NUM] -> offset stały
        long long offset = info->idx_const - s->low;
        gen_this_number(offset); // Wstaw offset do 'a'
    } 
    else if (info->access_type == 2) {
        // tab[VAR] -> offset dynamiczny
        // Musimy pobrać wartość zmiennej indeksującej
        Symbol* idx = get_symbol_record(info->idx_var);
        
        // Załaduj wartość indeksu do 'a'
        if (idx->is_ref) {
            emit("LOAD %d\n", idx->address);
            emit("SWP g\n");
            emit("RLOAD g\n");
        } else {
            emit("LOAD %d\n", idx->address);
        }
        
        // Odejmij dolny zakres (low)
        emit("SWP g\n");
        gen_this_number(s->low);
        emit("SWP g\n");
        emit("SUB g\n"); // a = index - low
    }

    
    emit("ADD h\n"); 
    // Teraz w 'a' jest finalny adres komórki tablicy
}

// pomocniczy stack do argumentów wywołania 
char call_args_stack[16][64];
int call_args_count = 0;

void reset_call_args() { call_args_count = 0; }
void add_call_arg(char* name) {
    if (call_args_count < 16) {
        strcpy(call_args_stack[call_args_count++], name);
    }
    free(name);
}



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
    int flags;      // dla typów T, I, O
    IdInfo* id_info;    // dla indentyfikatorów (tab[i])
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

%left PLUS MINUS
%left TIMES DIV MOD

%type <val> value
%type <val> expression
%type <flags> type
%type <id_info> identifier

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
        emit("LOAD %d\n", symbols[procedures[index].return_addr_loc].address);
        emit("RTRN\n");
        current_proc_name[0] = '\0';
    }
    | procedures PROCEDURE proc_head IS IN commands END {
        int index = find_procedure(current_proc_name);
        if (index < 0) {
            fprintf(stderr, "[ERROR] Unknown procedure '%s' at end.\n", current_proc_name);
            exit(1);
        }
        emit("LOAD %d\n", symbols[procedures[index].return_addr_loc].address);
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
        Symbol* s = get_symbol_record($1);

        if (s->flags & F_CONST) {
            fprintf(stderr, "[ERROR]: Modification of const %s\n", s->name); exit(1);
        }

        emit("SWP d\n");

        gen_addr($1);

        emit("SWP b\n");     // Adres do rb
        emit("SWP d\n");     // Wynik do ra
        emit("RSTORE b\n");  // Zapisujemy ra pod adres rb
        
        s->is_init = 1;     // Już zainicjalizowana
        free($1);
    }
    | READ identifier ';' {
        Symbol* s = get_symbol_record($2->name);
        if (s->flags & F_CONST) {
            fprintf(stderr, "[ERROR]: Modification of const %s\n", s->name); exit(1);
        }
        gen_addr($2);
        
        emit("SWP b\n");
        emit("READ\n");
        emit("RSTORE b\n");

        s->is_init = 1;

        free($2);
    }   
    | WRITE value ';'   {
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
        Procedure *p = &procedures[procedure_count];
        strcpy(p->name, name);
        p->start_line = line;   // CALL będzie skakał tutaj

        strcpy(current_proc_name, name);

        p->return_addr_loc = add_symbol("return_addr", 0, F_NONE, 0, 0);

        for (int i = 0; i < p->param_count; ++i) {
            int flags = p->param_flags[i];
            int index = add_symbol(p->param_names[i], 1, flags, 0, 0);      // low i high może być równe 0 dla tablic, bo dla referencji nie ma to znaczenia, rozmiar i tak jest w oryginale
            
            p->param_locs[i] = index;
        }

        // Po CALL w rejestrze (np. ra) jest adres powrotu – zapisujemy go
        emit("STORE %d\n", symbols[p->return_addr_loc].address);

        procedure_count++;
        free(name);
    }
    ;

proc_call:
    PIDENTIFIER '(' {
        reset_call_args();
    } args ')'{
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
        

        Procedure *p = &procedures[idx];

        if (p->param_count != call_args_count) {
             fprintf(stderr, "[ERROR]: Wrong arg count for %s\n", name_of_called_proc); exit(1);
        }

        for (int i = 0; i < p->param_count; ++i) {
            Symbol* s = get_symbol_record(call_args_stack[i]);
            
            if (s->is_ref) {
                emit("LOAD %d\n", s->address);  // po prostu przekazujemy referencję dalej
            } else {
                gen_this_number(s->address);    // przekazujemy wartość
            }
            int sym_idx = p->param_locs[i];
            emit("STORE %d\n", symbols[sym_idx].address);
        }
        
        emit("CALL %d\n", p->start_line);   // samo wywołanie procedury

        free($1);
    }
    ;

declarations:
    declarations ',' PIDENTIFIER { 
        add_symbol($3, 0, F_NONE, 0, 0);
        free($3); 
    }
    | declarations ',' PIDENTIFIER '[' NUM ':' NUM ']' { 
        add_symbol($3, 0, F_ARRAY, $5, $7);
        free($3);
    }
    | PIDENTIFIER { 
        add_symbol($1, 0, F_NONE, 0, 0);
        free($1); 
    }
    | PIDENTIFIER '[' NUM ':' NUM ']' { 
        add_symbol($1, 0, F_ARRAY, $3, $5);
        free($1); 
    }
    ;

args_decl:
    args_decl ',' type PIDENTIFIER {
        Procedure *p = &procedures[procedure_count];
        if (p->param_count >= 16) {
            fprintf(stderr, "[ERROR] Too many parameters in procedure '%s'.\n", current_proc_name);
            exit(1);
        }
        int idx = p->param_count++;
        p->param_flags[idx] = $3;
        strncpy(p->param_names[idx], $4, 23);

        free($4);
    }
    | type PIDENTIFIER {
        Procedure *p = &procedures[procedure_count];
        p->param_count = 1;
        p->param_flags[0] = $1;

        strncpy(p->param_names[0], $2, 23);
        free($2);
    }
    | {     // bez parametrów
       procedures[procedure_count].param_count = 0;
    }
    ;

type:
    T             { $$ = F_ARRAY; }
    | I           { $$ = F_CONST; }
    | O           { $$ = F_OUT; }
    | T I         { $$ = F_ARRAY | F_CONST; }
    | T O         { $$ = F_ARRAY | F_OUT; }
    |             { $$ = F_NONE; }
    ;       
args:
    args ',' PIDENTIFIER {
        add_call_arg($3);
    }
    | PIDENTIFIER {
        add_call_arg($1);
    }
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
        $$.id_info = NULL;
    }
    | value MINUS value {
        manage_value($3);
        emit("SWP b\n");
        manage_value($1);
        emit("SUB b\n"); 

        $$.is_num = 0;
        $$.id_info = NULL;
    }
    | value TIMES value {
        manage_value($1);               // ra = 1
        emit("SWP b\n");                // rb = 1
        manage_value($3);               // ra = 3
        emit("SWP b\n"); 
        gen_mul();          // odpowiednie liczby już są w odpowiednich rejestrach

        $$.is_num = 0;
        $$.id_info = NULL;
    }
    | value DIV value {
        manage_value($1);               
        emit("SWP b\n"); 
        manage_value($3);   
        gen_divmod(0);     // - 0 bo nie chcemy mieć reszty   

        $$.is_num = 0;
        $$.id_info = NULL;
    }
    | value MOD value {
        manage_value($1);       
        emit("SWP b\n");               
        manage_value($3);               
        gen_divmod(1);        

        $$.is_num = 0;
        $$.id_info = NULL;
    }
    ;

value:
    NUM {
        $$.is_num = 1;
        $$.num = $1;
        $$.id_info = NULL;
    }
    | identifier {
        Symbol* s = get_symbol_record($1->name);
        
        // Sprawdzanie O
        if ((s->flags & F_OUT) && s->is_init == 0) {
            fprintf(stderr, "[ERROR]: Use of uninitialized variable (type O): %s\n", s->name); exit(1);
        }
        $$.is_num = 0;
        $$.id_info = $1;
    }
    ;

identifier:
    PIDENTIFIER {
        IdInfo* info = (IdInfo*)malloc(sizeof(IdInfo));
        strcpy(info->name, $1);
        info->access_type = 0; // Zwykła zmienna
        free($1);
        $$ = info;
    }
    | PIDENTIFIER '[' PIDENTIFIER ']' {
        IdInfo* info = (IdInfo*)malloc(sizeof(IdInfo));
        strcpy(info->name, $1);
        info->access_type = 2;     // Tablica ze zmienną
        strcpy(info->idx_var, $3);

        free($1); free($3);
        $$ = info;
    }
    | PIDENTIFIER '[' NUM ']' {
        IdInfo* info = (IdInfo*)malloc(sizeof(IdInfo));
        strcpy(info->name, $1);
        info->access_type = 1;     // Tablica ze stałą
        info->idx_const = $3;
        free($1);
        $$ = info;
    }
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
        gen_addr(v.id_info);

        emit("SWP g\n");   // adres do g
        emit("RLOAD g\n"); // wartość spod adresu znajdującym się w rg pobieram do ra
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

void debug_print_symbols() {
    printf("--- SYMBOL TABLE DUMP ---\n");
    for(int i=0; i<symbol_count; i++) {
        printf("ID: %d | Name: %s | Addr: %d | IsRef: %d\n", 
               i, symbols[i].name, symbols[i].address, symbols[i].is_ref);
    }
    printf("-------------------------\n");
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
    debug_print_symbols();

    for (int i = 0; i < line; i++)
        fprintf(out, "%s", program[i]);

    
    fprintf(out, "HALT\n");

    fclose(yyin);
    fclose(out);

    return 0;
}

