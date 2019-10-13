#pragma once

#include <algorithm>
#include <cstddef>
#include <cstring>
#include <ctime>
#include <functional>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <sys/time.h>
#include <unistd.h>
#include <vector>

using memsetFunc = std::pair<std::function<void *(void *, int, size_t)>, const char *>;

struct benchResult
{
	const char *funcName;
	size_t time;
	size_t sizePerSecond;

	friend bool operator<(const benchResult& left, const benchResult& right)
	{
		return left.time < right.time;
	}
};

struct benchBatchInfo
{
	std::vector<benchResult> resultsAligned;
	std::vector<benchResult> resultsUnaligned;
	size_t size;
	size_t times;
	size_t sizePerSecond;
};

inline auto gettime()
{
	static struct timezone timezone = {0, 0};
	struct timeval time;
	gettimeofday(&time, &timezone);
	return ((uint64_t)time.tv_sec * 1000000 + (uint64_t)time.tv_usec);
}

inline const char *alignedStr(bool aligned)
{
	return aligned ? "aligned" : "unaligned";
}

template <typename T> inline T *alignByPowOf2(T *ptr, uintptr_t align)
{
	return (T *)(((uintptr_t)ptr + (align - 1)) & -(align));
}

inline void doOneBench(bool destinationAlign, size_t size, size_t times, memsetFunc memsetPtr, std::ostream& out, benchResult& result)
{
	std::unique_ptr<char []> data = std::make_unique<char []>(size + 0x40);
	char *alignedPtr = alignByPowOf2(data.get(), 0x40);
	char *dest = destinationAlign ? alignedPtr : (alignedPtr + 1);
	size = destinationAlign ? size : (size - 1);

	out << memsetPtr.second << ", " << size << " bytes, " << times << " times, " << alignedStr(destinationAlign) << " : ";
	out.flush();

	result.funcName = memsetPtr.second;

	usleep(2000);
	auto currentTime = gettime();
	for (size_t i = 0; i < times; ++i)
		memsetPtr.first(dest, 0, size);

	auto timeElapsed = gettime() - currentTime;
	auto sizePerSecond = size / timeElapsed;

	out << static_cast<double>(timeElapsed) / 1000.0 << "ms, "
	    << static_cast<double>(sizePerSecond) / (1.0 / 1000000.0) << "KB/s";

	result.time = timeElapsed;
	result.sizePerSecond = sizePerSecond;

	out << '\n';
	out.flush();
}

inline void doBenchAligns(size_t size, size_t times, memsetFunc memsetPtr, std::ostream& out, benchResult& resultAligned, benchResult& resultUnaligned)
{
	doOneBench(true, size, times, memsetPtr, out, resultAligned);
	doOneBench(false, size, times, memsetPtr, out, resultUnaligned);
}

inline void dumpBatchResult(const benchBatchInfo& result, std::ostream& out)
{
	auto [resultsAligned, resultsUnaligned, size, times, sizePerSecond] = result;
	out << "Leaderboards for size " << size << " (" << times << " times) : \n";

	size_t currentPlacement = 1;
	for (auto result : resultsAligned)
	{
		out << currentPlacement << "th : " << result.funcName << " in " << static_cast<double>(result.time) / 1000.0 << "ms" << '\n';
		++currentPlacement;
	}

	out << '\n';

	out << "Leaderboards for size " << size - 1 << " (" << times << " times) : \n";

	currentPlacement = 1;
	for (auto result : resultsUnaligned)
	{
		out << currentPlacement << "th : " << result.funcName << " in " << static_cast<double>(result.time) / 1000.0 << "ms, "
		    << static_cast<double>(result.time) / (1.0 / 1000000.0) << "KB/s" << '\n';
		++currentPlacement;
	}

	out << '\n';
}

constexpr std::pair<size_t, size_t> sizesTimes[] =
{
	{2, 3350000},
	{4, 2750000},
	{8, 2700000},
	{16, 2650000},
	{32, 2500000},
	{64, 2350000},
	{512, 1050000},
	{1024, 700000},
	{1024 * 4, 200000},
	{1024 * 8, 100000},
	{1024 * 64, 4650},
	{1024 * 1024, 260},
	{1024 * 1024 * 4, 60},
	{1024 * 1024 * 8, 30},
};
