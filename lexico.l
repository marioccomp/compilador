%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
QUEBRA (\r\n|\n|\r)
DIGITO [0-9]
MIN[a-z]
MAIU[A-Z]
VAR [_a-zA-Z][_a-zA-Z0-9]*
DELIM {ESPACO}+
FLOAT ({DIGITO}+"."{DIGITO}+)|("."{DIGITO}+)
NUM {DIGITO}+
%x COMENTARIO_BLOCO

%%

({QUEBRA}{ESPACO}*)+(?i:else) {
    for(int i = 0; yytext[i] != '\0'; i++) {
        if(yytext[i] == '\n') {
            linha++;
        }
        else if(yytext[i] == '\r') {
            linha++;

            if(yytext[i + 1] == '\n') {
                i++;
            }
        }
    }

    yylval.label = "else";
    return TK_ELSE;
}
"\r\n"      { linha++; return '\n'; }
"\n"        { linha++; return '\n'; }
"\r"        { linha++; return '\n'; }

{DELIM} 	{}

"+="        { yylval.label = "+"; return TK_ATRIB_COMP; }
"-="        { yylval.label = "-"; return TK_ATRIB_COMP; }
"*="        { yylval.label = "*"; return TK_ATRIB_COMP; }
"/="        { yylval.label = "/"; return TK_ATRIB_COMP; }
[+-]			{ return *yytext; }
[*/]             { return *yytext; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
"int"       {return TK_INT; }
{FLOAT}     { yylval.label = yytext; return TK_FLOAT_LIT; }
"float"     {  return TK_FLOAT; }
"char"      { return TK_CHAR; }
"bool"      { return TK_BOOL; }
"false"     { yylval.label = "0"; return TK_FALSE;}
"true"     { yylval.label = "1"; return TK_TRUE;}
"("        { return '('; }
")"        { return ')'; }
"["        { return '['; }
"]"        { return ']'; }
"{"         {return '{';}
"}"         {return '}';}
","         {return ',';}
\'[a-zA-Z]\' { yylval.label = yytext; return TK_LETTER; }
"="          {return '=';}
"=="         {yylval.label = yytext; return TK_RELACIONAL;}
"<"         {yylval.label = yytext; return TK_RELACIONAL;}
">"         {yylval.label = yytext; return TK_RELACIONAL;}
">="         {yylval.label = yytext; return TK_RELACIONAL;}
"<="         {yylval.label = yytext; return TK_RELACIONAL;}
"!="        {yylval.label = yytext; return TK_RELACIONAL;}
"||"         {yylval.label = yytext; return TK_OR;}
"&&"        {yylval.label = yytext; return TK_AND;}
"!"         {yylval.label = yytext; return TK_NOT;}
";"         {return ';';}
":"         {return ':';}
(?i:if)      {yylval.label = yytext; return TK_IF;}
(?i:while)    {yylval.label = yytext; return TK_WHILE;}
(?i:do) {yylval.label = yytext; return TK_DO;}
(?i:else)   {yylval.label = yytext; return TK_ELSE;}
(?i:for)    {yylval.label = yytext; return TK_FOR;}
(?i:break)  {return TK_BREAK;}
(?i:all)    {yylval.label = "all"; return TK_ALL;}
(?i:continue)  {return TK_CONTINUE;}
(?i:cin)    {return TK_CIN;}
(?i:cout)    {return TK_COUT;}
(?i:endl) { return TK_ENDL; }
(?i:func)   {return TK_FUNC;}
(?i:return) {return TK_RETURN;}
(?i:let)    {return TK_LET;}
(?i:const)    {return TK_CONST;}
(?i:global) { return TK_GLOBAL; }
">>"        {return TK_RR;}
"<<"        {return TK_LL;}
\"[^\"]*\" { yylval.label = yytext; return TK_STRING_LIT;}
(?i:string) { yylval.label = yytext; return TK_STRING;}
"switch"   { return TK_SWITCH; }
"case"     { return TK_CASE; }
"default"  { return TK_DEFAULT; }
"++"        {return TK_PP;}
"--"        {return TK_MM;}
"//".*                  { }

"/*"                    { BEGIN(COMENTARIO_BLOCO); }

<COMENTARIO_BLOCO>"*/"  { BEGIN(INITIAL); }
<COMENTARIO_BLOCO>\r\n  { linha++; }
<COMENTARIO_BLOCO>\n    { linha++; }
<COMENTARIO_BLOCO>\r    { linha++; }
<COMENTARIO_BLOCO>.     { }
<COMENTARIO_BLOCO><<EOF>> {
    fprintf(stderr, "Erro: comentario de bloco nao fechado\n");
    exit(1);
}

".."                    { return TK_DOTDOT; }

"**"                    { yylval.label = yytext; return TK_POW; }
"%"                     { yylval.label = yytext; return TK_MOD; }

"sqrt"                  { return TK_SQRT; }
"abs"                   { return TK_ABS; }
"min"                   { return TK_MIN; }
"max"                   { return TK_MAX; }





{VAR}       { yylval.label = yytext; return TK_ID; }


.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
