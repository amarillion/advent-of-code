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
	Test(2023,  1,  "day1/", "./solution.d", "test-input", format("%s\n%s", 1, 14)),
	Test(2023,  2,  "day2/", "./solution.d", "test-input", format("%s\n%s", 12, "abcde")),
	Test(2023,  3,  "day3/", "./solution.d", "test-input", format("%s\n%s", 4, 3)),
	Test(2023,  4,  "day4/", "./solution.d", "test-input", format("%s\n%s", 240, 4455)),

	Test(2023,  1,  "day1/", "./solution.d", "input", format("%s\n%s", 411, 56360)),
	Test(2023,  2,  "day2/", "./solution.d", "input", format("%s\n%s", 7410, "cnjxoritzhvbosyewrmqhgkul")),
	Test(2023,  3,  "day3/", "./solution.d", "input", format("%s\n%s", 111485, 113)),
	Test(2023,  4,  "day4/", "./solution.d", "input", format("%s\n%s", 50558, 28198)),
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