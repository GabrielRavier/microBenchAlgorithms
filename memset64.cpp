#include "memsetCommon.h"

extern "C"
{
	mkMemsetDecl(pdclibMemset)
	mkMemsetDecl(cloudlibcMemset)
	mkMemsetDecl(klibcMemset)
	mkMemsetDecl(neatlibcMemset)
	mkMemsetDecl(dietlibcMemset)
	mkMemsetDecl(uClibcMemset)
	mkMemsetDecl(newlibMemset)
	mkMemsetDecl(muslMemset)
	mkMemsetDecl(bionicSSE2SlmMemset)
	mkMemsetDecl(freeBsdMemset)
	mkMemsetDecl(freeBsdErmsMemset)
	mkMemsetDecl(inlineStringOpGccMemset)
	mkMemsetDecl(inlineStringOpGccSkylakeMemset)
}

const static std::array<memsetFunc, 12> funcs =
{
	{
		{memset, "system libc memset"},
		{pdclibMemset, "pdclib memset"},
		{cloudlibcMemset, "cloudlibc memset"},
		{klibcMemset, "klibc memset"},
		{neatlibcMemset, "neatlibc memset"},
		{dietlibcMemset, "dietlibc memset"},
		{uClibcMemset, "uClibc memset"},
		{newlibMemset, "newlib memset"},
		{muslMemset, "musl memset"},
		{bionicSSE2SlmMemset, "bionic SSE2 memset"},
		{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
		{inlineStringOpGccSkylakeMemset, "-minline-all-stringops -march=skylake gcc memset"}
	}
};

int main()
{
	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
