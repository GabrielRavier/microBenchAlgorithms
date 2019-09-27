TESTS = memset32 memset64

all: $(TESTS)

obj32/%.o: %.cpp
	@mkdir -p obj32
	g++ -c $^ -o $@ -m32 -Ofast -std=gnu++17

obj32/%AsmFuncs.o: %.asm
	@mkdir -p obj64
	nasm -f elf32 $< -o $@

obj64/%.o: %.cpp
	@mkdir -p obj64
	g++ -c $^ -o $@ -m64 -Ofast -std=gnu++17

obj64/%AsmFuncs.o: %.asm
	@mkdir -p obj64
	nasm -f elf64 $< -o $@

memset32: obj32/memset32.o obj32/memset32AsmFuncs.o
	g++ $^ -o $@ -m32 -Ofast

memset64: obj64/memset64.o obj64/memset64AsmFuncs.o
	g++ $^ -o $@ -m64 -Ofast

clean:
	rm -f obj32/*.o obj64/*.o

clobber: clean
	rm -f $(TESTS)

install: all
	@echo are you kidding'??'
