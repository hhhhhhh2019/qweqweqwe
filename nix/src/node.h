#ifndef NODE_H
#define NODE_H


#include <stdlib.h>


enum NodeType {
	NODE_EMPTY,
	NODE_BIN,
	NODE_UN,
	NODE_VALUE,
	NODE_POLY,
};

struct Node {
	enum NodeType type;
	int id;
};


enum NodeBinType {
	NODE_BIN_SUM,
	NODE_BIN_SUB,
	NODE_BIN_MUL,
	NODE_BIN_DIV,
	NODE_BIN_EQUALS,
	NODE_BIN_NOTEQ,
	NODE_BIN_LESS,
	NODE_BIN_LESSEQ,
	NODE_BIN_MORE,
	NODE_BIN_MOREEQ,
	NODE_BIN_LOGIC_AND,
	NODE_BIN_LOGIC_OR,
	NODE_BIN_BITWISE_AND,
	NODE_BIN_BITWISE_OR,
	NODE_BIN_BITWISE_XOR,
	NODE_BIN_SET_ACCESS,
	NODE_BIN_ARR_ACCESS,
	NODE_BIN_STRING_UNION,
	NODE_BIN_PATH_UNION,
	NODE_BIN_FUNCTION,
	NODE_BIN_ARG_DEFAULT,
	NODE_BIN_CALL,
	NODE_BIN_SET_VALUE,
	NODE_BIN_WITH,
	NODE_BIN_LET,
};

struct Node_bin {
	struct Node super;
	enum NodeBinType type;
	struct Node* left;
	struct Node* right;
};


enum NodeUnType {
	NODE_UN_NEG,
	NODE_UN_LOGIC_INV,
	NODE_UN_BITWISE_INV,
	NODE_UN_IMPORT,
};

struct Node_un {
	struct Node super;
	enum NodeUnType type;
	struct Node* child;
};


enum NodeValueType {
	NODE_VAL_NUMBER,
	NODE_VAL_STRING,
	NODE_VAL_PATH,
	NODE_VAL_ID,
	NODE_VAL_BOOL,
};

struct Node_value {
	struct Node super;
	enum NodeValueType type;
	union {
		double number;
		char* string;
		char* path;
		char* id;
		char boolean;
	};
};


enum NodePolyType {
	NODE_POLY_ARRAY,
	NODE_POLY_ARGS,
	NODE_POLY_SET,
};

struct Node_poly {
	struct Node super;
	enum NodePolyType type;
	unsigned int childs_count;
	struct Node** childs;
	char epsilon; // for function arguments
};


struct Node* new_node();
struct Node* new_bin_node(enum NodeBinType, struct Node*, struct Node*);
struct Node* new_un_node(enum NodeUnType, struct Node*);
struct Node* new_value_node(enum NodeValueType);
struct Node* new_poly_node(enum NodePolyType, int, ...);

void poly_node_append(struct Node_poly*, struct Node*);

void print_node(struct Node*, int);

int index_node(struct Node*, int);
void node_to_dot(struct Node*);


#endif
