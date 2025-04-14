%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;
%}

%option noyywrap

/* Regular expressions for tokens */
DIGIT       [0-9]
ALPHA       [a-zA-Z]
ALPHANUMERIC [a-zA-Z0-9_]
IDENTIFIER  {ALPHA}{ALPHANUMERIC}*
NUMBER      {DIGIT}+
WHITESPACE  [ \t]+
COMMENT     ("//"[^\n]*)

%%

{WHITESPACE}    /* ignore whitespace */
{COMMENT}       /* ignore comments */
\n              { line_num++; }

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

\"([^\"\n]|\\\")*\"  { 
                  yylval.sval = strdup(yytext); 
                  return STRING; 
                }

.               { printf("Lexical error on line %d: Unknown token %s\n", line_num, yytext); }

%%
