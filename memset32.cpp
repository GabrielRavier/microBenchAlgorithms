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
	mkMemsetDecl(bytewiseMemset)
	mkMemsetDecl(minixMemset)
	mkMemsetDecl(freeBsdMemset)
	mkMemsetDecl(inlineStringOpGccMemset)
	mkMemsetDecl(inlineStringOpGccI386Memset)
	mkMemsetDecl(inlineStringOpGccI486Memset)
	mkMemsetDecl(inlineStringOpGccI686Memset)
	mkMemsetDecl(inlineStringOpGccNoconaMemset)
}

const static memsetFunc funcs[] =
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
	{bionicSSE2AtomMemset, "bionic SSE2 Atom memset"},
	{glibcMemset, "glibc memset"},
	{glibcI586Memset, "glibc i586 memset"},
	{glibcI686Memset, "glibc i686 memset"},
	{asmlibMemset, "asmlib memset"},
	{bytewiseMemset, "bytewise memset"},
	{minixMemset, "minix memset"},
	{freeBsdMemset, "FreeBSD memset"},
	{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
	{inlineStringOpGccI386Memset, "-minline-all-stringops -march=i386 gcc memset"},
	{inlineStringOpGccI486Memset, "-minline-all-stringops -march=i486 gcc memset"},
	{inlineStringOpGccI686Memset, "-minline-all-stringops -march=i686 gcc memset"},
	{inlineStringOpGccNoconaMemset, "-minline-all-stringops -march=nocona gcc memset"},
};

int main()
{
	benchFunctions(funcs, std::cout);
	return EXIT_SUCCESS;
}
