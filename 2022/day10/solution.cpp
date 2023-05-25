//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <set>

using namespace std;

vector<int> simulate(const string &fname) {
	string line;
	ifstream infile(fname);
	int x = 1;
	vector<int> result;
	while(getline(infile, line)) {
		if (line == "noop") {
			result.push_back(x); // one cycle
		}
		else if (startsWith("addx ", line)){
			result.push_back(x); // two cycles...
			result.push_back(x);
			int delta = stol(line.substr(5));
			x += delta;
		}
		else {
			assert(false);
		}
	}
	return result;
}

int solve1(const vector<int> &data) {
	int sum = 0;
	for (int i = 20; i <= 220; i += 40) {
		sum += data[i-1] * i;
	}
	return sum;
}

void render(ostream &os, const vector<int> &data) {
	for (int pos = 0; pos < 240; ++pos) {
		int xco = (pos % 40);
		int signal = data[pos];
		if (abs(signal - xco) <= 1) {
			cout << '#';
		}
		else {
			cout << '.';
		}
		if (pos % 40 == 39) os << '\n';
	}
}

int main() {
	auto testInput = simulate("day10/test-input");
	assert(solve1(testInput) == 13140);
	auto input = simulate("day10/input");
	cout << solve1(input) << '\n';

	render(cout, testInput);
	cout << '\n';
	render(cout, input);
}