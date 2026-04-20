%{
#include <iostream>
#include <string>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;

struct atributos
{
	string label;
	string traducao;
};

int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_NUM TK_ID

%start S

%left '+' '-' '*' '/' '='

%%

S 			: PROGRAMA
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";
				
				for (int i = 1; i <= var_temp_qnt; i++){
					codigo_gerado += "\tint t" + to_string(i) + ";\n";
				}

				codigo_gerado += "\n";

				codigo_gerado += $1.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;

PROGRAMA    : CMD	{$$.traducao = $1.traducao;}
			| E  	{$$.traducao = $1.traducao;}
			;

CMD         : TK_ID '=' E
			{
				$$.traducao = $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}

E 			:E '-' T
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			} 

			|E '+' T
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " + " + $3.label + ";\n";
			}
	
			| T
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			;

T 			: T '*' F
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			
			| T '/' F
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| F
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
		
F 			: TK_NUM
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
