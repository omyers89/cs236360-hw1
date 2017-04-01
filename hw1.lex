%{

/* Declarations section */
#include <stdio.h>
#include <string.h>
char *yylval;
void showToken(char *);
void showString();
%}

%option yylineno
%option noyywrap

digit   		([0-9])
letter  		([a-zA-Z])
whitespace		([\t\n ])


%%
\"[^"\n]*["\n]          showString();

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

void showString()
{
    yylval = strdup(yytext+1);
    if (yylval[yyleng-2] != '"')
       printf("improperly terminated string");
    else
        yylval[yyleng-2] = 0;
    printf("found '%s'\n", yylval);
}
