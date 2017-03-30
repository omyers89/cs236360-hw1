%{
    #include "example1.hpp"
    #include "example1.tab.hpp"
%}


%option noyywrap
%option yylineno

%%

false		return FALSE;
true		return TRUE;
&&		return AND;
"||"		return OR;
\n		return '\n';
.               ;

%%