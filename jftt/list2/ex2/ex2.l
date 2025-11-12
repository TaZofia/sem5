%{
#include <stdio.h>
%}

%x STR_SINGLE STR_DOUBLE STR_TRIPLE_SQ STR_TRIPLE_DQ

%% 
\'              { ECHO; BEGIN(STR_SINGLE); }   /* beginning '...' */
\"              { ECHO; BEGIN(STR_DOUBLE); }   /* beginning "..." */
\"\"\"          { BEGIN(STR_TRIPLE_DQ); } 
\'\'\'          { BEGIN(STR_TRIPLE_SQ); } 

<STR_SINGLE>\'      { ECHO; BEGIN(INITIAL); }  /* end '...' */
<STR_DOUBLE>\"      { ECHO; BEGIN(INITIAL); }  /* end "..." */

<STR_SINGLE>.       { ECHO; }                  /* any sign in string */
<STR_DOUBLE>.       { ECHO; }

<STR_TRIPLE_DQ>\"\"\"  { BEGIN(INITIAL); }        
<STR_TRIPLE_DQ>\n      ;
<STR_TRIPLE_DQ>.       ;

<STR_TRIPLE_SQ>\'\'\'  { BEGIN(INITIAL); }        
<STR_TRIPLE_SQ>\n      ;
<STR_TRIPLE_SQ>.       ;


"#".*\n         ;

\n           ECHO;     
.            ECHO;
%%


int main(){


    FILE *input = fopen("file.py", "r");

    if (!input) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);

    return 0;
}