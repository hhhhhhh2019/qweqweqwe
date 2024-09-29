OUT = main

BISON = bison
FLEX  = flex
CC    = gcc
LD    = gcc

BISON_FLAGS = --color=always -Wall -fcaret -d
FLEX_FLAGS =
CC_FLAGS = -ggdb3
LD_FLAGS = -ggdb3


all: build/parser.o build/lexer.o build/main.o
	$(LD) $(LD_FLAGS) -o build/$(OUT) $^

build/%.o: src/%.c
	$(CC) $(CC_FLAGS) -o $@ -c $<

src/parser.c: src/parser.y
	$(BISON) $(BISON_FLAGS) $< -o $@

src/lexer.c: src/lexer.l
	$(FLEX) $(FLEX_FLAGS) -o $@ $<

clean:
	rm build/* -f
	rm src/parser.c src/parser.h src/lexer.c src/lexer.h -f
