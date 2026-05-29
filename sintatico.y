%{
#include <iostream>
#include <string>
#include <map>
#include <utility>
#include <tuple>
#include <vector>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int var_chave_qnt;
int label_qnt;
int linha = 1;
string codigo_gerado;
string variaveis;

struct variavel
{
	string nome_interno;
	string tipo;
	string valor;
};

vector<map<string, variavel>> tabelas;
vector<string> pilha_break;
vector<string> pilha_continue;


struct atributos
{
	string label;
	string traducao;
	string tipo;
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
IF			: TK_IF '(' E ')' BLOCO  // aqui fiquei com algumas duvidas sobre oq aceitar dentro dos parenteses, aceitar so bool?
			{
				if($3.tipo != "bool") {
					yyerror("A condição do " + $1.label + " deve ser do tipo bool");
					exit(1);
				}
				string exp = $3.traducao;
				string traducao = exp;
				string label = get_label_temp("fim_if");
				string temp = gentempcode();
				addVar(temp, $3.tipo);
				traducao += "\t" + temp + " = !" + $3.label + ";\n\tif " + "(" + temp + ") goto " + label + ";\n";
				traducao += $5.traducao + label + ":\n";
				$$.traducao = traducao;
			}
			| TK_IF '(' E ')' BLOCO QUEBRAS TK_ELSE BLOCO
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
				traducao += $5.traducao + "\tgoto " + fim_if + ";\n" + inicio_else + ":\n";
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
WHILE		: INICIO_WHILE '(' E ')' BLOCO
			{
				if($3.tipo != "bool") {
					yyerror("A condição do " + $1.label + " deve ser do tipo bool");
					exit(1);
				}

				string inicio = $1.tipo;
				string traducao = inicio + ":\n" + $3.traducao;
				string temp = gentempcode();
				addVar(temp, "bool");
				traducao += "\t" + temp + " = !" + $3.label + ";\n\tif " + "(" + temp + ") goto " + $1.label + ";\n";
				traducao += $5.traducao + "\tgoto " + inicio + ";\n" + $1.label + ":\n";
				pilha_break.pop_back();
				pilha_continue.pop_back();
				$$.traducao = traducao;
			}
			;
INICIO_DO	: TK_DO
			{
				string inicio = get_label_temp("inicio_do_while");
				string fim = get_label_temp("fim_do_while");
				$$.label = fim;
				$$.tipo = inicio;
				pilha_break.push_back(fim);
				pilha_continue.push_back(inicio);
			}
			;
DO_WHILE	: INICIO_DO BLOCO QUEBRAS TK_WHILE '(' E ')'
			{
				if($6.tipo != "bool") {
					yyerror("A condição do " + $1.label + " deve ser do tipo bool");
					exit(1);
				}
				string exp = $6.traducao;
				string inicio = $1.tipo;
				string fim = $1.label;
				string traducao = inicio + ":\n";

				traducao += $2.traducao + exp + "\tif (" + $6.label + ") goto " + inicio + ";\n";
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
				$$.label = fim_for;
				$$.tipo = inicio_for;
				pilha_break.push_back(fim_for);
				pilha_continue.push_back(inicio_for);
			}
			;
FOR			: ABRE_FOR D ';' E ';' ATRIB ')' QUEBRAS BLOCO
			{
				if($4.tipo != "bool") {
					yyerror("A expressão do 'for' deve ser do tipo bool");
					exit(1);
				}
				string traducao = $2.traducao;
				string inicio_for = $1.tipo;
				string fim_for = $1.label;
				traducao += inicio_for + ":\n" + $4.traducao;
				string temp = gentempcode();
				addVar(temp, "bool");
				traducao += "\t" + temp + " = !" + $4.label + ";\n";
				traducao += "\tif (" + temp + ") goto " + fim_for + ";\n" + $9.traducao;
				traducao += $6.traducao + "\tgoto " + inicio_for + ";\n";
				traducao += fim_for + ":\n";
				fechar_escopo();
				pilha_break.pop_back();
				pilha_continue.pop_back();
				$$.traducao = traducao;
			}
			;
BREAK		: TK_BREAK 
			{
				if(pilha_break.empty()) {
					yyerror("Nao existe loop para dar break");
					exit(1);
				}
				string traducao = "\tgoto " + pilha_break.back() + ";\n";
				$$.traducao = traducao;
			}
			;
CONTINUE		: TK_CONTINUE
			{
				if(pilha_continue.empty()) {
					yyerror("Nao existe loop para dar continue");
					exit(1);
				}
				string traducao = "\tgoto " + pilha_continue.back() + ";\n";
				$$.traducao = traducao;
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
			;
VALOR		: TK_TRUE
			{
				$$.tipo = "bool";
			}
			| TK_FALSE
			{
				$$.tipo = "bool";
			}
			| TK_LETTER
			{
				$$.tipo = "char";	
			} 
			| TK_NUM
			{
				$$.tipo = "int";
			}
			| TK_FLOAT_LIT
			{
				$$.tipo = "float";
			}
			;
CIN			: TK_CIN TK_RR TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel " + $3.label + " nao foi declarada anteriormente");
					exit(1);
				}

				variavel* var = get<2>(exists);

				string traducao = "\tcin >> " + var->nome_interno + ";\n";
				$$.traducao = traducao;		
			}
			;
COUT		: TK_COUT TK_LL TK_ID
			{
				tuple<bool, bool, variavel*> exists = existsVar($1.label, "any");

				if(!get<0>(exists)) {
					yyerror("Variavel " + $3.label + " nao foi declarada anteriormente");
					exit(1);
				}

				variavel* var = get<2>(exists);

				string traducao = "\tcout << " + var->nome_interno + ";\n";
				$$.traducao = traducao;		
			}
			| TK_COUT TK_LL TK_STRING
			{
				string traducao = "\tcout << " + $3.label + ";\n";
				$$.traducao = traducao;	
			}
			;
E 			: E '+' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode somar um " + $1.tipo + " com um " + $3.tipo);
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
					" = " + op1 + " + " + op3 + ";\n";
			}
			|
			E '-' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
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
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
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
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
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

				$$.traducao = $4.traducao + "\t" + $$.label + " = (" + $2.tipo + ") " + $4.label + ";\n";
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
				$$.traducao = traducao + "\t" + $$.label + " = " + op1 + " " + $2.label + " " + op3 + ";\n";
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
				$$.traducao = "";
			}
			| VALOR
			{
				$$.label = gentempcode();
				addVar($$.label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
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
			}
			| ATRIB
			|
			TIPO TK_ID '=' E
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

				if($1.tipo != $4.tipo) {
					string temp_cast = gentempcode();
					addVar(temp_cast, $1.tipo);
					traducao += "\t" + temp_cast + " = (" + $1.tipo + ") " + $4.label + ";\n";
					origem = temp_cast;
				}
				$$.traducao = traducao;
				$$.traducao += "\t" + var + " = " + origem + ";\n";
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
				if(var->tipo != $3.tipo) {
					string temp_cast = gentempcode();
					addVar(temp_cast, var->tipo);
					traducao += "\t" + temp_cast + " = (" + var->tipo + ") " + $3.label + ";\n";
					origem = temp_cast;
				}

				var->valor = origem;
				

				$$.traducao = traducao;
				$$.traducao += "\t" + var->nome_interno + " = " + origem + ";\n";
			}

%%

#include "lex.yy.c"

int yyparse();

string cabecalho() {
	string codigo = "/*Compilador FOCA*/\n"
					"#include <stdio.h>\n"
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


string footer() {
	string codigo = "\treturn 0;\n}\n";

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

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;
	var_chave_qnt = 0;
	label_qnt = 0;
	abrir_escopo();

	if (yyparse() == 0) {
		cout << cabecalho();
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
