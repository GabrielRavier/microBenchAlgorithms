#include "memsetCommon.h"

extern "C"
{
	mkMemsetDecl(pdclibMemset)
	mkMemsetDecl(cloudlibcMemset)
	mkMemsetDecl(libFtMemset)
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

int main()
{
	const static std::array<memsetFunc, 13> funcs =
	{
		{
			{memset, "system libc memset"},
			{pdclibMemset, "pdclib memset"},
			{cloudlibcMemset, "cloudlibc memset"},
			{libFtMemset, "libft memset"},
			{klibcMemset, "klibc memset"},
			{neatlibcMemset, "neatlibc memset"},
			{dietlibcMemset, "dietlibc memset"},
			{uClibcMemset, "uClibc memset"},
			{newlibMemset, "newlib memset"},
			{muslMemset, "musl memset"},
	#ifdef HAVE_SSE2
			{bionicSSE2SlmMemset, "bionic SSE2 memset"},
	#endif
			{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
			{inlineStringOpGccSkylakeMemset, "-minline-all-stringops -march=skylake gcc memset"}
		}
	};

	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
