/*Compilador FOCA*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
using namespace std;

char* read_string(int* tam) {
	int t1;
	int t2;
	int t3;
	int t5;
	int t6;
	int t7;
	int t8;
	int t9;
	int t10;
	int t11;
	int t12;
	int t13;
	int t14;
	int t15;
	char* t4;

	t1 = 16;
	t2 = 0;
	t4 = (char*) malloc(t1);
	t3 = getchar();

read_string_skip:
	t5 = t3 == '\n';
	t6 = t3 == '\r';
	t7 = t5 || t6;
	if (!t7) goto read_string_loop;
	t3 = getchar();
	goto read_string_skip;

read_string_loop:
	t8 = t3 == EOF;
	t9 = t3 == '\n';
	t10 = t3 == '\r';
	t11 = t8 || t9;
	t12 = t11 || t10;
	t13 = !t12;
	if (!t13) goto read_string_fim;

	t14 = t2 + 1;
	t15 = t14 >= t1;
	if (!t15) goto read_string_copia;

	t1 = t1 * 2;
	t4 = (char*) realloc(t4, t1);

read_string_copia:
	t4[t2] = (char) t3;
	t2 = t2 + 1;
	t3 = getchar();
	goto read_string_loop;

read_string_fim:
	t4[t2] = '\0';
	*tam = t2 + 1;
	return t4;
}

char* read_token(int* tam) {
	int t1;
	int t2;
	int t3;
	int t5;
	int t6;
	int t7;
	int t8;
	int t9;
	int t10;
	int t11;
	int t12;
	int t13;
	int t14;
	int t15;
	int t16;
	int t17;
	int t18;
	int t19;
	int t20;
	int t21;
	int t22;
	char* t4;

	t1 = 16;
	t2 = 0;
	t4 = (char*) malloc(t1);
	t3 = getchar();

read_token_skip:
	t5 = t3 == ' ';
	t6 = t3 == '\n';
	t7 = t3 == '\t';
	t8 = t3 == '\r';
	t9 = t5 || t6;
	t10 = t7 || t8;
	t11 = t9 || t10;
	if (!t11) goto read_token_loop;
	t3 = getchar();
	goto read_token_skip;

read_token_loop:
	t12 = t3 == EOF;
	t13 = t3 == ' ';
	t14 = t3 == '\n';
	t15 = t3 == '\t';
	t16 = t3 == '\r';
	t17 = t12 || t13;
	t18 = t14 || t15;
	t19 = t17 || t18;
	t20 = t19 || t16;
	t21 = !t20;
	if (!t21) goto read_token_fim;

	t22 = t2 + 1;
	t5 = t22 >= t1;
	if (!t5) goto read_token_copia;

	t1 = t1 * 2;
	t4 = (char*) realloc(t4, t1);

read_token_copia:
	t4[t2] = (char) t3;
	t2 = t2 + 1;
	t3 = getchar();
	goto read_token_loop;

read_token_fim:
	t4[t2] = '\0';
	*tam = t2 + 1;
	return t4;
}

int read_int() {
	int t1;
	char* t2;
	int t3;

	t2 = read_token(&t1);
	t3 = atoi(t2);
	free(t2);
	return t3;
}

float read_float() {
	int t1;
	char* t2;
	float t3;

	t2 = read_token(&t1);
	t3 = atof(t2);
	free(t2);
	return t3;
}

char read_char() {
	int t1;
	char* t2;
	char t3;

	t2 = read_token(&t1);
	t3 = t2[0];
	free(t2);
	return t3;
}

int read_bool() {
	int t1;
	char* t2;
	int t3;
	int t4;
	int t5;

	t2 = read_token(&t1);
	t3 = 0;

	t4 = strcmp(t2, "true") == 0;
	if (!t4) goto read_bool_testar_um;

	t3 = 1;
	goto read_bool_fim;

read_bool_testar_um:
	t5 = strcmp(t2, "1") == 0;
	if (!t5) goto read_bool_fim;

	t3 = 1;

read_bool_fim:
	free(t2);
	return t3;
}

int main(void) {
	int t1;
	int t2;
	int t3;
	int t4;

	t1 = read_int();
	t2 = t1 < 0;
	t3 = t1 > 9;
	t4 = t2 || t3;
	if (!t4) goto fim_subfaixa1;
	printf("Erro: valor fora da subfaixa [0..9]\n");
	exit(1);
fim_subfaixa1:
	return 0;
}
