%{
#include <stdio.h>
#include <stdlib.h>

int error_flag = 0;

const int p = 1234577;


int ipow(int base, int exp) {

    if (exp < 0) {
        exp = (p - 1 + exp) % p;  // a^-k ≡ a^(p-1-k)
    }

    long long result = 1;
    long long b = base % p;
    while (exp > 0) {
        if (exp % 2 == 1)
            result = (result * b) % p;
        b = (b * b) % p;
        exp /= 2;
    }
    return (int)result;
}

%}


%union {
    int ival;   /* typ semantyczny: liczba całkowita */
}

%token <ival> NUMBER
%token PLUS MINUS TIMES DIV POW
%token POWER_ERROR
%token LPAREN RPAREN   /* nowe tokeny dla nawiasów */

%type <ival> expr line

%right NEGPOV
%left PLUS MINUS
%right UMINUS 
%left TIMES DIV
%left POW

%%

input:
    /* pusty */
  | input line
  ;

line:
    error '\n' { error_flag = 0; }
  | expr '\n' { printf("= %d\n\n", $1); }
  | expr  { printf("= %d\n\n", $1); }
  ;


expr:
    NUMBER { $$ = $1 % p; }
  | POWER_ERROR { yyerror("Invalid powers"); YYERROR; }
  | expr PLUS expr   { $$ = ($1 + $3) % p; }
  | expr TIMES expr  { 
    long long int x3 = $3; //to avoid integer overflow
    long long int x1 = $1;
    $$ = (x1 * x3) % p; 
    }
  | LPAREN expr RPAREN { $$ = $2; }   /* obsługa nawiasów */
  | expr MINUS expr {$$ = ((($1 - $3) % p) + p) % p;}

  | expr POW expr {$$= ipow($1,$3);}
  | expr POW MINUS expr %prec NEGPOV {$$ = ipow($1, -$4);} 
  | MINUS expr %prec UMINUS { $$ = (-$2 + p) % p; }
  | expr DIV expr {

    if ($3 == 0){
        yyerror("Division by zero");
        YYERROR;
    }

    long long int x3= ipow($3, 1234575);
    long long int x1 = $1;
    long long int result = (x1 * x3) % p; 
    $$ = result;
  }
  ;
%%


int yyerror(const char *s) {
    fprintf(stderr, "[ERROR]: %s\n\n", s);
    return 0;
}
