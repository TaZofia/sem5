TARGET = kompilator

all: $(TARGET)

$(TARGET): parser.tab.o lex.yy.o
	gcc parser.tab.o lex.yy.o -o $(TARGET)

parser.tab.c parser.tab.h: parser.y types.h
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h types.h
	flex lexer.l

parser.tab.o: parser.tab.c types.h
	gcc -c parser.tab.c

lex.yy.o: lex.yy.c types.h
	gcc -c lex.yy.c

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c *.o
