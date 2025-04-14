# Rust Subset Compiler

A compiler implementation for a subset of the Rust programming language using Flex and Bison.

## Project Overview

This project implements a lexical analyzer and syntax parser for a significant subset of the Rust programming language. It demonstrates fundamental compiler design principles including tokenization, parsing, and syntax validation.

## Features

- **Lexical Analysis**: Tokenizes Rust code into language components using Flex
- **Syntax Analysis**: Parses token streams using a context-free grammar defined in Bison
- **Error Reporting**: Provides descriptive error messages for invalid syntax
- **AST Construction**: Builds an Abstract Syntax Tree representation (structure defined)
- **Support for Core Rust Features**:
  - Function declarations with return types
  - Variable declarations (mutable and immutable)
  - Basic types (i32, f64, bool, String)
  - Control structures (if-else, while, for)
  - Expressions and operators
  - Function calls
  - println! macro (simplified)

## Technical Implementation

### Context-Free Grammar

The project defines a comprehensive context-free grammar for a subset of Rust, including:

- Program structure
- Function declarations
- Variable declarations and assignments
- Type systems
- Control flow structures
- Expressions and operators
- Function calls

### Project Structure

- **lexer.l**: Flex specification for lexical analysis
- **parser.y**: Bison specification for syntax analysis
- **ast.h**: Abstract Syntax Tree definitions
- **main.c**: Driver program
- **test_valid.rs**: Sample valid Rust code
- **test_invalid.rs**: Sample invalid Rust code with syntax errors
- **Makefile**: Build automation

## Building the Project

### Prerequisites

- GCC (or compatible C compiler)
- Flex (The Fast Lexical Analyzer)
- Bison (Parser Generator)

### Compilation

```bash
# Build the entire project
make

# Clean build artifacts
make clean
```

### Testing

```bash
# Test with valid Rust code
make test-valid

# Test with invalid Rust code
make test-invalid
```

## Syntax Examples

### Valid Rust Code Example

```rust
fn main() {
    let x: i32 = 10;
    let mut y: i32 = 5;
    
    if x > y {
        println!("x is greater than y");
    } else {
        println!("x is not greater than y");
    }
    
    while y < x {
        y = y + 1;
        println!("y is now", y);
    }
}
```

### Grammar Highlights

```
fn_declaration
    : FN IDENTIFIER '(' ')' ARROW type stmt_block    
    | FN IDENTIFIER '(' ')' stmt_block 
    ;

var_declaration
    : LET IDENTIFIER ':' type '=' expr
    | LET MUT IDENTIFIER ':' type '=' expr
    | LET IDENTIFIER '=' expr
    | LET MUT IDENTIFIER '=' expr
    ;

conditional_expr
    : IF expr stmt_block
    | IF expr stmt_block ELSE stmt_block
    | IF expr stmt_block ELSE conditional_expr
    ;
```

## Future Enhancements

- Semantic analysis
- Type checking
- Support for more Rust features (structs, enums, traits)
- Code generation
- Optimization passes

## Educational Value

This project serves as an educational tool for understanding:

1. Compiler design principles
2. Lexical analysis with Flex
3. Parsing with Bison
4. Context-free grammar design
5. Abstract Syntax Tree implementation
6. Basic Rust syntax and semantics

## License

This project is open-source and available for educational purposes.

## Contributors

This project was developed as an academic exercise in compiler design and programming language implementation.
