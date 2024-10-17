#include <stdio.h>

#include "parser.h"
#include "node.h"


int main() {
	FILE* file = fopen("test/config/default.nix", "r");

	if (file == NULL) {
		perror("fopen");
		return 1;
	}
	
	struct Node* root = yyparse(file);
	fclose(file);

	if (root == NULL) return 1;

	index_node(root, 0);

	printf("digraph 1 {\n");
	node_to_dot(root);
	printf("}\n");

	/*Node* output_call = new_bin_node(NODE_BIN_CALL,*/
	/*    root);*/
}
