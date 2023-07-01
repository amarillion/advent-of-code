//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>

// part 2: 10:46-11:40;

enum class Orientation {
	EAST, SOUTH, WEST, NORTH
};

struct Face {
	Point uv;
	Face* neighbor[4];
	int deltaOrientation[4];
};

struct Map {
	int tileSize;
	Face faces[6];
};

void link(Face *src, Face *dest, int orientation, bool reverse = true) {
	src->neighbor[orientation] = dest;
	link(dest, src, (orientation + 2) % 4, false);
}

Map initTest() {
	enum {
		A, B, C, D, E, F
	};
/*

 4x4

  A
BCD
  EF

 */
	Map result;
	result.tileSize = 4;
	Face *faces = result.faces;
	faces[A] = {
			{ 8, 0, },
			&faces[A], &faces[D], &faces[A], &faces[E], 0, 0, 0, 0
	};
	faces[B] = {
			{ 0, 4, },
			&faces[C], &faces[B], &faces[D], &faces[B], 0, 0, 0, 0
	};
	faces[C] = {
			{ 4, 4 },
			&faces[D], &faces[C], &faces[B], &faces[C], 0, 0, 0, 0
	};
	faces[D] = {
			{8, 4},
			&faces[B], &faces[E], &faces[C], &faces[A], 0, 0, 0, 0
	};
	faces[E] = {
			{8, 8},
			&faces[F], &faces[A], &faces[F], &faces[D], 0, 0, 0, 0
	};
	faces[F] = {
			{12, 8},
			&faces[E], &faces[F], &faces[E], &faces[F], 0, 0, 0, 0
	};
	return result;
}

Map initMain() {
	enum { A, B, C, D, E, F };

	Map result;
	result.tileSize = 50;
	Face *faces = result.faces;
	/*
50x50

 AB
 C
DE
F
*/
	faces[A] = {
			{50, 0},
			&faces[B], &faces[C], &faces[B], &faces[E], 0, 0, 0, 0
	};
	faces[B] = {
			{100, 0},
			&faces[A], &faces[B], &faces[A], &faces[B], 0, 0, 0, 0
	};
	faces[C] = {
			{50, 50},
			&faces[C], &faces[E], &faces[C], &faces[A], 0, 0, 0, 0
	};
	faces[D] = {
			{0, 100},
			&faces[E], &faces[F], &faces[E], &faces[F], 0, 0, 0, 0
	};
	faces[E] = {
			{50, 100},
			&faces[D], &faces[A], &faces[D], &faces[C], 0, 0, 0, 0
	};
	faces[F] = {
			{0, 150},
			&faces[F], &faces[D], &faces[F], &faces[D], 0, 0, 0, 0
	};
	return result;
}


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
	const Face *face;
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
	Point gridPos = state.face->uv + state.pos;
	grid[gridPos] = facingChar[state.facing];
}

void move(Grid &grid, const Map &map, State &state, int num) {
	for (int i = 0; i < num; ++i) {
		grid[state.face->uv + state.pos] = facingChar[state.facing];

		Point newPos = state.pos;

		newPos += state.delta;

		const Face *newFace = state.face;

		if (newPos.x() >= map.tileSize || newPos.x() < 0 || newPos.y() >= map.tileSize || newPos.y() < 0) {
			// next face...
			newFace = state.face->neighbor[state.facing];
			newPos.mod(Point{ map.tileSize, map.tileSize });
		}

		Point gridPos = newFace->uv + newPos;
		assert(grid[gridPos] != ' ');

		if (grid[gridPos] == '#') {
			break; // reached wall
		}

		state.pos = newPos;
		state.face = newFace;
	}
}

State walk(Grid &grid, const Map &map, const string &route) {
	string remain = route;
	State state { {1, 0}, { 0, 0 }, &map.faces[0],0 };

	while (remain.length() > 0) {
		if (remain[0] == 'R' || remain[0] == 'L') {
			turn(grid, state, remain[0]);
			remain = remain.substr(1);
		}
		else {
			int num = stoi(remain);
			move(grid, map,state, num);
			string str = string_format("%i", num);
			remain = remain.substr(str.length());
		}
	}

	return state;
}

int solve1(const string &fname, const Map &map) {
	ifstream infile(fname);
	auto grid = readMap(infile);

	string route;
	getline(infile, route);
	cout << route << endl;

	auto state = walk(grid, map, route);

	grid.repr(cout, "");
	cout << endl;

	cout << state.pos << " - " << state.facing << endl;

	auto gridPos = state.face->uv + state.pos;
	int result = (gridPos.y() + 1) * 1000 + (gridPos.x() + 1) * 4 + state.facing;
	cout << result << endl;
	return result;
}

int main() {
	Map testMap = initTest();
	assert(solve1("day22/test-input", testMap) == 6032);

	Map input = initMain();
	cout << solve1("day22/input", input) << endl; // 89224
}