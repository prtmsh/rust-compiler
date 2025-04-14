#ifndef AST_H
#define AST_H

// Enum for different types of AST nodes
typedef enum {
    NODE_PROGRAM,
    NODE_FUNCTION,
    NODE_VAR_DECL,
    NODE_STATEMENT,
    NODE_EXPR,
    NODE_IF,
    NODE_WHILE,
    NODE_FOR,
    NODE_RETURN,
    NODE_ASSIGNMENT,
    NODE_IDENTIFIER,
    NODE_INTEGER,
    NODE_STRING,
    NODE_BOOLEAN,
    NODE_BINARY_OP,
    NODE_UNARY_OP,
    NODE_FUNC_CALL
} NodeType;

// Structure for AST nodes
struct ASTNode {
    NodeType type;
    union {
        // For identifiers and strings
        struct {
            char* value;
        } id;
        
        // For integer literals
        struct {
            int value;
        } integer;
        
        // For binary operations
        struct {
            struct ASTNode* left;
            int op;  // Operator token
            struct ASTNode* right;
        } binary_op;
        
        // For function declarations
        struct {
            char* name;
            struct ASTNode* params;
            char* return_type;
            struct ASTNode* body;
        } function;
        
        // For variable declarations
        struct {
            char* name;
            char* type;
            int is_mutable;
            struct ASTNode* init_expr;
        } var_decl;
        
        // For if statements
        struct {
            struct ASTNode* condition;
            struct ASTNode* if_body;
            struct ASTNode* else_body;
        } if_stmt;
        
        // For while loops
        struct {
            struct ASTNode* condition;
            struct ASTNode* body;
        } while_loop;
        
        // For function calls
        struct {
            char* func_name;
            struct ASTNode* args;
        } func_call;
    } data;
};

// Function prototypes for AST manipulation
struct ASTNode* create_node(NodeType type);
void free_ast(struct ASTNode* node);

#endif // AST_H
