%{
# include <stdio.h> 
#include <stdlib.h>
#include <math.h>
#define MAX 20

int stack[MAX];
int top = -1;

int wrong_symbol_flag = 0;
int too_few_arguments_flag = 0;

void push(int value);
int pop();
int peek();
%}

%%

-?[0-9]+                { ECHO; push(atoi(yytext)); }

"+"                     { ECHO; int a = pop(); int b = pop(); push(b + a); }
"-"                     { ECHO; int a = pop(); int b = pop(); push(b - a); }
"*"                     { ECHO; int a = pop(); int b = pop(); push(b * a); }
"/"                     { ECHO; int a = pop(); int b = pop(); push(b / a); }
"^"                     { ECHO; int a = pop(); int b = pop(); push((int)pow(b, a)); }
"%"                     { ECHO; int a = pop(); int b = pop(); push(b % a); }

\n                      {
                            ECHO;
                            if(too_few_arguments_flag == 1) {
                                printf("\n[ERROR] Too few arguments\n");
                                too_few_arguments_flag = 0;
                            } else if (wrong_symbol_flag == 1){
                                printf("\n[ERROR] Wrong symbol\n");
                                wrong_symbol_flag = 0;
                            } else if (top == 0) {
                                printf("= %d \n", stack[top]);
                            } else {
                                printf("\n[ERROR] Too few operands\n");
                            }
                            top = -1;
                                
                            printf("\n");
                        }       

\t                      ;   
[ ]                     { ECHO; }
.                       { ECHO; wrong_symbol_flag = 1;}

%%

void push(int value) {
    if(top < MAX - 1) {
        stack[++top] = value;
    } else {
        printf("Full stack\n");
    }
}
int pop() {
    if (top >= 0) {
        return stack[top--];
    } else {
        too_few_arguments_flag = 1;
        return -1; 
    }
}

int peek() {
    if (top >= 0) {
        return stack[top];
    } else {
        too_few_arguments_flag = 1;
        return -1;
    }
}


int main() {


    FILE *input = fopen("my_data.txt", "r");

    if (!input) {
        fprintf(stderr, "Can't open file\n");
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);

    return 0;
}


