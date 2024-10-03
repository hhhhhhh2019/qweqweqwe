/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_SRC_PARSER_H_INCLUDED
# define YY_YY_SRC_PARSER_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TOK_YYEMPTY = -2,
    TOK_YYEOF = 0,                 /* "end of file"  */
    TOK_YYerror = 256,             /* error  */
    TOK_YYUNDEF = 257,             /* "invalid token"  */
    TOK_PLUS = 258,                /* "+"  */
    TOK_MINUS = 259,               /* "-"  */
    TOK_STAR = 260,                /* "*"  */
    TOK_SLASH = 261,               /* "/"  */
    TOK_LBR = 262,                 /* "("  */
    TOK_RBR = 263,                 /* ")"  */
    TOK_LCBR = 264,                /* "{"  */
    TOK_RCBR = 265,                /* "}"  */
    TOK_DOT = 266,                 /* "."  */
    TOK_COMMA = 267,               /* ","  */
    TOK_COLON = 268,               /* ":"  */
    TOK_SEMICOLON = 269,           /* ";"  */
    TOK_ASSIGN = 270,              /* "="  */
    TOK_EQUALS = 271,              /* "=="  */
    TOK_NOTEQ = 272,               /* "!="  */
    TOK_MORE = 273,                /* ">"  */
    TOK_MOREEQ = 274,              /* ">="  */
    TOK_LESS = 275,                /* "<"  */
    TOK_LESSEQ = 276,              /* "<="  */
    TOK_AT = 277,                  /* "@"  */
    TOK_AMPERSAND = 278,           /* "&"  */
    TOK_DAMPERSAND = 279,          /* "&&"  */
    TOK_PIPE = 280,                /* "|"  */
    TOK_DPIPE = 281,               /* "||"  */
    TOK_CARET = 282,               /* "^"  */
    TOK_TILDA = 283,               /* "~"  */
    TOK_EXCLAMATION = 284,         /* "!"  */
    TOK_QUESTION = 285,            /* "?"  */
    TOK_DOLLAR = 286,              /* "$"  */
    TOK_EPSILON = 287,             /* "..."  */
    TOK_IMPORT = 288,              /* "import"  */
    TOK_INHERIT = 289,             /* "inherit"  */
    TOK_WITH = 290,                /* "with"  */
    TOK_IF = 291,                  /* "if"  */
    TOK_THEN = 292,                /* "then"  */
    TOK_ELSE = 293,                /* "else"  */
    TOK_LET = 294,                 /* "let"  */
    TOK_IN = 295,                  /* "in"  */
    TOK_OR = 296,                  /* "or"  */
    TOK_NUMBER = 297,              /* "number"  */
    TOK_ID = 298,                  /* "id"  */
    TOK_STRING = 299,              /* "string"  */
    TOK_STRING_PART = 300,         /* "string_part"  */
    TOK_PATH = 301,                /* "path"  */
    TOK_PATH_PART = 302,           /* "path_part"  */
    TOK_FUNC = 303,                /* FUNC  */
    TOK_NEG = 304,                 /* NEG  */
    TOK_INV = 305,                 /* INV  */
    TOK_NOT = 306,                 /* NOT  */
    TOK_CALL = 307                 /* CALL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 29 "src/parser.y"

	struct Node* node;

#line 120 "src/parser.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif




#ifndef YYPUSH_MORE_DEFINED
# define YYPUSH_MORE_DEFINED
enum { YYPUSH_MORE = 4 };
#endif

typedef struct yypstate yypstate;


int yypush_parse (yypstate *ps,
                  int pushed_char, YYSTYPE const *pushed_val);

yypstate *yypstate_new (void);
void yypstate_delete (yypstate *ps);

/* "%code provides" blocks.  */
#line 15 "src/parser.y"


void yyerror(const char*);
struct Node* yyparse(FILE*);


#line 153 "src/parser.h"

#endif /* !YY_YY_SRC_PARSER_H_INCLUDED  */
