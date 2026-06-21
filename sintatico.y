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
	bool constante;
};

struct argumento
{
	string nome;
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
	string variaveis;
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
void tiparVarDinamica(variavel* var, string tipo);
void verificarVarTipada(variavel* var, string nome);
void verificarNaoConstante(variavel* var, string nome);
void verificarExpressaoComValor(atributos attr, string contexto);
string tipo_c(string tipo);
void addDeclaracao(string declaracao);
string assinatura_funcao(funcao &f, bool com_nome_parametro);
string gerar_retorno_funcao(funcao &f, atributos ret);
bool isSubfaixa(string tipo);
bool isInteiro(string tipo);
int subfaixaMin(string tipo);
int subfaixaMax(string tipo);
string gerar_verificacao_subfaixa(string nome_var, string tipo);

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
%token TK_LET
%token TK_CONST
%token TK_POW
%token TK_MOD
%token TK_SQRT
%token TK_ABS
%token TK_MIN
%token TK_MAX
%token TK_DOTDOT

%start S

%left TK_OR
%left TK_AND
%left TK_RELACIONAL
%left '+' '-'
%left '*' '/' TK_MOD
%right TK_NOT TK_CAST TK_NEG
%right TK_POW


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
BREAK		: TK_BREAK ALL
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
				f.label = $2.label;
				f.tipo_retorno = "";
				f.var_retorno = "";
				f.var_chamada = "";
				f.fim_label = "";
				f.corpo = "";
				f.variaveis = "";
				f.definida = false;
				f.tem_return = false;
				f.retorno_tipado = false;

				funcoes[$2.label] = f;

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

				$$.tipo = $2.tipo;
			}
			;

LISTA_PARAMS_FUNC : PARAM_FUNC
			| LISTA_PARAMS_FUNC ',' PARAM_FUNC
			;

PARAM_FUNC : TK_ID ':' TIPO
			{
				addParametroFuncao($1.label, $3.tipo);
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

				f.tem_return = true;

				verificarExpressaoComValor($2, "como valor de return");
				$$.traducao = gerar_retorno_funcao(f, $2);
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

LISTA_ARGS : ARG_CHAMADA
			{
				$$.args = $1.args;
			}
			| LISTA_ARGS ',' ARG_CHAMADA
			{
				$$.args = $1.args;
				$$.args.push_back($3.args[0]);
			}
			;

ARG_CHAMADA : E
			{
				verificarExpressaoComValor($1, "como argumento de funcao");

				argumento a;
				a.nome = "";
				a.label = $1.label;
				a.traducao = $1.traducao;
				a.tipo = $1.tipo;
				a.tam = $1.tam;

				$$.args.clear();
				$$.args.push_back(a);
			}
			| TK_ID '=' E
			{
				verificarExpressaoComValor($3, "como argumento de funcao");

				argumento a;
				a.nome = $1.label;
				a.label = $3.label;
				a.traducao = $3.traducao;
				a.tipo = $3.tipo;
				a.tam = $3.tam;

				$$.args.clear();
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
			| TK_NUM TK_DOTDOT TK_NUM
			{
				int min = stoi($1.label);
				int max = stoi($3.label);

				if(min > max) {
					yyerror("Subfaixa invalida: limite inicial maior que limite final");
					exit(1);
				}

				$$.tipo = "subfaixa:" + $1.label + ":" + $3.label;
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

				verificarVarTipada(var, $3.label);
				verificarNaoConstante(var, $3.label);

				string traducao = "";

				if(var->tipo == "string") {
					traducao += "\tfree(" + var->nome_interno + ");\n";
					traducao += "\t" + var->nome_interno + " = read_string(&" + var->tam + ");\n";
				}
				else if(var->tipo == "int" || isSubfaixa(var->tipo)) {
					traducao += "\t" + var->nome_interno + " = read_int();\n";
					traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
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

				verificarVarTipada(var, $3.label);

				string traducao = "\tcout << " + var->nome_interno + ";\n";
				$$.traducao = traducao;		
			}
			| TK_COUT TK_LL TK_STRING_LIT
			{
				string traducao = "\tcout << " + $3.label + ";\n";
				$$.traducao = traducao;	
			}
			;
E 			: E TK_POW E
			{
				if(!isNumerico($1.tipo) || !isNumerico($3.tipo)) {
					yyerror("Exponenciacao so aceita tipos numericos");
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "float");

				$$.tipo = "float";
				$$.tam = "";

				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += "\t" + $$.label + " = pow(" + $1.label + ", " + $3.label + ");\n";
			}
			| E TK_MOD E
			{
				if(!isInteiro($1.tipo) || !isInteiro($3.tipo)) {
					yyerror("Operador % so aceita inteiros");
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "int");

				$$.tipo = "int";
				$$.tam = "";

				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += "\t" + $$.label + " = " + $1.label + " % " + $3.label + ";\n";
			}
			| TK_SQRT '(' E ')'
			{
				if(!isNumerico($3.tipo)) {
					yyerror("sqrt so aceita tipo numerico");
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, "float");

				$$.tipo = "float";
				$$.tam = "";

				$$.traducao = $3.traducao;
				$$.traducao += "\t" + $$.label + " = sqrt(" + $3.label + ");\n";
			}
			| TK_ABS '(' E ')'
			{
				if(!isNumerico($3.tipo)) {
					yyerror("abs so aceita tipo numerico");
					exit(1);
				}

				string tipo_resultado;

				if(tipo_c($3.tipo) == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);

				$$.tipo = tipo_resultado;
				$$.tam = "";

				$$.traducao = $3.traducao;

				if(tipo_resultado == "float") {
					$$.traducao += "\t" + $$.label + " = fabs(" + $3.label + ");\n";
				}
				else {
					$$.traducao += "\t" + $$.label + " = abs(" + $3.label + ");\n";
				}
			}
			| TK_MIN '(' E ',' E ')'
			{
				if(!isNumerico($3.tipo) || !isNumerico($5.tipo)) {
					yyerror("min so aceita tipos numericos");
					exit(1);
				}

				string tipo_resultado;

				if(tipo_c($3.tipo) == "float" || tipo_c($5.tipo) == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);

				$$.tipo = tipo_resultado;
				$$.tam = "";

				$$.traducao = $3.traducao + $5.traducao;
				$$.traducao += "\t" + $$.label + " = " + $3.label + " < " + $5.label + " ? " + $3.label + " : " + $5.label + ";\n";
			}
			| TK_MAX '(' E ',' E ')'
			{
				if(!isNumerico($3.tipo) || !isNumerico($5.tipo)) {
					yyerror("max so aceita tipos numericos");
					exit(1);
				}

				string tipo_resultado;

				if(tipo_c($3.tipo) == "float" || tipo_c($5.tipo) == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);

				$$.tipo = tipo_resultado;
				$$.tam = "";

				$$.traducao = $3.traducao + $5.traducao;
				$$.traducao += "\t" + $$.label + " = " + $3.label + " > " + $5.label + " ? " + $3.label + " : " + $5.label + ";\n";
			}
			| E '+' E
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
				string tipo_resultado;

				if(tipo_c($2.tipo) == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;
				$$.tam = "";

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
				$$.tam = "";

				string tipo = tipo_c($2.tipo);

				$$.traducao = $4.traducao;
				$$.traducao += "\t" + $$.label + " = (" + tipo + ") " + $4.label + ";\n";
				$$.traducao += gerar_verificacao_subfaixa($$.label, $2.tipo);
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

				if(isNumerico($1.tipo) && isNumerico($3.tipo) && tipo_c($1.tipo) != tipo_c($3.tipo)) {
					if(tipo_c($1.tipo) == "int" && tipo_c($3.tipo) == "float") {
						string temp_cast = gentempcode();
						addVar(temp_cast, "float");
						traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
						op1 = temp_cast;
					}

					if(tipo_c($3.tipo) == "int" && tipo_c($1.tipo) == "float") {
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

				verificarVarTipada(var, $1.label);

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
D			: TK_LET TK_ID ':' TIPO
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				string var = gentempcode();
				addVar($2.label, $4.tipo, false, var);

				$$.traducao = "";

				if($4.tipo == "string") {
					$$.traducao += "\t" + var + " = NULL;\n";
					$$.traducao += "\t" + var + "_tam = 0;\n";
				}
			}
			| ATRIB
			{
				$$.traducao = $1.traducao;
			}
			| TK_LET TK_ID ':' TIPO '=' E
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				verificarExpressaoComValor($6, "na inicializacao da variavel " + $2.label);
				if(!atribuicaoCompativel($4.tipo, $6.tipo)) { // aqui depois posso colocar a funcao que verifica se tipos sao compativeis
					yyerror("Tipos incompativeis de atribuição (" + $4.tipo + ", " + $6.tipo + ")");
					exit(1);
				}
				string var = gentempcode();
				addVar($2.label, $4.tipo, false, var);

				

				string traducao = $6.traducao;
				string origem = $6.label;

				if(isNumerico($4.tipo) && isNumerico($6.tipo) && tipo_c($4.tipo) != tipo_c($6.tipo)) {
					string temp_cast = gentempcode();
					addVar(temp_cast, $4.tipo);
					traducao += "\t" + temp_cast + " = (" + tipo_c($4.tipo) + ") " + $6.label + ";\n";
					origem = temp_cast;
				}

				$$.traducao = "";

                if($4.tipo == "string") {
                    $$.traducao += "\t" + var + " = NULL;\n";
                    $$.traducao += "\t" + var + "_tam = 0;\n";
                }

                $$.traducao += traducao;

                if($4.tipo == "string") {
					if($6.tipo == "char") {
						$$.traducao += "\t" + var + "_tam = 2;\n";
						$$.traducao += "\t" + var + " = (char*) malloc(" + var + "_tam);\n";
						$$.traducao += "\t" + var + "[0] = " + $6.label + ";\n";
						$$.traducao += "\t" + var + "[1] = '\\0';\n";
					}
					else {
						$$.traducao += "\t" + var + " = (char*) malloc(" + $6.tam + ");\n";
						$$.traducao += "\tstrcpy(" + var + ", " + $6.label + ");\n";
						$$.traducao += "\t" + var + "_tam = " + $6.tam + ";\n";
					}
				}
				else {
					$$.traducao += "\t" + var + " = " + origem + ";\n";
					$$.traducao += gerar_verificacao_subfaixa(var, $4.tipo);
				}

			}
			| TK_LET TK_ID
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}

				string var = gentempcode();
				addVar($2.label, "var", false, var);

				$$.traducao = "";
			}
			| TK_LET TK_ID '=' E
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}

				verificarExpressaoComValor($4, "na inicializacao da variavel " + $2.label);

				string var_nome = gentempcode();
				addVar($2.label, "var", false, var_nome);

				tuple<bool, bool, variavel*> exists_var = existsVar($2.label, "any");
				variavel* var = get<2>(exists_var);

				tiparVarDinamica(var, $4.tipo);

				$$.traducao = "";

				if(var->tipo == "string") {
					$$.traducao += "\t" + var->nome_interno + " = NULL;\n";
					$$.traducao += "\t" + var->tam + " = 0;\n";
				}

				$$.traducao += gerar_atribuicao_valor(var->nome_interno, var->tam, var->tipo, $4);
			}
			| TK_CONST TK_ID '=' E
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}

				verificarExpressaoComValor($4, "na inicializacao da variavel " + $2.label);

				string var_nome = gentempcode();
				addVar($2.label, "var", false, var_nome);

				tuple<bool, bool, variavel*> exists_var = existsVar($2.label, "any");
				variavel* var = get<2>(exists_var);

				tiparVarDinamica(var, $4.tipo);
				var->constante = true;

				$$.traducao = "";

				if(var->tipo == "string") {
					$$.traducao += "\t" + var->nome_interno + " = NULL;\n";
					$$.traducao += "\t" + var->tam + " = 0;\n";
				}

				$$.traducao += gerar_atribuicao_valor(var->nome_interno, var->tam, var->tipo, $4);
			}
			| TK_CONST TK_ID ':' TIPO '=' E
			{
				bool exists = exists_var_escopo_atual($2.label);
				if(exists) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}

				verificarExpressaoComValor($6, "na inicializacao da variavel " + $2.label);

				if(!atribuicaoCompativel($4.tipo, $6.tipo)) {
					yyerror("Tipos incompativeis de atribuição (" + $4.tipo + ", " + $6.tipo + ")");
					exit(1);
				}

				string var = gentempcode();
				addVar($2.label, $4.tipo, false, var);

				tuple<bool, bool, variavel*> exists_var = existsVar($2.label, "any");
				variavel* var_info = get<2>(exists_var);
				var_info->constante = true;

				string traducao = $6.traducao;
				string origem = $6.label;

				if(isNumerico($4.tipo) && isNumerico($6.tipo) && tipo_c($4.tipo) != tipo_c($6.tipo)) {
					string temp_cast = gentempcode();
					addVar(temp_cast, $4.tipo);
					traducao += "\t" + temp_cast + " = (" + tipo_c($4.tipo) + ") " + $6.label + ";\n";
					origem = temp_cast;
				}

				$$.traducao = "";

				if($4.tipo == "string") {
					$$.traducao += "\t" + var + " = NULL;\n";
					$$.traducao += "\t" + var + "_tam = 0;\n";
				}

				$$.traducao += traducao;

				if($4.tipo == "string") {
					if($6.tipo == "char") {
						$$.traducao += "\t" + var + "_tam = 2;\n";
						$$.traducao += "\t" + var + " = (char*) malloc(" + var + "_tam);\n";
						$$.traducao += "\t" + var + "[0] = " + $6.label + ";\n";
						$$.traducao += "\t" + var + "[1] = '\\0';\n";
					}
					else {
						$$.traducao += "\t" + var + " = (char*) malloc(" + $6.tam + ");\n";
						$$.traducao += "\tstrcpy(" + var + ", " + $6.label + ");\n";
						$$.traducao += "\t" + var + "_tam = " + $6.tam + ";\n";
					}
				}
				else {
					$$.traducao += "\t" + var + " = " + origem + ";\n";
					$$.traducao += gerar_verificacao_subfaixa(var, $4.tipo);
				}
			}
			;
ATRIB		: TK_ID '=' E
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				verificarExpressaoComValor($3, "na atribuicao de " + $1.label);
				verificarNaoConstante(var, $1.label);

				bool primeira_atribuicao_var = var->tipo == "var";

				if(primeira_atribuicao_var) {
					tiparVarDinamica(var, $3.tipo);
				}
				else if(!atribuicaoCompativel(var->tipo, $3.tipo)) {
					yyerror("A variavel " + $1.label + " eh do tipo " + var->tipo + " e vc tentou associar ela com um valor do tipo " + $3.tipo);
					exit(1);
				}

				string traducao = $3.traducao;
				string origem = $3.label;
				if(isNumerico(var->tipo) && isNumerico($3.tipo) && tipo_c(var->tipo) != tipo_c($3.tipo)) {
					string temp_cast = gentempcode();
					addVar(temp_cast, var->tipo);
					traducao += "\t" + temp_cast + " = (" + tipo_c(var->tipo) + ") " + $3.label + ";\n";
					origem = temp_cast;
				}

				var->valor = origem;
				
				$$.traducao = "";

				if(primeira_atribuicao_var && var->tipo == "string") {
					$$.traducao += "\t" + var->nome_interno + " = NULL;\n";
					$$.traducao += "\t" + var->tam + " = 0;\n";
				}

				$$.traducao += traducao;

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
					$$.traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
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
				verificarExpressaoComValor($3, "no operador composto de " + $1.label);
				verificarNaoConstante(var, $1.label);
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

					if(tipo_c(var->tipo) != tipo_c(tipo_resultado)) {
						string temp_cast = gentempcode();
						addVar(temp_cast, var->tipo);
						traducao += "\t" + temp_cast + " = (" + tipo_c(var->tipo) + ") " + resultado + ";\n";
						resultado = temp_cast;
					}

					traducao += "\t" + var->nome_interno + " = " + resultado + ";\n";
					traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);

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

				verificarNaoConstante(var, $1.label);

				if(var->tipo == "float") {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1.0;\n";
				}
				else {
					$$.traducao = "\t" + var->nome_interno + " = " + var->nome_interno + " + 1;\n";
				}

				$$.traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
			}
			| TK_ID TK_MM
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $1.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				verificarNaoConstante(var, $1.label);

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

				$$.traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
			}
			| TK_PP TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($2.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $2.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				verificarNaoConstante(var, $2.label);

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

				$$.traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
			}
			| TK_MM TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($2.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel '" + $2.label + "' nao foi declarada");
					exit(1);
				}

				variavel* var = get<2>(exists);

				verificarNaoConstante(var, $2.label);

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

				$$.traducao += gerar_verificacao_subfaixa(var->nome_interno, var->tipo);
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
					"#include <math.h>\n"
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
					"}\n\n";


	return codigo;
}

string tipo_c(string tipo) {
	if(tipo == "bool") return "int";
	if(tipo == "string") return "char*";
	if(tipo == "void") return "void";
	if(isSubfaixa(tipo)) return "int";

	return tipo;
}

void addDeclaracao(string declaracao) {
	if(!pilha_funcao.empty()) {
		string nome_funcao = pilha_funcao.back();
		funcoes[nome_funcao].variaveis += declaracao;
	}
	else {
		variaveis += declaracao;
	}
}

string assinatura_funcao(funcao &f, bool com_nome_parametro) {
	string assinatura = tipo_c(f.tipo_retorno) + " " + f.nome + "(";

	for(int i = 0; i < f.parametros.size(); i++) {
		if(i > 0) {
			assinatura += ", ";
		}

		if(f.parametros[i].tipo == "string") {
			assinatura += "char*";

			if(com_nome_parametro) {
				assinatura += " " + f.parametros[i].label;
			}

			assinatura += ", int";

			if(com_nome_parametro) {
				assinatura += " " + f.parametros[i].tam;
			}
		}
		else {
			assinatura += tipo_c(f.parametros[i].tipo);

			if(com_nome_parametro) {
				assinatura += " " + f.parametros[i].label;
			}
		}
	}

	assinatura += ")";
	return assinatura;
}

string gerar_retorno_funcao(funcao &f, atributos ret) {
	if(f.tipo_retorno == "") {
		f.tipo_retorno = ret.tipo;
	}
	else if(!atribuicaoCompativel(f.tipo_retorno, ret.tipo)) {
		yyerror("Retorno da funcao " + f.nome + " deveria ser " + f.tipo_retorno + ", mas recebeu " + ret.tipo);
		exit(1);
	}

	string traducao = ret.traducao;
	string origem = ret.label;

	if(isNumerico(f.tipo_retorno) && isNumerico(ret.tipo) && tipo_c(f.tipo_retorno) != tipo_c(ret.tipo)) {
		string temp_cast = gentempcode();
		addVar(temp_cast, f.tipo_retorno);

		traducao += "\t" + temp_cast + " = (" + tipo_c(f.tipo_retorno) + ") " + ret.label + ";\n";
		origem = temp_cast;
	}
	else if(f.tipo_retorno == "string" && ret.tipo == "char") {
		string temp_string = gentempcode();
		addVar(temp_string, "string");

		atributos attr;
		attr.label = ret.label;
		attr.traducao = "";
		attr.tipo = ret.tipo;
		attr.tam = ret.tam;

		traducao += gerar_atribuicao_valor(temp_string, temp_string + "_tam", "string", attr);
		origem = temp_string;
	}

	traducao += gerar_verificacao_subfaixa(origem, f.tipo_retorno);
	traducao += "\treturn " + origem + ";\n";

	return traducao;
}

void tiparVarDinamica(variavel* var, string tipo) {
	if(var->tipo != "var") {
		return;
	}

	var->tipo = tipo;

	if(tipo == "bool") {
		addDeclaracao("\tint " + var->nome_interno + ";\n");
	}
	else if(tipo == "string") {
		var->tam = var->nome_interno + "_tam";
		addDeclaracao("\tchar* " + var->nome_interno + ";\n");
		addDeclaracao("\tint " + var->nome_interno + "_tam;\n");
	}
	else {
		var->tam = "";
		addDeclaracao("\t" + tipo_c(tipo) + " " + var->nome_interno + ";\n");
	}
}

void verificarVarTipada(variavel* var, string nome) {
	if(var->tipo == "var") {
		yyerror("Variavel " + nome + " declarada com var ainda nao recebeu valor inicial");
		exit(1);
	}
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
		v.tam = "";
		v.constante = false;
		tabelas.back()[nome] = v;

		if(tipo == "var") {
			return;
		}
		// tabela[nome] = v;
		if(tipo == "bool") {
			addDeclaracao("\tint " + nome_interno + ";\n");
			return;
		}
		if(tipo == "string") {
			v.tam = nome_interno + "_tam";
			v.valor = "";
			addDeclaracao("\tchar* " + nome_interno + ";\n");
			addDeclaracao("\tint " + nome_interno + "_tam;\n");
			tabelas.back()[nome] = v;
			return;
		}
		addDeclaracao("\t" + tipo_c(tipo) + " " + nome_interno + ";\n");

		return;
	}
	
	variavel var;
	var.tipo = tipo;
	var.nome_interno = nome;
	var.valor = "";
	var.tam = "";
	var.constante = false;

	string nome_temp = get_chave_temp(); 

	tabelas.back()[nome_temp] = var;
	if(tipo == "bool") {
		addDeclaracao("\tint " + nome + ";\n");
		return;
	}
	if(tipo == "string") {
			var.tam = nome + "_tam";
			var.valor = "";
			addDeclaracao("\tchar* " + nome + ";\n");
			addDeclaracao("\tint " + nome + "_tam;\n");
			tabelas.back()[nome_temp] = var;
			return;
		}
	addDeclaracao("\t" + tipo_c(tipo) + " " + nome + ";\n");
}

void verificarNaoConstante(variavel* var, string nome) {
	if(var->constante) {
		yyerror("nao eh possivel alterar a constante " + nome);
		exit(1);
	}
}

void verificarExpressaoComValor(atributos attr, string contexto) {
	if(attr.tipo == "void") {
		yyerror("Funcao sem retorno nao pode ser usada " + contexto);
		exit(1);
	}
}

bool isSubfaixa(string tipo) {
	return tipo.rfind("subfaixa:", 0) == 0;
}

int subfaixaMin(string tipo) {
	int p1 = tipo.find(":");
	int p2 = tipo.find(":", p1 + 1);

	return stoi(tipo.substr(p1 + 1, p2 - p1 - 1));
}

int subfaixaMax(string tipo) {
	int p1 = tipo.find(":");
	int p2 = tipo.find(":", p1 + 1);

	return stoi(tipo.substr(p2 + 1));
}

bool isInteiro(string tipo) {
	return tipo == "int" || isSubfaixa(tipo);
}

string gerar_verificacao_subfaixa(string nome_var, string tipo) {
	if(!isSubfaixa(tipo)) {
		return "";
	}

	int min = subfaixaMin(tipo);
	int max = subfaixaMax(tipo);

	string menor = gentempcode();
	string maior = gentempcode();
	string erro = gentempcode();
	string fim = get_label_temp("fim_subfaixa");

	addVar(menor, "bool");
	addVar(maior, "bool");
	addVar(erro, "bool");

	string traducao = "";

	traducao += "\t" + menor + " = " + nome_var + " < " + to_string(min) + ";\n";
	traducao += "\t" + maior + " = " + nome_var + " > " + to_string(max) + ";\n";
	traducao += "\t" + erro + " = " + menor + " || " + maior + ";\n";
	traducao += "\tif (!" + erro + ") goto " + fim + ";\n";
	traducao += "\tprintf(\"Erro: valor fora da subfaixa [" + to_string(min) + ".." + to_string(max) + "]\\n\");\n";
	traducao += "\texit(1);\n";
	traducao += fim + ":\n";

	return traducao;
}

bool isNumerico(string t) {
	return t == "int" || t == "float" || isSubfaixa(t);
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

	if(isSubfaixa(t1)) {
		return isInteiro(t2);
	}

	if(isSubfaixa(t2)) {
		return t1 == "int";
	}

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

	if(exists_var_escopo_atual(nome)) {
		yyerror("Parametro " + nome + " ja foi declarado anteriormente");
		exit(1);
	}

	string interno = gentempcode();

	variavel v;
	v.nome_interno = interno;
	v.tipo = tipo;
	v.valor = "";
	v.tam = "";
	v.constante = false;

	if(tipo == "string") {
		v.tam = interno + "_tam";
	}

	tabelas.back()[nome] = v;

	argumento a;
	a.nome = nome;
	a.label = interno;
	a.traducao = "";
	a.tipo = tipo;
	a.tam = v.tam;

	funcoes[pilha_funcao.back()].parametros.push_back(a);
}

string gerar_atribuicao_valor(string destino, string destino_tam, string destino_tipo, atributos origem_attr) {
	string traducao = origem_attr.traducao;
	string origem = origem_attr.label;

	if(isNumerico(destino_tipo) && isNumerico(origem_attr.tipo) && tipo_c(destino_tipo) != tipo_c(origem_attr.tipo)) {
		string temp_cast = gentempcode();
		addVar(temp_cast, destino_tipo);
		traducao += "\t" + temp_cast + " = (" + tipo_c(destino_tipo) + ") " + origem_attr.label + ";\n";
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
		traducao += gerar_verificacao_subfaixa(destino, destino_tipo);
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

	bool tem_nomeado = false;
	bool tem_posicional = false;

	for(int i = 0; i < args.size(); i++) {
		if(args[i].nome != "") {
			tem_nomeado = true;
		}
		else {
			tem_posicional = true;
		}
	}

	if(tem_nomeado && tem_posicional) {
		yyerror("Chamada da funcao " + nome + " nao pode misturar argumentos por nome e por ordem");
		exit(1);
	}

	vector<argumento> args_ordenados;

	if(!tem_nomeado) {
		args_ordenados = args;
	}
	else {
		args_ordenados.resize(f.parametros.size());

		vector<bool> preenchido;

		for(int i = 0; i < f.parametros.size(); i++) {
			preenchido.push_back(false);
		}

		for(int i = 0; i < args.size(); i++) {
			int indice_parametro = -1;

			for(int j = 0; j < f.parametros.size(); j++) {
				if(f.parametros[j].nome == args[i].nome) {
					indice_parametro = j;
					break;
				}
			}

			if(indice_parametro == -1) {
				yyerror("Funcao " + nome + " nao possui parametro chamado " + args[i].nome);
				exit(1);
			}

			if(preenchido[indice_parametro]) {
				yyerror("Parametro " + args[i].nome + " foi passado mais de uma vez na funcao " + nome);
				exit(1);
			}

			args_ordenados[indice_parametro] = args[i];
			preenchido[indice_parametro] = true;
		}

		for(int i = 0; i < preenchido.size(); i++) {
			if(!preenchido[i]) {
				yyerror("Parametro " + f.parametros[i].nome + " nao foi informado na chamada da funcao " + nome);
				exit(1);
			}
		}
	}

	string traducao = "";
	string lista_args = "";

	for(int i = 0; i < args_ordenados.size(); i++) {
		argumento param = f.parametros[i];
		argumento arg = args_ordenados[i];

		if(!atribuicaoCompativel(param.tipo, arg.tipo)) {
			yyerror("Argumento " + to_string(i + 1) + " da funcao " + nome + " deveria ser " + param.tipo + ", mas recebeu " + arg.tipo);
			exit(1);
		}

		traducao += arg.traducao;

		string valor_arg = arg.label;
		string valor_tam = arg.tam;

		if(isNumerico(param.tipo) && isNumerico(arg.tipo) && tipo_c(param.tipo) != tipo_c(arg.tipo)) {
			string temp_cast = gentempcode();
			addVar(temp_cast, param.tipo);

			traducao += "\t" + temp_cast + " = (" + tipo_c(param.tipo) + ") " + arg.label + ";\n";
			valor_arg = temp_cast;
		}
		else if(param.tipo == "string" && arg.tipo == "char") {
			string temp_string = gentempcode();
			addVar(temp_string, "string");

			atributos attr;
			attr.label = arg.label;
			attr.traducao = "";
			attr.tipo = arg.tipo;
			attr.tam = arg.tam;

			traducao += gerar_atribuicao_valor(temp_string, temp_string + "_tam", "string", attr);
			valor_arg = temp_string;
			valor_tam = temp_string + "_tam";
		}

		traducao += gerar_verificacao_subfaixa(valor_arg, param.tipo);

		if(i > 0) {
			lista_args += ", ";
		}

		lista_args += valor_arg;

		if(param.tipo == "string") {
			lista_args += ", " + valor_tam;
		}
	}

	tipo = f.tipo_retorno;
	tam = "";

	if(tipo == "void") {
		label = "";
		traducao += "\t" + f.nome + "(" + lista_args + ");\n";
		return traducao;
	}

	label = gentempcode();
	addVar(label, tipo);

	traducao += "\t" + label + " = " + f.nome + "(" + lista_args + ");\n";

	if(tipo == "string") {
		tam = label + "_tam";
		traducao += gerar_tamanho_string(label, tam);
	}

	return traducao;
}

string montar_codigo_funcoes() {
	string codigo = "";

	for(auto &item : funcoes) {
		funcao &f = item.second;

		codigo += assinatura_funcao(f, false) + ";\n";
	}

	if(!funcoes.empty()) {
		codigo += "\n";
	}

	for(auto &item : funcoes) {
		funcao &f = item.second;

		codigo += assinatura_funcao(f, true) + " {\n";
		codigo += f.variaveis;

		if(f.variaveis != "") {
			codigo += "\n";
		}

		codigo += f.corpo;

		if(f.tipo_retorno == "void") {
			codigo += "\treturn;\n";
		}

		codigo += "}\n\n";
	}

	return codigo;
}


string footer() {
	string codigo = "\treturn 0;\n";
	codigo += "}\n";

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
	if(tipo_switch == tipo_case) {
		return true;
	}

	if(isSubfaixa(tipo_switch) && tipo_case == "int") {
		return true;
	}

	if(tipo_switch == "int" && isSubfaixa(tipo_case)) {
		return true;
	}

	return false;
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
		cout << codigo_funcoes;
		cout << "int main(void) {\n";
		cout << variaveis << endl;
		cout << codigo_gerado;
		cout << footer();
}

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
