# Rust Subset Compiler

A compiler implementation for a subset of the Rust programming language using Flex and Bison. This project demonstrates principles of compiler design including lexical analysis, parsing, and syntax validation.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Overview

This compiler processes a subset of Rust language features, providing meaningful error messages and validating syntax. It serves as a demonstration of compiler design principles and language implementation techniques.

## Features

- **Lexical Analysis**: Tokenizes Rust code using Flex
- **Syntax Parsing**: Validates syntax using a Bison-defined grammar
- **Detailed Error Reporting**: Provides clear error messages with line highlighting
- **Support for**:
  - Functions with parameters and return types
  - Variables (mutable and immutable)
  - Control structures (if-else, while, for)
  - Basic types and expressions
  - Function calls and the println! macro

## Getting Started

### Prerequisites

- GCC or compatible C compiler
- Flex (Fast Lexical Analyzer)
- Bison (Parser Generator)
- Make

### Installation

```bash
# Clone the repository
git clone https://github.com/prtmsh/rust-compiler.git
cd rust-compiler

# Build the project
make
```

## Usage

### Analyzing Rust Code

```bash
# Parse a valid Rust file
./rust-compiler path/to/your/code.rs

# Enable debug output
./rust-compiler path/to/your/code.rs -d

# Disable colored output
./rust-compiler path/to/your/code.rs -n
```

### Built-in Test Files

```bash
# Test with the included valid Rust example
make test-valid

# Test with the included invalid Rust example
make test-invalid
```

### Example Output

For a valid Rust file:
```
Parsing Rust code from tests/test_valid.rs
Parsing completed successfully.
```

For a file with errors:
```
Parsing Rust code from tests/test_invalid.rs
Syntax error at tests/test_invalid.rs:5:13: expected ';'
  let x = 10
            ^
  Expected: semicolon to terminate statement
Parsing failed with 1 error(s).
```

## Example Rust Code

This compiler can process code like:

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
        println!("Loop iteration {}", i);
    }
}
```

## Future Enhancements

- Semantic analysis and type checking
- Code generation
- Optimizations
- Support for more Rust features (structs, enums, traits)

## License

This project is open-source and available for educational purposes under the MIT License.
