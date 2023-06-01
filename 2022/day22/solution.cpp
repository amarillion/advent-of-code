//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>
#include <unordered_set>

using namespace std;

using Grid = Map2D<char>;

Grid readMap(istream &is) {
	vector<string> buffer;
	string line;
	int width = 0;
	while(getline(is, line)) {
		if (line == "") break;
		if (line.length() > width) { width = line.length(); }
		buffer.push_back(line);
	}
	int height = buffer.size();
	Grid result { width, height };
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			const auto &row = buffer[y];
			char val = (x >= row.length()) ? ' ' : row[x];
			result(x, y) = val;
		}
	}
	return result;
}

const char *facingChar = ">v<^";
struct State {
	Point delta;
	Point pos;
	int facing = 0;
};

void turn(Grid &grid, State &state, char dir) {
	if (dir == 'L') {
		Point delta2(state.delta.y(), -state.delta.x());
		state.delta = delta2;
		state.facing = (state.facing + 3) % 4;
	}
	else if (dir == 'R') {
		Point delta2(-state.delta.y(), state.delta.x());
		state.delta = delta2;
		state.facing = (state.facing + 1) % 4;
	}
	else {
		assert(false);
	}
	grid[state.pos] = facingChar[state.facing];
}

void move(Grid &grid, State &state, int num) {
	for (int i = 0; i < num; ++i) {
//		grid.repr(cout, "");

		Point newPos = state.pos;
		do {
			newPos += state.delta;
			newPos.mod(Point{ (int)grid.getDimMX(), (int)grid.getDimMY() });
		} while (grid[newPos] == ' ');

		if (grid[newPos] == '#') {
			break; // reached wall
		}

		state.pos = newPos;
		if (grid[state.pos] != ' ') grid[state.pos] = facingChar[state.facing];
	}
}

State walk(Grid &grid, const string &route) {
	string remain = route;
	State state { {1, 0}, { 0, 0 }, 0 };
	// move to start
	move(grid, state, 1);

	while (remain.length() > 0) {
		if (remain[0] == 'R' || remain[0] == 'L') {
			turn(grid, state, remain[0]);
			remain = remain.substr(1);
		}
		else {
			int num = stoi(remain);
			move(grid, state, num);
			string str = string_format("%i", num);
			remain = remain.substr(str.length());
		}
	}

	return state;
}

int solve1(const string &fname) {
	ifstream infile(fname);
	auto grid = readMap(infile);

	string route;
	getline(infile, route);
	cout << route << endl;

	auto state = walk(grid, route);

	grid.repr(cout, "");
	cout << endl;

	cout << state.pos << " - " << state.facing << endl;

	int result = (state.pos.y() + 1) * 1000 + (state.pos.x() + 1) * 4 + state.facing;
	cout << result << endl;
	return result;
}

int main() {
//	assert(solve1("day22/test-input") == 6032);
	cout << solve1("day22/input") << endl;
}