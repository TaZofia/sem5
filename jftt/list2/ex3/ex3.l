%{
#include <stdio.h>
int keep_docs = 0;
%}

%x STR_DOUBLE_Q MULTILINE_COM DOC1 DOC2

%%

\"                      { ECHO; BEGIN(STR_DOUBLE_Q); } 
<STR_DOUBLE_Q>\\\"      ECHO;       /* dont end when you find \" inside string*/
<STR_DOUBLE_Q>\"        { ECHO; BEGIN(INITIAL); }
<STR_DOUBLE_Q>.         ECHO;

"/*"                    { BEGIN(MULTILINE_COM); }
<MULTILINE_COM>"*/"     { BEGIN(INITIAL); }
<MULTILINE_COM>.        ;
<MULTILINE_COM>\n       ;


"/**"                   { if (keep_docs) ECHO; BEGIN(DOC1); }            /* multiline doc comment*/
<DOC1>"*/"              { if (keep_docs) ECHO; BEGIN(INITIAL); }
<DOC1>.                 { if (keep_docs) ECHO; }
<DOC1>\n                { if (keep_docs) ECHO; }

"/*!"                   { if (keep_docs) ECHO; BEGIN(DOC2); }            /* multiline doc comment*/
<DOC2>"*/"              { if (keep_docs) ECHO; BEGIN(INITIAL); }
<DOC2>.                 { if (keep_docs) ECHO; }
<DOC2>\n                { if (keep_docs) ECHO; }


"///".*               { if (keep_docs) ECHO; }      /* one line doc comment */
"//!".*               { if (keep_docs) ECHO; }      /* one line doc comment */
"//".*                ;                             /* normal comment */

\n                      ECHO;     
.                       ECHO;

%%

int main(int argc, char *argv[]) {

    if (argc > 1 && strcmp(argv[1], "-d") == 0) {
        keep_docs = 1;
    }

    FILE *input = fopen("file.cpp", "r");

    if (!input) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);

    return 0;
}