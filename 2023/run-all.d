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
	Test(2023,  1,  "day1/", "./solution.cpp", "test-input", "142\n142"),
	Test(2023,  1,  "day1/", "./solution.cpp", "test-input2", "198\n281"),
	Test(2023,  2,  "day2/", "./solution.cpp", "test-input", "8\n2286"),
	Test(2023,  3,  "day3/", "./solution.cpp", "test-input", "4361\n467835"),
	Test(2023,  4,  "day4/", "./solution.cpp", "test-input", "13\n30"),
	Test(2023,  5,  "day5/", "./solution.cpp", "test-input", "35\n46"),
	Test(2023,  6,  "day6/", "./Solution",     "test-input", "288\n71503"),
	Test(2023,  7,  "day7/", "./Solution",     "test-input", "6440\n5905"),
	
	Test(2023,  9,  "day9/", "./Solution", "test-input", "114\n2"),
	
	Test(2023, 18, "day18/", "./solution.d", "test-input", "[62, 952408144115]"),


	Test(2023,  1,  "day1/", "./solution.cpp", "input", "56397\n55701"),
	Test(2023,  2,  "day2/", "./solution.cpp", "input", "2239\n83435"),
	Test(2023,  3,  "day3/", "./solution.cpp", "input", "521515\n69527306"),
	Test(2023,  4,  "day4/", "./solution.cpp", "input", "21158\n6050769"),
	Test(2023,  5,  "day5/", "./solution.cpp", "input", "324724204\n104070862"),
	Test(2023,  6,  "day6/", "./Solution",     "input", "220320\n34454850"),
	Test(2023,  7,  "day7/", "./Solution",     "input", "248453531\n248781813"),
	/*


	public static void main(String[] args) throws IOException {
		var testData1 = parse1(Path.of("day6/test-input"));
		assertEqual(solve1(testData1), 288);

		var testData2 = parse2(Path.of("day6/test-input"));
		assertEqual(solve1(testData2), 71503);

		var data1 = parse1(Path.of("day6/input"));
		System.out.println(solve1(data1));

		var data2 = parse2(Path.of("day6/input"));
		System.out.println(solve1(data2));


*/

/*
		var testData = parse(Path.of("day7/test-input"));
		Util.assertEqual(solve1(testData), 6440);
		Util.assertEqual(solve2(testData), 5905);
		var data = parse(Path.of("day7/input"));
		System.out.println(solve1(data)); // 248453531
		System.out.println(solve2(data)); // 248781813
*/
	Test(2023,  9,  "day9/", "./Solution", "input", "2043677056\n1062"),
	
	Test(2023, 18, "day18/", "./solution.d", "input", "[31171, 131431655002266]"),
];

void runTest(Test t) {

	MonoTime before = MonoTime.currTime;
	writefln("Executing script %s %s", t.year, t.day);
	auto execResult = executeShell(format("%s %s", t.script, t.param), null, Config.none, size_t.max, t.workDir);
	assert(execResult.status == 0, format("Script failed with status code %s", execResult.status));
	writeln(execResult.output);
	assert(execResult.output.strip == t.expected, 
		format("Did not receive expected results")
	);
	MonoTime after = MonoTime.currTime;
	Duration timeElapsed = after - before;
	auto elapsedFormat = timeElapsed.split!("minutes", "seconds", "msecs");
	writefln("Elapsed: %02d:%02d.%03d\n\n", elapsedFormat.minutes, elapsedFormat.seconds, elapsedFormat.msecs);
}

void main(string[] args) {
	
	foreach(t; tests) {
		runTest(t);
	}
}