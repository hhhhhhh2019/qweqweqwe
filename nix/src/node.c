#include "node.h"

#include <stdarg.h>
#include <stdio.h>


struct Node* new_node() {
	struct Node* node = malloc(sizeof(struct Node));
	node->type = NODE_EMPTY;

	return node;
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

struct Node* new_tre_node(enum NodeTreType type, struct Node* first, struct Node* second, struct Node* third) {
	struct Node_tre* node = malloc(sizeof(struct Node_tre));
	node->super.type = NODE_TRE;
	node->type = type;
	node->first = first;
	node->second = second;
	node->third = third;

	return (struct Node*)node;
}


static void print_node_bin(struct Node_bin* node, int offset) {
	switch (node->type) {
		case NODE_BIN_SUM:          printf("sum\n"); break;
		case NODE_BIN_SUB:          printf("sub\n"); break;
		case NODE_BIN_MUL:          printf("mul\n"); break;
		case NODE_BIN_DIV:          printf("div\n"); break;
		case NODE_BIN_EQUALS:       printf("equals\n"); break;
		case NODE_BIN_NOTEQ:        printf("not equals\n"); break;
		case NODE_BIN_LESS:         printf("less\n"); break;
		case NODE_BIN_LESSEQ:       printf("less or equals\n"); break;
		case NODE_BIN_MORE:         printf("more\n"); break;
		case NODE_BIN_MOREEQ:       printf("more or equals\n"); break;
		case NODE_BIN_LOGIC_AND:    printf("logic and\n"); break;
		case NODE_BIN_LOGIC_OR:     printf("logic or\n"); break;
		case NODE_BIN_BITWISE_AND:  printf("bitwise and\n"); break;
		case NODE_BIN_BITWISE_OR:   printf("bitwise or\n"); break;
		case NODE_BIN_BITWISE_XOR:  printf("bitwise xor\n"); break;
		case NODE_BIN_SET_ACCESS:   printf("set access\n"); break;
		case NODE_BIN_ARR_ACCESS:   printf("array access\n"); break;
		case NODE_BIN_STRING_UNION: printf("string union\n"); break;
		case NODE_BIN_PATH_UNION:   printf("path union\n"); break;
		case NODE_BIN_FUNCTION:     printf("function\n"); break;
		case NODE_BIN_ARG_DEFAULT:  printf("argument with default value\n"); break;
		case NODE_BIN_CALL:         printf("call\n"); break;
		case NODE_BIN_SET_VALUE:    printf("set value\n"); break;
		case NODE_BIN_WITH:         printf("with\n"); break;
    case NODE_BIN_LET:          printf("let\n"); break;
	}

  print_node(node->left, offset + 1);
	print_node(node->right, offset + 1);
}


static void print_node_un(struct Node_un* node, int offset) {
	switch (node->type) {
		case NODE_UN_NEG:         printf("negate\n"); break;
		case NODE_UN_LOGIC_INV:   printf("logic inverse\n"); break;
		case NODE_UN_BITWISE_INV: printf("bitwise inverse\n"); break;
		case NODE_UN_IMPORT:      printf("import\n"); break;
		case NODE_UN_INHERIT:     printf("inherit\n"); break;
	}

	print_node(node->child, offset + 1);
}


static void print_node_value(struct Node_value* node, int offset) {
	switch (node->type) {
		case NODE_VAL_NUMBER: printf("%f\n", node->number); return;
		case NODE_VAL_STRING: printf("\"%s\"\n", node->string); return;
		case NODE_VAL_PATH:   printf("'%s'\n", node->path); return;
		case NODE_VAL_ID:     printf("%s\n", node->id); return;
		case NODE_VAL_BOOL:   printf("%d\n", node->boolean); return;
	}
}


static void print_node_poly(struct Node_poly* node, int offset) {
	switch (node->type) {
		case NODE_POLY_ARRAY: printf("array\n"); break;
		case NODE_POLY_ARGS: printf("arguments %d\n", node->epsilon); break;
		case NODE_POLY_SET: printf("set\n"); break;
	}

	for (int i = 0; i < node->childs_count; i++)
		print_node(node->childs[i], offset + 1);
}


void poly_node_append(struct Node_poly* root, struct Node* node) {
	root->childs = realloc(root->childs, sizeof(void*) * (++root->childs_count));
	root->childs[root->childs_count - 1] = node;
}


static void print_node_tre(struct Node_tre* node, int offset) {
	switch (node->type) {
		case NODE_TRE_IF: printf("if\n"); break;
	}

	print_node(node->first, offset + 1);
	print_node(node->second, offset + 1);
	print_node(node->third, offset + 1);
}


void print_node(struct Node* node, int offset) {
	for (int i = 0; i < offset; i++)
		printf("  ");

	if (node == NULL) {
		printf("NULL\n");
		return;
	}

	switch (node->type) {
		case NODE_EMPTY: printf("empty node\n"); break;
		case NODE_BIN:   print_node_bin((struct Node_bin*)node, offset); break;
		case NODE_UN:    print_node_un((struct Node_un*)node, offset); break;
		case NODE_VALUE: print_node_value((struct Node_value*)node, offset); break;
		case NODE_POLY:  print_node_poly((struct Node_poly*)node, offset); break;
		case NODE_TRE:   print_node_tre((struct Node_tre*)node, offset); break;
	}
}


int index_node(struct Node* node, int id) {
	if (node == NULL) return id;

	node->id = id++;

	switch (node->type) {
		case NODE_EMPTY: break;
		case NODE_VALUE: break;
		case NODE_UN: id = index_node(((struct Node_un*)node)->child, id); break;
		case NODE_BIN:
			id = index_node(((struct Node_bin*)node)->left, id);
			id = index_node(((struct Node_bin*)node)->right, id);
			break;
		case NODE_POLY:
			for (int i = 0; i < ((struct Node_poly*)node)->childs_count; i++)
				id = index_node(((struct Node_poly*)node)->childs[i], id);
			break;
		case NODE_TRE:
			id = index_node(((struct Node_tre*)node)->first, id);
			id = index_node(((struct Node_tre*)node)->second, id);
			id = index_node(((struct Node_tre*)node)->third, id);
			break;
	}

	return id;
}


static void node_value_to_dot(struct Node_value* node) {
	switch (node->type) {
		case NODE_VAL_NUMBER: printf(" [label=\"%f\"]\n", node->number); break;
		case NODE_VAL_STRING: printf(" [label=\"\\\"%s\\\"\"]\n", node->string); break;
		case NODE_VAL_PATH:   printf(" [label=\"'%s'\"]\n", node->path); break;
		case NODE_VAL_ID:     printf(" [label=\"%s\"]\n", node->id); break;
		case NODE_VAL_BOOL:   printf(" [label=%d]\n", node->boolean); break;
	}
}


static void node_un_to_dot(struct Node_un* node) {
	switch (node->type) {
		case NODE_UN_NEG:         printf(" [label=\"negate\"]\n"); break;
		case NODE_UN_LOGIC_INV:   printf(" [label=\"logic inverse\"]\n"); break;
		case NODE_UN_BITWISE_INV: printf(" [label=\"bitwise inverse\"]\n"); break;
		case NODE_UN_IMPORT:      printf(" [label=\"import\"]\n"); break;
		case NODE_UN_INHERIT:     printf(" [label=\"inherit\"]\n"); break;
	}

	printf("%d -> { %d }\n", node->super.id, node->child->id);
	node_to_dot(node->child);
}


static void node_bin_to_dot(struct Node_bin* node) {
	switch (node->type) {
		case NODE_BIN_SUM:          printf(" [label=\"+\"]\n"); break;
		case NODE_BIN_SUB:          printf(" [label=\"-\"]\n"); break;
		case NODE_BIN_MUL:          printf(" [label=\"*\"]\n"); break;
		case NODE_BIN_DIV:          printf(" [label=\"/\"]\n"); break;
		case NODE_BIN_EQUALS:       printf(" [label=\"==\"]\n"); break;
		case NODE_BIN_NOTEQ:        printf(" [label=\"!=\"]\n"); break;
		case NODE_BIN_LESS:         printf(" [label=\"<\"]\n"); break;
		case NODE_BIN_LESSEQ:       printf(" [label=\"<=\"]\n"); break;
		case NODE_BIN_MORE:         printf(" [label=\">\"]\n"); break;
		case NODE_BIN_MOREEQ:       printf(" [label=\">=\"]\n"); break;
		case NODE_BIN_LOGIC_AND:    printf(" [label=\"&&\"]\n"); break;
		case NODE_BIN_LOGIC_OR:     printf(" [label=\"||\"]\n"); break;
		case NODE_BIN_BITWISE_AND:  printf(" [label=\"&\"]\n"); break;
		case NODE_BIN_BITWISE_OR:   printf(" [label=\"|\"]\n"); break;
		case NODE_BIN_BITWISE_XOR:  printf(" [label=\"^\"]\n"); break;
		case NODE_BIN_SET_ACCESS:   printf(" [label=\".\"]\n"); break;
		case NODE_BIN_ARR_ACCESS:   printf(" [label=\"[]\"]\n"); break;
		case NODE_BIN_STRING_UNION: printf(" [label=\"string union\"]\n"); break;
		case NODE_BIN_PATH_UNION:   printf(" [label=\"path union\"]\n"); break;
		case NODE_BIN_FUNCTION:     printf(" [label=\"function\"]\n"); break;
		case NODE_BIN_ARG_DEFAULT:  printf(" [label=\"def arg\"]\n"); break;
		case NODE_BIN_CALL:         printf(" [label=\"call\"]\n"); break;
		case NODE_BIN_SET_VALUE:    printf(" [label=\"=\"]\n"); break;
		case NODE_BIN_WITH:         printf(" [label=\"with\"]\n"); break;
		case NODE_BIN_LET:          printf(" [label=\"let\"]\n"); break;
	}

	printf("%d -> { %d %d }\n", node->super.id, node->left->id, node->right->id);
	node_to_dot(node->left);
	node_to_dot(node->right);
}


static void node_poly_to_dot(struct Node_poly* node) {
	switch (node->type) {
		case NODE_POLY_ARRAY: printf(" [label=\"array\"]\n"); break;
		case NODE_POLY_ARGS:  printf(" [label=\"arguments\"]\n"); break;
		case NODE_POLY_SET:   printf(" [label=\"set\"]\n"); break;
	}

	printf("%d -> { ", node->super.id);

	for (int i = 0; i < node->childs_count; i++)
		printf("%d ", node->childs[i]->id);

	printf("}\n");

	for (int i = 0; i < node->childs_count; i++)
		node_to_dot(node->childs[i]);
}


static void node_tre_to_dot(struct Node_tre* node) {
	switch (node->type) {
		case NODE_TRE_IF: printf(" [label=\"if\"]\n");
	}

	printf("%d -> { %d %d %d }\n", node->super.id, node->first->id, node->second->id, node->third->id);

	node_to_dot(node->first);
	node_to_dot(node->second);
	node_to_dot(node->third);
}


void node_to_dot(struct Node* node) {
	if (node == NULL) return;

	printf("%d", node->id);

	switch (node->type) {
		case NODE_EMPTY: printf(" [label=\"empty node\"]\n"); break;
		case NODE_VALUE: node_value_to_dot((struct Node_value*)node); break;
		case NODE_UN:    node_un_to_dot((struct Node_un*)node); break;
		case NODE_BIN:   node_bin_to_dot((struct Node_bin*)node); break;
		case NODE_POLY:  node_poly_to_dot((struct Node_poly*)node); break;
		case NODE_TRE:   node_tre_to_dot((struct Node_tre*)node); break;
	}
}
