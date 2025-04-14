CC = gcc
CFLAGS = -Wall -g -I./include

SRC_DIR = src
INC_DIR = include
BUILD_DIR = build
TESTS_DIR = tests

SRCS = $(SRC_DIR)/main.c $(SRC_DIR)/error_reporter.c
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/lex.yy.o $(BUILD_DIR)/parser.tab.o $(BUILD_DIR)/error_reporter.o

all: dirs rust-compiler

dirs:
	@mkdir -p $(BUILD_DIR)

rust-compiler: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ -lfl

$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c $(INC_DIR)/ast.h $(BUILD_DIR)/parser.tab.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/lex.yy.o: $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/parser.tab.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/parser.tab.o: $(BUILD_DIR)/parser.tab.c $(INC_DIR)/ast.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/error_reporter.o: $(SRC_DIR)/error_reporter.c $(INC_DIR)/error_reporter.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/lex.yy.c: $(SRC_DIR)/lexer.l $(BUILD_DIR)/parser.tab.h
	flex -o $@ $<

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: $(SRC_DIR)/parser.y
	bison -d -o $(BUILD_DIR)/parser.tab.c $<

clean:
	rm -rf $(BUILD_DIR) rust-compiler

test-valid: rust-compiler
	./rust-compiler $(TESTS_DIR)/test_valid.rs

test-invalid: rust-compiler
	./rust-compiler $(TESTS_DIR)/test_invalid.rs --debug

.PHONY: all clean test-valid test-invalid dirs
