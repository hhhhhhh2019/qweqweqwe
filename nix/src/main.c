#include <stdio.h>

#include "parser.h"
#include "node.h"


int main() {
	FILE* file = fopen("test", "r");

	if (file == NULL) {
		perror("fopen");
		return 1;
	}
	
	struct Node* root = yyparse(file);
	print_node(root, 0);

	fclose(file);
}
