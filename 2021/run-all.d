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
	Test(2023,  1,  "day1/", "./solution.d",  "test", format("[%s, %s]", 7, 5)),
	Test(2023,  2,  "day2/", "./solution.d",  "test", format("[%s, %s]", 150, 900)),
	Test(2023,  3,  "day3/", "./solution.d",  "test", format("[%s, %s]", 198, 230)),
	Test(2023,  4,  "day4/", "./solution.d",  "test", format("[%s, %s]", 4512, 1924)),
	Test(2023,  5,  "day5/", "./solution.d",  "test", format("[%s, %s]", 5, 12)),
	Test(2023,  6,  "day6/", "./solution.d",  "test", format("[%s, %s]", 5934, 26984457539)),
	Test(2023,  7,  "day7/", "./solution.d",  "test", format("[%s, %s]", 37, 168)),

	Test(2023,  1,  "day1/", "./solution.d",  "input", format("[%s, %s]", 1477, 1523)),
	Test(2023,  2,  "day2/", "./solution.d",  "input", format("[%s, %s]", 2272262, 2134882034)),
	Test(2023,  3,  "day3/", "./solution.d",  "input", format("[%s, %s]", 4139586, 1800151)),
	Test(2023,  4,  "day4/", "./solution.d",  "input", format("[%s, %s]", 63424, 23541)),
	Test(2023,  5,  "day5/", "./solution.d",  "input", format("[%s, %s]", 6710, 20121)),
	Test(2023,  6,  "day6/", "./solution.d",  "input", format("[%s, %s]", 393019, 1757714216975)),
	Test(2023,  7,  "day7/", "./solution.d",  "input", format("[%s, %s]", 354129, 98905973)),

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