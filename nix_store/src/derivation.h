#ifndef DERIVATION_H
#define DERIVATION_H


struct Package_derivation;
typedef struct Package_derivation {
	char* name;
	char* version;
	char* hash;
	struct Package_derivation** build_inputs;
	char* build;
	struct Package_derivation** dependencies;
	char* install;
} Package_derivation;


#endif
