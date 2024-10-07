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

extern int lineno;
extern int column;
char error;

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
	LSBR        "["
	RSBR        "]"
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
	REC         "rec"
	<node>
	NUMBER      "number"
	ID          "id"
	STRING      "string"
	STRING_PART "string_part"
	PATH        "path"
	PATH_PART   "path_part"

%type <node> Start E String String_part Path Path_part Name args_set fargs farg set_args arr_args error

%start Start

%precedence FUNC
%left "&&" "||"
%left "==" "!=" ">" ">=" "<" "<="
%left "&" "|" "^"
%left "+" "-"
%left "*" "/"
%precedence NEG INV NOT
%left CALL NUMBER ID STRING PATH

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
 | "!" E %prec NOT { $$ = new_un_node(NODE_UN_LOGIC_INV, $2); }
 | "~" E %prec INV { $$ = new_un_node(NODE_UN_BITWISE_INV, $2); }
 | "(" E ")" { $$ = $2; }
 | NUMBER
 | String
 | Path
 | Name
 | args_set ":" E %prec FUNC { $$ = new_bin_node(NODE_BIN_FUNCTION, $1, $3); }
 | ID ":" E %prec FUNC { $$ = new_bin_node(NODE_BIN_FUNCTION, $1, $3); }
 | E E %prec CALL { $$ = new_bin_node(NODE_BIN_CALL, $1, $2); }
 | "{" set_args "}" { $$ = $2; }
 | "{" "}" { $$ = new_poly_node(NODE_POLY_SET, 0); }
 | "rec" "{" set_args "}" { $$ = $3; ((struct Node_poly*)$$)->epsilon = 1; }
 | "rec" "{" "}" { $$ = new_poly_node(NODE_POLY_SET, 0); ((struct Node_poly*)$$)->epsilon = 1; }
 | "[" arr_args "]" { $$ = $2; }
 | "[" arr_args "," "]" { $$ = $2; }
 | "[" "]" { $$ = new_poly_node(NODE_POLY_ARRAY, 0); }
 | "with" Name ";" E { $$ = new_bin_node(NODE_BIN_WITH, $2, $4); }
 | "let" set_args "in" E { $$ = new_bin_node(NODE_BIN_LET, $2, $4); }
 | "if" E "then" E "else" E { $$ = new_tre_node(NODE_TRE_IF, $2, $4, $6); }
 | "import" Path { $$ = new_un_node(NODE_UN_IMPORT, $2); }

 | error { $$ = new_node(); }
 | "with" error ";" E { $$ = new_bin_node(NODE_BIN_WITH, new_node(), $4); }
 | "import" error { $$ = new_un_node(NODE_UN_IMPORT, new_node()); }
 | "let" error "in" E { $$ = new_bin_node(NODE_BIN_LET, new_node(), $4); }

Name: ID
    | Name "." ID { $$ = new_bin_node(NODE_BIN_SET_ACCESS, $1, $3); }
    | Name "." String { $$ = new_bin_node(NODE_BIN_SET_ACCESS, $1, $3); }
    | Name "." Path { $$ = new_bin_node(NODE_BIN_SET_ACCESS, $1, $3); }

args_set: "{" fargs "}" { $$ = $2; }
        | "{" fargs "," "}" { $$ = $2; }
        | "{" fargs "," EPSILON "}" { $$ = $2;
                                      ((struct Node_poly*)$$)->epsilon = 1; }
        | "{" EPSILON "}" { $$ = new_poly_node(NODE_POLY_ARGS, 0);
                            ((struct Node_poly*)$$)->epsilon = 1; }
        | "{" "}" { $$ = new_poly_node(NODE_POLY_ARGS, 0); }
        | "{" error "}" { $$ = new_node(); }

fargs: farg { $$ = new_poly_node(NODE_POLY_ARGS, 1, $1); }
     | fargs "," farg { poly_node_append((struct Node_poly*)$$, $3); }
     | fargs "," error { poly_node_append((struct Node_poly*)$$, new_node()); }

farg: ID
    | ID "?" E { $$ = new_bin_node(NODE_BIN_ARG_DEFAULT, $1, $3); }

String: String_part STRING { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }
      | STRING

String_part: STRING_PART E RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }
           | String_part E RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, $2); }
           | STRING_PART error RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, new_node()); }
           | String_part error RCBR { $$ = new_bin_node(NODE_BIN_STRING_UNION, $1, new_node()); }

Path: Path_part PATH { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }
    | PATH

Path_part: PATH_PART E RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }
         | Path_part E RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, $2); }
         | Path_part error RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, new_node()); }
         | PATH_PART error RCBR { $$ = new_bin_node(NODE_BIN_PATH_UNION, $1, new_node()); }

set_args: Name "=" E ";" {
            $$ = new_poly_node(NODE_POLY_SET, 1,
                new_bin_node(NODE_BIN_SET_VALUE, $1, $3)); }
        | set_args Name "=" E ";" {
            poly_node_append((struct Node_poly*)$$,
                new_bin_node(NODE_BIN_SET_VALUE, $2, $4)); }
        | "import" "path" ";" {
            $$ = new_poly_node(NODE_POLY_SET, 1,
                new_un_node(NODE_UN_IMPORT, $2)); }
        | set_args "import" "path" ";" {
            poly_node_append((struct Node_poly*)$$,
                new_un_node(NODE_UN_IMPORT, $3)); }
        | "inherit" Path ";" {
            $$ = new_poly_node(NODE_POLY_SET, 1,
                new_un_node(NODE_UN_INHERIT, $2));
        }
        | set_args "inherit" Name ";" {
            poly_node_append((struct Node_poly*)$$,
                new_un_node(NODE_UN_INHERIT, $3));
        }
        | error "=" E ";" {
            $$ = new_poly_node(NODE_POLY_SET, 1,
                new_bin_node(NODE_BIN_SET_VALUE, new_node(), $3)); }
        | set_args error "=" E ";" {
            poly_node_append((struct Node_poly*)$$,
                new_bin_node(NODE_BIN_SET_VALUE, new_node(), $4)); }

arr_args: E { $$ = new_poly_node(NODE_POLY_ARRAY, 1, $1);  }
        | arr_args "," E { poly_node_append((struct Node_poly*)$$, $3); }

%%


void yyerror(const char* msg) {
	fprintf(stderr, "%d.%d: %s\n", lineno, column, msg);
	error = 1;
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
	error = 0;

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

	if (error) return NULL;

	return parser_root;
}
