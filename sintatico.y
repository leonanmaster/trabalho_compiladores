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
map<string,string> tipos_temporarios;
map<pair<string,string>, string> tabela_de_conversao = {
    {{"int","int"}, "int"},
    {{"int","float"}, "float"},
    {{"float","int"}, "float"},
    {{"float","float"}, "float"}
};


int yylex(void);
void yyerror(string);
string gentempcode();
bool precisa_materializar(const atributos&);
void materializa_operando(atributos&, string&);
void converte_para_float(atributos&, string&);
%}

%token TK_NUM TK_ID TK_INT TK_NUM_FLOAT TK_CHAR TK_CARACTER TK_BOOL TK_BOOL_LIT TK_MENOR_IGUAL TK_MAIOR_IGUAL TK_IGUAL_IGUAL TK_DIFERENTE TK_MENOR TK_MAIOR TK_AND TK_FLOAT

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

COMANDO     : TK_ID '=' E ';'
			{
				variavel var = variaveis[$1.label];

				if(var.tipo == "bool" && var.nome_sistema == "") {
					var.nome_sistema = gentempcode();
					tipos_temporarios[var.nome_sistema] = "int";
				}

				if(var.tipo == "float" && var.nome_sistema == "") {
					var.nome_sistema = gentempcode();
					tipos_temporarios[var.nome_sistema] = "float";
				}

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
			|TK_BOOL TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = "";
				var.tipo = "bool";

				variaveis[var.nome_usuario] = var;
				tipos_temporarios[var.nome_sistema] = "int";

				$$.traducao = "";
			}
			| TK_FLOAT TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = "";
				var.tipo = "float";

				variaveis[var.nome_usuario] = var;
				tipos_temporarios[var.nome_sistema] = "int";

				$$.traducao = "";
			}

			| TK_CHAR TK_ID ';'
			{
				variavel var;
				var.nome_usuario = $2.label;
				var.nome_sistema = gentempcode();
				var.tipo = "char";

				variaveis[var.nome_usuario] = var;
				tipos_temporarios[var.nome_sistema] = var.tipo;
			}
			|E  	{$$.traducao = $1.traducao;}

E 			:E '-' T
			{
				atributos esq = $1;
				atributos dir = $3;
				string traducao = "";

				cast = tabela_de_conversao[{esq.tipo, dir.tipo}];

				materializa_operando(esq, traducao);
				if (cast == "float" && esq.tipo == "int") {
					converte_para_float(esq, traducao);
				}

				materializa_operando(dir, traducao);
				if (cast == "float" && dir.tipo == "int") {
					converte_para_float(dir, traducao);
				}

				$$.label = gentempcode();
				$$.tipo = cast;
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + esq.label + " - " + dir.label + ";\n";
			}
			|E '<' T
			{
				$$.label = gentempcode();
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
				 " = " + $1.label + " < " + $3.label + ";\n";
			}
			|E TK_AND T
			{
				$1.label = gentempcode();
				$$.label = gentempcode();
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
				 " = " + $1.label + " && " + $3.label + ";\n";
			}
			|E '>' T
			{
				$$.label = gentempcode();
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
				 " = " + $1.label + " > " + $3.label + ";\n";
			}
			|E '+' T
			{
				atributos esq = $1;
				atributos dir = $3;
				string traducao = "";

				cast = tabela_de_conversao[{esq.tipo, dir.tipo}];

				materializa_operando(esq, traducao);
				if (cast == "float" && esq.tipo == "int") {
					converte_para_float(esq, traducao);
				}

				materializa_operando(dir, traducao);
				if (cast == "float" && dir.tipo == "int") {
					converte_para_float(dir, traducao);
				}

				$$.label = gentempcode();
				$$.tipo = cast;
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + esq.label + " + " + dir.label + ";\n";
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
				atributos esq = $1;
				atributos dir = $3;
				string traducao = "";

				cast = tabela_de_conversao[{esq.tipo, dir.tipo}];

				materializa_operando(esq, traducao);
				if (cast == "float" && esq.tipo == "int") {
					converte_para_float(esq, traducao);
				}

				materializa_operando(dir, traducao);
				if (cast == "float" && dir.tipo == "int") {
					converte_para_float(dir, traducao);
				}

				$$.label = gentempcode();
				$$.tipo = cast;
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + esq.label + " * " + dir.label + ";\n";
			}
			
			| T '/' F
			{
				atributos esq = $1;
				atributos dir = $3;
				string traducao = "";

				cast = tabela_de_conversao[{esq.tipo, dir.tipo}];

				materializa_operando(esq, traducao);
				if (cast == "float" && esq.tipo == "int") {
					converte_para_float(esq, traducao);
				}

				materializa_operando(dir, traducao);
				if (cast == "float" && dir.tipo == "int") {
					converte_para_float(dir, traducao);
				}

				$$.label = gentempcode();
				$$.tipo = cast;
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + esq.label + " / " + dir.label + ";\n";
			}
			| F
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			}
			| '!' F
			{
				$2.label = gentempcode();
				$$.label = gentempcode();

				$$.tipo = "bool";
				tipos_temporarios[$$.label] = "int";
				$$.traducao = $2.traducao + "\t" + $$.label + " = !" + $2.label + ";\n";
			}
F 			: TK_CARACTER
			{
				$$.label = $1.label;
				$$.tipo = "char";
				$$.traducao = "";
			}
			| TK_BOOL_LIT
			{
				$$.label = $1.label;
				$$.tipo = "bool";
				$$.traducao = "";
			}
			|
			TK_NUM
			{
				$$.label = gentempcode();
				$$.tipo = "int";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_NUM_FLOAT
			{
				$$.label = $1.label;
				$$.tipo = "float";
				$$.traducao = "";
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

bool precisa_materializar(const atributos& valor)
{
	return valor.traducao.empty() && !valor.label.empty() && valor.label[0] != 't';
}

void materializa_operando(atributos& valor, string& traducao)
{
	if (!valor.traducao.empty()) {
		traducao += valor.traducao;
		return;
	}

	if (precisa_materializar(valor)) {
		string literal = valor.label;
		valor.label = gentempcode();
		tipos_temporarios[valor.label] = valor.tipo;
		traducao += "\t" + valor.label + " = " + literal + ";\n";
	}
}

void converte_para_float(atributos& valor, string& traducao)
{
	string origem = valor.label;
	valor.label = gentempcode();
	valor.tipo = "float";
	tipos_temporarios[valor.label] = valor.tipo;
	traducao += "\t" + valor.label + " = (float) " + origem + ";\n";
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
