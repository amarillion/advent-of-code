#!/usr/bin/env -S rdmd -I..
module runall;

import std.process;
import std.stdio;
import std.format;
import std.string;
import core.time;

struct Test {
	int year = 2024;
	int day;
	string workDir;
	string script;
	string param;
	string expected;

	this(int day, string script, string param, string expected) {
		this.year = 2024;
		this.workDir = format("day%s/", day);
		this.day = day;
		this.script = script;
		this.param = param;
		this.expected = expected;
	}
}

Test[] tests = [
	Test(1,  "./solution.ts", "test-input", format("%s\n%s", 11, 31)),
	Test(2,  "./solution.ts", "test-input", format("%s\n%s", 2, 4)),
	Test(3,  "./solution.ts", "test-input", format("%s\n%s", 161, 48)),
	Test(4,  "./solution.ts", "test-input", format("%s\n%s", 18, 9)),
	Test(5,  "./solution.ts", "test-input", format("%s\n%s", 143, 123)),
	Test(6,  "./simple.ts",   "test-input", format("%s\n%s", 41, 6)),
	Test(6,  "./solution.ts", "test-input", format("%s\n%s", 41, 6)),
	Test(7,  "./solution.ts", "test-input", format("%s\n%s", 3749, 11387)),
	Test(8,  "./solution.ts", "test-input", format("%s\n%s", 14, 34)),
	Test(9,  "./solution.ts", "test-input", format("%s\n%s", 1928, 2858)),
	Test(10, "./solution.ts", "test-input", format("%s\n%s", 36, 81)),
	Test(11, "./solution.ts", "test-input", format("%s\n%s", 55312, 65601038650482)),
	Test(12, "./solution.ts", "test-input", format("%s\n%s", 140, 80)),
	Test(12, "./solution.ts", "test-input2", format("%s\n%s", 1184, 368)),
	Test(13, "./solution.ts", "test-input", format("%s\n%s", 480, 875318608908)),

	Test(15, "./solution.ts", "test-input", format("%s\n%s", 10092, 9021)),
	Test(16, "./solution.ts", "test-input", format("%s\n%s", 7036, 45)),
	
	Test(20, "./solution.ts", "test-input", format("%s\n%s", 1, 285)),

	Test(1,  "./solution.ts", "input", format("%s\n%s", 2769675, 24643097)),
	Test(2,  "./solution.ts", "input", format("%s\n%s", 269, 337)),
	Test(3,  "./solution.ts", "input", format("%s\n%s", 184576302, 118173507)),
	Test(4,  "./solution.ts", "input", format("%s\n%s", 2547, 1939)),
	Test(5,  "./solution.ts", "input", format("%s\n%s", 6267, 5184)),
	Test(6,  "./solution.ts", "input", format("%s\n%s", 5242, 1424)),
	Test(7,  "./solution.ts", "input", format("%s\n%s", 42283209483350, 1026766857276279)),
	Test(8,  "./solution.ts", "input", format("%s\n%s", 400, 1280)),
	Test(9,  "./solution.ts", "input", format("%s\n%s", 6353658451014, 6382582136592)),
	Test(10, "./solution.ts", "input", format("%s\n%s", 550, 1255)),
	Test(11, "./solution.ts", "input", format("%s\n%s", 183435, 218279375708592)),
	Test(12, "./solution.ts", "input", format("%s\n%s", 1488414, 911750)),
	Test(13, "./solution.ts", "input", format("%s\n%s", 33209, 83102355665474)),

	Test(15, "./solution.ts", "input", format("%s\n%s", 1515788, 1516544)),
	Test(16, "./solution.ts", "input", format("%s\n%s", 83444, 483)),

	Test(20, "./solution.ts", "input", format("%s\n%s", 1411, 1010263)),

];

void runTest(PerformanceContext context, Test t) {

	MonoTime before = MonoTime.currTime;
	writefln("Executing script %s %s", t.year, t.day);
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
	context.logPerformance(format("%s day %s %s %s", t.year, t.day, t.script, t.param), timeElapsed.total!"msecs");
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