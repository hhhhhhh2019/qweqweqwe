%option noyywrap nounput bison-bridge
%option reentrant stack
%option header-file="src/lexer.h"

%{

#include "parser.h"
#include "node.h"

#define PUSH_STATE(state) yy_push_state(state, yyscanner);
#define POP_STATE() yy_pop_state(yyscanner);

%}

%s DEFAULT
%x STRING
%x LONG_STRING
%x PATH

%%

\"              { yylval->node = new_value_node(NODE_VAL_STRING);
                  struct Node_value* node = (struct Node_value*)yylval->node;
                  node->string = calloc(1, 1);
                  PUSH_STATE(STRING) }
<STRING>"${"    { PUSH_STATE(DEFAULT) return TOK_STRING_PART; }
<STRING>\"      { POP_STATE() return TOK_STRING; }
<STRING>\n      { POP_STATE() printf("string error\n"); return TOK_YYerror; }
<STRING>\\.     { struct Node_value* node = (struct Node_value*)yylval->node;
                  int len = strlen(node->string);
                  node->string = realloc(node->string, len + 3);
                  node->string[len + 0] = yytext[0];
                  node->string[len + 1] = yytext[1];
                  node->string[len + 2] = 0;
}
<STRING>.       { struct Node_value* node = (struct Node_value*)yylval->node;
                  int len = strlen(node->string);
                  node->string = realloc(node->string, len + 2);
                  node->string[len + 0] = yytext[0];
                  node->string[len + 1] = 0;
}
<STRING><<EOF>> { printf("string error\n"); }
\'            { printf("path start\n"); PUSH_STATE(PATH) }
<PATH>"${"    { printf("eval start\n"); PUSH_STATE(DEFAULT) }
<PATH>\'      { POP_STATE(); printf("path end\n"); }
<PATH>\n      { POP_STATE(); printf("path error\n"); }
<PATH>\\.     { printf("path data: %s\n", yytext); }
<PATH>.       { printf("path data: %s\n", yytext); }
<PATH><<EOF>> { printf("path error\n"); }
\''                  { printf("long string start\n"); PUSH_STATE(LONG_STRING) }
<LONG_STRING>"${"    { printf("eval start\n"); PUSH_STATE(DEFAULT) }
<LONG_STRING>''      { POP_STATE() printf("long string end\n"); }
<LONG_STRING>\\.     { printf("long string data: %s\n", yytext); }
<LONG_STRING>.       { printf("long string data: %s\n", yytext); }
<LONG_STRING><<EOF>> { printf("long string error\n"); }
"+"               { return TOK_PLUS; }
"-"               { return TOK_MINUS; }
"*"               { return TOK_STAR; }
"/"               { return TOK_SLASH; }
"("               { return TOK_LBR; }
")"               { return TOK_RBR; }
"{"               { PUSH_STATE(DEFAULT) return TOK_LCBR; }
<INITIAL>"}"      { return TOK_RCBR; }
"}"               { POP_STATE()
                    if (YYSTATE == STRING || YYSTATE == LONG_STRING || YYSTATE == PATH) {
                        yylval->node = new_value_node(NODE_VAL_STRING);
                        struct Node_value* node = (struct Node_value*)yylval->node;
                        node->string = calloc(1, 1);
                        return TOK_RCBR;
                    }
                    return TOK_RCBR;
}
","               { return TOK_COMMA; }
":"               { return TOK_COLON; }
";"               { return TOK_SEMICOLON; }
"="               { return TOK_ASSIGN; }
"=="              { return TOK_EQUALS; }
"!="              { return TOK_NOTEQ; }
">"               { return TOK_MORE; }
">="              { return TOK_MOREEQ; }
"<"               { return TOK_LESS; }
"<="              { return TOK_LESSEQ; }
"@"               { return TOK_AT; }
"&"               { return TOK_AMPERSAND; }
"&&"              { return TOK_DAMPERSAND; }
"|"               { return TOK_PIPE; }
"||"              { return TOK_DPIPE; }
"^"               { return TOK_CARET; }
"~"               { return TOK_TILDA; }
"!"               { return TOK_EXCLAMATION; }
"?"               { return TOK_QUESTION; }
"$"               { return TOK_DOLLAR; }
"..."             { return TOK_EPSILON; }
"import"          { return TOK_IMPORT; }
"inherit"         { return TOK_INHERIT; }
"with"            { return TOK_WITH; }
"if"              { return TOK_IF; }
"then"            { return TOK_THEN; }
"else"            { return TOK_ELSE; }
"let"             { return TOK_LET; }
"in"              { return TOK_IN; }
"or"              { return TOK_OR; }
(([0-9]*\.[0-9]*)|([0-9]+))([eE][+-]?[0-9]+)? {
          yylval->node = new_value_node(NODE_VAL_NUMBER);
          ((struct Node_value*)yylval->node)->number = atof(yytext);
          return TOK_NUMBER; }
[^ \t\n\+\-\*/(){}\[\]\&\~\\|/:;<=>%\^"'\.,?!0-9][^ \t\n\+\-\*/(){}\[\]\&\~\\|/:;<=>%\^"'\.,?!]* {
          yylval->node = new_value_node(NODE_VAL_ID);
          struct Node_value* node = (struct Node_value*)yylval->node;
          node->string = malloc(strlen(yytext)+1); strcpy(node->string, yytext);
          return TOK_ID; }
#.+$
.
[ \t\n]+ // idk why . dont include this symbols

%%
