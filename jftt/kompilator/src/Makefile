# Nazwa programu
TARGET = kompilator

all: $(TARGET)

$(TARGET): parser.tab.c lex.yy.c
	gcc parser.tab.c lex.yy.c -o $(TARGET)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c
