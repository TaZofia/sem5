all: ex2.exe

lex.yy.c: ex2.l
	flex ex2.l

ex2.exe: lex.yy.c
	gcc -o ex2.exe lex.yy.c -lfl

clean:
	rm -f lex.yy.c ex2.exe