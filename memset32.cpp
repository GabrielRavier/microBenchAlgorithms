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
	mkMemsetDecl(newlibSmallMemset)
	mkMemsetDecl(muslMemset)
	mkMemsetDecl(bionicSSE2AtomMemset)
	mkMemsetDecl(glibcMemset)
	mkMemsetDecl(glibcI586Memset)
	mkMemsetDecl(glibcI686Memset)
	mkMemsetDecl(asmlibMemset)
	mkMemsetDecl(asmlibSSE2Memset)
	mkMemsetDecl(asmlibSSE2v2Memset)
	mkMemsetDecl(asmlibAVXMemset)
	mkMemsetDecl(asmlibAVX512FMemset)
	mkMemsetDecl(asmlibAVX512BWMemset)
	mkMemsetDecl(msvc2003Memset)
	mkMemsetDecl(bytewiseMemset)
	mkMemsetDecl(minixMemset)
	mkMemsetDecl(freeBsdMemset)
	mkMemsetDecl(inlineStringOpGccMemset)
	mkMemsetDecl(inlineStringOpGccI386Memset)
	mkMemsetDecl(inlineStringOpGccI486Memset)
	mkMemsetDecl(inlineStringOpGccI686Memset)
	mkMemsetDecl(inlineStringOpGccNoconaMemset)
}

int main()
{
	const static std::array funcs =
	{
		memsetFunc{memset, "system libc memset"},
		memsetFunc{pdclibMemset, "pdclib memset"},
		memsetFunc{cloudlibcMemset, "cloudlibc memset"},
		memsetFunc{klibcMemset, "klibc memset"},
		memsetFunc{neatlibcMemset, "neatlibc memset"},
		memsetFunc{dietlibcMemset, "dietlibc memset"},
		memsetFunc{uClibcMemset, "uClibc memset"},
		memsetFunc{newlibMemset, "newlib memset"},
		memsetFunc{newlibSmallMemset, "newlib memset optimized for size"},
		memsetFunc{muslMemset, "musl memset"},

#ifdef HAVE_SSE2
		memsetFunc{bionicSSE2AtomMemset, "bionic SSE2 Atom memset"},
#endif

		memsetFunc{glibcMemset, "glibc memset"},
		memsetFunc{glibcI586Memset, "glibc i586 memset"},
		memsetFunc{glibcI686Memset, "glibc i686 memset"},
		memsetFunc{asmlibMemset, "asmlib memset"},

#ifdef HAVE_SSE2
		memsetFunc{asmlibSSE2Memset, "asmlib SSE2 memset"},
		memsetFunc{asmlibSSE2v2Memset, "asmlib SSE2 memset v2"},
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

		memsetFunc{msvc2003Memset, "MSVC 2003 memset"},
		memsetFunc{bytewiseMemset, "bytewise memset"},
		memsetFunc{minixMemset, "minix memset"},
		memsetFunc{freeBsdMemset, "FreeBSD memset"},
		memsetFunc{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
		memsetFunc{inlineStringOpGccI386Memset, "-minline-all-stringops -march=i386 gcc memset"},
		memsetFunc{inlineStringOpGccI486Memset, "-minline-all-stringops -march=i486 gcc memset"},
		memsetFunc{inlineStringOpGccI686Memset, "-minline-all-stringops -march=i686 gcc memset"},
		memsetFunc{inlineStringOpGccNoconaMemset, "-minline-all-stringops -march=nocona gcc memset"}
	};

	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
