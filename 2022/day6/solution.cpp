//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <set>

using namespace std;

string readInput(const string &fname) {
	ifstream infile(fname);
	string line;
	getline(infile, line);
	return line;
}

bool distinctChars(const string &s) {
	set<char> chars;
	for (auto ch : s) {
		chars.insert(ch);
	}
	return chars.size() == s.length();
}

int findMarker(const string &input, int size = 4) {
	for (int pos = 0; pos < input.length() - size; ++pos) {
		auto s = input.substr(pos, size);
		if (distinctChars(s)) return pos + size;
	}
	return -1;
}

int main() {
	assert(findMarker("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7);
	assert(findMarker("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5);
	assert(findMarker("nppdvjthqldpwncqszvftbrmjlhg") == 6);
	assert(findMarker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10);
	assert(findMarker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11);
	string input = readInput("day6/input");
	cout << findMarker(input) << endl;

	assert(findMarker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14) == 19);
	assert(findMarker("bvwbjplbgvbhsrlpgdmjqwftvncz", 14) == 23);
	assert(findMarker("nppdvjthqldpwncqszvftbrmjlhg", 14) == 23);
	assert(findMarker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14) == 29);
	assert(findMarker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14) == 26);
	cout << findMarker(input, 14) << endl;
}