//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>

using namespace std;

string readInput(const string &fname) {
	ifstream infile(fname);
	string line;
	getline(infile, line);
	return line;
}

int findMarker(const string &input) {
	for (int pos = 0; pos < input.length() - 4; ++pos) {
		auto s = input.substr(pos, pos + 4);
		bool dup = false;
		for (int i = 0; i < 4; ++i) {
			for (int j = i + 1; j < 4; ++j) {
				if (s[i] == s[j]) dup = true;
			}
		}
		if (!dup) return pos + 4;
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
}