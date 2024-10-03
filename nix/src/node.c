#include "node.h"

#include <stdarg.h>
#include <stdio.h>


struct Node* new_node() {
	return NULL;
}

struct Node* new_bin_node(enum NodeBinType type, struct Node* left, struct Node* right) {
	struct Node_bin* node = malloc(sizeof(struct Node_bin));
	node->super.type = NODE_BIN;
	node->type = type;
	node->left = left;
	node->right = right;

	return (struct Node*)node;
}

struct Node* new_un_node(enum NodeUnType type, struct Node* child) {
	struct Node_un* node = malloc(sizeof(struct Node_un));
	node->super.type = NODE_UN;
	node->type = type;
	node->child = child;
	return (struct Node*)node;
}

struct Node* new_value_node(enum NodeValueType type) {
	struct Node_value* node = malloc(sizeof(struct Node_value));
	node->super.type = NODE_VALUE;
	node->type = type;
	return (struct Node*)node;
}

struct Node* new_poly_node(enum NodePolyType type, int count, ...) {
	struct Node_poly* node = malloc(sizeof(struct Node_poly));
	node->super.type = NODE_POLY;
	node->type = type;
	node->childs_count = count;
	node->childs = malloc(sizeof(void*) * count);

	va_list ptr;
	va_start(ptr, count);
	for (int i = 0; i < count; i++)
		node->childs[i] = va_arg(ptr, struct Node*);
	va_end(ptr);

	return (struct Node*)node;
}


static void print_node_bin(struct Node_bin* node, int offset) {
	switch (node->type) {
		case (NODE_BIN_SUM):          printf("sum\n"); break;
		case (NODE_BIN_SUB):          printf("sub\n"); break;
		case (NODE_BIN_MUL):          printf("mul\n"); break;
		case (NODE_BIN_DIV):          printf("div\n"); break;
		case (NODE_BIN_EQUALS):       printf("equals\n"); break;
		case (NODE_BIN_NOTEQ):        printf("not equals\n"); break;
		case (NODE_BIN_LESS):         printf("less\n"); break;
		case (NODE_BIN_LESSEQ):       printf("less or equals\n"); break;
		case (NODE_BIN_MORE):         printf("more\n"); break;
		case (NODE_BIN_MOREEQ):       printf("more or equals\n"); break;
		case (NODE_BIN_LOGIC_AND):    printf("logic and\n"); break;
		case (NODE_BIN_LOGIC_OR):     printf("logic or\n"); break;
		case (NODE_BIN_BITWISE_AND):  printf("bitwise and\n"); break;
		case (NODE_BIN_BITWISE_OR):   printf("bitwise or\n"); break;
		case (NODE_BIN_BITWISE_XOR):  printf("bitwise xor\n"); break;
		case (NODE_BIN_SET_ACCESS):   printf("set access\n"); break;
		case (NODE_BIN_ARR_ACCESS):   printf("array access\n"); break;
		case (NODE_BIN_STRING_UNION): printf("string union\n"); break;
		case (NODE_BIN_PATH_UNION):   printf("path union\n"); break;
		case (NODE_BIN_FUNCTION):     printf("function\n"); break;
		case (NODE_BIN_ARG_DEFAULT):  printf("argument with default value\n"); break;
		case (NODE_BIN_CALL):         printf("call\n"); break;
		case (NODE_BIN_SET_VALUE):    printf("set value\n"); break;
	}

	print_node(node->left, offset + 1);
	print_node(node->right, offset + 1);
}


static void print_node_un(struct Node_un* node, int offset) {
	switch (node->type) {
		case (NODE_UN_NEG): printf("negate\n"); break;
		case (NODE_UN_LOGIC_INV): printf("logic inverse\n"); break;
		case (NODE_UN_BITWISE_INV): printf("bitwise inverse\n"); break;
	}

	print_node(node->child, offset + 1);
}


static void print_node_value(struct Node_value* node, int offset) {
	switch (node->type) {
		case (NODE_VAL_NUMBER): printf("%f\n", node->number); return;
		case (NODE_VAL_STRING): printf("\"%s\"\n", node->string); return;
		case (NODE_VAL_PATH):   printf("'%s'\n", node->path); return;
		case (NODE_VAL_ID):     printf("%s\n", node->id); return;
		case (NODE_VAL_BOOL):   printf("%d\n", node->boolean); return;
	}
}


static void print_node_poly(struct Node_poly* node, int offset) {
	switch (node->type) {
		case (NODE_POLY_ARRAY): printf("array\n"); break;
		case (NODE_POLY_ARGS): printf("arguments %d\n", node->epsilon); break;
		case (NODE_POLY_SET): printf("set\n"); break;
	}

	for (int i = 0; i < node->childs_count; i++)
		print_node(node->childs[i], offset + 1);
}


void poly_node_append(struct Node_poly* root, struct Node* node) {
	root->childs = realloc(root->childs, sizeof(void*) * (++root->childs_count));
	root->childs[root->childs_count - 1] = node;
}


void print_node(struct Node* node, int offset) {
	for (int i = 0; i < offset; i++)
		printf("  ");

	if (node == NULL) {
		printf("NULL\n");
		return;
	}

	switch (node->type) {
		case (NODE_EMPTY): printf("empty node\n"); break;
		case (NODE_BIN):   print_node_bin((struct Node_bin*)node, offset); break;
		case (NODE_UN):    print_node_un((struct Node_un*)node, offset); break;
		case (NODE_VALUE): print_node_value((struct Node_value*)node, offset); break;
		case (NODE_POLY):  print_node_poly((struct Node_poly*)node, offset); break;
	}
}
