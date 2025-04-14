%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/ast.h"
#include "../include/error_reporter.h"
#include "parser.tab.h"

int line_num = 1;
int column_num = 1;
int token_start_column = 1;
extern int debug_mode;
ErrorReporter error_reporter;

void update_location() {
    token_start_column = column_num;
    column_num += yyleng;
}

void count_newlines() {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\n') {
            line_num++;
            column_num = 1;
        } else {
            column_num++;
        }
    }
}

void lexical_error(const char* token) {
    char suggestion[256] = "";
    
    // Provide suggestions for common errors
    if (strcmp(token, ".") == 0) {
        strcpy(suggestion, "Did you mean '..' for range operator?");
    } else if (strcmp(token, "..=") == 0) {
        strcpy(suggestion, "The inclusive range operator '..=' is not supported in this subset. Use '..' instead.");
    } else if (strcmp(token, "=>") == 0) {
        strcpy(suggestion, "Did you mean '->' for function return type?");
    }
    
    report_lexical_error(&error_reporter, line_num, token_start_column, token, suggestion);
}

%}

%option noyywrap

/* Regular expressions for tokens */
DIGIT       [0-9]
ALPHA       [a-zA-Z_]
IDENTIFIER  {ALPHA}({ALPHA}|{DIGIT})*
NUMBER      {DIGIT}+
WHITESPACE  [ \t\r]+
STRING      \"([^\"\n]|\\.)*\"
CHAR        '([^'\n]|\\.)'

%%

{WHITESPACE}    { update_location(); /* ignore whitespace */ }
\n              { line_num++; column_num = 1; /* Track line numbers */ }

"//"[^\n]*      { update_location(); /* Single-line comment - ignore */ }

"/*"            { 
                  update_location();
                  int c;
                  int start_line = line_num;
                  int nested = 1;
                  
                  while ((c = input()) != 0) {
                      if (c == '\n') {
                          line_num++;
                          column_num = 1;
                      } else {
                          column_num++;
                      }
                      
                      if (c == '/' && (c = input()) == '*') {
                          column_num++;
                          nested++;
                      } else if (c == '*' && (c = input()) == '/') {
                          column_num++;
                          if (--nested == 0) break;
                      } else if (c == 0) {
                          report_syntax_error(&error_reporter, start_line, token_start_column, 
                                            "Unclosed comment", "/* must be closed with */");
                          break;
                      }
                  }
                }

"fn"            { update_location(); return FN; }
"let"           { update_location(); return LET; }
"mut"           { update_location(); return MUT; }
"if"            { update_location(); return IF; }
"else"          { update_location(); return ELSE; }
"while"         { update_location(); return WHILE; }
"for"           { update_location(); return FOR; }
"in"            { update_location(); return IN; }
"return"        { update_location(); return RETURN; }
"true"          { update_location(); return TRUE; }
"false"         { update_location(); return FALSE; }

"i32"           { update_location(); return INT_TYPE; }
"f64"           { update_location(); return FLOAT_TYPE; }
"bool"          { update_location(); return BOOL_TYPE; }
"String"        { update_location(); return STRING_TYPE; }
"println!"      { update_location(); return PRINTLN; }

"=="            { update_location(); return EQ; }
"!="            { update_location(); return NE; }
"<="            { update_location(); return LE; }
">="            { update_location(); return GE; }
"&&"            { update_location(); return AND; }
"||"            { update_location(); return OR; }
"->"            { update_location(); return ARROW; }
".."            { update_location(); return RANGE; }

[(){}\[\],;:]   { update_location(); return yytext[0]; }
"+"             { update_location(); return '+'; }
"-"             { update_location(); return '-'; }
"*"             { update_location(); return '*'; }
"/"             { update_location(); return '/'; }
"<"             { update_location(); return '<'; }
">"             { update_location(); return '>'; }
"="             { update_location(); return '='; }
"!"             { update_location(); return '!'; }

{IDENTIFIER}    { 
                  update_location();
                  yylval.sval = strdup(yytext); 
                  return IDENTIFIER; 
                }

{NUMBER}        { 
                  update_location();
                  yylval.ival = atoi(yytext); 
                  return INTEGER; 
                }

{STRING}        {
                  update_location();
                  /* Remove the quotes */
                  yytext[strlen(yytext)-1] = '\0';
                  yylval.sval = strdup(yytext+1); 
                  return STRING;
                }

.               { 
                  update_location();
                  lexical_error(yytext);
                }

%%
