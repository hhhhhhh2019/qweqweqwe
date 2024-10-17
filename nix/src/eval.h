#ifndef EVAL_H
#define EVAL_H


#include "node.h"


struct Node* set_get(struct Node*, struct Node* name);
void set_set(struct Node*, struct Node* name, struct Node* value);


#endif
