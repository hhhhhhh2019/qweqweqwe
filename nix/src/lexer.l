%option yylineno
%option noyywrap nounput bison-bridge
%option reentrant stack
%option header-file="src/lexer.h"

%{

#include "parser.h"
#include "node.h"

#define PUSH_STATE(state) yy_push_state(state, yyscanner);
#define POP_STATE() yy_pop_state(yyscanner);

int lineno = 1;
int next_column = 1;
int column = 1;

#define COLUMN(n) column = next_column; next_column += n

%}

%s DEFAULT
%x STRING
%x LONG_STRING
%x PATH

%%

\"              { COLUMN(1); yylval->node = new_value_node(NODE_VAL_STRING);
                  struct Node_value* node = (struct Node_value*)yylval->node;
                  node->string = calloc(1, 1);
                  PUSH_STATE(STRING) }
<STRING>"${"    { COLUMN(2); PUSH_STATE(DEFAULT) return TOK_STRING_PART; }
<STRING>\"      { COLUMN(1); POP_STATE() return TOK_STRING; }
<STRING>\n      { COLUMN(1); POP_STATE() printf("string error\n"); return TOK_YYerror; }
<STRING>\\.     { COLUMN(2); struct Node_value* node = (struct Node_value*)yylval->node;
                  int len = strlen(node->string);
                  node->string = realloc(node->string, len + 3);
                  node->string[len + 0] = yytext[0];
                  node->string[len + 1] = yytext[1];
                  node->string[len + 2] = 0;
}
<STRING>.       { COLUMN(1); struct Node_value* node = (struct Node_value*)yylval->node;
                  int len = strlen(node->string);
                  node->string = realloc(node->string, len + 2);
                  node->string[len + 0] = yytext[0];
                  node->string[len + 1] = 0;
}
<STRING><<EOF>> { printf("string error\n"); return TOK_YYerror; }
\'            { COLUMN(1); yylval->node = new_value_node(NODE_VAL_PATH);
                struct Node_value* node = (struct Node_value*)yylval->node;
                node->path = calloc(1, 1);
                PUSH_STATE(PATH) }
<PATH>"${"    { COLUMN(2); PUSH_STATE(DEFAULT) return TOK_PATH_PART; }
<PATH>\'      { COLUMN(1); POP_STATE(); return TOK_PATH; }
<PATH>\n      { COLUMN(1); POP_STATE(); printf("path error\n"); return TOK_YYerror; }
<PATH>\\.     { COLUMN(2); struct Node_value* node = (struct Node_value*)yylval->node;
                int len = strlen(node->path);
                node->path = realloc(node->path, len + 3);
                node->path[len + 0] = yytext[0];
                node->path[len + 1] = yytext[1];
                node->path[len + 2] = 0;
}
<PATH>.       { COLUMN(1); struct Node_value* node = (struct Node_value*)yylval->node;
                int len = strlen(node->path);
                node->path = realloc(node->path, len + 2);
                node->path[len + 0] = yytext[0];
                node->path[len + 1] = 0;
}
<PATH><<EOF>> { printf("path error\n"); return TOK_YYerror; }
\''                  { COLUMN(2); yylval->node = new_value_node(NODE_VAL_STRING);
                       struct Node_value* node = (struct Node_value*)yylval->node;
                       node->string = calloc(1, 1);
                       PUSH_STATE(LONG_STRING) }
<LONG_STRING>"${"    { COLUMN(2); PUSH_STATE(DEFAULT) return TOK_STRING_PART; }
<LONG_STRING>''      { COLUMN(2); POP_STATE() return TOK_STRING; }
<LONG_STRING>\\.     { COLUMN(2); struct Node_value* node = (struct Node_value*)yylval->node;
                       int len = strlen(node->string);
                       node->string = realloc(node->string, len + 3);
                       node->string[len + 0] = yytext[0];
                       node->string[len + 1] = yytext[1];
                       node->string[len + 2] = 0;
}
<LONG_STRING>.       { COLUMN(1); struct Node_value* node = (struct Node_value*)yylval->node;
                       int len = strlen(node->string);
                       node->string = realloc(node->string, len + 2);
                       node->string[len + 0] = yytext[0];
                       node->string[len + 1] = 0;
}
<LONG_STRING><<EOF>> { printf("long string error\n"); return TOK_YYerror; }
"+"               { COLUMN(1); return TOK_PLUS; }
"-"               { COLUMN(1); return TOK_MINUS; }
"*"               { COLUMN(1); return TOK_STAR; }
"/"               { COLUMN(1); return TOK_SLASH; }
"("               { COLUMN(1); return TOK_LBR; }
")"               { COLUMN(1); return TOK_RBR; }
"{"               { COLUMN(1); PUSH_STATE(DEFAULT) return TOK_LCBR; }
<INITIAL>"}"      { COLUMN(1); return TOK_RCBR; }
"}"               { COLUMN(1); POP_STATE()
                    if (YYSTATE == STRING || YYSTATE == LONG_STRING || YYSTATE == PATH) {
                        yylval->node = new_value_node(NODE_VAL_STRING);
                        struct Node_value* node = (struct Node_value*)yylval->node;
                        node->string = calloc(1, 1);
                        return TOK_RCBR;
                    }
                    return TOK_RCBR;
}
"["               { COLUMN(1); return TOK_LSBR; }
"]"               { COLUMN(1); return TOK_RSBR; }
"\."              { COLUMN(1); return TOK_DOT; }
","               { COLUMN(1); return TOK_COMMA; }
":"               { COLUMN(1); return TOK_COLON; }
";"               { COLUMN(1); return TOK_SEMICOLON; }
"="               { COLUMN(1); return TOK_ASSIGN; }
"=="              { COLUMN(2); return TOK_EQUALS; }
"!="              { COLUMN(2); return TOK_NOTEQ; }
">"               { COLUMN(1); return TOK_MORE; }
">="              { COLUMN(2); return TOK_MOREEQ; }
"<"               { COLUMN(1); return TOK_LESS; }
"<="              { COLUMN(2); return TOK_LESSEQ; }
"@"               { COLUMN(1); return TOK_AT; }
"&"               { COLUMN(1); return TOK_AMPERSAND; }
"&&"              { COLUMN(2); return TOK_DAMPERSAND; }
"|"               { COLUMN(1); return TOK_PIPE; }
"||"              { COLUMN(2); return TOK_DPIPE; }
"^"               { COLUMN(1); return TOK_CARET; }
"~"               { COLUMN(1); return TOK_TILDA; }
"!"               { COLUMN(1); return TOK_EXCLAMATION; }
"?"               { COLUMN(1); return TOK_QUESTION; }
"$"               { COLUMN(1); return TOK_DOLLAR; }
"..."             { COLUMN(3); return TOK_EPSILON; }
"import"          { COLUMN(6); return TOK_IMPORT; }
"inherit"         { COLUMN(7); return TOK_INHERIT; }
"with"            { COLUMN(4); return TOK_WITH; }
"if"              { COLUMN(2); return TOK_IF; }
"then"            { COLUMN(4); return TOK_THEN; }
"else"            { COLUMN(4); return TOK_ELSE; }
"let"             { COLUMN(3); return TOK_LET; }
"in"              { COLUMN(2); return TOK_IN; }
"or"              { COLUMN(2); return TOK_OR; }
"rec"             { COLUMN(3); return TOK_REC; }
(([0-9]*\.[0-9]*)|([0-9]+))([eE][+-]?[0-9]+)? {
          COLUMN(strlen(yytext));
          yylval->node = new_value_node(NODE_VAL_NUMBER);
          ((struct Node_value*)yylval->node)->number = atof(yytext);
          return TOK_NUMBER; }
[^ \t\n\+\-\*/(){}\[\]\&\~\\|/:;<=>%\^"'\.,?!0-9][^ \t\n\+\-\*/(){}\[\]\&\~\\|/:;<=>%\^"'\.,?!]* {
          COLUMN(strlen(yytext));
          yylval->node = new_value_node(NODE_VAL_ID);
          struct Node_value* node = (struct Node_value*)yylval->node;
          node->string = malloc(strlen(yytext)+1); strcpy(node->string, yytext);
          return TOK_ID; }
#.+$ { COLUMN(strlen(yytext)); }
. { COLUMN(1); }
[ \t]+ { COLUMN(1); } // idk why . dont include this symbols
\n { lineno++; next_column = 1; }

%%
