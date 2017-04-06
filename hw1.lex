%{

/* Declarations section */
#include <stdio.h>
#include <string.h>
char *yylval;
void showToken(char *);
void showString();
void printErr();
void printEscapeErr(char * name);
char* handleAsciiChar();
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
E               ([Ee][+-]?{digit}+)
asciiTrailer    ({digit}{digit}{digit}{digit})

%%
\"                          { BEGIN STRING; s = buf; }
<STRING>\\\"                 { *s++ = '\"'; }
<STRING>\\\                  { *s++ = '\\'; }
<STRING>\\b                  { *s++ = '\b'; }
<STRING>\\f                  { *s++ = '\f'; }
<STRING>\\r                  { *s++ = '\r'; }
<STRING>\\n                  { *s++ = '\n'; }
<STRING>\\t                   { *s++ = '\t'; }
<STRING>\\u{asciiTrailer}     {
                                char* res = handleAsciiChar();
                                int i;
                                printf("RES: %s\n", res);
                                for(i=0;i<6;i++)
                                    *s++ = res[i];
                                free(res);
                              }
<STRING>\\[^bfrntu]     { printEscapeErr("Undefined escape sequence"); }

<STRING>\"      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "STRING", buf);
                }
<STRING>\n      { printf("Error unclosed string\n"); exit(0);}
<STRING>.       { *s++ = *yytext; }

\/\/             { BEGIN LN_COMM; s = buf; }
<LN_COMM>\n      { 
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno-1, "LN_COMMENT", buf);
                }
<LN_COMM>.    { *s++ = *yytext; }

\/\*            { BEGIN BK_COMM; s = buf; *s++ = '/'; *s++='*';}
<BK_COMM>\*\/      { 
                    
                    *s++='*';
                  *s++ = '/';
                  *s = 0;
                  BEGIN 0;
                  printf("%d %s %s\n", yylineno, "BK_COMMENT", buf);
                }

<BK_COMM>"EOF"    { printf("Error unclosed block comment\n"); exit(0);}
<BK_COMM>.    { *s++ = *yytext; }


\{                           showToken("OBJ_START");
\}                           showToken("OBJ_END");
\[                           showToken("ARR_START");
\]                           showToken("ARR_END");
:                           showToken("COLON");
,                           showToken("COMMA");
{digit}+.{digit}+{E}?		showToken("NUMBER");
{digit}+{E}?          			showToken("NUMBER");


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

//not used
void showString()
{
    
    yylval = strdup(yytext+1);
    if (yylval[yyleng-2] != '"')
       printf("improperly terminated string");
    else
        yylval[yyleng-2] = 0;
    printf("%d %s %s\n", yylineno, "STRING", yylval);
    //printf("found '%s'\n", yylval);
}

void printEscapeErr(char * name){
    printf("Error %s %s\n",name, yytext+1);
    exit(0);
}

void printErr(){
    printf("Error %s\n", yytext);
    exit(0);
}

char* handleAsciiChar(){

    char prefix = '#';
    int num = (int)strtol(yytext+2, NULL, 16);
    char * buffer = (char *) malloc(strlen(yytext));

    sprintf(buffer,"%c",prefix);
    sprintf(buffer + strlen(buffer),"%d",num);
    sprintf(buffer + strlen(buffer),"%c",prefix);

    return buffer;
}



/* \"[^"\n]*["\n]          showString(); */
/* doing nothing */
/*{digit}+.{digit}+          			showToken("NUMBER");
{digit}+          			showToken("NUMBER");
*/
