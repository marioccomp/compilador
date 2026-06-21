%{
#include <iostream>
#include <string>
#include <map>
#include <utility>
#include <tuple>
#include <vector>
#include <stdlib.h>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int var_chave_qnt;
int label_qnt;
int linha = 1;
string codigo_gerado;
string variaveis;
int chamada_funcao_qnt;

struct variavel
{
	string nome_interno;
	string tipo;
	string valor;
	string tam;
};

struct argumento
{
	string label;
	string traducao;
	string tipo;
	string tam;
};

struct funcao
{
	string nome;
	string label;
	string tipo_retorno;
	string var_retorno;
	string var_chamada;
	string fim_label;
	string corpo;
	vector<argumento> parametros;
	vector<pair<int, string>> retornos;
	bool definida;
	bool tem_return;
	bool retorno_tipado;
};

vector<map<string, variavel>> tabelas;
vector<string> pilha_break;
vector<string> pilha_continue;
vector<string> pilha_switch_expr;
vector<string> pilha_switch_tipo;
vector<string> pilha_funcao;
map<string, funcao> funcoes;


struct atributos
{
	string label;
	string traducao;
	string tipo;
	string tam;

	string teste;
    string corpo;
    string default_label;
    bool tem_default;

	vector<argumento> args;
};

int yylex(void);
void yyerror(string);
string gentempcode();
string get_chave_temp();
string get_label_temp(string label);
void addVar(string nome, string tipo, bool interno = true, string nome_interno = "");
tuple<bool, bool, variavel*> existsVar(string nome, string tipo);
bool atribuicaoCompativel(string t1, string t2);
bool isNumerico(string t);
bool isBool(string t);
bool relacionalCompativel(string op, string t1, string t2);
bool logicoCompativel(string t1, string t2);
void abrir_escopo();
void fechar_escopo();
bool exists_var_escopo_atual(string nome);
bool somaCompativel(string t1, string t2);
bool operacao_compativel(string t1, string t2);
bool caseCompativel(string tipo_switch, string tipo_case);
string gerar_tamanho_string(string ponteiro, string tam);
void addParametroFuncao(string nome, string tipo);
string gerar_atribuicao_valor(string destino, string destino_tam, string destino_tipo, atributos origem_attr);
string gerar_chamada_funcao(string nome, vector<argumento> args, string &tipo, string &label, string &tam);
string montar_codigo_funcoes();
%}

%token TK_NUM
%token TK_ID
%token TK_INT
%token TK_FLOAT
%token TK_CHAR
%token TK_LETTER
%token TK_TRUE
%token TK_FALSE
%token TK_BOOL
%token TK_FLOAT_LIT
%token TK_RELACIONAL
%token TK_OR
%token TK_NOT
%token TK_AND
%token TK_IF
%token TK_WHILE
%token TK_DO
%token TK_ELSE
%token TK_FOR
%token TK_BREAK
%token TK_CONTINUE
%token TK_CIN
%token TK_COUT
%token TK_LL
%token TK_RR
%token TK_STRING
%token TK_STRING_LIT
%token TK_DEFAULT
%token TK_CASE
%token TK_SWITCH
%token TK_PP
%token TK_MM
%token TK_ATRIB_COMP
%token TK_FUNC
%token TK_RETURN
%token TK_ALL

%start S

%left TK_OR
%left TK_AND
%left TK_RELACIONAL
%left '+' '-'
%left '*' '/'
%right TK_NOT TK_CAST TK_NEG


%%


S           : INICIO CMDS FINAIS
			{
				codigo_gerado = $2.traducao;
			}
            | INICIO CMDS
			{
				codigo_gerado = $2.traducao;
			}
			| INICIO
			{
				codigo_gerado = "";
			}
            ;

INICIO      : 
            | FINAIS
            ;

CMDS        : CMD
			{
				$$.traducao = $1.traducao;
			}
            | CMDS FINAIS CMD
			{
				$$.traducao = $1.traducao + $3.traducao;
			}
            ;

FINAIS      : FIM
            | FINAIS FIM
            ;

FIM         : '\n'
            | ';'
            ;

QUEBRAS		:
			| QUEBRAS '\n'
			;
CMD			: E
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
				$$.tipo = $1.tipo;
			}
			|
			D
			{
				$$.traducao = $1.traducao;
			}
			|
			BLOCO
			{
				$$.traducao = $1.traducao;
			}
			|
			IF
			{
				$$.traducao = $1.traducao;
			}
			|
			WHILE
			{
				$$.traducao = $1.traducao;
			}
			|
			DO_WHILE
			{
				$$.traducao = $1.traducao;
			}
			|
			FOR
			{
				$$.traducao = $1.traducao;
			}
			| BREAK
			{
				$$.traducao = $1.traducao;	
			}
			| CONTINUE
			{
				$$.traducao = $1.traducao;	
			}
			| CIN
			{
				$$.traducao = $1.traducao;
			}
			| COUT
			{
				$$.traducao = $1.traducao;
			}
			| SWITCH
			{
				$$.traducao = $1.traducao;
			}
			| RETURN
			{
				$$.traducao = $1.traducao;
			}
			| FUNCAO
			{
				$$.traducao = "";
			}
			;

ABRE_BLOCO	: '{'
			{
				abrir_escopo();
			}
			;
FECHA_BLOCO : '}'
			{
				fechar_escopo();
			}
			;
BLOCO		: ABRE_BLOCO INICIO FECHA_BLOCO
			{
				$$.traducao = "";
			}
			| ABRE_BLOCO INICIO CMDS FECHA_BLOCO
			{
				$$.traducao = $3.traducao;
			}
			| ABRE_BLOCO INICIO CMDS FINAIS FECHA_BLOCO
			{
				$$.traducao = $3.traducao;
			}
			;
IF			: TK_IF '(' E ')' QUEBRAS BLOCO  // aqui fiquei com algumas duvidas sobre oq aceitar dentro dos parenteses, aceitar so bool?
			{
				if($3.tipo != "bool") {
					yyerror("A condição do 'if' deve ser do tipo bool");
					exit(1);
				}
				string exp = $3.traducao;
				string traducao = exp;
				string label = get_label_temp("fim_if");
				string temp = gentempcode();
				addVar(temp, $3.tipo);
				traducao += "\t" + temp + " = !" + $3.label + ";\n\tif " + "(" + temp + ") goto " + label + ";\n";
				traducao += $6.traducao + label + ":\n";
				$$.traducao = traducao;
			}
			| TK_IF '(' E ')' QUEBRAS BLOCO TK_ELSE BLOCO
			{
				if($3.tipo != "bool") {
					yyerror("A condição do " + $1.label + " deve ser do tipo bool");
					exit(1);
				}
				string exp = $3.traducao;
				string traducao = exp;

				string inicio_else = get_label_temp("else");

				string fim_if = get_label_temp("fim_if");
				string temp = gentempcode();
				addVar(temp, $3.tipo);
				traducao += "\t" + temp + " = !" + $3.label + ";\n\tif " + "(" + temp + ") goto " + inicio_else + ";\n";
				traducao += $6.traducao + "\tgoto " + fim_if + ";\n" + inicio_else + ":\n";
				traducao += $8.traducao + fim_if + ":\n";
				$$.traducao = traducao;
			}

			;
INICIO_WHILE : TK_WHILE 
			{
				
				string fim = get_label_temp("fim_while");
				string inicio = get_label_temp("inicio_while");
				pilha_break.push_back(fim);
				pilha_continue.push_back(inicio);

				$$.label = fim;
				$$.tipo = inicio;
				
			}
			;
WHILE		: INICIO_WHILE '(' E ')' QUEBRAS BLOCO
			{
				if($3.tipo != "bool") {
					yyerror("A condição do 'while' deve ser do tipo bool");
					exit(1);
				}
				string inicio = $1.tipo;
				string traducao = inicio + ":\n" + $3.traducao;
				string temp = gentempcode();
				addVar(temp, "bool");
				traducao += "\t" + temp + " = !" + $3.label + ";\n\tif " + "(" + temp + ") goto " + $1.label + ";\n";
				traducao += $6.traducao + "\tgoto " + inicio + ";\n" + $1.label + ":\n";
				pilha_break.pop_back();
				pilha_continue.pop_back();
				$$.traducao = traducao;
			}
			;
INICIO_DO	: TK_DO
			{
				string inicio = get_label_temp("inicio_do_while");
				string teste = get_label_temp("teste_do_while");
				string fim = get_label_temp("fim_do_while");
				$$.label = fim;
				$$.tipo = inicio;
				$$.tam = teste;

				pilha_break.push_back(fim);
				pilha_continue.push_back(teste);
			}
			;
DO_WHILE	: INICIO_DO QUEBRAS BLOCO QUEBRAS TK_WHILE '(' E ')'
			{
				if($7.tipo != "bool") {
					yyerror("A condição do 'do while' deve ser do tipo bool");
					exit(1);
				}
				string exp = $7.traducao;
				string inicio = $1.tipo;
				string fim = $1.label;
				string teste = $1.tam;

				string traducao = inicio + ":\n";
				traducao += $3.traducao;
				traducao += teste + ":\n";
				traducao += $7.traducao;
				traducao += "\tif (" + $7.label + ") goto " + inicio + ";\n";
				traducao += fim + ":\n";
				pilha_break.pop_back();
				pilha_continue.pop_back();
				$$.traducao = traducao;
			}
			;
ABRE_FOR	: TK_FOR '('
			{
				abrir_escopo();
				string fim_for = get_label_temp("fim_for");
				string inicio_for = get_label_temp("inicio_for");
				string atualiza_for = get_label_temp("atualiza_for");
				$$.label = fim_for;
				$$.tipo = inicio_for;
				$$.tam = atualiza_for;
				pilha_break.push_back(fim_for);
				pilha_continue.push_back(atualiza_for);
			}
			;
FOR_INI     :
            {
                $$.traducao = "";
            }
            | D
            {
                $$.traducao = $1.traducao;
            }
            ;
FOR_COND    :
            {
                $$.traducao = "";
                $$.label = "1";
                $$.tipo = "bool";
            }
            | E
            {
                $$ = $1;
            }
            ;
FOR_ATUAL   :
            {
                $$.traducao = "";
            }
            | ATRIB
            {
                $$.traducao = $1.traducao;
            }
            ;
FOR			: ABRE_FOR FOR_INI ';' FOR_COND ';' FOR_ATUAL ')' QUEBRAS BLOCO
			{
				if($4.tipo != "bool") {
					yyerror("A expressão do 'for' deve ser do tipo bool");
					exit(1);
				}
				string traducao = $2.traducao;
				string inicio_for = $1.tipo;
				string fim_for = $1.label;
				string atualiza_for = $1.tam;
				traducao += inicio_for + ":\n" + $4.traducao;
				string temp = gentempcode();
				addVar(temp, "bool");
				traducao += "\t" + temp + " = !" + $4.label + ";\n";
				traducao += "\tif (" + temp + ") goto " + fim_for + ";\n" + $9.traducao;
				traducao += atualiza_for + ":\n";
				traducao += $6.traducao + "\tgoto " + inicio_for + ";\n";
				traducao += fim_for + ":\n";
				fechar_escopo();
				pilha_break.pop_back();
				pilha_continue.pop_back();
				$$.traducao = traducao;
			}
			;
INICIO_SWITCH : TK_SWITCH '(' E ')' QUEBRAS '{'
			{

				string fim_switch = get_label_temp("fim_switch");

				abrir_escopo();

				pilha_break.push_back(fim_switch);
				pilha_switch_expr.push_back($3.label);
				pilha_switch_tipo.push_back($3.tipo);

				$$.label = fim_switch;
				$$.tipo = $3.tipo;
				$$.traducao = $3.traducao;
			}
			;

SWITCH      : INICIO_SWITCH INICIO CASES INICIO '}'
            {
                string fim_switch = $1.label;

                string destino_default;

                if($3.tem_default) {
                    destino_default = $3.default_label;
                }
                else {
                    destino_default = fim_switch;
                }

                $$.traducao = $1.traducao;
                $$.traducao += $3.teste;
                $$.traducao += "\tgoto " + destino_default + ";\n";
                $$.traducao += $3.corpo;
                $$.traducao += fim_switch + ":\n";

                pilha_break.pop_back();
                pilha_switch_expr.pop_back();
                pilha_switch_tipo.pop_back();

                fechar_escopo();
            }
            ;
CASES  		: CASE_ITEM
			{
				$$.teste = $1.teste;
				$$.corpo = $1.corpo;
				$$.tem_default = $1.tem_default;
				$$.default_label = $1.default_label;
			}
			| CASES CASE_ITEM
			{
				if($1.tem_default && $2.tem_default) {
					yyerror("switch nao pode ter mais de um default");
					exit(1);
				}

				$$.teste = $1.teste + $2.teste;
				$$.corpo = $1.corpo + $2.corpo;
				$$.tem_default = $1.tem_default || $2.tem_default;

				if($1.tem_default) {
					$$.default_label = $1.default_label;
				}
				else {
					$$.default_label = $2.default_label;
				}
			}
			;

CASE_ITEM   : TK_CASE VALOR ':' CORPO_CASE
            {
                string tipo_switch = pilha_switch_tipo.back();

                if(!caseCompativel(tipo_switch, $2.tipo)) {
                    yyerror("case do tipo " + $2.tipo + " incompativel com switch do tipo " + tipo_switch);
                    exit(1);
                }

                string label_case = get_label_temp("case");

                if(tipo_switch == "string") {
                    string cmp = gentempcode();
                    addVar(cmp, "int");

                    $$.teste = "\t" + cmp + " = strcmp(" + pilha_switch_expr.back() + ", " + $2.label + ");\n";
                    $$.teste += "\tif (" + cmp + " == 0) goto " + label_case + ";\n";
                }
                else {
                    $$.teste = "\tif (" + pilha_switch_expr.back() + " == " + $2.label + ") goto " + label_case + ";\n";
                }

                $$.corpo = label_case + ":\n";
                $$.corpo += $4.traducao;

                $$.corpo += "\tgoto " + pilha_break.back() + ";\n";

                $$.tem_default = false;
                $$.default_label = "";
            }
            | TK_DEFAULT ':' CORPO_CASE
            {
                string label_default = get_label_temp("default_switch");

                $$.teste = "";
                $$.corpo = label_default + ":\n";
                $$.corpo += $3.traducao;

                $$.corpo += "\tgoto " + pilha_break.back() + ";\n";

                $$.tem_default = true;
                $$.default_label = label_default;
            }
            ;

CORPO_CASE  : INICIO
            {
                $$.traducao = "";
            }
            | INICIO CMDS
            {
                $$.traducao = $2.traducao;
            }
            | INICIO CMDS FINAIS
            {
                $$.traducao = $2.traducao;
            }
            ;
BREAK		: TK_BREAK TK_ALL
			{
				if(pilha_break.empty()) {
					yyerror("Nao existe loop para dar break");
					exit(1);
				}

				string back = pilha_break.back();
				if($2.label == "all") {
					back = pilha_break[0];
				}

				string traducao = "\tgoto " + back + ";\n";
				$$.traducao = traducao;
			}
			;
CONTINUE	: TK_CONTINUE ALL
			{
				if(pilha_continue.empty()) {
					yyerror("Nao existe loop para dar continue");
					exit(1);
				}

				string back = pilha_continue.back();
				if($2.label == "all") {
					back = pilha_continue[0];
				}
				string traducao = "\tgoto " + back + ";\n";
				$$.traducao = traducao;
			}
			;
ALL			: TK_ALL
			|
			;
INICIO_FUNCAO : TK_FUNC TK_ID '('
			{
				if(!pilha_funcao.empty()) {
					yyerror("Nao pode declarar funcao dentro de outra funcao");
					exit(1);
				}

				if(funcoes.find($2.label) != funcoes.end()) {
					yyerror("Funcao " + $2.label + " ja foi declarada");
					exit(1);
				}

				funcao f;
				f.nome = $2.label;
				f.label = "func_" + $2.label;
				f.tipo_retorno = "";
				f.var_retorno = gentempcode();
				f.var_chamada = gentempcode();
				f.fim_label = get_label_temp("fim_func_" + $2.label);
				f.corpo = "";
				f.definida = false;
				f.tem_return = false;
				f.retorno_tipado = false;

				funcoes[$2.label] = f;

				addVar(f.var_chamada, "int");

				abrir_escopo();
				pilha_funcao.push_back($2.label);
			}
			;

PARAMS_FUNC :
			{
				$$.traducao = "";
			}
			| LISTA_PARAMS_FUNC
			{
				$$.traducao = "";
			}
			;
RETORNO_FUNC :
			{
				$$.tipo = "";
			}
			| ':' TIPO
			{
				if(pilha_funcao.empty()) {
					yyerror("Tipo de retorno declarado fora de funcao");
					exit(1);
				}

				string nome_funcao = pilha_funcao.back();
				funcao &f = funcoes[nome_funcao];

				f.tipo_retorno = $2.tipo;
				f.retorno_tipado = true;

				addVar(f.var_retorno, f.tipo_retorno);

				$$.tipo = $2.tipo;
			}
			;

LISTA_PARAMS_FUNC : PARAM_FUNC
			| LISTA_PARAMS_FUNC ',' PARAM_FUNC
			;

PARAM_FUNC : TIPO TK_ID
			{
				addParametroFuncao($2.label, $1.tipo);
			}
			;

FUNCAO     : INICIO_FUNCAO PARAMS_FUNC ')' RETORNO_FUNC QUEBRAS BLOCO
			{
				string nome_funcao = pilha_funcao.back();
				funcao &f = funcoes[nome_funcao];

				if(f.retorno_tipado && !f.tem_return) {
					yyerror("Funcao " + nome_funcao + " foi declarada com retorno " + f.tipo_retorno + ", mas nao possui return");
					exit(1);
				}

				if(!f.tem_return && !f.retorno_tipado) {
					f.tipo_retorno = "void";
				}

				f.corpo = $6.traducao;
				f.definida = true;

				fechar_escopo();
				pilha_funcao.pop_back();

				$$.traducao = "";
			}
			;

RETURN     : TK_RETURN E
			{
				if(pilha_funcao.empty()) {
					yyerror("return so pode ser usado dentro de funcao");
					exit(1);
				}

				string nome_funcao = pilha_funcao.back();
				funcao &f = funcoes[nome_funcao];

				if(f.tipo_retorno == "") {
					f.tipo_retorno = $2.tipo;
					addVar(f.var_retorno, f.tipo_retorno);
				}
				else if(!atribuicaoCompativel(f.tipo_retorno, $2.tipo)) {
					yyerror("Retorno da funcao " + nome_funcao + " deveria ser " + f.tipo_retorno + ", mas recebeu " + $2.tipo);
					exit(1);
				}

				f.tem_return = true;

				$$.traducao = gerar_atribuicao_valor(f.var_retorno, f.var_retorno + "_tam", f.tipo_retorno, $2);
				$$.traducao += "\tgoto " + f.fim_label + ";\n";
			}
			;

ARGS       :
			{
				$$.args.clear();
			}
			| LISTA_ARGS
			{
				$$.args = $1.args;
			}
			;

LISTA_ARGS : E
			{
				argumento a;
				a.label = $1.label;
				a.traducao = $1.traducao;
				a.tipo = $1.tipo;
				a.tam = $1.tam;

				$$.args.clear();
				$$.args.push_back(a);
			}
			| LISTA_ARGS ',' E
			{
				argumento a;
				a.label = $3.label;
				a.traducao = $3.traducao;
				a.tipo = $3.tipo;
				a.tam = $3.tam;

				$$.args = $1.args;
				$$.args.push_back(a);
			}
			;

CHAMADA    : TK_ID '(' ARGS ')'
			{
				$$.traducao = gerar_chamada_funcao($1.label, $3.args, $$.tipo, $$.label, $$.tam);
			}
			;
TIPO		: TK_INT
			{
				$$.tipo = "int";
			}
			| TK_BOOL
			{
				$$.tipo = "bool";
			}
			| TK_FLOAT
			{
				$$.tipo = "float";
			}
			| TK_CHAR
			{
				$$.tipo = "char";
			}
			| TK_STRING
			{
				$$.tipo = "string";
			}

			;
VALOR		: TK_TRUE
			{
				$$.label = $1.label;
				$$.tipo = "bool";
			}
			| TK_FALSE
			{
				$$.label = $1.label;
				$$.tipo = "bool";
			}
			| TK_LETTER
			{
				$$.label = $1.label;
				$$.tipo = "char";	
			} 
			| TK_NUM
			{
				$$.label = $1.label;
				$$.tipo = "int";
			}
			| TK_FLOAT_LIT
			{
				$$.label = $1.label;
				$$.tipo = "float";
			}
			| TK_STRING_LIT
			{
				$$.label = $1.label;
				$$.tipo = "string";
			}
			;
CIN			: TK_CIN TK_RR TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($3.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel " + $3.label + " nao foi declarada anteriormente");
					exit(1);
				}

				variavel* var = get<2>(exists);

				string traducao = "";

				if(var->tipo == "string") {
					traducao += "\tfree(" + var->nome_interno + ");\n";
					traducao += "\t" + var->nome_interno + " = read_string(&" + var->tam + ");\n";
				}
				else if(var->tipo == "int") {
					traducao += "\t" + var->nome_interno + " = read_int();\n";
				}
				else if(var->tipo == "float") {
					traducao += "\t" + var->nome_interno + " = read_float();\n";
				}
				else if(var->tipo == "char") {
					traducao += "\t" + var->nome_interno + " = read_char();\n";
				}
				else if(var->tipo == "bool") {
					traducao += "\t" + var->nome_interno + " = read_bool();\n";
				}

				$$.traducao = traducao;
			}
			;
COUT		: TK_COUT TK_LL TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($3.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel " + $3.label + " nao foi declarada anteriormente");
					exit(1);
				}

				variavel* var = get<2>(exists);

				string traducao = "\tcout << " + var->nome_interno + ";\n";
				$$.traducao = traducao;		
			}
			| TK_COUT TK_LL TK_STRING_LIT
			{
				string traducao = "\tcout << " + $3.label + ";\n";
				$$.traducao = traducao;	
			}
			;
E 			: E '+' E
			{
				bool soma_compativel = somaCompativel($1.tipo, $3.tipo);
				if(!soma_compativel) {
					yyerror("Voce nao pode somar um " + $1.tipo + " com um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "string" || $3.tipo == "string") {
					tipo_resultado = "string";
				}
				else if($1.tipo == "char" && $3.tipo == "char") {
					tipo_resultado = "string";
				}
				else if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast;
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast;
				}

				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;
				$$.tam = "";

				if(tipo_resultado == "string") {
					$$.tam = $$.label + "_tam";
					$$.traducao = traducao;

					if($1.tipo == "string" && $3.tipo == "string") {
						string soma_tam = gentempcode();
						addVar(soma_tam, "int");

						$$.traducao += "\t" + soma_tam + " = " + $1.tam + " + " + $3.tam + ";\n";
						$$.traducao += "\t" + $$.tam + " = " + soma_tam + " - 1;\n";
						$$.traducao += "\t" + $$.label + " = (char*) malloc(" + $$.tam + ");\n";
						$$.traducao += "\tstrcpy(" + $$.label + ", " + op1 + ");\n";
						$$.traducao += "\tstrcat(" + $$.label + ", " + op3 + ");\n";
					}
					else if($1.tipo == "char" && $3.tipo == "char") {
						$$.traducao += "\t" + $$.tam + " = 3;\n";
						$$.traducao += "\t" + $$.label + " = (char*) malloc(" + $$.tam + ");\n";
						$$.traducao += "\t" + $$.label + "[0] = " + op1 + ";\n";
						$$.traducao += "\t" + $$.label + "[1] = " + op3 + ";\n";
						$$.traducao += "\t" + $$.label + "[2] = '\\0';\n";
					}
					else if($1.tipo == "string" && $3.tipo == "char") {
						string idx_char = gentempcode();
						string idx_null = gentempcode();

						addVar(idx_char, "int");
						addVar(idx_null, "int");

						$$.traducao += "\t" + $$.tam + " = " + $1.tam + " + 1;\n";
						$$.traducao += "\t" + $$.label + " = (char*) malloc(" + $$.tam + ");\n";
						$$.traducao += "\tstrcpy(" + $$.label + ", " + op1 + ");\n";

						$$.traducao += "\t" + idx_char + " = " + $1.tam + " - 1;\n";
						$$.traducao += "\t" + $$.label + "[" + idx_char + "] = " + op3 + ";\n";

						$$.traducao += "\t" + idx_null + " = " + $$.tam + " - 1;\n";
						$$.traducao += "\t" + $$.label + "[" + idx_null + "] = '\\0';\n";
					}
					else if($1.tipo == "char" && $3.tipo == "string") {
						$$.traducao += "\t" + $$.tam + " = " + $3.tam + " + 1;\n";
						$$.traducao += "\t" + $$.label + " = (char*) malloc(" + $$.tam + ");\n";

						$$.traducao += "\t" + $$.label + "[0] = " + op1 + ";\n";
						$$.traducao += "\t" + $$.label + "[1] = '\\0';\n";
						$$.traducao += "\tstrcat(" + $$.label + ", " + op3 + ");\n";
					}
				}
				else {
					$$.traducao = traducao + "\t" + $$.label +
						" = " + op1 + " + " + op3 + ";\n";
    			}
			}
			|
			E '-' E
			{
				bool operacaoCompativel = operacao_compativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode subtrair um " + $3.tipo + " de um " + $1.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = $1.tipo;
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n"; 
					op1 = temp_cast;
				}
				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n"; 
					op3 = temp_cast;
				}

				$$.label = gentempcode();

				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;

				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " - " + op3 + ";\n";
			}
			|
   			 E '*' E
			{
				bool operacaoCompativel = operacao_compativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode multiplicar um " + $1.tipo + " por um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = $1.tipo;
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast; 
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast; 
				} 
				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;


				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " * " + op3 + ";\n";
			}
			|
			 E '/' E
			{
				bool operacaoCompativel = operacao_compativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode dividir um " + $1.tipo + " por um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = $1.tipo;
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast;
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast;
				}

				$$.label = gentempcode();

				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " / " + op3 + ";\n";
			}
			 | '(' E ')'
    		{
       			$$ = $2; 
    		}
			| '-' E %prec TK_NEG
			{
				if(!isNumerico($2.tipo)) {
					yyerror("simbolo - invalido para o tipo " + $2.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, $2.tipo);
				$$.tipo = $2.tipo;

				$$.traducao = $2.traducao + "\t" + $$.label + " = -" + $2.label + ";\n";
			}
			| '(' TIPO ')' E %prec TK_CAST
			{
				if(!atribuicaoCompativel($2.tipo, $4.tipo)) {
					yyerror("conversao invalida de " + $4.tipo + " para " + $2.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, $2.tipo);
				$$.tipo = $2.tipo;

				string tipo = $2.tipo == "bool" ? "int" : $2.tipo;

				$$.traducao = $4.traducao + "\t" + $$.label + " = (" + tipo + ") " + $4.label + ";\n";
			}
			| E TK_RELACIONAL E
			{
				if(!relacionalCompativel($2.label, $1.tipo, $3.tipo)) {
					yyerror("Operacao relacional invalida: " + $1.tipo + " " + $2.label + " " + $3.tipo);
					exit(1);
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if(isNumerico($1.tipo) && isNumerico($3.tipo) && $1.tipo != $3.tipo) {
					if($1.tipo == "int") {
						string temp_cast = gentempcode();
						addVar(temp_cast, "float");
						traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
						op1 = temp_cast;
					}

					if($3.tipo == "int") {
						string temp_cast = gentempcode();
						addVar(temp_cast, "float");
						traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
						op3 = temp_cast;
					}
				}

				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				if($1.tipo == "string") {
					$$.traducao = traducao + "\t" + $$.label + " = strcmp(" + $1.label + ", " + $3.label + ") " + $2.label + " 0;\n";
				}
				else {
					$$.traducao = traducao + "\t" + $$.label + " = " + op1 + " " + $2.label + " " + op3 + ";\n";
				 }
			}
			| E TK_OR E
			{

				if(!logicoCompativel($1.tipo, $3.tipo)) {
					yyerror("Operacao logica invalida: " + $1.tipo + " " + $2.label + " " + $3.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";

			}
			| E TK_AND E
			{

				if(!logicoCompativel($1.tipo, $3.tipo)) {
					yyerror("Operacao logica invalida: " + $1.tipo + " " + $2.label + " " + $3.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";

			}
			| TK_NOT E
			{

				if($2.tipo != "bool") {
					yyerror("Operacao de negacao invalida: !" + $2.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $2.traducao + "\t" + $$.label + " = !" + $2.label + ";\n";
			}
			| TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");
				if(!get<0>(exists)) {
					yyerror("Variavel " + $1.label + " nao foi declarada anteriormente");
					exit(1);
				}
				variavel* var = get<2>(exists);
				$$.label = var->nome_interno;
				$$.tipo = var->tipo;
				$$.tam = var->tam;
				$$.traducao = "";
			}
			| VALOR 
			{
				$$.label = gentempcode();
				addVar($$.label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.tam = "";
				$$.traducao = "";

				if($1.tipo == "string") {
					string value = $1.label;

					if(value.size() >= 2 && value[0] == '"' && value[value.size() - 1] == '"') {
						value = value.substr(1, value.size() - 2);
					}

					$$.tam = $$.label + "_tam";

					$$.traducao += "\t" + $$.tam + " = " + to_string(value.length() + 1) + ";\n";
					$$.traducao += "\t" + $$.label + " = (char*) malloc(" + $$.tam + ");\n";

					for(int i = 0; i < value.length(); i++) {
						$$.traducao += "\t" + $$.label + "[" + to_string(i) + "] = '" + value[i] + "';\n"; 
					}

					$$.traducao += "\t" + $$.label + "[" + to_string(value.length()) + "] = '\\0';\n"; 
				}
				else {
					$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				}
			}
			| CHAMADA
			{
				$$ = $1;
			}
			;
D			: TIPO TK_ID
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				string var = gentempcode();
				addVar($2.label, $1.tipo, false, var);

				$$.traducao = "";

				if($1.tipo == "string") {
					$$.traducao += "\t" + var + " = NULL;\n";
					$$.traducao += "\t" + var + "_tam = 0;\n";
				}
			}
			| ATRIB
			{
				$$.traducao = $1.traducao;
			}
			| TIPO TK_ID '=' E
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				if(!atribuicaoCompativel($1.tipo, $4.tipo)) { // aqui depois posso colocar a funcao que verifica se tipos sao compativeis
					yyerror("Tipos incompativeis de atribuição (" + $1.tipo + ", " + $4.tipo + ")");
					exit(1);
				}
				string var = gentempcode();
				addVar($2.label, $1.tipo, false, var);

				

				string traducao = $4.traducao;
				string origem = $4.label;

				if(isNumerico($1.tipo) && isNumerico($4.tipo) && $1.tipo != $4.tipo) {
					string temp_cast = gentempcode();
					addVar(temp_cast, $1.tipo);
					traducao += "\t" + temp_cast + " = (" + $1.tipo + ") " + $4.label + ";\n";
					origem = temp_cast;
				}

				$$.traducao = "";

                if($1.tipo == "string") {
                    $$.traducao += "\t" + var + " = NULL;\n";
                    $$.traducao += "\t" + var + "_tam = 0;\n";
                }

                $$.traducao += traducao;

                if($1.tipo == "string") {
					if($4.tipo == "char") {
						$$.traducao += "\t" + var + "_tam = 2;\n";
						$$.traducao += "\t" + var + " = (char*) malloc(" + var + "_tam);\n";
						$$.traducao += "\t" + var + "[0] = " + $4.label + ";\n";
						$$.traducao += "\t" + var + "[1] = '\\0';\n";
					}
					else {
						$$.traducao += "\t" + var + " = (char*) malloc(" + $4.tam + ");\n";
						$$.traducao += "\tstrcpy(" + var + ", " + $4.label + ");\n";
						$$.traducao += "\t" + var + "_tam = " + $4.tam + ";\n";
					}
				}
				else {
					$$.traducao += "\t" + var + " = " + origem + ";\n";
				}

			}
			;
ATRIB		: TK_ID '=' E
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, $3.tipo);

				variavel* var = get<2>(exists);

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				else if(!atribuicaoCompativel(var->tipo, $3.tipo)) {
					yyerror("A variavel " + $1.label + " eh do tipo " + var->tipo + " e vc tentou associar ela com um valor do tipo " + $3.tipo);
					exit(1);
				}

				string traducao = $3.traducao;
				string origem = $3.label;
				if(isNumerico(var->tipo) && isNumerico($3.tipo) && var->tipo != $3.tipo) {
					string temp_cast = gentempcode();
					addVar(temp_cast, var->tipo);
					traducao += "\t" + temp_cast + " = (" + var->tipo + ") " + $3.label + ";\n";
					origem = temp_cast;
				}

				var->valor = origem;
				
				$$.traducao = traducao;

				if(var->tipo == "string" && origem == var->nome_interno) {
				}
				else if(var->tipo == "string") {
					$$.traducao += "\tfree(" + var->nome_interno + ");\n";

					if($3.tipo == "char") {
						$$.traducao += "\t" + var->nome_interno + "_tam = 2;\n";
						$$.traducao += "\t" + var->nome_interno + " = (char*) malloc(" + var->nome_interno + "_tam);\n";
						$$.traducao += "\t" + var->nome_interno + "[0] = " + $3.label + ";\n";
						$$.traducao += "\t" + var->nome_interno + "[1] = '\\0';\n";
					}
					else {
						$$.traducao += "\t" + var->nome_interno + " = (char*) malloc(" + $3.tam + ");\n";
						$$.traducao += "\tstrcpy(" + var->nome_interno + ", " + origem + ");\n";
						$$.traducao += "\t" + var->nome_interno + "_tam = " + $3.tam + ";\n";
					}
				}
				else {
					$$.traducao += "\t" + var->nome_interno + " = " + origem + ";\n";
				}
			}
			| TK_ID TK_ATRIB_COMP E
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);
				string op = $2.label;

				if(op == "+" && var->tipo == "string") {
					if($3.tipo != "string" && $3.tipo != "char") {
						yyerror("Operador += em string so aceita string ou char");
						exit(1);
					}

					$$.traducao = $3.traducao;

					string novo_tam = gentempcode();
					string novo_ptr = gentempcode();

					addVar(novo_tam, "int");
					addVar(novo_ptr, "string");

					if($3.tipo == "string") {
						string soma_tam = gentempcode();
						addVar(soma_tam, "int");

						$$.traducao += "\t" + soma_tam + " = " + var->tam + " + " + $3.tam + ";\n";
						$$.traducao += "\t" + novo_tam + " = " + soma_tam + " - 1;\n";
						$$.traducao += "\t" + novo_ptr + " = (char*) malloc(" + novo_tam + ");\n";
						$$.traducao += "\tstrcpy(" + novo_ptr + ", " + var->nome_interno + ");\n";
						$$.traducao += "\tstrcat(" + novo_ptr + ", " + $3.label + ");\n";
					}
					else {
						string idx_char = gentempcode();
						string idx_null = gentempcode();

						addVar(idx_char, "int");
						addVar(idx_null, "int");

						$$.traducao += "\t" + novo_tam + " = " + var->tam + " + 1;\n";
						$$.traducao += "\t" + novo_ptr + " = (char*) malloc(" + novo_tam + ");\n";
						$$.traducao += "\tstrcpy(" + novo_ptr + ", " + var->nome_interno + ");\n";
						$$.traducao += "\t" + idx_char + " = " + var->tam + " - 1;\n";
						$$.traducao += "\t" + novo_ptr + "[" + idx_char + "] = " + $3.label + ";\n";
						$$.traducao += "\t" + idx_null + " = " + novo_tam + " - 1;\n";
						$$.traducao += "\t" + novo_ptr + "[" + idx_null + "] = '\\0';\n";
					}

					$$.traducao += "\tfree(" + var->nome_interno + ");\n";
					$$.traducao += "\t" + var->nome_interno + " = " + novo_ptr + ";\n";
					$$.traducao += "\t" + var->tam + " = " + novo_tam + ";\n";
				}
				else {
					if(op == "+") {
						if(!somaCompativel(var->tipo, $3.tipo)) {
							yyerror("Voce nao pode usar += entre " + var->tipo + " e " + $3.tipo);
							exit(1);
						}
					}
					else {
						if(!operacao_compativel(var->tipo, $3.tipo)) {
							yyerror("Voce nao pode usar " + op + "= entre " + var->tipo + " e " + $3.tipo);
							exit(1);
						}
					}

					if(!isNumerico(var->tipo) || !isNumerico($3.tipo)) {
						yyerror("Operador " + op + "= invalido para os tipos " + var->tipo + " e " + $3.tipo);
						exit(1);
					}

					string tipo_resultado;

					if(var->tipo == "float" || $3.tipo == "float") {
						tipo_resultado = "float";
					}
					else {
						tipo_resultado = "int";
					}

					if(!atribuicaoCompativel(var->tipo, tipo_resultado)) {
						yyerror("Resultado de " + op + "= eh " + tipo_resultado + ", incompativel com " + var->tipo);
						exit(1);
					}

					string traducao = $3.traducao;
					string op1 = var->nome_interno;
					string op3 = $3.label;

					if(var->tipo == "int" && tipo_resultado == "float") {
						string temp_cast = gentempcode();
						addVar(temp_cast, "float");
						traducao += "\t" + temp_cast + " = (float) " + var->nome_interno + ";\n";
						op1 = temp_cast;
					}

					if($3.tipo == "int" && tipo_resultado == "float") {
						string temp_cast = gentempcode();
						addVar(temp_cast, "float");
						traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
						op3 = temp_cast;
					}

					string resultado = gentempcode();
					addVar(resultado, tipo_resultado);

					traducao += "\t" + resultado + " = " + op1 + " " + op + " " + op3 + ";\n";

					if(var->tipo != tipo_resultado) {
						string temp_cast = gentempcode();
						addVar(temp_cast, var->tipo);
						traducao += "\t" + temp_cast + " = (" + var->tipo + ") " + resultado + ";\n";
						resultado = temp_cast;
					}

					traducao += "\t" + var->nome_interno + " = " + resultado + ";\n";

					$$.traducao = traducao;
				}
			}
			| TK_ID TK_PP
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, $1.tipo);

				variavel* var = get<2>(exists);

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				else if(!isNumerico(var->tipo)) {
					yyerror("A variavel " + $1.label + " nao eh numerica para usar o operador ++");
					exit(1);
				}

				if(var->tipo == "float") {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1.0;\n";
				}
				else {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1;\n";
				}
			}
			| TK_ID TK_MM
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				if(!isNumerico(var->tipo)) {
					yyerror("A variavel " + $1.label + " nao eh numerica para usar o operador --");
					exit(1);
				}

				if(var->tipo == "float") {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " - 1.0;\n";
				}
				else {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " - 1;\n";
				}
			}
			| TK_PP TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($2.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $2.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				if(!isNumerico(var->tipo)) {
					yyerror("A variavel " + $2.label + " nao eh numerica para usar o operador ++");
					exit(1);
				}

				$$.label = var->nome_interno;
				$$.tipo = var->tipo;
				$$.tam = "";

				if(var->tipo == "float") {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1.0;\n";
				}
				else {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1;\n";
				}
			}
			| TK_MM TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($2.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $2.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				if(!isNumerico(var->tipo)) {
					yyerror("A variavel " + $2.label + " nao eh numerica para usar o operador --");
					exit(1);
				}

				$$.label = var->nome_interno;
				$$.tipo = var->tipo;
				$$.tam = "";

				if(var->tipo == "float") {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " - 1.0;\n";
				}
				else {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " - 1;\n";
				}
			}
			;
%%

#include "lex.yy.c"

int yyparse();

string cabecalho() {
	string codigo = "/*Compilador FOCA*/\n"
					"#include <stdio.h>\n"
					"#include <stdlib.h>\n"
					"#include <string.h>\n"
					"#include <iostream>\n"
					"using namespace std;\n\n"

					"char* read_string(int* tam) {\n"
					"\tint t1;\n"
					"\tint t2;\n"
					"\tint t3;\n"
					"\tint t5;\n"
					"\tint t6;\n"
					"\tint t7;\n"
					"\tint t8;\n"
					"\tint t9;\n"
					"\tint t10;\n"
					"\tint t11;\n"
					"\tint t12;\n"
					"\tint t13;\n"
					"\tint t14;\n"
					"\tint t15;\n"
					"\tchar* t4;\n\n"

					"\tt1 = 16;\n"
					"\tt2 = 0;\n"
					"\tt4 = (char*) malloc(t1);\n"
					"\tt3 = getchar();\n\n"

					"read_string_skip:\n"
					"\tt5 = t3 == '\\n';\n"
					"\tt6 = t3 == '\\r';\n"
					"\tt7 = t5 || t6;\n"
					"\tif (!t7) goto read_string_loop;\n"
					"\tt3 = getchar();\n"
					"\tgoto read_string_skip;\n\n"

					"read_string_loop:\n"
					"\tt8 = t3 == EOF;\n"
					"\tt9 = t3 == '\\n';\n"
					"\tt10 = t3 == '\\r';\n"
					"\tt11 = t8 || t9;\n"
					"\tt12 = t11 || t10;\n"
					"\tt13 = !t12;\n"
					"\tif (!t13) goto read_string_fim;\n\n"

					"\tt14 = t2 + 1;\n"
					"\tt15 = t14 >= t1;\n"
					"\tif (!t15) goto read_string_copia;\n\n"

					"\tt1 = t1 * 2;\n"
					"\tt4 = (char*) realloc(t4, t1);\n\n"

					"read_string_copia:\n"
					"\tt4[t2] = (char) t3;\n"
					"\tt2 = t2 + 1;\n"
					"\tt3 = getchar();\n"
					"\tgoto read_string_loop;\n\n"

					"read_string_fim:\n"
					"\tt4[t2] = '\\0';\n"
					"\t*tam = t2 + 1;\n"
					"\treturn t4;\n"
					"}\n\n"

					"char* read_token(int* tam) {\n"
					"\tint t1;\n"
					"\tint t2;\n"
					"\tint t3;\n"
					"\tint t5;\n"
					"\tint t6;\n"
					"\tint t7;\n"
					"\tint t8;\n"
					"\tint t9;\n"
					"\tint t10;\n"
					"\tint t11;\n"
					"\tint t12;\n"
					"\tint t13;\n"
					"\tint t14;\n"
					"\tint t15;\n"
					"\tint t16;\n"
					"\tint t17;\n"
					"\tint t18;\n"
					"\tint t19;\n"
					"\tint t20;\n"
					"\tint t21;\n"
					"\tint t22;\n"
					"\tchar* t4;\n\n"

					"\tt1 = 16;\n"
					"\tt2 = 0;\n"
					"\tt4 = (char*) malloc(t1);\n"
					"\tt3 = getchar();\n\n"

					"read_token_skip:\n"
					"\tt5 = t3 == ' ';\n"
					"\tt6 = t3 == '\\n';\n"
					"\tt7 = t3 == '\\t';\n"
					"\tt8 = t3 == '\\r';\n"
					"\tt9 = t5 || t6;\n"
					"\tt10 = t7 || t8;\n"
					"\tt11 = t9 || t10;\n"
					"\tif (!t11) goto read_token_loop;\n"
					"\tt3 = getchar();\n"
					"\tgoto read_token_skip;\n\n"

					"read_token_loop:\n"
					"\tt12 = t3 == EOF;\n"
					"\tt13 = t3 == ' ';\n"
					"\tt14 = t3 == '\\n';\n"
					"\tt15 = t3 == '\\t';\n"
					"\tt16 = t3 == '\\r';\n"
					"\tt17 = t12 || t13;\n"
					"\tt18 = t14 || t15;\n"
					"\tt19 = t17 || t18;\n"
					"\tt20 = t19 || t16;\n"
					"\tt21 = !t20;\n"
					"\tif (!t21) goto read_token_fim;\n\n"

					"\tt22 = t2 + 1;\n"
					"\tt5 = t22 >= t1;\n"
					"\tif (!t5) goto read_token_copia;\n\n"

					"\tt1 = t1 * 2;\n"
					"\tt4 = (char*) realloc(t4, t1);\n\n"

					"read_token_copia:\n"
					"\tt4[t2] = (char) t3;\n"
					"\tt2 = t2 + 1;\n"
					"\tt3 = getchar();\n"
					"\tgoto read_token_loop;\n\n"

					"read_token_fim:\n"
					"\tt4[t2] = '\\0';\n"
					"\t*tam = t2 + 1;\n"
					"\treturn t4;\n"
					"}\n\n"

					"int read_int() {\n"
					"\tint t1;\n"
					"\tchar* t2;\n"
					"\tint t3;\n\n"

					"\tt2 = read_token(&t1);\n"
					"\tt3 = atoi(t2);\n"
					"\tfree(t2);\n"
					"\treturn t3;\n"
					"}\n\n"

					"float read_float() {\n"
					"\tint t1;\n"
					"\tchar* t2;\n"
					"\tfloat t3;\n\n"

					"\tt2 = read_token(&t1);\n"
					"\tt3 = atof(t2);\n"
					"\tfree(t2);\n"
					"\treturn t3;\n"
					"}\n\n"

					"char read_char() {\n"
					"\tint t1;\n"
					"\tchar* t2;\n"
					"\tchar t3;\n\n"

					"\tt2 = read_token(&t1);\n"
					"\tt3 = t2[0];\n"
					"\tfree(t2);\n"
					"\treturn t3;\n"
					"}\n\n"

					"int read_bool() {\n"
					"\tint t1;\n"
					"\tchar* t2;\n"
					"\tint t3;\n"
					"\tint t4;\n"
					"\tint t5;\n\n"

					"\tt2 = read_token(&t1);\n"
					"\tt3 = 0;\n\n"

					"\tt4 = strcmp(t2, \"true\") == 0;\n"
					"\tif (!t4) goto read_bool_testar_um;\n\n"

					"\tt3 = 1;\n"
					"\tgoto read_bool_fim;\n\n"

					"read_bool_testar_um:\n"
					"\tt5 = strcmp(t2, \"1\") == 0;\n"
					"\tif (!t5) goto read_bool_fim;\n\n"

					"\tt3 = 1;\n\n"

					"read_bool_fim:\n"
					"\tfree(t2);\n"
					"\treturn t3;\n"
					"}\n\n"

					"int main(void) {\n";

	return codigo;
}

void addVar(string nome, string tipo, bool interno, string nome_interno) {
	if(!interno) {
		bool exists = exists_var_escopo_atual(nome);
		if(exists) {
			yyerror("Ja existe uma variavel com esse nome");
			exit(1);
		};

		variavel v;
		v.nome_interno = nome_interno;
		v.tipo = tipo;
		v.valor = "";
		tabelas.back()[nome] = v;
		// tabela[nome] = v;
		if(tipo == "bool") {
			variaveis += "\tint " + nome_interno + ";" + "\n";
			return;
		}
		if(tipo == "string") {
			v.tam = nome_interno + "_tam";
			v.valor = "";
			variaveis += "\tchar* " + nome_interno + ";" + "\n";
			variaveis += "\tint " + nome_interno + "_tam;\n";
			tabelas.back()[nome] = v;
			return;
		}
		variaveis += "\t" + tipo + " " + nome_interno + ";" + "\n";

		return;
	}
	
	variavel var;
	var.tipo = tipo;
	var.nome_interno = nome;

	string nome_temp = get_chave_temp(); 

	tabelas.back()[nome_temp] = var;
	if(tipo == "bool") {
		variaveis += "\tint " + nome + ";" + "\n";
		return;
	}
	if(tipo == "string") {
			var.tam = nome + "_tam";
			var.valor = "";
			variaveis += "\tchar* " + nome+ ";" + "\n";
			variaveis += "\tint " + nome + "_tam;\n";
			tabelas.back()[nome_temp] = var;
			return;
		}
	variaveis += "\t" + tipo + " " + nome + ";" + "\n";
}

bool isNumerico(string t) {
	return t == "int" || t == "float";
}

bool isBool(string t) {
	return t == "bool";
}

bool relacionalCompativel(string op, string t1, string t2) {
	if(op == "<" || op == "<=" || op == ">" || op == ">=") {
		return isNumerico(t1) && isNumerico(t2);
	}

	if(op == "==" || op == "!=") {
		if(isNumerico(t1) && isNumerico(t2)) return true;

		return t1 == t2;
	}

	return false;
}

bool logicoCompativel(string t1, string t2) {
	return t1 == "bool" && t2 == "bool";
}

bool atribuicaoCompativel(string t1, string t2) {
	if(t1 == t2) return true;

	if(isNumerico(t1) && isNumerico(t2)) return true;

	if(t1 == "string" && t2 == "char") return true;

	return false;
}

bool somaCompativel(string t1, string t2) {
	if(t1 == "bool" || t2 == "bool") return false;

	if(t1 == t2) return true;

	if(t1 == "char" && t2 == "string") return true;

	if(t1 == "string" && t2 == "char") return true;

	if(isNumerico(t1) && isNumerico(t2)) return true;

	return false;
}

bool operacao_compativel(string t1, string t2) {
	if(t1 == "bool" || t2 == "bool") return false;
	if(isNumerico(t1) && isNumerico(t2)) return true;

	return false;
}

tuple<bool, bool, variavel*> existsVar(string nome, string tipo) {

	for(int i = tabelas.size() - 1; i >= 0; i--) {
		
		bool exists = tabelas[i].find(nome) != tabelas[i].end();
		if(exists) {
			return {true, tabelas[i][nome].tipo == tipo, &tabelas[i][nome]};
		}
	}
	
	return {false, false, nullptr};
	
}

bool exists_var_escopo_atual(string nome) {
	 if(tabelas.empty()) {
        return false;
    }

    return tabelas.back().find(nome) != tabelas.back().end();
}

void abrir_escopo() {
	tabelas.push_back(map<string, variavel>());
}

void fechar_escopo() {
	tabelas.pop_back();
}

void addParametroFuncao(string nome, string tipo) {
	if(pilha_funcao.empty()) {
		yyerror("Parametro declarado fora de funcao");
		exit(1);
	}

	string interno = gentempcode();
	addVar(nome, tipo, false, interno);

	tuple<bool, bool, variavel*> exists = existsVar(nome, "any");
	variavel* var = get<2>(exists);

	argumento a;
	a.label = var->nome_interno;
	a.traducao = "";
	a.tipo = var->tipo;
	a.tam = var->tam;

	funcoes[pilha_funcao.back()].parametros.push_back(a);
}

string gerar_atribuicao_valor(string destino, string destino_tam, string destino_tipo, atributos origem_attr) {
	string traducao = origem_attr.traducao;
	string origem = origem_attr.label;

	if(isNumerico(destino_tipo) && isNumerico(origem_attr.tipo) && destino_tipo != origem_attr.tipo) {
		string temp_cast = gentempcode();
		addVar(temp_cast, destino_tipo);
		traducao += "\t" + temp_cast + " = (" + destino_tipo + ") " + origem_attr.label + ";\n";
		origem = temp_cast;
	}

	if(destino_tipo == "string") {
		if(origem_attr.tipo == "char") {
			traducao += "\t" + destino_tam + " = 2;\n";
			traducao += "\t" + destino + " = (char*) malloc(" + destino_tam + ");\n";
			traducao += "\t" + destino + "[0] = " + origem + ";\n";
			traducao += "\t" + destino + "[1] = '\\0';\n";
		}
		else {
			traducao += "\t" + destino + " = (char*) malloc(" + origem_attr.tam + ");\n";
			traducao += "\tstrcpy(" + destino + ", " + origem + ");\n";
			traducao += "\t" + destino_tam + " = " + origem_attr.tam + ";\n";
		}
	}
	else {
		traducao += "\t" + destino + " = " + origem + ";\n";
	}

	return traducao;
}

string gerar_chamada_funcao(string nome, vector<argumento> args, string &tipo, string &label, string &tam) {
	if(funcoes.find(nome) == funcoes.end()) {
		yyerror("Funcao " + nome + " nao foi declarada");
		exit(1);
	}

	funcao &f = funcoes[nome];

	if(!f.definida) {
		yyerror("Funcao " + nome + " precisa ser declarada antes de ser chamada");
		exit(1);
	}

	if(args.size() != f.parametros.size()) {
		yyerror("Funcao " + nome + " esperava " + to_string(f.parametros.size()) + " argumento(s), mas recebeu " + to_string(args.size()));
		exit(1);
	}

	string traducao = "";

	for(int i = 0; i < args.size(); i++) {
		argumento param = f.parametros[i];
		argumento arg = args[i];

		if(!atribuicaoCompativel(param.tipo, arg.tipo)) {
			yyerror("Argumento " + to_string(i + 1) + " da funcao " + nome + " deveria ser " + param.tipo + ", mas recebeu " + arg.tipo);
			exit(1);
		}

		atributos attr_arg;
		attr_arg.label = arg.label;
		attr_arg.traducao = arg.traducao;
		attr_arg.tipo = arg.tipo;
		attr_arg.tam = arg.tam;

		traducao += gerar_atribuicao_valor(param.label, param.tam, param.tipo, attr_arg);
	}

	chamada_funcao_qnt++;
	string retorno = get_label_temp("ret_" + nome);
	f.retornos.push_back({chamada_funcao_qnt, retorno});

	traducao += "\t" + f.var_chamada + " = " + to_string(chamada_funcao_qnt) + ";\n";
	traducao += "\tgoto " + f.label + ";\n";
	traducao += retorno + ":\n";

	tipo = f.tipo_retorno;
	tam = "";
	label = "";

	if(tipo != "void") {
		label = gentempcode();
		addVar(label, tipo);

		if(tipo == "string") {
			tam = label + "_tam";

			atributos ret_attr;
			ret_attr.label = f.var_retorno;
			ret_attr.traducao = "";
			ret_attr.tipo = "string";
			ret_attr.tam = f.var_retorno + "_tam";

			traducao += gerar_atribuicao_valor(label, tam, "string", ret_attr);
		}
		else {
			traducao += "\t" + label + " = " + f.var_retorno + ";\n";
		}
	}

	return traducao;
}

string montar_codigo_funcoes() {
	string codigo = "";

	for(auto &item : funcoes) {
		funcao &f = item.second;

		codigo += f.label + ":\n";
		codigo += f.corpo;
		codigo += f.fim_label + ":\n";

		for(int i = 0; i < f.retornos.size(); i++) {
			string temp = gentempcode();
			addVar(temp, "bool");

			codigo += "\t" + temp + " = " + f.var_chamada + " == " + to_string(f.retornos[i].first) + ";\n";
			codigo += "\tif (" + temp + ") goto " + f.retornos[i].second + ";\n";
		}

		codigo += "\tgoto fim_programa;\n";
	}

	return codigo;
}


string footer() {
	string codigo = "\tgoto fim_programa;\n";
	codigo += "fim_programa:\n";
	codigo += "\treturn 0;\n}\n";

	return codigo;
}

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

string get_chave_temp()
{
	var_chave_qnt++;
	return "@!" + to_string(var_chave_qnt);
}

string get_label_temp(string label)
{
	label_qnt++;
	return label + to_string(label_qnt);
}


bool caseCompativel(string tipo_switch, string tipo_case) {
    return tipo_switch == tipo_case;
}

string gerar_tamanho_string(string ponteiro, string tam) {
	string traducao = "";

	string label = get_label_temp("tam_string");
	string indice = gentempcode();
	string caractere = gentempcode();
	string eh_fim = gentempcode();
	string continua = gentempcode();

	addVar(indice, "int");
	addVar(caractere, "char");
	addVar(eh_fim, "bool");
	addVar(continua, "bool");

	traducao += "\t" + tam + " = 0;\n";
	traducao += label + ":\n";
	traducao += "\t" + tam + " = " + tam + " + 1;\n";
	traducao += "\t" + indice + " = " + tam + " - 1;\n";
	traducao += "\t" + caractere + " = " + ponteiro + "[" + indice + "];\n";
	traducao += "\t" + eh_fim + " = " + caractere + " == '\\0';\n";
	traducao += "\t" + continua + " = !" + eh_fim + ";\n";
	traducao += "\tif (" + continua + ") goto " + label + ";\n";

	return traducao;
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;
	var_chave_qnt = 0;
	label_qnt = 0;
	chamada_funcao_qnt = 0;
	abrir_escopo();

	if (yyparse() == 0) {
		string codigo_funcoes = montar_codigo_funcoes();

		cout << cabecalho();
		cout << variaveis << endl;
		cout << "\tgoto inicio_programa;\n";
		cout << codigo_funcoes;
		cout << "inicio_programa:\n";
		cout << codigo_gerado;
		cout << footer();
}

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
