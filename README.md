# Rust Subset Compiler

A compiler implementation for a subset of the Rust programming language using Flex and Bison.

## Project Overview

This project implements a lexical analyzer and syntax parser for a significant subset of the Rust programming language. It demonstrates fundamental compiler design principles including tokenization, parsing, and syntax validation.

## Repository Structure

```
rust-compiler/
├── include/               # Header files
│   ├── ast.h             # Abstract Syntax Tree definitions
│   └── error_reporter.h  # Error reporting utilities
├── src/                   # Source code
│   ├── main.c            # Main entry point
│   ├── error_reporter.c  # Error reporting implementation
│   ├── lexer.l           # Flex specification for lexical analysis
│   └── parser.y          # Bison specification for syntax analysis
├── tests/                 # Test Rust files
│   ├── test_valid.rs     # Valid Rust code examples
│   └── test_invalid.rs   # Invalid Rust code examples
├── build/                 # Build artifacts (created during build)
├── Makefile              # Build automation
└── README.md             # Project documentation
```

## Features

- **Lexical Analysis**: Tokenizes Rust code into language components using Flex
- **Syntax Analysis**: Parses token streams using a context-free grammar defined in Bison
- **Error Reporting**: Provides descriptive error messages with line highlighting
- **AST Construction**: Structure defined for Abstract Syntax Tree representation
- **Support for Core Rust Features**:
  - Function declarations with return types
  - Variable declarations (mutable and immutable)
  - Basic types (i32, f64, bool, String)
  - Control structures (if-else, while, for)
  - Expressions and operators
  - Function calls
  - println! macro (simplified)

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
    
    // For loop with range
    for i in 0..5 {
        println!("Loop iteration", i);
    }
}
```

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
