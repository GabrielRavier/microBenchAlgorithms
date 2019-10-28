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
	const static std::array<memsetFunc, 29> funcs =
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
			{newlibSmallMemset, "newlib memset optimized for size"},
			{muslMemset, "musl memset"},

	#ifdef HAVE_SSE2
			{bionicSSE2AtomMemset, "bionic SSE2 Atom memset"},
	#endif

			{glibcMemset, "glibc memset"},
			{glibcI586Memset, "glibc i586 memset"},
			{glibcI686Memset, "glibc i686 memset"},
			{asmlibMemset, "asmlib memset"},
	#ifdef HAVE_SSE2
			{asmlibSSE2Memset, "asmlib SSE2 memset"},
			{asmlibSSE2v2Memset, "asmlib SSE2 memset v2"},
	#endif

	#ifdef HAVE_AVX
			{asmlibAVXMemset, "asmlib AVX memset"},
	#endif

	#ifdef HAVE_AVX512F
			{asmlibAVX512FMemset, "asmlib AVX512F memset"},
	#endif

	#ifdef HAVE_AVX512BW
			{asmlibAVX512BWMemset, "asmlib AVX512BW memset"},
	#endif
			{msvc2003Memset, "MSVC 2003 memset"},
			{bytewiseMemset, "bytewise memset"},
			{minixMemset, "minix memset"},
			{freeBsdMemset, "FreeBSD memset"},
			{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
			{inlineStringOpGccI386Memset, "-minline-all-stringops -march=i386 gcc memset"},
			{inlineStringOpGccI486Memset, "-minline-all-stringops -march=i486 gcc memset"},
			{inlineStringOpGccI686Memset, "-minline-all-stringops -march=i686 gcc memset"},
			{inlineStringOpGccNoconaMemset, "-minline-all-stringops -march=nocona gcc memset"}
		}
	};

	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
