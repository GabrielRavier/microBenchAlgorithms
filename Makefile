TESTS = memset32 memset64

CXXFLAGS = -std=gnu++2a -W -Wall -Wextra -DHAVE_AVX

ifeq ($(RELEASE), 1)
	CXXFLAGS += -Ofast -s -flto
else
	CXXFLAGS += -Og -ggdb3
	ASMFLAGS += -gdwarf
endif

all: $(TESTS)

obj32/%.o: %.cpp
	@mkdir -p obj32
	g++ -c $^ -o $@ -m32 $(CXXFLAGS)

obj32/%AsmFuncs.o: %.asm
	@mkdir -p obj64
	nasm -f elf32 $< -o $@ $(ASMFLAGS)

obj64/%.o: %.cpp
	@mkdir -p obj64
	g++ -c $^ -o $@ -m64 $(CXXFLAGS)

obj64/%AsmFuncs.o: %.asm
	@mkdir -p obj64
	nasm -f elf64 $< -o $@ $(ASMFLAGS)

memset32: obj32/memset32.o obj32/memset32AsmFuncs.o
	g++ $^ -o $@ -m32 $(CXXFLAGS)

memset64: obj64/memset64.o obj64/memset64AsmFuncs.o
	g++ $^ -o $@ -m64 $(CXXFLAGS)

clean:
	rm -f obj32/*.o obj64/*.o

clobber: clean
	rm -f $(TESTS)

install: all
	@echo Are you kidding '??'
