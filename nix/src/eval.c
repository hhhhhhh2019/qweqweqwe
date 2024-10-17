#include "eval.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>


struct Node* set_get(struct Node* set_node, struct Node* name) {
	assert(set_node->type == NODE_POLY_SET);

	struct Node_set* set = (struct Node_set*)set_node;
}


void set_set(struct Node* set_node, struct Node* name, struct Node* value) {
	assert(set_node->type == NODE_POLY);
	assert(((struct Node_poly*)set_node)->type == NODE_POLY_SET);
	assert(name->type == NODE_VALUE || name->type == NODE_BIN);

	struct Node_poly* set = (struct Node_poly*)set_node;

	if (name->type == NODE_VALUE) {
		for (int i = 0; i < set->childs_count; i++) {
			struct Node_set_elem* child = (struct Node_set_elem*)set->childs[i];

			if (strcmp(child->name, ((struct Node_value*)name)->id) != 0)
				continue;
			
			if (child->node->type != NODE_POLY && ((struct Node_poly*)child->node)->type != NODE_POLY_SET) {
				printf("set_set error: %d\n", __LINE__);
				return;
			}

			

			return;
		}

		set->childs = realloc(set->childs, sizeof(struct Node_set_elem*) * ++set->childs_count);
		struct Node_set_elem* new_child = malloc(sizeof(struct Node_set_elem));
		new_child->super.type = NODE_UN;
		new_child->name = ((struct Node_value*)name)->id;
		new_child->node = value;
		set->childs[set->childs_count - 1] = (struct Node*)new_child;

		return;
	}

	struct Node_set_elem* new_child = malloc(sizeof(struct Node_set_elem));
	new_child->super.type = NODE_UN;
	new_child->name = ((struct Node_value*)((struct Node_bin*)name)->right)->id;
	new_child->node = value;
	set_set(set_node, ((struct Node_bin*)name)->left, new_poly_node(NODE_POLY_SET, 1, (struct Node*)new_child));
}
