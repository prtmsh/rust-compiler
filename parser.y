%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "error_reporter.h"

extern int line_num;
extern int column_num;
extern int token_start_column;
extern int debug_mode;
extern int yylex();
extern FILE* yyin;
extern ErrorReporter error_reporter;

// Keep track of parsing context
char current_context[256] = "";

void set_context(const char* ctx) {
    strncpy(current_context, ctx, sizeof(current_context) - 1);
    current_context[sizeof(current_context) - 1] = '\0';
}

void yyerror(const char* s) {
    char message[512];
    char expected[256] = "";
    
    // For "syntax error, unexpected X" messages, extract the unexpected token
    const char* unexpected = strstr(s, "unexpected");
    if (unexpected) {
        snprintf(message, sizeof(message), "%s", s);
        
        // Try to provide context-specific help
        if (strstr(current_context, "function declaration")) {
            strcpy(expected, "function name, parameter list, return type, or function body");
        } else if (strstr(current_context, "variable declaration")) {
            strcpy(expected, "variable name, type, or initializer");
        } else if (strstr(current_context, "expression")) {
            strcpy(expected, "identifier, literal, function call, or operator");
        } else if (strstr(current_context, "statement")) {
            strcpy(expected, "variable declaration, assignment, function call, or control flow statement");
        }
    } else {
        snprintf(message, sizeof(message), "%s in %s", s, 
                 current_context[0] ? current_context : "program");
    }
    
    report_syntax_error(&error_reporter, line_num, token_start_column, message, expected);
}

%}

%union {
    int ival;
    char* sval;
    struct ASTNode* node;
}

/* Token declarations */
%token FN LET MUT IF ELSE WHILE FOR IN RETURN
%token TRUE FALSE INT_TYPE FLOAT_TYPE BOOL_TYPE STRING_TYPE PRINTLN
%token EQ NE LE GE AND OR ARROW RANGE
%token <sval> IDENTIFIER STRING
%token <ival> INTEGER

/* Non-terminal type declarations */
%type <node> program decl_list declaration fn_declaration var_declaration
%type <node> param_list param type stmt_block stmt_list statement expr expr_list fn_call
%type <node> primary_expr conditional_expr while_loop for_loop range_expr
%type <node> assignment return_stmt

/* Operator precedence */
%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%right '!' UMINUS

%start program

%%

program
    : decl_list                        { 
        if (debug_mode) printf("Valid Rust program\n");
    }
    ;

decl_list
    : declaration                      {}
    | decl_list declaration            {}
    ;

declaration
    : fn_declaration                   {}
    | var_declaration ';'              {}
    ;

fn_declaration
    : FN IDENTIFIER '(' ')' ARROW type stmt_block    
                                       { 
        set_context("function declaration");
        if (debug_mode) printf("Parsed function: %s\n", $2); 
    }
    | FN IDENTIFIER '(' ')' stmt_block 
                                       { 
        set_context("function declaration");
        if (debug_mode) printf("Parsed void function: %s\n", $2); 
    }
    | FN IDENTIFIER '(' param_list ')' ARROW type stmt_block    
                                       { 
        set_context("function declaration");
        if (debug_mode) printf("Parsed function with params: %s\n", $2); 
    }
    | FN IDENTIFIER '(' param_list ')' stmt_block 
                                       { 
        set_context("function declaration");
        if (debug_mode) printf("Parsed void function with params: %s\n", $2); 
    }
    ;

param_list
    : param                            { set_context("parameter list"); }
    | param_list ',' param             { set_context("parameter list"); }
    ;

param
    : IDENTIFIER ':' type              { set_context("parameter"); }
    ;

var_declaration
    : LET IDENTIFIER ':' type '=' expr  { 
        set_context("variable declaration");
        if (debug_mode) printf("Parsed variable declaration: %s\n", $2); 
    }
    | LET MUT IDENTIFIER ':' type '=' expr 
                                        { 
        set_context("mutable variable declaration");
        if (debug_mode) printf("Parsed mutable variable: %s\n", $3); 
    }
    | LET IDENTIFIER '=' expr           { 
        set_context("inferred variable declaration");
        if (debug_mode) printf("Parsed inferred variable: %s\n", $2); 
    }
    | LET MUT IDENTIFIER '=' expr       { 
        set_context("mutable inferred variable declaration");
        if (debug_mode) printf("Parsed mutable inferred variable: %s\n", $3); 
    }
    ;

type
    : INT_TYPE                         { set_context("type"); }
    | FLOAT_TYPE                       { set_context("type"); }
    | BOOL_TYPE                        { set_context("type"); }
    | STRING_TYPE                      { set_context("type"); }
    ;

stmt_block
    : '{' stmt_list '}'                { set_context("statement block"); }
    | '{' '}'                          { set_context("empty statement block"); }
    ;

stmt_list
    : statement                        { set_context("statement list"); }
    | stmt_list statement              { set_context("statement list"); }
    ;

statement
    : var_declaration ';'              { set_context("statement"); }
    | assignment ';'                   { set_context("statement"); }
    | fn_call ';'                      { set_context("statement"); }
    | return_stmt ';'                  { set_context("statement"); }
    | conditional_expr                 { set_context("statement"); }
    | while_loop                       { set_context("statement"); }
    | for_loop                         { set_context("statement"); }
    | stmt_block                       { set_context("statement"); }
    ;

expr
    : primary_expr                     { set_context("expression"); }
    | expr '+' expr                    { set_context("addition expression"); }
    | expr '-' expr                    { set_context("subtraction expression"); }
    | expr '*' expr                    { set_context("multiplication expression"); }
    | expr '/' expr                    { set_context("division expression"); }
    | expr '<' expr                    { set_context("less-than expression"); }
    | expr '>' expr                    { set_context("greater-than expression"); }
    | expr EQ expr                     { set_context("equality expression"); }
    | expr NE expr                     { set_context("inequality expression"); }
    | expr LE expr                     { set_context("less-equal expression"); }
    | expr GE expr                     { set_context("greater-equal expression"); }
    | expr AND expr                    { set_context("logical AND expression"); }
    | expr OR expr                     { set_context("logical OR expression"); }
    | '!' expr                         { set_context("logical NOT expression"); }
    | '-' expr %prec UMINUS           { set_context("negation expression"); }
    | fn_call                          { set_context("function call expression"); }
    | range_expr                       { set_context("range expression"); }
    ;

primary_expr
    : IDENTIFIER                       { set_context("identifier"); }
    | INTEGER                          { set_context("integer literal"); }
    | TRUE                             { set_context("boolean literal"); }
    | FALSE                            { set_context("boolean literal"); }
    | STRING                           { set_context("string literal"); }
    | '(' expr ')'                     { set_context("parenthesized expression"); }
    ;

expr_list
    : expr                             { set_context("expression list"); }
    | expr_list ',' expr               { set_context("expression list"); }
    | /* empty */                      { set_context("empty expression list"); }
    ;

fn_call
    : IDENTIFIER '(' expr_list ')'     { 
        set_context("function call");
        if (debug_mode) printf("Parsed function call: %s\n", $1); 
    }
    | PRINTLN '(' expr_list ')'        { 
        set_context("println macro call");
        if (debug_mode) printf("Parsed println statement\n"); 
    }
    ;

conditional_expr
    : IF expr stmt_block               { 
        set_context("if statement");
        if (debug_mode) printf("Parsed if statement\n"); 
    }
    | IF expr stmt_block ELSE stmt_block { 
        set_context("if-else statement");
        if (debug_mode) printf("Parsed if-else statement\n"); 
    }
    | IF expr stmt_block ELSE conditional_expr { 
        set_context("if-else-if statement");
        if (debug_mode) printf("Parsed if-else-if statement\n"); 
    }
    ;

while_loop
    : WHILE expr stmt_block            { 
        set_context("while loop");
        if (debug_mode) printf("Parsed while loop\n"); 
    }
    ;

for_loop
    : FOR IDENTIFIER IN expr stmt_block { 
        set_context("for loop");
        if (debug_mode) printf("Parsed for loop\n"); 
    }
    ;

range_expr
    : expr RANGE expr                  { 
        set_context("range expression");
        if (debug_mode) printf("Parsed range expression\n"); 
    }
    ;

assignment
    : IDENTIFIER '=' expr              { 
        set_context("assignment");
        if (debug_mode) printf("Parsed assignment to %s\n", $1); 
    }
    ;

return_stmt
    : RETURN expr                      { 
        set_context("return statement");
        if (debug_mode) printf("Parsed return statement\n"); 
    }
    | RETURN                           { 
        set_context("void return statement");
        if (debug_mode) printf("Parsed void return\n"); 
    }
    ;

%%
