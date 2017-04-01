%{

/* Declarations section */
#include <stdio.h>
#include <string.h>
char *yylval;
void showToken(char *);
void showString();

char buf[100];
char *s;

%}

%x STRING
%option yylineno
%option noyywrap

digit   		([0-9])
letter  		([a-zA-Z])
whitespace		([\t\n ])


%%
\"              { BEGIN STRING; s = buf; }
<STRING>\\\"    { *s++ = '\"'; }
<STRING>\\\     { *s++ = '\\'; }
<STRING>\/     { *s++ = '\/'; }
<STRING>\\b    { *s++ = '\b'; }
<STRING>\\f    { *s++ = '\f'; }
<STRING>\\r    { *s++ = '\r'; }
<STRING>\\n     { *s++ = '\n'; }
<STRING>\\t     { *s++ = '\t'; }

<STRING>\"      { 
                  *s = 0;
                  BEGIN 0;
                  printf("found '%s'\n", buf);
                }
<STRING>\n      { printf("invalid string"); exit(1); }
<STRING>.       { *s++ = *yytext; }





\{                           showToken("OBJ_START");
\}                           showToken("OBJ_END");
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

/* \"[^"\n]*["\n]          showString(); */
