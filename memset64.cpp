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
	mkMemsetDecl(asmlibSSE2Memset)
	mkMemsetDecl(asmlibAVXMemset)
	mkMemsetDecl(asmlibAVX512FMemset)
	mkMemsetDecl(asmlibAVX512BWMemset)
	mkMemsetDecl(kosMK3Memset)
	mkMemsetDecl(dklibcMemset)
	mkMemsetDecl(stringAsmMemset)
	mkMemsetDecl(josMemset)
	mkMemsetDecl(freeBsdMemset)
	mkMemsetDecl(freeBsdErmsMemset)
	mkMemsetDecl(inlineStringOpGccMemset)
	mkMemsetDecl(inlineStringOpGccSkylakeMemset)
}

int main()
{
	const static std::array funcs =
	{
		memsetFunc{memset, "system libc memset"},
		memsetFunc{pdclibMemset, "pdclib memset"},
		memsetFunc{cloudlibcMemset, "cloudlibc memset"},
		memsetFunc{libFtMemset, "libft memset"},
		memsetFunc{klibcMemset, "klibc memset"},
		memsetFunc{neatlibcMemset, "neatlibc memset"},
		memsetFunc{dietlibcMemset, "dietlibc memset"},
		memsetFunc{uClibcMemset, "uClibc memset"},
		memsetFunc{newlibMemset, "newlib memset"},
		memsetFunc{muslMemset, "musl memset"},

#ifdef HAVE_SSE2
		memsetFunc{bionicSSE2SlmMemset, "bionic SSE2 memset"},
		memsetFunc{asmlibSSE2Memset, "asmlib SSE2 memset"},
#endif

#ifdef HAVE_AVX
		memsetFunc{asmlibAVXMemset, "asmlib AVX memset"},
#endif

#ifdef HAVE_AVX512F
		memsetFunc{asmlibAVX512FMemset, "asmlib AVX512F memset"},
#endif

#ifdef HAVE_AVX512BW
		memsetFunc{asmlibAVX512BWMemset, "asmlib AVX512BW memset"},
#endif

		memsetFunc{kosMK3Memset, "kOS MK3 memset"},
		memsetFunc{dklibcMemset, "dklibc memset"},
		memsetFunc{stringAsmMemset, "string.asm memset"},
		memsetFunc{josMemset, "jos memset"},
		memsetFunc{freeBsdMemset, "FreeBSD memset"},
		memsetFunc{freeBsdErmsMemset, "FreeBSD ERMS memset"},
		memsetFunc{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
		memsetFunc{inlineStringOpGccSkylakeMemset, "-minline-all-stringops -march=skylake gcc memset"}
	};

	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
