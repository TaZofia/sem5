// na razie value jest tylko stringiem trzeba potem poprawić żeby mogło być też liczbą. 
// Trzeba stworzyć odpowiedni własny typ

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

void yyerror(const char *s) {
    fprintf(stderr, "Bison error: %s\n", s);
}
%}


%union {
    char* str;
    long long num;
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

%type <str> value
%type <str> identifier

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
    READ identifier ';'
    {
        int addr = get_symbol($2);
        fprintf(out, "READ\n");
        fprintf(out, "STORE %d\n", addr);
    }
    | WRITE value ';'         
    { 
        int addr = get_symbol($2);
        fprintf(out, "LOAD %d\n", addr);
        fprintf(out, "WRITE\n"); 
    }
    ;

declarations:
    declarations ',' PIDENTIFIER                            { add_symbol($3); }
    | declarations ',' PIDENTIFIER '[' NUM ':' NUM ']'
    | PIDENTIFIER                                           { add_symbol($1); }
    | PIDENTIFIER '[' NUM ':' NUM ']'
    ;

value:
    //NUM
    | identifier    { $$ = $1; }
    ;

identifier:
    PIDENTIFIER    { $$ = $1; }
    ;
%%

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
    fprintf(out, "HALT\n");

    fclose(yyin);
    fclose(out);

    return 0;
}

