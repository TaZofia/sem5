all: zad1.exe

lex.yy.c: zad1.l
	flex zad1.l

zad1.exe: lex.yy.c
	gcc -o zad1.exe lex.yy.c -lfl

clean:
	rm -f lex.yy.c zad1.exe
