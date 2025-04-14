#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "error_reporter.h"

void init_error_reporter(ErrorReporter* reporter, const char* filename, int use_colors) {
    reporter->filename = strdup(filename);
    reporter->file_handle = fopen(filename, "r");
    reporter->use_colors = use_colors;
    reporter->line_buffer[0] = '\0';
}

const char* get_line_content(ErrorReporter* reporter, int line_num) {
    if (!reporter->file_handle) {
        return NULL;
    }
    
    // Reset file position to beginning
    fseek(reporter->file_handle, 0, SEEK_SET);
    
    // Read lines until we reach the target line or EOF
    int current_line = 1;
    while (current_line < line_num && fgets(reporter->line_buffer, MAX_LINE_LENGTH, reporter->file_handle)) {
        current_line++;
    }
    
    // If we found the line, return it (removing newline)
    if (current_line == line_num && fgets(reporter->line_buffer, MAX_LINE_LENGTH, reporter->file_handle)) {
        // Remove trailing newline if present
        int len = strlen(reporter->line_buffer);
        if (len > 0 && reporter->line_buffer[len-1] == '\n') {
            reporter->line_buffer[len-1] = '\0';
        }
        return reporter->line_buffer;
    }
    
    return NULL;
}

void report_syntax_error(ErrorReporter* reporter, int line_num, int column, const char* message, const char* expected) {
    const char* line_content = get_line_content(reporter, line_num);
    
    if (reporter->use_colors) {
        fprintf(stderr, "%sSyntax error%s at %s%s:%d:%d%s: %s\n", 
                COLOR_RED, COLOR_RESET,
                COLOR_BLUE, reporter->filename, line_num, column, 
                COLOR_RESET, message);
    } else {
        fprintf(stderr, "Syntax error at %s:%d:%d: %s\n", 
                reporter->filename, line_num, column, message);
    }
    
    if (line_content) {
        fprintf(stderr, "  %s\n", line_content);
        
        // Print marker pointing to error location
        fprintf(stderr, "  ");
        for (int i = 0; i < column - 1; i++) {
            fprintf(stderr, " ");
        }
        
        if (reporter->use_colors) {
            fprintf(stderr, "%s^%s\n", COLOR_RED, COLOR_RESET);
        } else {
            fprintf(stderr, "^\n");
        }
    }
    
    if (expected && expected[0] != '\0') {
        if (reporter->use_colors) {
            fprintf(stderr, "  %sExpected:%s %s\n", COLOR_GREEN, COLOR_RESET, expected);
        } else {
            fprintf(stderr, "  Expected: %s\n", expected);
        }
    }
}

void report_lexical_error(ErrorReporter* reporter, int line_num, int column, const char* token, const char* suggestion) {
    const char* line_content = get_line_content(reporter, line_num);
    
    if (reporter->use_colors) {
        fprintf(stderr, "%sLexical error%s at %s%s:%d:%d%s: Unrecognized token '%s'\n", 
                COLOR_RED, COLOR_RESET,
                COLOR_BLUE, reporter->filename, line_num, column, 
                COLOR_RESET, token);
    } else {
        fprintf(stderr, "Lexical error at %s:%d:%d: Unrecognized token '%s'\n", 
                reporter->filename, line_num, column, token);
    }
    
    if (line_content) {
        fprintf(stderr, "  %s\n", line_content);
        
        // Print marker pointing to error location
        fprintf(stderr, "  ");
        for (int i = 0; i < column - 1; i++) {
            fprintf(stderr, " ");
        }
        
        if (reporter->use_colors) {
            fprintf(stderr, "%s^%s\n", COLOR_RED, COLOR_RESET);
        } else {
            fprintf(stderr, "^\n");
        }
    }
    
    if (suggestion && suggestion[0] != '\0') {
        if (reporter->use_colors) {
            fprintf(stderr, "  %sSuggestion:%s %s\n", COLOR_YELLOW, COLOR_RESET, suggestion);
        } else {
            fprintf(stderr, "  Suggestion: %s\n", suggestion);
        }
    }
}

void cleanup_error_reporter(ErrorReporter* reporter) {
    if (reporter->filename) {
        free(reporter->filename);
        reporter->filename = NULL;
    }
    
    if (reporter->file_handle) {
        fclose(reporter->file_handle);
        reporter->file_handle = NULL;
    }
}
