%{
    #include "example2.hpp"
    #include "example2.tab.hpp"
%}


%option noyywrap
%option yylineno

%%

[0-9]       yylval.i = yytext[0] - '0'; return NUM;
[a-z]       yylval.c = yytext[0]; return CHAR;
[<>]        return yytext[0];
\n          return '\n';

%%