OUT = main

CC    = gcc
LD    = gcc

CC_FLAGS = -ggdb3
LD_FLAGS = -ggdb3


all: build/$(OUT)

build/$(OUT): build/main.o
	$(LD) $(LD_FLAGS) -o build/$(OUT) $^

build/%.o: src/%.c
	$(CC) $(CC_FLAGS) -o $@ -c $<

clean:
	rm build/* -f
