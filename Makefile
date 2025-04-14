CC = gcc
CFLAGS = -Wall -g

all: rust-compiler

rust-compiler: main.o lex.yy.o parser.tab.o
	$(CC) $(CFLAGS) -o rust-compiler main.o lex.yy.o parser.tab.o -lfl

main.o: main.c ast.h parser.tab.h
	$(CC) $(CFLAGS) -c main.c

lex.yy.o: lex.yy.c parser.tab.h
	$(CC) $(CFLAGS) -c lex.yy.c

parser.tab.o: parser.tab.c ast.h
	$(CC) $(CFLAGS) -c parser.tab.c

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

clean:
	rm -f rust-compiler *.o lex.yy.c parser.tab.c parser.tab.h

test-valid: rust-compiler
	./rust-compiler test_valid.rs

test-invalid: rust-compiler
	./rust-compiler test_invalid.rs

.PHONY: all clean test-valid test-invalid
