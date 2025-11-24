%{
#include <stdio.h>
#include <stdlib.h>

int div_by_zero = 0;
%}


%union {
    int ival;   /* typ semantyczny: liczba całkowita */
}

%token <ival> NUMBER
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN   /* nowe tokeny dla nawiasów */
%token POW

%type <ival> expr line

%left PLUS MINUS
%left TIMES DIV
%left POW

%%

input:
    /* pusty */
  | input line
  ;

line:
    expr '\n'   { 
      if(div_by_zero == 0)
        printf("= %d\n", $1); 
      else
        div_by_zero = 0;
    }
  ;

expr:
    NUMBER
  | expr PLUS expr   { $$ = $1 + $3; }
  | expr MINUS expr  { $$ = $1 - $3; }
  | expr TIMES expr  { $$ = $1 * $3; }
  | expr DIV expr    { 
      if($3 == 0) {
        printf("[ERROR] Can't divide by 0\n"); 
        div_by_zero = 1;
      }
      else 
        $$ = $1 / $3; 
    }
  | expr POW expr    { 
      /* lewostronne potęgowanie */
      int result = 1;
      for (int i = 0; i < $3; i++) result *= $1;    /* potęgowanie jako mnożenie */
      $$ = result;
    }
  | LPAREN expr RPAREN { $$ = $2; }   /* obsługa nawiasów */
  ;

%%


int yyerror(const char *s) {
    fprintf(stderr, "Błąd: %s\n", s);
    return 0;
}
