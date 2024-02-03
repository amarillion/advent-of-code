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
	Test(2023,  1,  "day1/", "./solution.cpp", "test-input", format("%s\n%s", 142, 142)),
	Test(2023,  1,  "day1/", "./solution.cpp", "test-input2", format("%s\n%s", 198, 281)),
	Test(2023,  2,  "day2/", "./solution.cpp", "test-input", format("%s\n%s", 8, 2286)),
	Test(2023,  3,  "day3/", "./solution.cpp", "test-input", format("%s\n%s", 4361, 467835)),
	Test(2023,  4,  "day4/", "./solution.cpp", "test-input", format("%s\n%s", 13, 30)),
	Test(2023,  5,  "day5/", "./solution.cpp", "test-input", format("%s\n%s", 35, 46)),
	Test(2023,  6,  "day6/", "./Solution",     "test-input", format("%s\n%s", 288, 71503)),
	Test(2023,  7,  "day7/", "./Solution",     "test-input", format("%s\n%s", 6440, 5905)),
	Test(2023,  8,  "day8/", "./solution.ts",  "test-input", format("%s\n%s", 2, 2)),
	Test(2023,  9,  "day9/", "./Solution",     "test-input", format("%s\n%s", 114, 2)),
	Test(2023, 10, "day10/", "./solution.d",   "test-input", format("[%s, %s]", 8, 1)),
	Test(2023, 11, "day11/", "./solution.d",   "test-input 100", format("[%s, %s]", 374, 8410)),
	Test(2023, 12, "day12/", "./solution.d",   "test-input", format("[%s, %s]", 21, 525_152)),
	Test(2023, 13, "day13/", "./solution.d",   "test-input", format("[%s, %s]", 405, 400)),
	Test(2023, 14, "day14/", "./solution.d",   "test-input", format("%s\n%s", 136, 64)),
	Test(2023, 15, "day15/", "./solution.d",   "test-input", format("%s\n%s", 1320, 145)),
	Test(2023, 16, "day16/", "./solution.d",   "test-input", format("%s\n%s", 46, 51)),
	Test(2023, 17, "day17/", "./solution.d",   "test-input", format("%s\n%s", 102, 94)),
	Test(2023, 17, "day17/", "./solution.d",   "test-input2", format("%s\n%s", 59, 71)),
	Test(2023, 18, "day18/", "./solution.d", "test-input", "[62, 952408144115]"),
	Test(2023, 19, "day19/", "./solution.d", "test-input", format("%s\n%s", 19114, 167409079868000)),
	Test(2023, 20, "day20/", "./solution.d", "test-input", format("%s\n%s", 32000000, 1)),
	Test(2023, 20, "day20/", "./solution.d", "test-input2", format("%s\n%s", 11687500, 1)),

	Test(2023, 21, "day21/", "./solution.d", "test-input", format("%s\n%s", 2665, 470149643712804)),
	Test(2023, 22, "day22/", "./solution.d", "test-input", format("[%s, %s]", 5, 7)),
	Test(2023, 23, "day23/", "./solution.d", "test-input", format("%s\n%s", 94, 154)),

	Test(2023, 25, "day25/", "./solution.d", "test-input", format("%s", 54)),


	Test(2023,  1,  "day1/", "./solution.cpp", "input", format("%s\n%s", 56397, 55701)),
	Test(2023,  2,  "day2/", "./solution.cpp", "input", format("%s\n%s", 2239, 83435)),
	Test(2023,  3,  "day3/", "./solution.cpp", "input", format("%s\n%s", 521515, 69527306)),
	Test(2023,  4,  "day4/", "./solution.cpp", "input", format("%s\n%s", 21158, 6050769)),
	Test(2023,  5,  "day5/", "./solution.cpp", "input", format("%s\n%s", 324724204, 104070862)),
	Test(2023,  6,  "day6/", "./Solution",     "input", format("%s\n%s", 220320, 34454850)),
	Test(2023,  7,  "day7/", "./Solution",     "input", format("%s\n%s", 248453531, 248781813)),
	Test(2023,  8,  "day8/", "./solution.ts",  "input", format("%s\n%s", 16409, 11795205644011)),
	Test(2023,  9,  "day9/", "./Solution",     "input", format("%s\n%s", 2043677056, 1062)),
	Test(2023, 10, "day10/", "./solution.d",   "input", format("[%s, %s]", 6867, 595)),
	Test(2023, 11, "day11/", "./solution.d",   "input 1000000", format("[%s, %s]", 9_639_160, 752_936_133_304)),
	Test(2023, 12, "day12/", "./solution.d",   "input", format("[%s, %s]", 7090, 6_792_010_726_878)),
	Test(2023, 13, "day13/", "./solution.d",   "input", format("[%s, %s]", 31739, 31539)),
	Test(2023, 14, "day14/", "./solution.d",   "input", format("%s\n%s", 106990, 100531)),
	Test(2023, 15, "day15/", "./solution.d",   "input", format("%s\n%s", 521_341, 252_782)),
	Test(2023, 16, "day16/", "./solution.d",   "input", format("%s\n%s", 7951, 8148)),
	Test(2023, 17, "day17/", "./solution.d",   "input", format("%s\n%s", 665, 809)),	
	Test(2023, 18, "day18/", "./solution.d",   "input", "[31171, 131431655002266]"),
	Test(2023, 19, "day19/", "./solution.d",   "input", format("%s\n%s", 376008, 124078207789312)),
	Test(2023, 20, "day20/", "./solution.d",   "input", format("%s\n%s", 812609846, 245114020323037)),
	Test(2023, 21, "day21/", "./solution.d",   "input", format("%s\n%s", 3764, 622926941971282)),
	Test(2023, 22, "day22/", "./solution.d",   "input", format("[%s, %s]", 430, 60558)),
	Test(2023, 23, "day23/", "./solution.d",   "input", format("%s\n%s", 2430, 6534)),

	Test(2023, 25, "day25/", "./solution.d",   "input", format("%s", 525264)),

];

void runTest(Test t) {

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
}

void main(string[] args) {
	
	foreach(t; tests) {
		runTest(t);
	}
}