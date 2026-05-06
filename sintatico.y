%{
#include <iostream>
#include <string>
#include <map>
#include <utility>

#define YYSTYPE atributos
#define true 1
#define false 0
using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;
string cast;
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
map<string,string> tipos_temporarios; /* Esta tabela mapeia o nome da var temporaria (t1, t2 etc) pro tipo dela. */

map<pair<string,string>, string> tabela_de_conversao = {
    {{"int","int"}, "int"},
    {{"int","float"}, "float"},
    {{"float","int"}, "float"},
    {{"float","float"}, "float"}
};


int yylex(void);
void yyerror(string);
string gentempcode(string tipo);
bool precisa_materializar(const atributos&);
void materializa_operando(atributos&, string&);
void converte_para_float(atributos&, string&);
%}

%token TK_NUM TK_ID TK_INT TK_NUM_FLOAT TK_CHAR TK_CARACTER TK_BOOL TK_BOOL_LIT TK_MENOR_IGUAL TK_MAIOR_IGUAL TK_IGUAL_IGUAL TK_DIFERENTE TK_MENOR TK_MAIOR TK_AND TK_OR TK_FLOAT TK_CAST_INT

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
					string tipo = tipos_temporarios[nome_temp];

					codigo_gerado += "\t" + tipo + " " + nome_temp + ";\n";
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

COMANDO     : TK_ID '=' E ';'
			{
				variavel var = variaveis[$1.label];
				$$.traducao = $3.traducao + "\t" + var.nome_sistema + " = " + $3.label + ";\n";
			}
			| TK_INT TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = gentempcode("int");
				var.tipo = "int";
				variaveis[var.nome_usuario] = var;


				$$.traducao = "";
			}
			| TK_FLOAT TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = gentempcode("float");
				var.tipo = "float";

				variaveis[var.nome_usuario] = var;

				$$.traducao = "";
			}

			| TK_CHAR TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = gentempcode("char");
				var.tipo = "char";

				variaveis[var.nome_usuario] = var;
				$$.traducao = "";
			}
			|E  	{$$.traducao = $1.traducao;}

E 			:E '-' T
			{
				/* O tipo de $$ dependerá dos tipos dos operandos. POR HORA, VOU COLOCAR INT. Mas precisará checar os tipos */
				$$.label = gentempcode("int");

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			|E '+' T
			{
				$$.label = gentempcode("int");

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
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			
			| T '/' F
			{
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| F
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			}
			;

F 			: TK_NUM
			{
				$$.label = gentempcode("int");
				$$.tipo = "int";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_NUM_FLOAT
			{
				$$.label = gentempcode("float");
				$$.tipo = "float";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				/* VERIFICAR SE JÁ ESTÁ DECLARADA */
				variavel var = variaveis[$1.label];
				$$.label = var.nome_sistema;
			}
			| TK_CARACTER
			{
				$$.label = gentempcode("char");
				$$.tipo  = "char";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

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

string gentempcode(string tipo)
{
	var_temp_qnt++;
	string nome = "t" + to_string(var_temp_qnt);
	tipos_temporarios[nome] = tipo;

	return nome;
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
