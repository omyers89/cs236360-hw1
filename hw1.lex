%{

/* Declarations section */
#include <stdio.h>
#include <string.h>
char *yylval;
void showToken(char *);
void showString();
void printErr();
void printEscapeErr(char * name);
char* handleUnicode();
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
hexLetter       ([a-fA-F])
whitespace		([\t\n ])
hexDigit   ({digit}|{hexLetter})
hexTrailer4     ({hexDigit}){4}

%%
\"                          { BEGIN STRING; s = buf; }
<STRING>\\\"                 { *s++ = '\"'; }
<STRING>\\\\                  { *s++ = '\\'; }
<STRING>\\b                  { *s++ = '\b'; }
<STRING>\\f                  { *s++ = '\f'; }
<STRING>\\r                  { *s++ = '\r'; }
<STRING>\\n                  { *s++ = '\n'; }
<STRING>\\t                   { *s++ = '\t'; }
<STRING>\\u{hexTrailer4}    {
                                char* res = handleUnicode();
                                int i;
                                for(i=0;i<strlen(res);i++)
                                    *s++ = res[i];
                                free(res);
                              }
<STRING>\\\/                   { *s++ = '/'; }			  
<STRING>\\[^bfrnt]     { printEscapeErr("Undefined escape sequence"); }

<STRING>\"      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "STRING", buf);
                }
<STRING>\n      { printf("Error unclosed string\n"); exit(0);}
<STRING>.       { *s++ = *yytext; }

\/\/             { BEGIN LN_COMM; s = buf; *s++ = '/'; *s++='/'; }
<LN_COMM>\n      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno-1, "LN_COMMENT", buf);
                }
<LN_COMM>.    { *s++ = *yytext; }

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]     {printf("%d %s %s\n", yylineno, "BK_COMMENT", yytext);}
[/][*]                                  {printf("Error unclosed block comment\n"); exit(0); }

\{                           showToken("OBJ_START");
\}                           showToken("OBJ_END");
\[                           showToken("ARR_START");
\]                           showToken("ARR_END");
:                           showToken("COLON");
,                           showToken("COMMA");

[-+]?{digit}*\.?{digit}+([eE][-+]?{digit}+)?        showToken("NUMBER");


{whitespace}				;
true                showToken("TRUE");
false                showToken("FALSE");
null                showToken("NULL");
<<EOF>>		{showToken("EOF"); exit(1);}
.		            printErr();

%%

void showToken(char * name)
{
        printf("%d %s %s\n", yylineno, name, yytext);
}

void printEscapeErr(char * name){
    printf("Error %s %s\n",name, yytext+1);
    exit(0);
}

void printErr(){
    printf("Error %s\n", yytext);
    exit(0);
}

char* handleUnicode(){

    char prefix = '#';
    int num = (int)strtol(yytext+2, NULL, 16);
    char * buffer = (char *) malloc(strlen(yytext));

    sprintf(buffer,"%c",prefix);
    sprintf(buffer + strlen(buffer),"%d",num);
    sprintf(buffer + strlen(buffer),"%c",prefix);

    return buffer;
}
