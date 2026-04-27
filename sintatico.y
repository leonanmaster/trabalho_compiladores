%{
#include <iostream>
#include <string>
#include <map>
#include <vector>

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

struct literal
{
	string label;
	char   tipo;
};

vector<literal> literais;

struct variavel
{
	string nome_usuario;
	string nome_sistema;
	int    valor;	
};
map<string, variavel> variaveis;

int yylex(void);
void yyerror(string);
string gentempcode(char tipo);
%}

%token TK_NUM TK_ID TK_INT TK_FLOAT

%start S

%left '+' '-' '*' '/' '='

%%

S 			: COMANDOS
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";
				
				for (int i = 0; i < var_temp_qnt; i++){
					if (literais[i].tipo == 'i') {
						codigo_gerado += "\tint " + literais[i].label + ";\n";
					} else if (literais[i].tipo == 'f') {
						codigo_gerado += "\tfloat " + literais[i].label + ";\n";
					}
				}

				codigo_gerado += "\n";

				codigo_gerado += $1.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;

COMANDOS    : COMANDO COMANDOS	{$$.traducao = $1.traducao + $2.traducao;}
		    | COMANDO 			{$$.traducao = $1.traducao;}
			;

COMANDO     : TK_ID '=' E
			{
				variavel var = variaveis[$1.label];
				$$.traducao = $3.traducao + "\t" + var.nome_sistema + " = " + $3.label + ";\n";
			}
			| TK_INT TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = gentempcode('i');
				variaveis[var.nome_usuario] = var;
			}
			|E  	{$$.traducao = $1.traducao;}

E 			:E '-' T
			{
				$$.label = gentempcode('i');
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			} 

			|E '+' T
			{
				$$.label = gentempcode('i');
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
				$$.label = gentempcode('i');
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			
			| T '/' F
			{
				$$.label = gentempcode('i');
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
				$$.label = gentempcode('i');
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_FLOAT
			{
				$$.label = gentempcode('f');
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				variavel var = variaveis[$1.label];
				$$.label     = var.nome_sistema;
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

string gentempcode(char tipo)
{
	var_temp_qnt++;
	string label = "t" + to_string(var_temp_qnt);

	literal lit;
	lit.label = label;
	lit.tipo = tipo;

	literais.push_back(lit);

	return label;
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
