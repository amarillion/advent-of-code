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
	result.push_back(0); // 0th cycle...
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

int solve1(vector<int> data) {
	int sum = 0;
	for (int i = 20; i <= 220; i += 40) {
		cout << i << ": " << data[i] << endl;
		sum += data[i] * i;
	}
	return sum;
}

int main() {
	assert(solve1(simulate("day10/test-input")) == 13140);
	cout << solve1(simulate("day10/input"));
}