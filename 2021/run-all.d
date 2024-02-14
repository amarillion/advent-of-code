#!/usr/bin/env -S rdmd -I..
module runall;

import std.process;
import std.stdio;
import std.format;
import std.string;
import core.time;

struct Test {
	int year;
	int day;
	string workDir;
	string script;
	string param;
	string expected;
}


Test[] tests = [
	Test(2021,  1,  "day1/", "./solution.d",  "test", format("[%s, %s]", 7, 5)),
	Test(2021,  2,  "day2/", "./solution.d",  "test", format("[%s, %s]", 150, 900)),
	Test(2021,  3,  "day3/", "./solution.d",  "test", format("[%s, %s]", 198, 230)),
	Test(2021,  4,  "day4/", "./solution.d",  "test", format("[%s, %s]", 4512, 1924)),
	Test(2021,  5,  "day5/", "./solution.d",  "test", format("[%s, %s]", 5, 12)),
	Test(2021,  6,  "day6/", "./solution.d",  "test", format("[%s, %s]", 5934, 26984457539)),
	Test(2021,  7,  "day7/", "./solution.d",  "test", format("[%s, %s]", 37, 168)),
	Test(2021,  8,  "day8/", "./solution.d",  "test", format("[%s, %s]", 26, 61229)),
	Test(2021,  8,  "day8/", "./solution.d",  "test2", format("[%s, %s]", 0, 5353)),
	Test(2021,  9,  "day9/", "./solution.d",  "test", format("[%s, %s]", 15, 1134)),
	Test(2021, 10,  "day10/", "./solution.d",  "test", format("[%s, %s]", 26397, 288957)),
	Test(2021, 11,  "day11/", "./solution.d",  "test", format("[%s, %s]", 1656, 195)),
	Test(2021, 12,  "day12/", "./solution.d",  "test", format("[%s, %s]", 10, 36)),
	Test(2021, 12,  "day12/", "./solution.d",  "test2", format("[%s, %s]", 19, 103)),
	Test(2021, 13,  "day13/", "./solution.d",  "test", "
#####
#...#
#...#
#...#
#####
17"),	
	Test(2021, 14,  "day14/", "./solution.d",  "test", format("[%s, %s]", 1588, 2188189693529)),
	Test(2021, 15,  "day15/", "./solution.d",  "test", format("[%s, %s]", 40, 315)),
	Test(2021, 16,  "day16/", "./solution.d",  "test", format("[%s, %s]", 14, 3)),

	Test(2021, 17,  "day17/", "./solution.d",  "test", format("[%s, %s]", 45, 112)),
	Test(2021, 18,  "day18/", "./solution.d",  "test", format("[%s, %s]", 4140, 3993)),
	Test(2021, 19,  "day19/", "./solution.d",  "test", format("[%s, %s]", 79, 3621)),
	Test(2021, 20,  "day20/", "./solution.d",  "test", format("[%s, %s]", 35, 3351)),
	Test(2021, 21,  "day21/", "./solution.d",  "test", format("[%s, %s]", 739785, 444356092776315)),
	Test(2021, 22,  "day22/", "./solution.d",  "test", format("[%s, %s]", 590784, 39769202357779)),
	Test(2021, 22,  "day22/", "./solution.d",  "test2", format("[%s, %s]", 474140, 2758514936282235)),
	Test(2021, 23,  "day23/", "./solution.d",  "test", format("[%s, %s]", 12521, 44169)),
	// Skip 24: no test problem given 
	Test(2021, 25,  "day25/", "./solution.d",  "test", format("%s", 58)),

	Test(2021,  1,  "day1/", "./solution.d",  "input", format("[%s, %s]", 1477, 1523)),
	Test(2021,  2,  "day2/", "./solution.d",  "input", format("[%s, %s]", 2272262, 2134882034)),
	Test(2021,  3,  "day3/", "./solution.d",  "input", format("[%s, %s]", 4139586, 1800151)),
	Test(2021,  4,  "day4/", "./solution.d",  "input", format("[%s, %s]", 63424, 23541)),
	Test(2021,  5,  "day5/", "./solution.d",  "input", format("[%s, %s]", 6710, 20121)),
	Test(2021,  6,  "day6/", "./solution.d",  "input", format("[%s, %s]", 393019, 1757714216975)),
	Test(2021,  7,  "day7/", "./solution.d",  "input", format("[%s, %s]", 354129, 98905973)),
	Test(2021,  8,  "day8/", "./solution.d",  "input", format("[%s, %s]", 473, 1097568)),
	Test(2021,  9,  "day9/", "./solution.d",  "input", format("[%s, %s]", 502, 1330560)),
	Test(2021, 10,  "day10/", "./solution.d",  "input", format("[%s, %s]", 358737, 4329504793)),
	Test(2021, 11,  "day11/", "./solution.d",  "input", format("[%s, %s]", 1732, 290)),
	Test(2021, 12,  "day12/", "./solution.d",  "input", format("[%s, %s]", 5254, 149385)),
	Test(2021, 13,  "day13/", "./solution.d",  "input", "
.##..###..#..#.####.###...##..#..#.#..#
#..#.#..#.#..#....#.#..#.#..#.#..#.#..#
#..#.#..#.####...#..#..#.#....#..#.####
####.###..#..#..#...###..#....#..#.#..#
#..#.#.#..#..#.#....#....#..#.#..#.#..#
#..#.#..#.#..#.####.#.....##...##..#..#
747"),

	Test(2021, 14,  "day14/", "./solution.d",  "input", format("[%s, %s]", 3048, 3288891573057)),
	Test(2021, 15,  "day15/", "./solution.d",  "input", format("[%s, %s]", 714, 2948)),
	Test(2021, 16,  "day16/", "./solution.d",  "input", format("[%s, %s]", 893, 4358595186090)),
	Test(2021, 17,  "day17/", "./solution.d",  "input", format("[%s, %s]", 4005, 2953)),
	Test(2021, 18,  "day18/", "./solution.d",  "input", format("[%s, %s]", 3869, 4671)),
	Test(2021, 19,  "day19/", "./solution.d",  "input", format("[%s, %s]", 326, 10630)),
	Test(2021, 20,  "day20/", "./solution.d",  "input", format("[%s, %s]", 4964, 13202)),
	Test(2021, 21,  "day21/", "./solution.d",  "input", format("[%s, %s]", 998088, 306621346123766)),
	Test(2021, 22,  "day22/", "./solution.d",  "input", format("[%s, %s]", 588200, 1207167990362099)),
	Test(2021, 23,  "day23/", "./solution.d",  "input", format("[%s, %s]", 16244, 43226)),
	Test(2021, 24,  "day24/", "./solution.d",  "input", format(`["%s", "%s"]`, 99429795993929, 18113181571611)),
	Test(2021, 25,  "day25/", "./solution.d",  "input", format("%s", 486)),
];

void runTest(PerformanceContext context, Test t) {

	MonoTime before = MonoTime.currTime;
	writefln("Executing script %s %s", t.year, t.day);
	auto execResult = executeShell(format("%s %s", t.script, t.param), null, Config.none, size_t.max, t.workDir);
	assert(execResult.status == 0, format("Script failed with status code %s", execResult.status));
	// writeln(execResult.output);
	assert(execResult.output.strip == t.expected.strip, 
		format("Did not receive expected results")
	);
	MonoTime after = MonoTime.currTime;
	Duration timeElapsed = after - before;
	auto elapsedFormat = timeElapsed.split!("minutes", "seconds", "msecs");
	writefln("Elapsed: %02d:%02d.%03d\n", elapsedFormat.minutes, elapsedFormat.seconds, elapsedFormat.msecs);
	context.logPerformance(format("%s day %s %s", t.year, t.day, t.param), timeElapsed.total!"msecs");
}

struct PerformanceContext {
	string gitHash;
	string host;
	string branch;
	string cpu;
	string todayIso;
}

import std.socket : Socket;
import std.datetime : DateTime, Clock;

PerformanceContext getPerformanceContext() {
	PerformanceContext result;
	
	result.todayIso = Clock.currTime().toISOExtString(); //TODO: dlang has no custom date formatting option, so you get what you get.

	result.host = Socket.hostName();

	auto hashExec = executeShell("git log -1 --format='%h'");
	result.gitHash = hashExec.status == 0 ? hashExec.output.strip : "Unknown hash";
	
	auto branchExec = executeShell("git rev-parse --abbrev-ref HEAD");
	result.branch = branchExec.status == 0 ? branchExec.output.strip : "Unknown branch";

	auto cpuExec = executeShell("lscpu | grep 'Model name' | sed -r 's/Model name:\\s{1,}(.*) @ .*z\\s*/\\1/g'");
	result.cpu = cpuExec.status == 0 ? cpuExec.output.strip : "Unknown CPU";

	return result;
}

void logPerformance(PerformanceContext context, string test, long durationMsec) {
	File file;
	file.open("performance.log", "a");

	file.writefln("%s\t%s\t%s\t%s\t%s\t%s\t%s", 
		context.todayIso,
		test,
		durationMsec,
		context.gitHash,
		context.branch,
		context.host,
		context.cpu);

	file.close();
}

void main(string[] args) {
	PerformanceContext context = getPerformanceContext();	
	foreach(t; tests) {
		runTest(context, t);
	}
}