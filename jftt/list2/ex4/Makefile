all: ex4.exe

lex.yy.c: ex4.l
	flex ex4.l

ex4.exe: lex.yy.c
	gcc -o ex4.exe lex.yy.c -lfl -lm

clean:
	rm -f lex.yy.c ex4.exe