%{
#include <stdio.h>
#include <stdlib.h>

FILE *out;
extern FILE *yyin;

void yyerror(const char *s) {
    fprintf(stderr, "Bison error: %s\n", s);
}
%}


%token WRITE
%token READ
%token PIDENTIFIER
%token NUM
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
    READ identifier';'        { fprintf(out, "READ\n"); }
    | WRITE value';'          { fprintf(out, "WRITE\n"); }
    ;

declarations:
    declarations ',' PIDENTIFIER
    | declarations ',' PIDENTIFIER '[' NUM ':' NUM ']'
    | PIDENTIFIER
    | PIDENTIFIER '[' NUM ':' NUM ']'
    ;

value:
    NUM
    | identifier
    ;

identifier:
    PIDENTIFIER
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

    fclose(yyin);
    fclose(out);

    return 0;
}

