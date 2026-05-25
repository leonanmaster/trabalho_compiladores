%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
LETRA [a-zA-Z]
SINAL [+-]

DELIM {ESPACO}+
NUM_FLOAT {SINAL}?{DIGITO}+"."{DIGITO}+
NUM {SINAL}?{DIGITO}+
CARACTERE_CHAR "'"({LETRA}|{ESPACO}|{DIGITO})"'"
ID {LETRA}({LETRA}|{DIGITO})*

IGUAL_IGUAL "=="
MAIOR_QUE ">"
MENOR_QUE "<"
MAIOR_IGUAL ">="
MENOR_IGUAL "<="
DIFERENTE "!="

OPERADOR_RELACIONAL {IGUAL_IGUAL}|{MAIOR_QUE}|{MENOR_QUE}|{MAIOR_IGUAL}|{MENOR_IGUAL}|{DIFERENTE}

%%

"\n"		{ linha++; }

{DELIM} 	{}

[+*-/=;]		{ return *yytext; }

[(){}]		{ return *yytext; }



{NUM_FLOAT} {yylval.label = yytext; return TK_NUM_FLOAT;}

{CARACTERE_CHAR} {yylval.label = yytext; return TK_CARACTER;}

"char"     {return TK_CHAR;}

{OPERADOR_RELACIONAL} { yylval.label = yytext; return TK_OPERADOR_RELACIONAL; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }

"int"       { return TK_INT; }

"true"      { yylval.label = "1"; return TK_BOOL_LIT; }

"false"     { yylval.label = "0"; return TK_BOOL_LIT; }

"bool"      { return TK_BOOL; }

"float"     { return TK_FLOAT; }

"(int)"   { return TK_CAST_INT; }
"(float)" { return TK_CAST_FLOAT; }

"not"       { yylval.label = yytext; return TK_NOT; }
"and"       { yylval.label = yytext; return TK_AND; }
"or"        { yylval.label = yytext; return TK_OR; }

"if"        { return TK_IF; }
"else"      { return TK_ELSE; }

"while"     { return TK_WHILE; }
"do"        { return TK_DO; }
"for"       { return TK_FOR; }

"continue"  { return TK_CONTINUE; }
"break"     { return TK_BREAK; }


{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
