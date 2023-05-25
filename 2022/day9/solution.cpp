//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <set>

using namespace std;

struct State {
	Point head {0, 0};
	Point tail {0, 0 };
};

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

size_t simulate(const string &fname) {
	State state;
	ifstream infile(fname);
	string line;
	set<Point> visited;

	visited.insert(state.tail);

	while(getline(infile, line)) {
		Step step = parseStep(line);

		for (int i = 0; i < step.num; ++i) {
			// head movement
			state.head += step.dir;
			// tail movement

			Point delta = state.head - state.tail;
			bool hasTwo = (abs(delta.x()) >= 2) || (abs(delta.y()) >= 2);
			if (hasTwo) {
				Point move = Point(sgn(delta.x()), sgn(delta.y()));
				state.tail += move;
			}

			visited.insert(state.tail);
		}
	}

	return visited.size();
}

int main() {
	assert(simulate("day9/test-input") == 13);
	cout << simulate("day9/input");
}