%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(const char *s);

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

%code requires {
    typedef struct {
        int val;
        char *rpn;
    } node_t;
}

%union {
    int ival;   /* typ semantyczny: liczba całkowita */
    node_t node;
}

%token <ival> NUMBER
%token PLUS MINUS TIMES DIV POW
%token POWER_ERROR
%token LPAREN RPAREN   /* nowe tokeny dla nawiasów */

%type <node> expr


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
  | error      { error_flag = 0; }
  | expr '\n' { 
        printf("%s\n", $1.rpn);
        printf("= %d\n\n", $1.val);
        free($1.rpn);
    }
  | expr {
        printf("\n%s\n", $1.rpn);
        printf("= %d\n\n", $1.val);
        free($1.rpn);
    }
  ;


expr:
    NUMBER {
        $$.val = $1 % p;
        char buf[64];
        sprintf(buf, "%d", $1 % p);
        $$.rpn = strdup(buf);
    }

  | POWER_ERROR { yyerror("Invalid powers"); YYERROR; }

  | expr PLUS expr {
      $$.val = ($1.val + $3.val) % p;
      int len = strlen($1.rpn) + strlen($3.rpn) + 3;
      $$.rpn = malloc(len);
      sprintf($$.rpn, "%s %s +", $1.rpn, $3.rpn);
  }

  | expr TIMES expr {
      long long x1 = $1.val, x3 = $3.val;
      $$.val = (x1 * x3) % p;
      int len = strlen($1.rpn) + strlen($3.rpn) + 3;
      $$.rpn = malloc(len);
      sprintf($$.rpn, "%s %s *", $1.rpn, $3.rpn);
  }

  | LPAREN expr RPAREN {      /* obsługa nawiasów */
    $$.val = $2.val;
    $$.rpn = strdup($2.rpn);
  }

  | expr MINUS expr {
    $$.val = ((($1.val - $3.val) % p) + p) % p;
    int len = strlen($1.rpn) + strlen($3.rpn) + 3;
    $$.rpn = malloc(len);
    sprintf($$.rpn, "%s %s -", $1.rpn, $3.rpn);
  }

  | expr POW expr {
    $$.val = ipow($1.val, $3.val);
    int len = strlen($1.rpn) + strlen($3.rpn) + 3;
    $$.rpn = malloc(len);
    sprintf($$.rpn, "%s %s ^", $1.rpn, $3.rpn);
  } 

  | expr POW MINUS expr %prec NEGPOV {
    $$.val = ipow($1.val, -$4.val);

    int negexp = (p - 1 -$4.val) % p;;
    char buf[64];
    sprintf(buf, "%d", negexp);

    int len = strlen($1.rpn) + strlen(buf) + 3;
    $$.rpn = malloc(len);
    sprintf($$.rpn, "%s %s ^", $1.rpn, buf);
  }
  
  | MINUS expr %prec UMINUS {      /* minus unarny */
    $$.val = (-$2.val + p) % p;
    int len = strlen($2.rpn) + 10;
    $$.rpn = malloc(len);
    sprintf($$.rpn, "%d", $$.val);  // w ONP zapisujemy już wartość
  }

  | expr DIV expr {
    if ($3.val == 0) {
        yyerror("Division by zero");
        YYERROR;
    }
    long long inv = ipow($3.val, p-2);
    $$.val = ($1.val * inv) % p;
    int len = strlen($1.rpn) + strlen($3.rpn) + 3;
    $$.rpn = malloc(len);
    sprintf($$.rpn, "%s %s /", $1.rpn, $3.rpn);
  }
  ;
%%


int yyerror(const char *s) {
    fprintf(stderr, "[ERROR]: %s\n\n", s);
    return 0;
}
