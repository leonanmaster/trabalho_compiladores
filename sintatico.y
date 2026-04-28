%{
#include <iostream>
#include <string>
#include <map>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};

struct variavel
{
	string nome_usuario;
	string nome_sistema;
	string tipo;	
};
map<string, variavel> variaveis;
map<string,string> tipos_temporarios;

int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_NUM TK_ID TK_INT TK_NUM_FLOAT

%start S

%left '+' '-' '*' '/' '='

%%

S 			: COMANDOS
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";
				
				for (int i = 1; i <= var_temp_qnt; i++){
					string nome_temp = "t" + to_string(i);
					string tipo_temp = "int";

					if (tipos_temporarios.count(nome_temp) > 0) {
						tipo_temp = tipos_temporarios[nome_temp];
					}

					codigo_gerado += "\t" + tipo_temp + " " + nome_temp + ";\n";
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
				var.nome_sistema = gentempcode();
				var.tipo = "int";

				variaveis[var.nome_usuario] = var;
				tipos_temporarios[var.nome_sistema] = var.tipo;

				$$.traducao = "";
			}
			|E  	{$$.traducao = $1.traducao;}

E 			:E '-' T
			{
				$$.label = gentempcode();
				$$.tipo = ($1.tipo == "float" || $3.tipo == "float") ? "float" : "int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			} 

			|E '+' T
			{
				$$.label = gentempcode();
				$$.tipo = ($1.tipo == "float" || $3.tipo == "float") ? "float" : "int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " + " + $3.label + ";\n";
			}
	
			| T
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			}
			;

T 			: T '*' F
			{
				string operando_esq = $1.label;
				string operando_dir = $3.label;

				if ($3.tipo == "float" && $1.tipo != "float") {
					operando_esq = $3.label;
					operando_dir = $1.label;
				}

				$$.label = gentempcode();
				$$.tipo = ($1.tipo == "float" || $3.tipo == "float") ? "float" : "int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + operando_esq + " * " + operando_dir + ";\n";
			}
			
			| T '/' F
			{
				$$.label = gentempcode();
				$$.tipo = ($1.tipo == "float" || $3.tipo == "float") ? "float" : "int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| F
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			}
		
F 			: TK_NUM
			{
				$$.label = gentempcode();
				$$.tipo = "int";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_NUM_FLOAT
			{
				$$.label = gentempcode();
				$$.tipo = "float";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				variavel var = variaveis[$1.label];
				$$.label     = var.nome_sistema;
				$$.tipo = var.tipo;
				$$.traducao = "";
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
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
