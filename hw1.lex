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
%x LN_COMM
%x BK_COMM
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
<STRING>\\u     { *s++ = '\u'; }
<STRING>\"      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "STRING", buf);
                }
<STRING>\n      { printf("invalid string"); exit(1); }
<STRING>.       { *s++ = *yytext; }

//             { BEGIN LN_COMM; s = buf; }
<STRING>\n      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "LN_COMMENT", buf);
                }
<LN_COMM>.    { *s++ = *yytext; }

/\*            { BEGIN BK_COMMENT; s = buf; }
<STRING>\*/      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "BK_COMMENT", buf);
                }
<LN_COMM>.    { *s++ = *yytext; }


\{                           showToken("OBJ_START");
\}                           showToken("OBJ_END");
[                           showToken("ARR_START");
]                           showToken("ARR_END");
:                           showToken("COLON");
,                           showToken("COMMA");
{digit}+          			showToken("NUMBER");
{whitespace}				;
true                showToken("TRUE");
false                showToken("FALSE");
null                showToken("NULL");

//



.		printf("Lex doesn't know what that is!\n %s", yytext);

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
    printf("%d %s %s\n", yylineno, name, yylval);
    //printf("found '%s'\n", yylval);
}

/* \"[^"\n]*["\n]          showString(); */
