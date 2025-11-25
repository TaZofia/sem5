%{
#include "calculator.tab.h"   /* nagłówek wygenerowany przez Bison */
#include <stdlib.h>
%}

%%

[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }
[ \t\r]+    ;   /* ignoruj spacje i tabulatory */
\n          { return '\n'; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIV; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"^"         { return POW; }

[0-9]+\^[0-9]+\^    {return POWER_ERROR; }

.           { return yytext[0]; }   /* dowolny inny znak zwróć jako sam siebie */

%%

int yywrap(void) {
    return 1;
}
