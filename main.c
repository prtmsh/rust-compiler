#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern FILE* yyin;
extern int yyparse(void);
extern int line_num;
int debug_mode = 0;

void print_usage(const char* program_name) {
    fprintf(stderr, "Usage: %s <input_file.rs> [-d]\n", program_name);
    fprintf(stderr, "  -d    Enable debug mode\n");
}

int main(int argc, char* argv[]) {
    char* filename = NULL;
    
    // Parse command line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-d") == 0) {
            debug_mode = 1;
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

    // Set flex to read from the input file
    yyin = input;

    printf("Parsing Rust code from %s\n", filename);
    if (debug_mode) {
        printf("Debug mode enabled\n");
    }
    
    // Reset line counter
    line_num = 1;
    
    // Parse the input
    int result = yyparse();
    
    // Close the input file
    fclose(input);
    
    if (result == 0) {
        printf("Parsing completed successfully.\n");
        return 0;
    } else {
        printf("Parsing failed with %d error(s).\n", result);
        return 1;
    }
}
