#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyparse(void);
extern FILE *yyin;

#define MAX_LINE 1024

int main() {
    FILE *fp = fopen("exercise.txt", "r");
    if (!fp) {
        perror("[ERROR] Can't open exercise.txt");
        return 1;
    }

    char line[MAX_LINE];      // bufor na jedną wczytaną linię 
    char combined_line[MAX_LINE * 4];  // bufor na linie kończące się \ 

    line[0] = '\0';
    combined_line[0] = '\0';
    
    while (fgets(line, sizeof(line), fp)) {

        if (line[0] == '#') {     // pomiń komentarze
            continue;
        }

        size_t len = strlen(line);

        if (len > 0 && line[len - 2] == '\\' && line[len - 1] == '\n') {
            line[len - 2] = '\0'; 
            strcat(combined_line, line);
            continue;  // czytaj kolejną linię 
        } else {
            strcat(combined_line, line);
            printf("%s", combined_line); 
        }

        /* mamy pełne wyrażenie */
        if (strlen(combined_line) > 0) {
            /* otwórz strumień z pamięci */
            FILE *tmp = fmemopen(combined_line, strlen(combined_line), "r");
            if (!tmp) {
                perror("[ERROR] Can't open stream");
                fclose(fp);
                return 1;
            }
            yyin = tmp;
            yyparse();
            fclose(tmp);
            combined_line[0] = '\0';  /* wyczyść bufor */
        }
    }

    fclose(fp);
    return 0;
}