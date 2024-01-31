#!/usr/bin/env -S rdmd -I..
module runall;

import std.process;
import std.stdio;
import std.format;
import std.string;

struct Test {
	int year;
	int day;
	string workDir;
	string script;
	string param;
	string expected;
}


Test[] tests = [
	Test(2023, 1, "day1/", "./solution.cpp", "test-input", "142\n142"),
	Test(2023, 1, "day1/", "./solution.cpp", "test-input2", "198\n281"),
	Test(2023, 1, "day1/", "./solution.cpp", "input", "56397\n55701"),

	Test(2023, 18, "day18/", "./solution.d", "test-input", "[62, 952408144115]"),
	Test(2023, 18, "day18/", "./solution.d", "input", "[31171, 131431655002266]"),
];

void runTest(Test t) {
	writefln("Executing script %s %s", t.year, t.day);
	auto execResult = executeShell(format("%s %s", t.script, t.param), null, Config.none, size_t.max, t.workDir);
	assert(execResult.status == 0, format("Script failed with status code %s", execResult.status));
	writeln(execResult.output);
	assert(execResult.output.strip == t.expected, "Did not receive expected results");
}

void main(string[] args) {
	
	foreach(t; tests) {
		runTest(t);
	}
}