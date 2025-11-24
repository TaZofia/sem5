TARGET = calculator

YFILE = calculator.y
LFILE = calculator.l
CFILE = main.c

YOUTPUT = calculator.tab.c
YHEADER = calculator.tab.h
LOBJECT = lex.yy.c

CC = gcc
CFLAGS = -Wall -g

all: $(TARGET)

# Budowanie programu
$(TARGET): $(YOUTPUT) $(LOBJECT) $(CFILE)
	$(CC) $(CFLAGS) $(YOUTPUT) $(LOBJECT) $(CFILE) -o $(TARGET)

# Generowanie plików z Bison
$(YOUTPUT) $(YHEADER): $(YFILE)
	bison -d $(YFILE)

# Generowanie pliku z Flex
$(LOBJECT): $(LFILE) $(YHEADER)
	flex $(LFILE)

# Sprzątanie
clean:
	rm -f $(YOUTPUT) $(YHEADER) $(LOBJECT)

run: $(TARGET)
	./$(TARGET)