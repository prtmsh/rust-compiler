%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int line_num;
extern int debug_mode;
extern int yylex();
extern FILE* yyin;

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d: %s\n", line_num, s);
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
        if (debug_mode) printf("Parsed function: %s\n", $2); 
    }
    | FN IDENTIFIER '(' ')' stmt_block 
                                       { 
        if (debug_mode) printf("Parsed void function: %s\n", $2); 
    }
    | FN IDENTIFIER '(' param_list ')' ARROW type stmt_block    
                                       { 
        if (debug_mode) printf("Parsed function with params: %s\n", $2); 
    }
    | FN IDENTIFIER '(' param_list ')' stmt_block 
                                       { 
        if (debug_mode) printf("Parsed void function with params: %s\n", $2); 
    }
    ;

param_list
    : param                            {}
    | param_list ',' param             {}
    ;

param
    : IDENTIFIER ':' type              {}
    ;

var_declaration
    : LET IDENTIFIER ':' type '=' expr  { 
        if (debug_mode) printf("Parsed variable declaration: %s\n", $2); 
    }
    | LET MUT IDENTIFIER ':' type '=' expr 
                                        { 
        if (debug_mode) printf("Parsed mutable variable: %s\n", $3); 
    }
    | LET IDENTIFIER '=' expr           { 
        if (debug_mode) printf("Parsed inferred variable: %s\n", $2); 
    }
    | LET MUT IDENTIFIER '=' expr       { 
        if (debug_mode) printf("Parsed mutable inferred variable: %s\n", $3); 
    }
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
    | fn_call ';'                      {}
    | return_stmt ';'                  {}
    | conditional_expr                 {}
    | while_loop                       {}
    | for_loop                         {}
    | stmt_block                       {}
    ;

expr
    : primary_expr                     {}
    | expr '+' expr                    {}
    | expr '-' expr                    {}
    | expr '*' expr                    {}
    | expr '/' expr                    {}
    | expr '<' expr                    {}
    | expr '>' expr                    {}
    | expr EQ expr                     {}
    | expr NE expr                     {}
    | expr LE expr                     {}
    | expr GE expr                     {}
    | expr AND expr                    {}
    | expr OR expr                     {}
    | '!' expr                         {}
    | '-' expr %prec UMINUS           {}
    | fn_call                          {}
    | range_expr                       {}
    ;

primary_expr
    : IDENTIFIER                       {}
    | INTEGER                          {}
    | TRUE                             {}
    | FALSE                            {}
    | STRING                           {}
    | '(' expr ')'                     {}
    ;

expr_list
    : expr                             {}
    | expr_list ',' expr               {}
    | /* empty */                      {}
    ;

fn_call
    : IDENTIFIER '(' expr_list ')'     { 
        if (debug_mode) printf("Parsed function call: %s\n", $1); 
    }
    | PRINTLN '(' expr_list ')'        { 
        if (debug_mode) printf("Parsed println statement\n"); 
    }
    ;

conditional_expr
    : IF expr stmt_block               { 
        if (debug_mode) printf("Parsed if statement\n"); 
    }
    | IF expr stmt_block ELSE stmt_block { 
        if (debug_mode) printf("Parsed if-else statement\n"); 
    }
    | IF expr stmt_block ELSE conditional_expr { 
        if (debug_mode) printf("Parsed if-else-if statement\n"); 
    }
    ;

while_loop
    : WHILE expr stmt_block            { 
        if (debug_mode) printf("Parsed while loop\n"); 
    }
    ;

for_loop
    : FOR IDENTIFIER IN expr stmt_block { 
        if (debug_mode) printf("Parsed for loop\n"); 
    }
    ;

range_expr
    : expr RANGE expr                  { 
        if (debug_mode) printf("Parsed range expression\n"); 
    }
    ;

assignment
    : IDENTIFIER '=' expr              { 
        if (debug_mode) printf("Parsed assignment to %s\n", $1); 
    }
    ;

return_stmt
    : RETURN expr                      { 
        if (debug_mode) printf("Parsed return statement\n"); 
    }
    | RETURN                           { 
        if (debug_mode) printf("Parsed void return\n"); 
    }
    ;

%%
