#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "error_reporter.h"

extern FILE* yyin;
extern int yyparse(void);
extern int line_num;
extern int column_num;
extern ErrorReporter error_reporter;

int debug_mode = 0;
int use_colors = 1; // Default to using colors

void print_usage(const char* program_name) {
    fprintf(stderr, "Usage: %s <input_file.rs> [options]\n", program_name);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -d, --debug     Enable debug mode\n");
    fprintf(stderr, "  -n, --no-color  Disable colored output\n");
    fprintf(stderr, "  -h, --help      Show this help message\n");
}

int main(int argc, char* argv[]) {
    char* filename = NULL;
    
    // Parse command line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--debug") == 0) {
            debug_mode = 1;
        } else if (strcmp(argv[i], "-n") == 0 || strcmp(argv[i], "--no-color") == 0) {
            use_colors = 0;
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (!filename) {
            filename = argv[i];
        } else {
            print_usage(argv[0]);
            return 1;
        }
    }
    
    if (!filename) {
        print_usage(argv[0]);
        return 1;
    }

    // Open the input file
    FILE* input = fopen(filename, "r");
    if (!input) {
        fprintf(stderr, "Cannot open input file %s\n", filename);
        return 1;
    }

    // Initialize the error reporter
    init_error_reporter(&error_reporter, filename, use_colors);

    // Set flex to read from the input file
    yyin = input;

    printf("Parsing Rust code from %s\n", filename);
    if (debug_mode) {
        printf("Debug mode enabled\n");
    }
    
    // Reset line counter
    line_num = 1;
    column_num = 1;
    
    // Parse the input
    int result = yyparse();
    
    // Close the input file
    fclose(input);
    
    // Clean up error reporter
    cleanup_error_reporter(&error_reporter);
    
    if (result == 0) {
        printf("Parsing completed successfully.\n");
        return 0;
    } else {
        printf("Parsing failed with %d error(s).\n", result);
        return 1;
    }
}
