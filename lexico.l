%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
LETRA [a-zA-Z]

DELIM {ESPACO}+
NUM_FLOAT {DIGITO}+"."{DIGITO}+
NUM {DIGITO}+
ID {LETRA}({LETRA}|{DIGITO})*

%%

"\n"		{ linha++; }

{DELIM} 	{}

[+*-/=;]		{ return *yytext; }

[()]		{ return *yytext; }

{NUM_FLOAT} {yylval.label = yytext; return TK_NUM_FLOAT;}

{NUM}		{ yylval.label = yytext; return TK_NUM; }

"int"       { return TK_INT; }

{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
