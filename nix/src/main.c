#include <stdio.h>

#include "parser.h"
#include "lexer.h"


int main() {
	yyscan_t scanner;
	yylex_init(&scanner);

	enum yytokentype token;

	FILE* file = fopen("test", "r");

	if (file == NULL) {
		perror("fopen");
		return 1;
	}
	
	yyset_in(file, scanner);
	
	while ((token = yylex(scanner))) {
		/*printf("%s\n", yysymbol_name(token));*/
	}

	yylex_destroy(scanner);

	fclose(file);
}
