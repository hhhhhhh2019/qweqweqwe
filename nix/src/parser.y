%define api.header.include {"parser.h"}
%define api.pure full
%define api.push-pull push
%define api.token.prefix {TOK_}
%define parse.lac full
%define parse.error detailed

%{

#include <stdio.h>

void yyerror(char*);

%}

%union {
	int a;
}

%token
	PLUS      "+"
	LBR       "("
	RBR       ")"
	LCBR      "{"
	RCBR      "}"
	COMMA     ","
	COLON     ":"
	SEMICOLON ";"
	ASSIGN    "="
	NUMBER    "number"
	ID        "id"

%%

E: NUMBER

%%


void yyerror(char* msg) {
	printf("%s\n", msg);
}
