%{
#include "types.h"
#include "parser.tab.h"
%}

%%

[ \t\n\r]+        ;          /* ignorujemy białe znaki */
"#".*             ;          /* ignorujemy komentarze */

WRITE             return WRITE;
READ              return READ;
PROGRAM           return PROGRAM;
IS                return IS;
IN                return IN;
END               return END;
PROCEDURE         return PROCEDURE;
IF                return IF;
THEN              return THEN;
ELSE              return ELSE;
ENDIF             return ENDIF; 
WHILE             return WHILE;
DO                return DO;
ENDWHILE          return ENDWHILE;
REPEAT            return REPEAT;
UNTIL             return UNTIL; 
FOR               return FOR;
FROM              return FROM;
TO                return TO;
ENDFOR            return ENDFOR;
DOWNTO            return DOWNTO;

T                 return T;
I                 return I;
O                 return O;



"["               return '[';
"]"               return ']';
"("               return '('; 
")"               return ')'; 
":"               return ':'; 
";"               return ';';
","               return ','; 


":="              return ASSIGN;

"+"               return PLUS;
"-"               return MINUS;
"*"               return TIMES;
"/"               return DIV;
"%"               return MOD;

"="               return EQ;
"!="              return NEQ;
">"               return GT;
"<"               return LT;
">="              return GE;
"<="              return LE;

[_a-z]+           { yylval.str = strdup(yytext); return PIDENTIFIER; }
[0-9]+            { yylval.num = atoll(yytext); return NUM;  }

.                 ;          /* ignorujemy wszystko inne */

%%

int yywrap() { return 1; }
