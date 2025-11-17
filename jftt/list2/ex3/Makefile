all: ex3.exe

lex.yy.c: ex3.l
	flex ex3.l

ex3.exe: lex.yy.c
	gcc -o ex3.exe lex.yy.c -lfl

clean:
	rm -f lex.yy.c ex3.exe