OUT = main

BISON = bison
FLEX  = flex
CC    = gcc
LD    = gcc

BISON_FLAGS = --color=always -Wall -fcaret -d
FLEX_FLAGS =
CC_FLAGS = -ggdb3
LD_FLAGS = -ggdb3


all: src/parser.c src/lexer.c build/$(OUT)

build/$(OUT): build/parser.o build/lexer.o build/main.o build/node.o
	$(LD) $(LD_FLAGS) -o build/$(OUT) $^

build/%.o: src/%.c
	$(CC) $(CC_FLAGS) -o $@ -c $<

build/main.o: src/main.c src/node.h src/parser.h
	$(CC) $(CC_FLAGS) -o $@ -c $<

build/parser.o: src/parser.c src/node.h src/lexer.h
	$(CC) $(CC_FLAGS) -o $@ -c $<

build/lexer.o: src/lexer.c src/node.h src/parser.h
	$(CC) $(CC_FLAGS) -o $@ -c $<

src/parser.c: src/parser.y src/node.h
	$(BISON) $(BISON_FLAGS) $< -o $@

src/lexer.c: src/lexer.l
	$(FLEX) $(FLEX_FLAGS) -o $@ $<

clean:
	rm build/* -f
	rm src/parser.c src/parser.h src/lexer.c src/lexer.h -f
