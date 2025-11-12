%{
#include <stdio.h>
int word_count = 0;
int line_count = 1;
%}

%%

^[[:space:]]+              ;
\n[[:space:]]+             { line_count++; printf("\n"); }    // ignore whitespace at the beginning of line

[[:space:]]+\n             { line_count++; printf("\n"); }  // ignore whitespace at the end of line

[ \t]+                     { printf(" "); }   // spaces and tabs become one space

[[:space:]]+EOF            ;    // ignore whitespace at the end of file

\n{2,}                     { line_count++; printf("\n"); }  // ignore 2 or more new lines


\n                         { line_count++; printf("\n"); } // every line - just one
[^ \t\n]+                  { word_count++; printf("%s", yytext); } //every word


%%

int main(){
    FILE *append = fopen("example.txt", "a");
    if (!append) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }
    fprintf(append, "EOF");
    fclose(append);


    FILE *input = fopen("example.txt", "r");

    if (!input) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);

    printf("|lines: %d|", line_count);
    printf("words: %d\n", word_count);


    FILE *edit = fopen("example.txt", "r+");
    if (!edit) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }

    // find file size
    fseek(edit, 0, SEEK_END);
    long size = ftell(edit);

    // - EOF lenght - 3 bytes
    long new_size = size - 3;
    if (new_size < 0) new_size = 0;

    // make file shorter
    int fd = fileno(edit);
    ftruncate(fd, new_size);

    fclose(edit);


    return 0;
}

