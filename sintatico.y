%{
#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <utility>

#define YYSTYPE atributos
#define true 1
#define false 0
using namespace std;

int var_temp_qnt;
int label_qnt;
int linha = 1;
string codigo_gerado;
string cast;

struct atributos
{
	string label;
	string traducao;
	string tipo;
	int    tamanho;
};

struct variavel
{
	string nome_usuario;
	string nome_sistema;
	string tipo;
};

// map<string, variavel> variaveis;
vector<map<string, variavel>> pilha_de_tabelas;

vector<string> pilha_labels_fim; // para break
vector<string> pilha_labels_inicio; // para continue

vector<atributos> pilha_exp_switch;

void empilha_escopo() {
	pilha_de_tabelas.push_back(map<string, variavel>());
}
void desempilha_escopo() {
	if (!pilha_de_tabelas.empty()) {
		pilha_de_tabelas.pop_back();
	}
}

map<string,string> tipos_temporarios; /* Esta tabela mapeia o nome da var temporaria (t1, t2 etc) pro tipo dela. */

map<pair<string,string>, string> tabela_de_conversao = {
    {{"int","int"}, "int"},
    {{"int","float"}, "float"},
    {{"float","int"}, "float"},
    {{"float","float"}, "float"},
    {{"int","char"}, ""},
	{{"char","int"}, ""}, 
	{{"float","char"}, ""}, 
	{{"char","float"}, ""},
	{{"char","char"}, ""},
	{{"bool","bool"}, ""},
	{{"int","bool"}, ""},
	{{"bool","int"}, ""},
	{{"float","bool"}, ""},
	{{"bool","float"}, ""},
	{{"char","bool"}, ""},
	{{"bool","char"}, ""}
	/* caso nao queria que seja possivel operar dois tipos, deixe o resultado como string vazia */
};


int yylex(void);
void yyerror(string);
string gentempcode(string tipo);
string genlabelcode();
variavel obtem_variavel(string nome);
atributos gera_operacao(atributos recebedor_resultado, atributos esq, atributos dir, string operador);
atributos gera_operacao_comparacao(atributos recebedor_resultado, atributos esq, atributos dir, string operador);
atributos gera_operacao_logica(atributos recebedor_resultado, atributos esq, atributos dir, string operador);
atributos verifica_not(atributos operando);
bool precisa_materializar(const atributos&);
void materializa_operando(atributos&, string&);
void converte_para_float(atributos&, string&);
int tamanho_string_literal(string literal);
string gera_tamanho_string(string texto, string temp_tamanho);
%}

%token TK_NUM TK_ID TK_INT TK_NUM_FLOAT TK_CHAR TK_CARACTER TK_BOOL TK_BOOL_LIT TK_OPERADOR_RELACIONAL TK_NOT TK_AND TK_OR TK_FLOAT TK_CAST_INT TK_CAST_FLOAT TK_IF TK_ELSE	TK_WHILE TK_DO TK_FOR TK_CONTINUE TK_BREAK TK_SWITCH TK_CASE TK_DEFAULT TK_STRING_LITERAL TK_STRING TK_IN TK_SHIFT_RIGHT TK_OUT TK_SHIFT_LEFT

%nonassoc LOWER_THAN_ELSE
%nonassoc TK_ELSE

%start S

%left '+' '-' '*' '/' '='

%%

S 			: COMANDOS
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <iostream>\n"
								"#include <cstdlib>\n"
								"#include <cstring>\n"
								"using namespace std;\n\n"
								"int main(void) {\n";
				
				for (int i = 1; i <= var_temp_qnt; i++){
					string nome_temp = "t" + to_string(i);
					string tipo = tipos_temporarios[nome_temp];

					if (tipo == "string") {
						codigo_gerado += "\tchar* " + nome_temp + ";\n";
					} else if (tipo == "string_buffer") {
						codigo_gerado += "\tchar " + nome_temp + "[256];\n";
					} else {
						codigo_gerado += "\t" + tipo + " " + nome_temp + ";\n";
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

COMANDO     : TK_ID '=' L ';'
			{
				variavel var_recebedora = obtem_variavel($1.label);
				if (var_recebedora.tipo != $3.tipo) {
					yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $3.tipo + " e " + var_recebedora.tipo);
				} else {
					$$.traducao = $3.traducao + "\t" + var_recebedora.nome_sistema + " = " + $3.label + ";\n";
				}
			}
			| TK_OUT TK_SHIFT_LEFT L ';'
			{
				$$.traducao = $3.traducao + "\tcout << " + $3.label + ";\n";
			}
			| TK_IN TK_SHIFT_RIGHT TK_ID ';'
			{
				variavel var = obtem_variavel($3.label);

				if (var.tipo == "int") {
					$$.traducao = "\tcin >> " + var.nome_sistema + ";\n";
				}
				else if (var.tipo == "float") {
					$$.traducao = "\tcin >> " + var.nome_sistema + ";\n";
				}
				else if (var.tipo == "char") {
					$$.traducao = "\tcin >> " + var.nome_sistema + ";\n";
				}
				else if (var.tipo == "bool") {
					$$.traducao = "\tcin >> " + var.nome_sistema + ";\n";
				}
				else if (var.tipo == "string") {
					string buffer = gentempcode("string_buffer");
					string temp_tamanho = gentempcode("int");
					string temp_tamanho_final = gentempcode("int");

					$$.traducao = "";

					// lê a linha inteira, inclusive com espaços
					$$.traducao += "\tcin >> ws;\n";
					$$.traducao += "\tcin.getline(" + buffer + ", 256);\n";

					// calcula o tamanho sem strlen
					$$.traducao += gera_tamanho_string(buffer, temp_tamanho);

					// aloca dinamicamente
					$$.traducao += "\t" + temp_tamanho_final + " = " + temp_tamanho + " + 1;\n";
					$$.traducao += "\t" + var.nome_sistema + " = (char*) malloc(" + temp_tamanho_final + ");\n";
					$$.traducao += "\tstrcpy(" + var.nome_sistema + ", " + buffer + ");\n";
				}
				else {
					yyerror("tipo invalido para entrada: " + var.tipo);
				}
			}
			
			| TK_INT TK_ID ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back(); // apenas referência para evitar copias desnecessárias
				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("int");
					var.tipo = "int";
					escopo_atual[var.nome_usuario] = var;
				}
				$$.traducao = "";
			}
			| TK_FLOAT TK_ID ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();
				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("float");
					var.tipo = "float";
					escopo_atual[var.nome_usuario] = var;
				}
				$$.traducao = "";
			}
			| TK_CHAR TK_ID ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();
				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("char");
					var.tipo = "char";
					escopo_atual[var.nome_usuario] = var;
				}
				$$.traducao = "";
			}
			| TK_BOOL TK_ID ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();
				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("int");
					var.tipo = "bool";
					escopo_atual[var.nome_usuario] = var;
				}
				$$.traducao = "";
			}
			|L  	{$$.traducao = $1.traducao;}
			| TK_ID '=' TK_CAST_FLOAT TK_ID ';'
			{
				variavel var_recebedora = obtem_variavel($1.label);
				variavel var_fonte = obtem_variavel($4.label);
				if (var_recebedora.tipo != "float") {
					yyerror("tipo incompatível para cast: " + var_recebedora.tipo);
				}
				else {
					$$.tipo = "float";
					$$.traducao = "\t" + var_recebedora.nome_sistema + " = (float) " + var_fonte.nome_sistema + ";\n";
					var_recebedora.tipo = "float";
				tipos_temporarios[var_recebedora.nome_sistema] = "float";
			}
			}
			| TK_ID '=' TK_CAST_INT TK_ID ';'
			{
				variavel var_recebedora = obtem_variavel($1.label);
				variavel var_fonte = obtem_variavel($4.label);
				if (var_recebedora.tipo != "int") {
					yyerror("tipo incompatível para cast: " + var_recebedora.tipo);
				}
				else {
					$$.tipo = "int";
					$$.traducao = "\t" + var_recebedora.nome_sistema + " = (int) " + var_fonte.nome_sistema + ";\n";
					var_recebedora.tipo = "int";
				tipos_temporarios[var_recebedora.nome_sistema] = "int";
			}
			}
			| TK_IF '(' L ')' COMANDO %prec LOWER_THAN_ELSE // para permitir if sem chaves, aplicando apenas ao comando seguinte
			{
				if ($3.tipo != "bool") {
					yyerror("condicao do if deve ser bool, foi fornecido: " + $3.tipo);
				}

				string label_fim = genlabelcode();
				string temp_not = gentempcode("int");
				$$.traducao = $3.traducao +
								"\t" + temp_not + " = !" + $3.label + ";\n" +
								"\tif (" + temp_not + ") goto " + label_fim + ";\n" +
								$5.traducao +
								label_fim + ":\n";

			}
			| TK_IF '(' L ')' COMANDO TK_ELSE COMANDO
			{
				if ($3.tipo != "bool") {
					yyerror("condicao do if deve ser bool, foi fornecido: " + $3.tipo);
				}

				string label_else = genlabelcode();
				string label_fim = genlabelcode();
				string temp_not = gentempcode("int");

				$$.traducao = $3.traducao +

								"\t" + temp_not + " = !" + $3.label + ";\n" +
								"\tif (" + temp_not + ") goto " + label_else + ";\n" +
								$5.traducao +
								"\tgoto " + label_fim + ";\n" +
								label_else + ":\n" +
								$7.traducao +
								label_fim + ":\n";
			}
			| TK_SWITCH '(' L ')'
			{
				if ($3.tipo != "int" && $3.tipo != "char") {
					yyerror("condicao do switch deve ser int ou char, foi fornecido: " + $3.tipo);
				}
				
				pilha_exp_switch.push_back($3);

				string label_inicio = genlabelcode();
				string label_fim = genlabelcode();
				pilha_labels_inicio.push_back(label_inicio);
				pilha_labels_fim.push_back(label_fim);
			}
			'{' CASES '}'
			{
				string label_fim = pilha_labels_fim.back();

				$$.traducao = $3.traducao +
							  $7.traducao +
							  label_fim + ":\n";

				pilha_labels_inicio.pop_back();
				pilha_labels_fim.pop_back();
				pilha_exp_switch.pop_back();							  								
			}
			| TK_WHILE '(' L ')'
			{
				string label_inicio = genlabelcode();
				string label_fim = genlabelcode();
				pilha_labels_inicio.push_back(label_inicio);
				pilha_labels_fim.push_back(label_fim);
			}
			
			COMANDO
			
			{
				if ($3.tipo != "bool") {
					yyerror("condicao do while deve ser bool, foi fornecido: " + $3.tipo);
				}

				string label_inicio = pilha_labels_inicio.back();
            	string label_fim = pilha_labels_fim.back();
				string temp_not = gentempcode("int");

				$$.traducao = label_inicio + ":\n" +
								$3.traducao +
								"\t" + temp_not + " = !" + $3.label + ";\n" +
								"\tif (" + temp_not + ") goto " + label_fim + ";\n" +
								$6.traducao +
								"\tgoto " + label_inicio + ";\n" +
								label_fim + ":\n";
				
				pilha_labels_inicio.pop_back();
				pilha_labels_fim.pop_back();
			}
			| TK_DO 
			{
				string label_inicio = genlabelcode();
				string label_fim = genlabelcode();
				pilha_labels_inicio.push_back(label_inicio);
				pilha_labels_fim.push_back(label_fim);
			}

			COMANDO TK_WHILE '(' L ')' ';'

			{
				if ($6.tipo != "bool") {
					yyerror("condicao do while deve ser bool, foi fornecido: " + $6.tipo);
				}

				string label_inicio = pilha_labels_inicio.back();
				string label_fim = pilha_labels_fim.back();
				string temp_not = gentempcode("int");

				$$.traducao = label_inicio + ":\n" +
								$3.traducao +
								$6.traducao +
								"\t" + temp_not + " = !" + $6.label + ";\n" +
								"\tif (" + temp_not + ") goto " + label_fim + ";\n" +
								"\tgoto " + label_inicio + ";\n" +
								label_fim + ":\n";

				pilha_labels_inicio.pop_back();
                pilha_labels_fim.pop_back();
			}
			| TK_STRING TK_ID ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("string");
					var.tipo = "string";
					escopo_atual[var.nome_usuario] = var;
				}

				$$.traducao = "";
			}
			| TK_FOR '(' TK_ID '=' L ';' L ';' TK_ID '=' L ')' 
			{
				string label_inicio = genlabelcode();
				string label_fim = genlabelcode();
				pilha_labels_inicio.push_back(label_inicio);
				pilha_labels_fim.push_back(label_fim);
			}
			
			COMANDO // pressupoe q for tem a forma for (i = 0; i < 10; i = i + 1), com o contador previamente declarado e sem operadores como i++...

			{
				variavel var_contador = obtem_variavel($3.label);
				if (var_contador.tipo != "int") {
					yyerror("contador de for deve ser int, foi fornecido: " + var_contador.tipo);
				}
				if ($7.tipo != "bool") {
					yyerror("condicao de for deve ser bool, foi fornecido: " + $7.tipo);
				}
				variavel var_atualizacao = obtem_variavel($9.label);
				if (var_atualizacao.tipo != "int") {
					yyerror("atualizacao de for deve ser int, foi fornecido: " + var_atualizacao.tipo);
				}

				string label_inicio = pilha_labels_inicio.back();
				string label_fim = pilha_labels_fim.back();
				string temp_not = gentempcode("int");

				$$.traducao = 	$5.traducao + 
								"\t" + var_contador.nome_sistema + " = " + $5.label + ";\n" + 
								label_inicio + ":\n" + 
								$7.traducao + 
								"\t" + temp_not + " = !" + $7.label + ";\n" +
								"\tif (" + temp_not + ") goto " + label_fim + ";\n" + 
								$14.traducao + 
								$11.traducao + 
								"\t" + var_atualizacao.nome_sistema + " = " + $11.label + ";\n" + 
								"\tgoto " + label_inicio + ";\n" + 
								label_fim + ":\n";
				
				pilha_labels_inicio.pop_back();
                pilha_labels_fim.pop_back();
			}
			| TK_FOR '('
			{
				empilha_escopo();
			}
			TK_INT TK_ID '=' L ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($5.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $5.label);
				} else {
					variavel var;
					var.nome_usuario = $5.label;
					var.nome_sistema = gentempcode("int");
					var.tipo = "int";
					escopo_atual[var.nome_usuario] = var;

					if (var.tipo != $7.tipo) {
						yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $7.tipo + " e " + var.tipo);
					}

					$$.traducao = $7.traducao + "\t" + var.nome_sistema + " = " + $7.label + ";\n";
				}
			}
			L ';' TK_ID '=' L ')'
			{
				string label_inicio = genlabelcode();
				string label_fim = genlabelcode();

				pilha_labels_inicio.push_back(label_inicio);
				pilha_labels_fim.push_back(label_fim);
			}
			COMANDO
			{
				variavel var_contador = obtem_variavel($5.label);

				if (var_contador.tipo != "int") {
					yyerror("contador de for deve ser int, foi fornecido: " + var_contador.tipo);
				}

				if ($10.tipo != "bool") {
					yyerror("condicao de for deve ser bool, foi fornecido: " + $10.tipo);
				}

				variavel var_atualizacao = obtem_variavel($12.label);

				if (var_atualizacao.tipo != "int") {
					yyerror("atualizacao de for deve ser int, foi fornecido: " + var_atualizacao.tipo);
				}

				string label_inicio = pilha_labels_inicio.back();
				string label_fim = pilha_labels_fim.back();
				string temp_not = gentempcode("int");

				$$.traducao =  $7.traducao +
							"\t" + var_contador.nome_sistema + " = " + $7.label + ";\n" +
							label_inicio + ":\n" +
							$10.traducao +
							"\t" + temp_not + " = !" + $10.label + ";\n" +
							"\tif (" + temp_not + ") goto " + label_fim + ";\n" +
							$17.traducao +
							$14.traducao +
							"\t" + var_atualizacao.nome_sistema + " = " + $14.label + ";\n" +
							"\tgoto " + label_inicio + ";\n" +
							label_fim + ":\n";

				pilha_labels_inicio.pop_back();
				pilha_labels_fim.pop_back();

				desempilha_escopo();
			}
			| TK_BREAK ';'
			{
				if (pilha_labels_fim.empty()) {
					yyerror("comando 'break' usado fora de loop");
				} else {
					$$.traducao = "\tgoto " + pilha_labels_fim.back() + ";\n";
				}
			}
			| TK_CONTINUE ';'
			{
				if (pilha_labels_inicio.empty()) {
					yyerror("comando 'continue' usado fora de loop");
				} else {
					$$.traducao = "\tgoto " + pilha_labels_inicio.back() + ";\n";
				}
			}
			| BLOCO
			{
				$$.traducao = $1.traducao;
			}
			| TK_INT TK_ID '=' L ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("int");
					var.tipo = "int";
					escopo_atual[var.nome_usuario] = var;

					if (var.tipo != $4.tipo) {
						yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $4.tipo + " e " + var.tipo);
					}

					$$.traducao = $4.traducao + "\t" + var.nome_sistema + " = " + $4.label + ";\n";
				}
			}
			| TK_FLOAT TK_ID '=' L ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("float");
					var.tipo = "float";
					escopo_atual[var.nome_usuario] = var;

					if (var.tipo != $4.tipo) {
						yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $4.tipo + " e " + var.tipo);
					}

					$$.traducao = $4.traducao + "\t" + var.nome_sistema + " = " + $4.label + ";\n";
				}
			}
			;
			| TK_BOOL TK_ID '=' L ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("int");
					var.tipo = "bool";
					escopo_atual[var.nome_usuario] = var;

					if (var.tipo != $4.tipo) {
						yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $4.tipo + " e " + var.tipo);
					}

					$$.traducao = $4.traducao + "\t" + var.nome_sistema + " = " + $4.label + ";\n";
				}
			}
			| TK_STRING TK_ID '=' L ';'
			{
				auto& escopo_atual = pilha_de_tabelas.back();

				if (escopo_atual.find($2.label) != escopo_atual.end()) {
					yyerror("variavel ja declarada neste escopo: " + $2.label);
				} else {
					variavel var;
					var.nome_usuario = $2.label;
					var.nome_sistema = gentempcode("string");
					var.tipo = "string";
					escopo_atual[var.nome_usuario] = var;

					if (var.tipo != $4.tipo) {
						yyerror("tipo do resultado da operação é incompatível com o tipo esperado: " + $4.tipo + " e " + var.tipo);
					}

					$$.traducao = $4.traducao + "\t" + var.nome_sistema + " = " + $4.label + ";\n";
				}
			}
			;
CASES       : CASE CASES
    		{
				$$.traducao = $1.traducao + $2.traducao;
			}
			| CASE
			{
				$$.traducao = $1.traducao;
			}
			;
CASE        : TK_CASE F ':' COMANDOS
            {
				atributos exp_switch = pilha_exp_switch.back();
				
				if (exp_switch.tipo != $2.tipo) {
					yyerror("tipo da expressao do case nao corresponde ao tipo da expressao do switch");
				}

				string label_prox_case = genlabelcode();

				string temp_comp = gentempcode("int");
				string temp_not = gentempcode("int");

				$$.traducao = $2.traducao + 
							"\t" + temp_comp + " = " + exp_switch.label + " == " + $2.label + ";\n" +
							"\t" + temp_not + " = !" + temp_comp + ";\n" +
							"\tif (" + temp_not + ") goto " + label_prox_case + ";\n" +
							$4.traducao + 
							label_prox_case + ":\n";
			}
			| TK_DEFAULT ':' COMANDOS
			{
				$$.traducao = $3.traducao;
			}
			;
BLOCO		: '{'
			{
				empilha_escopo();
			}
			COMANDOS '}' 
			{
				desempilha_escopo();
				$$.traducao = $3.traducao; 
				// aqui é 3 porque o bloco é composto por 3 partes: '{', COMANDOS e '}'. O comando que interessa para
				// a tradução é o COMANDOS, que é o $2, mas como tem um empilha_escopo() antes, o $2 passa a ser o $3.
			}
			;
/* or -> and -> not */
L			: L TK_OR K
			{
				$$ = gera_operacao_logica($$, $1, $3, "||");

			}
			|K   {$$.traducao = $1.traducao;}
			;

K			: K TK_AND M
			{
				$$ = gera_operacao_logica($$, $1, $3, "&&");
			}
			|M   {$$.traducao = $1.traducao;}
			;

M			: TK_NOT M
			{
				$$ = verifica_not($2);
			}
			|R   {$$.traducao = $1.traducao;}
			;

R			: R TK_OPERADOR_RELACIONAL E
			{
				$$ = gera_operacao_comparacao($$, $1, $3, $2.label);
			}
					/* VAI TER QUE SETAR O TIPO DE E, PARA FAZER AS VALIDAÇÕES DE OPERAÇÕES */
			|E  	{$$.traducao = $1.traducao; $$.tipo = $1.tipo;}

			;
			/* FAZER A MESMA COISA QUE NO RELACIONAL, CRIAR TK_OPERACOES_SOMA_SUB SLA */
E 			:E '-' T
			{
				$$ = gera_operacao($$, $1, $3, "-");
			}
			|E '+' T
			{
				$$ = gera_operacao($$, $1, $3, "+");
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
				$$ = gera_operacao($$, $1, $3, "*");
			}
			
			| T '/' F
			{
				$$ = gera_operacao($$, $1, $3, "/");
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
				variavel var = obtem_variavel($1.label);
				$$.label = var.nome_sistema;
				$$.tipo = var.tipo;
				$$.traducao = "";
			}
			| TK_STRING_LITERAL
			{
				int tamanho = tamanho_string_literal($1.label);
				int tamanho_malloc = tamanho + 1;

				$$.label = gentempcode("string");
				$$.tipo = "string";
				$$.tamanho = tamanho;

				tipos_temporarios[$$.label] = "string";

				string conteudo = $1.label;

				// troca aspas simples por aspas duplas para gerar C válido
				conteudo[0] = '"';
				conteudo[conteudo.size() - 1] = '"';

				$$.traducao = "\t" + $$.label + " = (char*) malloc(" + to_string(tamanho_malloc) + ");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", " + conteudo + ");\n";
			}
			| TK_CARACTER
			{
				$$.label = gentempcode("char");
				$$.tipo  = "char";
				tipos_temporarios[$$.label] = $$.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

			}
			| TK_BOOL_LIT
			{
				$$.label = gentempcode("int");
				$$.tipo  = "bool";
				tipos_temporarios[$$.label] = "int";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";

			}
			| '(' L ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int tamanho_string_literal(string literal)
{
    return literal.size() - 2;
}

string gera_tamanho_string(string texto, string temp_tamanho)
{
    string temp_char = gentempcode("char");
    string temp_cond = gentempcode("int");

    string label_inicio = genlabelcode();
    string label_fim = genlabelcode();

    string codigo;

    codigo += "\t" + temp_tamanho + " = 0;\n";
    codigo += label_inicio + ":\n";
    codigo += "\t" + temp_char + " = " + texto + "[" + temp_tamanho + "];\n";
    codigo += "\t" + temp_cond + " = " + temp_char + " == '\\0';\n";
    codigo += "\tif (" + temp_cond + ") goto " + label_fim + ";\n";
    codigo += "\t" + temp_tamanho + " = " + temp_tamanho + " + 1;\n";
    codigo += "\tgoto " + label_inicio + ";\n";
    codigo += label_fim + ":\n";

    return codigo;
}

string gentempcode(string tipo)
{
	var_temp_qnt++;
	string nome = "t" + to_string(var_temp_qnt);
	tipos_temporarios[nome] = tipo;

	return nome;
}

string genlabelcode()
{
	label_qnt++;
	string nome = "L" + to_string(label_qnt);

	return nome;
}

variavel obtem_variavel(string nome)
{
	for (int i = pilha_de_tabelas.size() - 1; i >= 0; i--) {
		auto it = pilha_de_tabelas[i].find(nome);

		if (it != pilha_de_tabelas[i].end()) {
			return it->second;
		}
	}
	yyerror("variavel nao declarada: " + nome);
	return variavel{};

}

atributos verifica_not(atributos operando){
	atributos resultado;

	if (operando.tipo != "bool"){
		yyerror("operador lógico 'not' só pode ser aplicado a operandos do tipo bool, mas foi fornecido: " + operando.tipo);
		return resultado;
	}
	resultado.label = gentempcode("int");
	resultado.tipo = "bool";
	resultado.traducao = operando.traducao + "\t" + resultado.label + " = !" + operando.label + ";\n";
	return resultado;
}

atributos gera_operacao_logica(atributos recebedor_resultado, atributos esq, atributos dir, string operador)
{
	atributos resultado;

	if (esq.tipo != "bool" || dir.tipo != "bool") {
		yyerror("operadores lógicos só podem ser aplicados a operandos do tipo bool, mas foram fornecidos: " + esq.tipo + " e " + dir.tipo);
		return resultado;
	}

	resultado.label = gentempcode("int");
	resultado.tipo = "bool";
	resultado.traducao = esq.traducao + dir.traducao + "\t" + resultado.label + " = " + esq.label + " " + operador + " " + dir.label + ";\n";

	return resultado;
}

atributos gera_operacao_comparacao(atributos recebedor_resultado, atributos esq, atributos dir, string operador)
{
	atributos resultado;

	if (esq.tipo == "string" && dir.tipo == "string" && (operador == "==" || operador == "!=")) {
		resultado.label = gentempcode("int");
		resultado.tipo = "bool";
		resultado.traducao = esq.traducao + dir.traducao;

		string indice = gentempcode("int");
		string caractere_esq = gentempcode("char");
		string caractere_dir = gentempcode("char");

		string label_inicio = genlabelcode();
		string label_diferentes = genlabelcode();
		string label_fim = genlabelcode();

		string valor_inicial;
		string valor_quando_diferentes;

		if (operador == "==") {
			valor_inicial = "1";
			valor_quando_diferentes = "0";
		}
		else {
			valor_inicial = "0";
			valor_quando_diferentes = "1";
		}

		resultado.traducao += "\t" + resultado.label + " = " + valor_inicial + ";\n";
		resultado.traducao += "\t" + indice + " = 0;\n";

		resultado.traducao += label_inicio + ":\n";
		resultado.traducao += "\t" + caractere_esq + " = " + esq.label + "[" + indice + "];\n";
		resultado.traducao += "\t" + caractere_dir + " = " + dir.label + "[" + indice + "];\n";

		string temp_comparacao;
		temp_comparacao = gentempcode("int");
		resultado.traducao += "\t" + temp_comparacao + " = " + caractere_esq + " != " + caractere_dir + ";\n";
		resultado.traducao += "\tif (" + temp_comparacao + ") goto " + label_diferentes + ";\n";

		temp_comparacao = gentempcode("int");
		resultado.traducao += "\t" + temp_comparacao + " = " + caractere_esq + " == '\\0'"  + ";\n";
		resultado.traducao += "\tif (" + temp_comparacao + ") goto " + label_fim + ";\n";

		resultado.traducao += "\t" + indice + " = " + indice + " + 1;\n";
		resultado.traducao += "\tgoto " + label_inicio + ";\n";

		resultado.traducao += label_diferentes + ":\n";
		resultado.traducao += "\t" + resultado.label + " = " + valor_quando_diferentes + ";\n";

		resultado.traducao += label_fim + ":\n";

		return resultado;
	}

	string tipo_operandos = tabela_de_conversao[{esq.tipo, dir.tipo}];

	if (esq.tipo == "char" && dir.tipo == "char"){
		if (operador == "==" || operador == "!="){
			
			resultado.label = gentempcode("int");
			resultado.tipo = "bool";
			resultado.traducao = esq.traducao + dir.traducao;

			string label_esq = esq.label;
			string label_dir = dir.label;

			resultado.traducao += "\t" + resultado.label + " = " + label_esq + " " + operador + " " + label_dir + ";\n";

			return resultado;
		}
	}	

	if (tipo_operandos == "") {
		yyerror("tipos incompatíveis: " + esq.tipo + " e " + dir.tipo);
		return resultado;
	}

	resultado.label = gentempcode(tipo_operandos);
	resultado.tipo = "bool";
	resultado.traducao = esq.traducao + dir.traducao;

	string label_esq = esq.label;
	string label_dir = dir.label;

	if (esq.tipo != tipo_operandos) {
		label_esq = gentempcode(tipo_operandos);
		resultado.traducao += "\t" + label_esq + " = (" + tipo_operandos + ") " + esq.label + ";\n";
	}

	if (dir.tipo != tipo_operandos) {
		label_dir = gentempcode(tipo_operandos);
		resultado.traducao += "\t" + label_dir + " = (" + tipo_operandos + ") " + dir.label + ";\n";
	}
	

	resultado.traducao += "\t" + resultado.label + " = " + label_esq + " " + operador + " " + label_dir + ";\n";

	return resultado;
}

atributos gera_operacao(atributos recebedor_resultado, atributos esq, atributos dir, string operador)
{
	atributos resultado;
	
	
	if (operador == "+" && esq.tipo == "string" && dir.tipo == "string") {
		string tamanho_esq = gentempcode("int");
		string tamanho_dir = gentempcode("int");
		string tamanho_total = gentempcode("int");

		resultado.label = gentempcode("string");
		resultado.tipo = "string";
		resultado.traducao = esq.traducao + dir.traducao;

		resultado.traducao += gera_tamanho_string(esq.label, tamanho_esq);
		resultado.traducao += gera_tamanho_string(dir.label, tamanho_dir);

		resultado.traducao += "\t" + tamanho_total + " = " + tamanho_esq + " + " + tamanho_dir + " + 1;\n";
		resultado.traducao += "\t" + resultado.label + " = (char*) malloc(" + tamanho_total + ");\n";

		resultado.traducao += "\tstrcpy(" + resultado.label + ", " + esq.label + ");\n";
		resultado.traducao += "\tstrcpy(" + resultado.label + " + " + tamanho_esq + ", " + dir.label + ");\n";

		return resultado;
	}	

	string tipo_resultado = tabela_de_conversao[{esq.tipo, dir.tipo}];


	if (tipo_resultado == "") {
		yyerror("tipos incompatíveis: " + esq.tipo + " e " + dir.tipo);
		return resultado;
	}

	resultado.label = gentempcode(tipo_resultado);
	resultado.tipo = tipo_resultado;
	resultado.traducao = esq.traducao + dir.traducao;

	string label_esq = esq.label;
	string label_dir = dir.label;

	if (esq.tipo != tipo_resultado) {
		label_esq = gentempcode(tipo_resultado);
		resultado.traducao += "\t" + label_esq + " = (" + tipo_resultado + ") " + esq.label + ";\n";
	}

	if (dir.tipo != tipo_resultado) {
		label_dir = gentempcode(tipo_resultado);
		resultado.traducao += "\t" + label_dir + " = (" + tipo_resultado + ") " + dir.label + ";\n";
	}
	

	resultado.traducao += "\t" + resultado.label + " = " + label_esq + " " + operador + " " + label_dir + ";\n";

	return resultado;
}


int main(int argc, char* argv[])
{
	var_temp_qnt = 0;
	empilha_escopo(); //global

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}