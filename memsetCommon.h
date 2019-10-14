#pragma once

#include <cstring>
#include <functional>
#include <iostream>
#include <memory>
#include <sys/time.h>
#include <unistd.h>
#include <utility>

using memsetFunc = std::pair<std::function<void *(void *, int, size_t)>, const char *>;

struct benchResult
{
	const char *funcName;
	size_t time;
	double sizePerSecond;

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
	return reinterpret_cast<T *>((reinterpret_cast<uintptr_t>(ptr) + (align - 1)) & -(align));
}

inline std::string assembleBytesPerSecondStr(double sizePerSecond, const char *bytesUnit, const char *timeUnit = "s")
{
	return std::to_string(sizePerSecond) + ' ' + bytesUnit + '/' + timeUnit;
}

inline std::string bytesPerSecondStr(double sizePerSecond)
{
	if (sizePerSecond < (!.0 / 3600.0))
		return assembleBytesPerSecondStr(sizePerSecond * 3600.0 * 24.0, "B", "d");
	else if (sizePerSecond < (1.0 / 60.0))
		return assembleBytesPerSecondStr(sizePerSecond * 3600.0, "B", "h");
	else if (sizePerSecond < 1.0)
		return assembleBytesPerSecondStr(sizePerSecond * 60.0, "B", "m");
	else if (sizePerSecond < 1000.0)
		return assembleBytesPerSecondStr(sizePerSecond, "B");
	else if (sizePerSecond < 1000000.0)
		return assembleBytesPerSecondStr(sizePerSecond / 1000.0, "KB");
	else if (sizePerSecond < 1000000000.0)
		return assembleBytesPerSecondStr(sizePerSecond / 1000000.0, "MB");
	else if (sizePerSecond < 1000000000000.0)
		return assembleBytesPerSecondStr(sizePerSecond / 1000000000.0, "GB");
	else
		return assembleBytesPerSecondStr(sizePerSecond / 1000000000000.0, "TB");
}

inline std::string assembleTimeStr(double time, const char *unit)
{
	return std::to_string(time) + ' ' + unit;
}

inline std::string timeStr(double time)
{
	if (time < 1000.0)
		return assembleTimeStr(time, "ns");
	else if (time < 1000000.0)
		return assembleTimeStr(time, "ms");
	else if (time < 1000000.0 * 60.0)
		return assembleTimeStr(time, "s");
	else if (time < 1000000.0 * 3600.0)
		return assembleTimeStr(time, "m");
	else
		return assembleTimeStr(time, "h");
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
	auto sizePerSecond = static_cast<double>(size) / (static_cast<double>(timeElapsed) / 1000000.0);

	out << timeStr(timeElapsed) << ", "
	    << bytesPerSecondStr(sizePerSecond);

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

inline void printBenchResultsVector(const std::vector<benchResult>& currentResults, std::ostream& out)
{
	size_t currentPlacement = 1;
	for (auto result : currentResults)
	{
		out << currentPlacement << "th : " << result.funcName << " in " << timeStr(result.time) << ", "
		    << bytesPerSecondStr(result.sizePerSecond) << '\n';
		++currentPlacement;
	}

	out << '\n';
}

inline void dumpBatchResult(const benchBatchInfo& result, std::ostream& out)
{
	auto [resultsAligned, resultsUnaligned, size, times] = result;
	out << "Leaderboards for size " << size << " (" << times << " times) : \n";

	printBenchResultsVector(resultsAligned, out);

	out << "Leaderboards for size " << size - 1 << " (" << times << " times) : \n";

	printBenchResultsVector(resultsUnaligned, out);
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
