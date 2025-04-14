#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern FILE* yyin;
extern int yyparse(void);

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file.rs>\n", argv[0]);
        return 1;
    }

    // Open the input file
    FILE* input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Cannot open input file %s\n", argv[1]);
        return 1;
    }

    // Set flex to read from the input file
    yyin = input;

    printf("Parsing Rust code from %s\n", argv[1]);
    
    // Parse the input
    int result = yyparse();
    
    // Close the input file
    fclose(input);
    
    if (result == 0) {
        printf("Parsing completed successfully.\n");
        return 0;
    } else {
        printf("Parsing failed.\n");
        return 1;
    }
}
