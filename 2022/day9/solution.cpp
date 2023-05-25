//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <set>
#include <deque>

using namespace std;

struct Step {
	Point dir {0, 0};
	int num {0};
};

Step parseStep(const string &line) {
	Point dir;
	switch (line[0]) {
		case 'R': dir = Point(1, 0); break;
		case 'U': dir = Point(0, -1); break;
		case 'D': dir = Point(0, 1); break;
		case 'L': dir = Point(-1, 0); break;
		default: assert(false);
	}
	int num = stoi(line.substr(2));
	return Step { dir, num };
}

// after: https://stackoverflow.com/questions/1903954/is-there-a-standard-sign-function-signum-sgn-in-c-c
template <typename T> int sgn(T val) {
	return (T(0) < val) - (val < T(0));
}

size_t simulate(const string &fname, int nodes = 2) {
	deque<Point> state;
	size_t tail = nodes - 1;
	ifstream infile(fname);
	string line;
	set<Point> visited;

	// init state
	for (int i = 0; i < nodes; ++i) {
		state.push_back(Point(0,0));
	}

	visited.insert(state[tail]);

	while(getline(infile, line)) {
		Step step = parseStep(line);

		for (int i = 0; i < step.num; ++i) {
			// head movement
			state[0] += step.dir;
			// tail movement

			for (int j = 1; j < state.size(); ++j) {
				Point delta = state[j-1] - state[j];
				bool hasTwo = (abs(delta.x()) >= 2) || (abs(delta.y()) >= 2);
				if (hasTwo) {
					Point move = Point(sgn(delta.x()), sgn(delta.y()));
					state[j] += move;
				}
			}
			visited.insert(state[tail]);
		}
	}

	return visited.size();
}

int main() {
	assert(simulate("test-input") == 13);
	assert(simulate("test-input", 10) == 1);
	cout << simulate("input") << '\n';
	cout << simulate("input", 10) << '\n';
}