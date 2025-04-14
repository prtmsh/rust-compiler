%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int line_num;
extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
    int ival;
    char* sval;
    struct ASTNode* node;
}

/* Token declarations */
%token FN LET MUT IF ELSE WHILE FOR IN RETURN
%token TRUE FALSE INT_TYPE FLOAT_TYPE BOOL_TYPE STRING_TYPE PRINTLN
%token EQ NE LE GE AND OR ARROW
%token <sval> IDENTIFIER STRING
%token <ival> INTEGER

/* Non-terminal type declarations */
%type <node> program decl_list declaration fn_declaration var_declaration
%type <node> type stmt_block stmt_list statement expr expr_list fn_call
%type <node> primary_expr conditional_expr while_loop for_loop
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
    : decl_list                        { printf("Valid Rust program\n"); }
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
                                       { printf("Parsed function: %s\n", $2); }
    | FN IDENTIFIER '(' ')' stmt_block 
                                       { printf("Parsed void function: %s\n", $2); }
    ;

var_declaration
    : LET IDENTIFIER ':' type '=' expr  { printf("Parsed variable declaration: %s\n", $2); }
    | LET MUT IDENTIFIER ':' type '=' expr 
                                        { printf("Parsed mutable variable: %s\n", $3); }
    | LET IDENTIFIER '=' expr           { printf("Parsed inferred variable: %s\n", $2); }
    | LET MUT IDENTIFIER '=' expr       { printf("Parsed mutable inferred variable: %s\n", $3); }
    ;

type
    : INT_TYPE                         {}
    | FLOAT_TYPE                       {}
    | BOOL_TYPE                        {}
    | STRING_TYPE                      {}
    ;

stmt_block
    : '{' stmt_list '}'                {}
    | '{' '}'                          {}
    ;

stmt_list
    : statement                        {}
    | stmt_list statement              {}
    ;

statement
    : var_declaration ';'              {}
    | assignment ';'                   {}
    | expr ';'                         {}
    | conditional_expr                 {}
    | while_loop                       {}
    | for_loop                         {}
    | return_stmt ';'                  {}
    | PRINTLN '(' expr_list ')' ';'    { printf("Parsed println statement\n"); }
    | ';'                              {}
    ;

assignment
    : IDENTIFIER '=' expr              { printf("Parsed assignment to %s\n", $1); }
    ;

expr
    : primary_expr                     {}
    | expr '+' expr                    {}
    | expr '-' expr                    {}
    | expr '*' expr                    {}
    | expr '/' expr                    {}
    | expr EQ expr                     {}
    | expr NE expr                     {}
    | expr '<' expr                    {}
    | expr '>' expr                    {}
    | expr LE expr                     {}
    | expr GE expr                     {}
    | expr AND expr                    {}
    | expr OR expr                     {}
    | '!' expr                         {}
    | '-' expr %prec UMINUS           {}
    | '(' expr ')'                     {}
    | fn_call                          {}
    ;

primary_expr
    : IDENTIFIER                       {}
    | INTEGER                          {}
    | STRING                           {}
    | TRUE                             {}
    | FALSE                            {}
    ;

expr_list
    : expr                             {}
    | STRING                           {}
    | expr_list ',' expr               {}
    | expr_list ',' STRING             {}
    ;

fn_call
    : IDENTIFIER '(' ')'               { printf("Parsed function call: %s\n", $1); }
    | IDENTIFIER '(' expr_list ')'     { printf("Parsed function call with args: %s\n", $1); }
    ;

conditional_expr
    : IF expr stmt_block               { printf("Parsed if statement\n"); }
    | IF expr stmt_block ELSE stmt_block 
                                       { printf("Parsed if-else statement\n"); }
    | IF expr stmt_block ELSE conditional_expr 
                                       { printf("Parsed if-else-if statement\n"); }
    ;

while_loop
    : WHILE expr stmt_block            { printf("Parsed while loop\n"); }
    ;

for_loop
    : FOR IDENTIFIER IN expr stmt_block 
                                       { printf("Parsed for loop\n"); }
    ;

return_stmt
    : RETURN                           { printf("Parsed return statement\n"); }
    | RETURN expr                      { printf("Parsed return with expression\n"); }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d: %s\n", line_num, s);
}
