%{
#include "calc.tab.h"
#include <stdlib.h>
%}

%option noyywrap

%%

"#".* { /* Exercise 2.1*/ }

[ \t\n]+                { /* Ignore whitespace and newlines */ }

[0-9]+\.[0-9]+          { 
                            /* Exercise 2.1: Match floats */
                            yylval.fval = atof(yytext); 
                            return FNUM; 
                        }

[0-9]+                  { 
                            /* Match integers */
                            yylval.ival = atoi(yytext); 
                            return NUM; 
                        }

"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return TIMES; }
"/"                     { return DIVIDE; }
"^"                     { return CARET; }  /* Exercise 3.2: Exponentiation operator */
"("                     { return LPAREN; }
")"                     { return RPAREN; }

.                       { printf("Unknown character: %s\n", yytext); }

%%
