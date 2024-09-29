%option noyywrap nounput
%option reentrant stack
%option header-file="src/lexer.h"

%{

#include "parser.h"

#define PUSH_STATE(state) yy_push_state(state, yyscanner); offset++
#define POP_STATE() yy_pop_state(yyscanner); offset--

int offset = 0;

#define PRINT_OFFSET for (int i = 0; i < offset; i++) printf("  ");

%}

%s DEFAULT
%x STRING
%x LONG_STRING
%x PATH

%%

\"                { PRINT_OFFSET printf("string start\n"); PUSH_STATE(STRING); }
<STRING>"${"      { PRINT_OFFSET printf("eval start\n"); PUSH_STATE(DEFAULT); }
<STRING>\"        { POP_STATE(); PRINT_OFFSET printf("string end\n"); }
<STRING>\n        { POP_STATE(); PRINT_OFFSET printf("string error\n"); }
<STRING>\\.       { PRINT_OFFSET printf("string data: %s\n", yytext); }
<STRING>.         { PRINT_OFFSET printf("string data: %s\n", yytext); }
<STRING><<EOF>>   { PRINT_OFFSET printf("string error\n"); }
\'                { PRINT_OFFSET printf("path start\n"); PUSH_STATE(PATH); }
<PATH>"${"        { PRINT_OFFSET printf("eval start\n"); PUSH_STATE(DEFAULT); }
<PATH>\'          { POP_STATE(); PRINT_OFFSET printf("path end\n"); }
<PATH>\n          { POP_STATE(); PRINT_OFFSET printf("path error\n"); }
<PATH>\\.         { PRINT_OFFSET printf("path data: %s\n", yytext); }
<PATH>.           { PRINT_OFFSET printf("path data: %s\n", yytext); }
<PATH><<EOF>>     { PRINT_OFFSET printf("path error\n"); }
\''               { PRINT_OFFSET printf("long string start\n"); PUSH_STATE(LONG_STRING); }
<LONG_STRING>"${" { PRINT_OFFSET printf("eval start\n"); PUSH_STATE(DEFAULT); }
<LONG_STRING>''   { POP_STATE(); PRINT_OFFSET printf("long string end\n"); }
<LONG_STRING>\\.  { PRINT_OFFSET printf("long string data: %s\n", yytext); }
<LONG_STRING>.    { PRINT_OFFSET printf("long string data: %s\n", yytext); }
<STRING><<EOF>>   { PRINT_OFFSET printf("long string error\n"); }
"+"               { PRINT_OFFSET printf("+\n"); return TOK_PLUS; }
"("               { PRINT_OFFSET printf("(\n"); return TOK_LBR; }
")"               { PRINT_OFFSET printf(")\n"); return TOK_RBR; }
"{"               { PRINT_OFFSET printf("{\n"); PUSH_STATE(DEFAULT); return TOK_LCBR; }
<INITIAL>"}"      { PRINT_OFFSET printf("}\n"); return TOK_RCBR; }
"}"               { POP_STATE(); PRINT_OFFSET
                    if (YYSTATE == STRING || YYSTATE == LONG_STRING || YYSTATE == PATH) { printf("eval end\n"); return TOK_RCBR; }
                    printf("}\n"); return TOK_RCBR;
}
","               { PRINT_OFFSET printf(",\n"); return TOK_COMMA; }
":"               { PRINT_OFFSET printf(":\n"); return TOK_COLON; }
";"               { PRINT_OFFSET printf(";\n"); return TOK_SEMICOLON; }
"="               { PRINT_OFFSET printf("=\n"); return TOK_ASSIGN; }
[0-9]+            { PRINT_OFFSET printf("number: %s\n", yytext); return TOK_NUMBER; }
[^ \t\n\+\-\*/(){}\[\]\&\~\\|/:;<=>%\^"'\.,?!]+ { PRINT_OFFSET printf("id: %s\n", yytext); return TOK_ID; }
.

%%
