%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
#include "ast.h"

int line_num = 1;
extern int debug_mode;

void lexical_error(const char* message) {
    fprintf(stderr, "Lexical error on line %d: %s\n", line_num, message);
}

%}

%option noyywrap

/* Regular expressions for tokens */
DIGIT       [0-9]
ALPHA       [a-zA-Z_]
IDENTIFIER  {ALPHA}({ALPHA}|{DIGIT})*
NUMBER      {DIGIT}+
WHITESPACE  [ \t\r]+
STRING      \"[^"]*\"

%%

{WHITESPACE}    { /* ignore whitespace */ }
\n              { line_num++; /* Track line numbers */ }

"//"[^\n]*      { /* Single-line comment - ignore */ }
"/*"([^*]|"*"[^/])*"*/"  { 
    /* Multi-line comment - count newlines */
    for (int i = 0; yytext[i] != '\0'; i++) {
        if (yytext[i] == '\n') line_num++;
    }
}

"fn"            { return FN; }
"let"           { return LET; }
"mut"           { return MUT; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"in"            { return IN; }
"return"        { return RETURN; }
"true"          { return TRUE; }
"false"         { return FALSE; }

"i32"           { return INT_TYPE; }
"f64"           { return FLOAT_TYPE; }
"bool"          { return BOOL_TYPE; }
"String"        { return STRING_TYPE; }
"println!"      { return PRINTLN; }

"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }
"&&"            { return AND; }
"||"            { return OR; }
"->"            { return ARROW; }

[(){}\[\],;:]   { return yytext[0]; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"<"             { return '<'; }
">"             { return '>'; }
"="             { return '='; }
"!"             { return '!'; }

{IDENTIFIER}    { 
                  yylval.sval = strdup(yytext); 
                  return IDENTIFIER; 
                }

{NUMBER}        { 
                  yylval.ival = atoi(yytext); 
                  return INTEGER; 
                }

{STRING}        {
                  /* Remove the quotes */
                  yytext[strlen(yytext)-1] = '\0';
                  yylval.sval = strdup(yytext+1); 
                  return STRING;
                }

.               { 
                  char msg[100];
                  snprintf(msg, sizeof(msg), "Unknown token %s", yytext);
                  lexical_error(msg);
                }

%%
