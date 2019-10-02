#include "memsetCommon.h"

extern "C"
{
#define mkMemsetDecl(x) void *x(void *, int, size_t);
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
	{muslMemset, "musl memset"},
	{bionicSSE2SlmMemset, "bionic SSE2 memset"},
	{inlineStringOpGccMemset, "-minline-all-stringops gcc memset"},
	{inlineStringOpGccSkylakeMemset, "-minline-all-stringops -march=skylake gcc memset"},
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
