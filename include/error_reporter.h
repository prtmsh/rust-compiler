#ifndef ERROR_REPORTER_H
#define ERROR_REPORTER_H

#include <stdio.h>

// ANSI color codes for terminal output
#define COLOR_RED     "\x1b[31m"
#define COLOR_GREEN   "\x1b[32m"
#define COLOR_YELLOW  "\x1b[33m"
#define COLOR_BLUE    "\x1b[34m"
#define COLOR_MAGENTA "\x1b[35m"
#define COLOR_RESET   "\x1b[0m"

// Maximum line length for source code
#define MAX_LINE_LENGTH 1024

// Error reporter context
typedef struct {
    char* filename;
    FILE* file_handle;
    char line_buffer[MAX_LINE_LENGTH];
    int use_colors;
} ErrorReporter;

// Initialize the error reporter
void init_error_reporter(ErrorReporter* reporter, const char* filename, int use_colors);

// Print a syntax error with line highlighting
void report_syntax_error(ErrorReporter* reporter, int line_num, int column, const char* message, const char* expected);

// Print a lexical error with line highlighting
void report_lexical_error(ErrorReporter* reporter, int line_num, int column, const char* token, const char* suggestion);

// Clean up error reporter resources
void cleanup_error_reporter(ErrorReporter* reporter);

// Get the current line from source file
const char* get_line_content(ErrorReporter* reporter, int line_num);

#endif // ERROR_REPORTER_H
