#include "memsetCommon.h"

extern "C"
{
#define mkMemsetDecl(x) void *x(void *, int, size_t);
	mkMemsetDecl(pdclibMemset)
	mkMemsetDecl(dietLibcMemset)
	mkMemsetDecl(uClibcMemset)
	mkMemsetDecl(newlibMemset)
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
	{dietLibcMemset, "dietlibc memset"},
	{uClibcMemset, "uClibc memset"},
	{newlibMemset, "newlib memset"},
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
	std::vector<benchBatchInfo> results;
	for (auto sizeTime : sizesTimes)
	{
		std::vector<benchResult> resultsCurrentSizeAligned;
		std::vector<benchResult> resultsCurrentSizeUnaligned;
		for (auto func : funcs)
		{
			benchResult resultAligned, resultUnaligned;
			doBenchAligns(sizeTime.first, sizeTime.second, func, std::cout, resultAligned, resultUnaligned);

			resultsCurrentSizeAligned.push_back(resultAligned);
			resultsCurrentSizeUnaligned.push_back(resultUnaligned);
		}
		std::sort(resultsCurrentSizeAligned.begin(), resultsCurrentSizeAligned.end());
		std::sort(resultsCurrentSizeUnaligned.begin(), resultsCurrentSizeUnaligned.end());
		results.push_back({std::move(resultsCurrentSizeAligned), std::move(resultsCurrentSizeUnaligned), sizeTime.first, sizeTime.second});
		std::cout << '\n';
	}

	std::cout << "\n\n";

	for (auto benchBatchResult : results)
		dumpBatchResult(benchBatchResult, std::cout);
}
