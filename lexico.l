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
CARACTERE_CHAR "'"({LETRA}|{ESPACO})"'"
ID {LETRA}({LETRA}|{DIGITO})*

%%

"\n"		{ linha++; }

{DELIM} 	{}

[+*-/=;<>!]		{ return *yytext; }

[()]		{ return *yytext; }



{NUM_FLOAT} {yylval.label = yytext; return TK_NUM_FLOAT;}

{CARACTERE_CHAR} {yylval.label = yytext; return TK_CARACTER;}

"char"     {return TK_CHAR;}

{NUM}		{ yylval.label = yytext; return TK_NUM; }

"int"       { return TK_INT; }

"true"      { yylval.label = "1"; return TK_BOOL_LIT; }

"false"     { yylval.label = "0"; return TK_BOOL_LIT; }

"bool"      { return TK_BOOL; }

"float"     { return TK_FLOAT; }

"(int)"   { return TK_CAST_INT; }

"&&"      { return TK_AND; }

{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
