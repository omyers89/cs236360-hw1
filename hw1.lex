%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);

%}

%option yylineno
%option noyywrap

digit   		([0-9])
letter  		([a-zA-Z])
whitespace		([\t\n ])

%%
{                           showToken("OBJ_START");
}                           showToken("OBJ_END");
"..."                       showToken("STRING");
:                           showToken("COLON");
,                           showToken("COMMA");
{digit}+          			showToken("number");
{letter}+					showToken("word");
{letter}+@{letter}+\.com		showToken("email address");
{whitespace}				;
.		printf("Lex doesn't know what that is!\n");

%%

void showToken(char * name)
{
        printf("%d %s %s\n", yylineno, name, yytext);
}

