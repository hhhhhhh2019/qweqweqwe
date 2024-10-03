%define api.header.include {"parser.h"}
%define api.pure full
%define api.push-pull push
%define api.token.prefix {TOK_}
%define parse.lac full
%define parse.error detailed

%code top{

#include <stdio.h>
#include "node.h"

}

%code provides {

void yyerror(const char*);
struct Node* yyparse(FILE*);

}

%code {

#include "lexer.h"
struct Node* parser_root;

}

%union {
	struct Node* node;
}

%token
	PLUS        "+"
	MINUS       "-"
	STAR        "*"
	SLASH       "/"
	LBR         "("
	RBR         ")"
	LCBR        "{"
	RCBR        "}"
	DOT         "."
	COMMA       ","
	COLON       ":"
	SEMICOLON   ";"
	ASSIGN      "="
	EQUALS      "=="
	NOTEQ       "!="
	MORE        ">"
	MOREEQ      ">="
	LESS        "<"
	LESSEQ      "<="
	AT          "@"
	AMPERSAND   "&"
	DAMPERSAND  "&&"
	PIPE        "|"
	DPIPE       "||"
	CARET       "^"
	TILDA       "~"
	EXCLAMATION "!"
	QUESTION    "?"
	DOLLAR      "$"
	EPSILON     "..."
	IMPORT      "import"
	INHERIT     "inherit"
	WITH        "with"
	IF          "if"
	THEN        "then"
	ELSE        "else"
	LET         "let"
	IN          "in"
	OR          "or"
	<node>
	NUMBER      "number"
	ID          "id"
	STRING      "string"
	STRING_PART "string_part"
	PATH        "path"
	PATH_PART   "path_part"

%type <node> Start E String String_part Path Path_part Name

%start Start

//%precedence FUNC
%left "&&" "||"
%left "==" "!=" ">" ">=" "<" "<="
%left "&" "|" "^"
%left "+" "-"
%left "*" "/"
%precedence NEG INV
//%precedence CALL

%%

Start: E { $$ = parser_root = $1; }

E: E "+" E  { $$ = new_bin_node(NODE_BIN_SUM,         $1, $3); }
 | E "-" E  { $$ = new_bin_node(NODE_BIN_SUB,         $1, $3); }
 | E "*" E  { $$ = new_bin_node(NODE_BIN_MUL,         $1, $3); }
 | E "/" E  { $$ = new_bin_node(NODE_BIN_DIV,         $1, $3); }
 | E "==" E { $$ = new_bin_node(NODE_BIN_EQUALS,      $1, $3); }
 | E "!=" E { $$ = new_bin_node(NODE_BIN_NOTEQ,       $1, $3); }
 | E "<" E  { $$ = new_bin_node(NODE_BIN_LESS,        $1, $3); }
 | E "<=" E { $$ = new_bin_node(NODE_BIN_LESSEQ,      $1, $3); }
 | E ">" E  { $$ = new_bin_node(NODE_BIN_MORE,        $1, $3); }
 | E ">=" E { $$ = new_bin_node(NODE_BIN_MOREEQ,      $1, $3); }
 | E "&&" E { $$ = new_bin_node(NODE_BIN_LOGIC_AND,   $1, $3); }
 | E "||" E { $$ = new_bin_node(NODE_BIN_LOGIC_OR,    $1, $3); }
 | E "&" E  { $$ = new_bin_node(NODE_BIN_BITWISE_AND, $1, $3); }
 | E "|" E  { $$ = new_bin_node(NODE_BIN_BITWISE_OR,  $1, $3); }
 | E "^" E  { $$ = new_bin_node(NODE_BIN_BITWISE_XOR, $1, $3); }
 | "-" E %prec NEG { $$ = new_un_node(NODE_UN_NEG, $2); }
 | "!" E %prec INV { $$ = new_un_node(NODE_UN_LOGIC_INV, $2); }
 | "~" E %prec INV { $$ = new_un_node(NODE_UN_BITWISE_INV, $2); }
 | "(" E ")" { $$ = $2; }
 | NUMBER
 | String
 | Path
 | Name
 //| fargs ":" E %prec FUNC { $$ = new_node(NODE_FUNC, 2); $$->childs[0] = $1; $$->childs[1] = $3; }
 //| ID ":" E %prec FUNC { $$ = new_node(NODE_FUNC, 2); $$->childs[0] = $1; $$->childs[1] = $3; }
 //| E E %prec CALL { $$ = new_node(NODE_CALL, 2); $$->childs[0] = $1; $$->childs[1] = $2; }

Name: ID
    | Name "." ID { $$ = new_bin_node(NODE_BIN_SET_ACCESS, $1, $3); }

//fargs: "{" farg "}" { $$ = $2; }
//     | "{" farg "," EPSILON "}" { $$ = $2; $$->epsilon = 1; }
//     | "{" EPSILON "}" { $$ = new_node(NODE_FARGS, 0); $$->epsilon = 1; }
//     | "{" farg "," "}" { $$ = $2; }
//     | "{" "}" { $$ = new_node(NODE_FARGS, 0); }

//farg: ID { $$ = new_node(NODE_FARG, 2); $$->childs[0] = $1; $$->childs[1] = NULL; }
//    | ID "?" E { $$ = new_node(NODE_FARG, 2); $$->childs[0] = $1; $$->childs[1] = $3; }
//    | farg "," ID { $$ = new_node(NODE_FARG, 3); $$->childs[0] = $3; $$->childs[1] = NULL; $$->childs[2] = $1; }
//    | farg "," ID "?" E { $$ = new_node(NODE_FARG, 3); $$->childs[0] = $3; $$->childs[1] = $5; $$->childs[2] = $1; }

String: String_part STRING { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }
      | STRING

String_part: STRING_PART E RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }
           | String_part E RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }

Path: Path_part PATH { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }
    | PATH

Path_part: PATH_PART E RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }
         | Path_part E RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }

%%


void yyerror(const char* msg) {
	printf("%s\n", msg);
}


char* token_name[] = {
    [TOK_YYEOF] = "end of file",
    [TOK_YYerror] = "error",
    [TOK_YYUNDEF] = "invalid token",
    [TOK_PLUS] = "+",
    [TOK_MINUS] = "-",
    [TOK_STAR] = "*",
    [TOK_SLASH] = "/",
    [TOK_LBR] = "(",
    [TOK_RBR] = ")",
    [TOK_LCBR] = "{",
    [TOK_RCBR] = "}",
    [TOK_DOT] = ".",
    [TOK_COMMA] = ",",
    [TOK_COLON] = ":",
    [TOK_SEMICOLON] = ";",
    [TOK_ASSIGN] = "=",
    [TOK_EQUALS] = "==",
    [TOK_NOTEQ] = "!=",
    [TOK_MORE] = ">",
    [TOK_MOREEQ] = ">=",
    [TOK_LESS] = "<",
    [TOK_LESSEQ] = "<=",
    [TOK_AT] = "@",
    [TOK_AMPERSAND] = "&",
    [TOK_DAMPERSAND] = "&&",
    [TOK_PIPE] = "|",
    [TOK_DPIPE] = "||",
    [TOK_CARET] = "^",
    [TOK_TILDA] = "~",
    [TOK_EXCLAMATION] = "!",
    [TOK_QUESTION] = "?",
    [TOK_DOLLAR] = "$",
    [TOK_EPSILON] = "...",
    [TOK_IMPORT] = "import",
    [TOK_INHERIT] = "inherit",
    [TOK_WITH] = "with",
    [TOK_IF] = "if",
    [TOK_THEN] = "then",
    [TOK_ELSE] = "else",
    [TOK_LET] = "let",
    [TOK_IN] = "in",
    [TOK_OR] = "or",
    [TOK_NUMBER] = "number",
    [TOK_ID] = "id",
    [TOK_STRING] = "string",
    [TOK_STRING_PART] = "string_part",
    [TOK_PATH] = "path",
    [TOK_PATH_PART] = "path_part",
    [TOK_NEG] = "NEG",
    [TOK_INV] = "INV",
};


struct Node* yyparse(FILE* file) {
	yyscan_t scanner;
	yylex_init(&scanner);
	yyset_in(file, scanner);

	yypstate* state = yypstate_new();
	int status;
	YYSTYPE lval;

	do {
		int token = yylex(&lval, scanner);
		//printf("%s\n", token_name[token]);
		status = yypush_parse(state, token, &lval);
	} while (status == YYPUSH_MORE);

	yylex_destroy(scanner);

	yypstate_delete(state);

	return parser_root;
}
