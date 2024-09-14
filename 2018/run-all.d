#!/usr/bin/env -S rdmd -I..
module runall;

import std.process;
import std.stdio;
import std.format;
import std.string;
import core.time;

struct Test {
	int day;
	string workDir;
	string script;
	string param;
	string expected;

	this(int day, string script, string param, string expected) {
		this.day = day;
		this.workDir = format("day%s/", day);
		this.script = script;
		this.param = param;
		this.expected = expected;
	}
}

const day10test = 
`#...#..###
#...#...#.
#...#...#.
#####...#.
#...#...#.
#...#...#.
#...#...#.
#...#..###
3`;
const day10 = 
`######.....###..#....#..#....#...####....####...#....#..#....#
#...........#...#....#..##...#..#....#..#....#..##...#..#....#
#...........#....#..#...##...#..#.......#.......##...#...#..#.
#...........#....#..#...#.#..#..#.......#.......#.#..#...#..#.
#####.......#.....##....#.#..#..#.......#.......#.#..#....##..
#...........#.....##....#..#.#..#.......#.......#..#.#....##..
#...........#....#..#...#..#.#..#.......#.......#..#.#...#..#.
#.......#...#....#..#...#...##..#.......#.......#...##...#..#.
#.......#...#...#....#..#...##..#....#..#....#..#...##..#....#
######...###....#....#..#....#...####....####...#....#..#....#
10612`;

enum YEAR = 2018;
Test[] tests = [
	Test(1,  "./solution.d", "test-input", format("%s\n%s", 1, 14)),
	Test(2,  "./solution.d", "test-input", format("%s\n%s", 12, "abcde")),
	Test(3,  "./solution.d", "test-input", format("%s\n%s", 4, 3)),
	Test(4,  "./solution.d", "test-input", format("%s\n%s", 240, 4455)),
	Test(5,  "./solution.d", "test-input", format("%s\n%s", 10, 4)),
	Test(6,  "./solution.d", "test-input", format("%s\n%s", 17, 16)),
	Test(7,  "./solution.d", "test-input", format("%s\n%s", "CABDFE", 15)),
	Test(8,  "./solution.d", "test-input", format("%s\n%s", 138, 66)),
	Test(9,  "./solution.d", "test-input", format("%s\n%s", 32, 22563)),
	Test(10,  "./solution.d", "test-input", day10test),

	Test(1,  "./solution.d", "input", format("%s\n%s", 411, 56360)),
	Test(2,  "./solution.d", "input", format("%s\n%s", 7410, "cnjxoritzhvbosyewrmqhgkul")),
	Test(3,  "./solution.d", "input", format("%s\n%s", 111485, 113)),
	Test(4,  "./solution.d", "input", format("%s\n%s", 50558, 28198)),
	Test(5,  "./solution.d", "input", format("%s\n%s", 10888, 6952)),
	Test(6,  "./solution.d", "input", format("%s\n%s", 4215, 40376)),
	Test(7,  "./solution.d", "input", format("%s\n%s", "IOFSJQDUWAPXELNVYZMHTBCRGK", 931)),	
	Test(8,  "./solution.d", "input", format("%s\n%s", 48496, 32850)),
	Test(9,  "./solution.d", "input", format("%s\n%s", 405143, 3411514667)),
	Test(10,  "./solution.d", "input", day10),
];

void runTest(PerformanceContext context, Test t) {

	MonoTime before = MonoTime.currTime;
	writefln("Executing script %s %s", YEAR, t.day);
	auto execResult = executeShell(format("%s %s", t.script, t.param), null, Config.none, size_t.max, t.workDir);
	assert(execResult.status == 0, format("Script failed with status code %s", execResult.status));
	// writeln(execResult.output);
	assert(execResult.output.strip == t.expected, 
		format("Did not receive expected results")
	);
	MonoTime after = MonoTime.currTime;
	Duration timeElapsed = after - before;
	auto elapsedFormat = timeElapsed.split!("minutes", "seconds", "msecs");
	writefln("Elapsed: %02d:%02d.%03d\n", elapsedFormat.minutes, elapsedFormat.seconds, elapsedFormat.msecs);
	context.logPerformance(format("%s day %s %s %s", YEAR, t.day, t.script, t.param), timeElapsed.total!"msecs");
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