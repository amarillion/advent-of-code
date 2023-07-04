//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

using Grid = Map2D<char>;

enum class Orientation {
	EAST, SOUTH, WEST, NORTH
};

struct Face {
	Face() {}
	Face(Point _uv) : uv(_uv) {}

	Point uv = { 0, 0 };
	Face* neighbor[4] = { nullptr, nullptr, nullptr, nullptr };
	int deltaOrientation[4] = { -1, -1, -1, -1 };
};

struct Map {
	int tileSize;
	Face faces[6];

	void link(int src, int dest, int direction, int deltaOrientation = -1, bool reverse = true) {
		assert(faces[src].neighbor[direction] == nullptr); // double writes should not happen
		faces[src].neighbor[direction] = &faces[dest];
		faces[src].deltaOrientation[direction] = deltaOrientation < 0 ? 0 : deltaOrientation;
		if (reverse) {
			int reverseDirection;
			int reverseOrientation;
			switch (deltaOrientation) {
				case 0: case -1: reverseDirection = (direction + 2) % 4; reverseOrientation = deltaOrientation; break;
				case 2: reverseDirection = direction; reverseOrientation = deltaOrientation; break;
				case 3: case 1: reverseDirection = (direction + deltaOrientation) % 4; reverseOrientation = 4-deltaOrientation; break;
				default: assert(false);
			}
			link(dest, src, reverseDirection, reverseOrientation, false);

//			repr(std::cout);
		}
	}

	void repr(std::ostream &os) {
		for (int f = 0; f < 6; ++f) {
			os << "Face: " << char(f + 'A') << ": ";
			for (int i = 0; i < 4; ++i) {
				Face *face = faces[f].neighbor[i];
				if (face) {
					os << char((face - faces) + 'A');
				}
				else {
					os << '-';
				}
			}
			os << std::endl;
		}
	}
};

struct State {
	Point pos;
	const Face *face;
	int facing = 0;
};

inline bool operator==(const State& lhs, const State& rhs) {
	return
		lhs.pos == rhs.pos &&
		lhs.face == rhs.face &&
		lhs.facing == rhs.facing;
}

void move(Grid &grid, const Map &map, State &state, int num);

void testMap(Map &map, bool cube = true) {
	// check that each face has 4 exits.
	for (const auto &face : map.faces) {
		for (const auto neighbor: face.neighbor) {
			assert(neighbor != nullptr);
		}
	}

	if (!cube) return;

	// create an empty map;
	Grid grid { map.tileSize * 4, map.tileSize * 4, ' ' };
	for (const auto &face : map.faces) {
		for (int x = 0; x < map.tileSize; ++x) {
			for (int y = 0; y < map.tileSize; ++y) {
				Point pos = face.uv + Point(x, y);
				grid[pos] = '.';
			}
		}
	}

	for (int facing = 0; facing < 3; ++facing) {
		State init{{0, 0}, &map.faces[0], facing};
		State state = init;

		// try moving on the map from start all the way around the cube in one direction
		for (int i = 0; i < 4; ++i) {
			move(grid, map, state, map.tileSize);
		}
		assert(init == state); // should arrive back where we started
	}
}

Map initTest(bool isCube) {
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
	faces[A] = Face({ 8, 0 } );
	faces[B] = Face({ 0, 4 } );
	faces[C] = Face({ 4, 4 } );
	faces[D] = Face({ 8, 4 } );
	faces[E] = Face({ 8, 8 } );
	faces[F] = Face({12, 8 } );

	result.link(A, D, 1);
	result.link(B, C, 0);
	result.link(C, D, 0);
	result.link(D, E, 1);
	result.link(E, F, 0);

	if (isCube) {
		result.link(A, F, 0, 2);
		result.link(A, B, 3, 2);
		result.link(A, C, 2, 1);
		result.link(B, E, 1, 2);
		result.link(C, E, 1, 1);
		result.link(D, F, 0, 3);
		result.link(F, B, 1, 1);
	}
	else {
		result.link(A, A, 0);
		result.link(B, B, 1);
		result.link(C, C, 1);
		result.link(F, F, 1);
		result.link(D, B, 0);
		result.link(E, A, 1);
		result.link(F, E, 0);
	}

	testMap(result, isCube);
	return result;
}

Map initMain(bool isCube) {
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

	faces[A] = Face({ 50, 0 } );
	faces[B] = Face({ 100, 0 } );
	faces[C] = Face({ 50, 50 } );
	faces[D] = Face({ 0, 100 } );
	faces[E] = Face({ 50, 100 } );
	faces[F] = Face({0, 150 } );

	result.link(A, B, 0);
	result.link(A, C, 1);
	result.link(C, E, 1);
	result.link(D, E, 0);
	result.link(D, F, 1);

	if (isCube) {
		result.link(A, D, 2, 2);
		result.link(A, F, 3, 3);
		result.link(B, E, 0, 2);
		result.link(B, C, 1, 3);
		result.link(B, F, 3);
		result.link(C, D, 2, 1);
		result.link(E, F, 1, 3);
	}
	else {
		result.link(B, A, 0);
		result.link(B, B, 1);
		result.link(C, C, 0);
		result.link(E, D, 0);
		result.link(E, A, 1);
		result.link(F, F, 0);
		result.link(F, D, 1);
	}
	testMap(result, false);
	return result;
}

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

Point delta[4] {
	{ 1, 0 },
	{ 0, 1 },
	{ -1, 0 },
	{ 0, -1 }
};

void turn(Grid &grid, State &state, char dir) {
	if (dir == 'L') {
		state.facing = (state.facing + 3) % 4;
	}
	else if (dir == 'R') {
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

		newPos += delta[state.facing];
		int newFacing = state.facing;

		const Face *newFace = state.face;

		if (newPos.x() >= map.tileSize || newPos.x() < 0 || newPos.y() >= map.tileSize || newPos.y() < 0) {
			// next face...
			newFace = state.face->neighbor[state.facing];
			newPos.mod(Point{ map.tileSize, map.tileSize });

			int deltaOrientation = state.face->deltaOrientation[state.facing];
			if (deltaOrientation > 0) {
				newFacing = (newFacing + 4 - deltaOrientation) % 4;

				// rotate around pivot. TODO: extract function...
				int siz1 = map.tileSize - 1;
				switch (deltaOrientation) {
					case 1: newPos = { newPos.y(), siz1 - newPos.x() }; break;
					case 2: newPos = { siz1 - newPos.x(), siz1 - newPos.y() }; break;
					case 3: newPos = { siz1 - newPos.y(), newPos.x() }; break;
					default: break;
				}
			}
		}

		Point gridPos = newFace->uv + newPos;
		assert(grid[gridPos] != ' ');

		if (grid[gridPos] == '#') {
			break; // reached wall
		}

		state.pos = newPos;
		state.face = newFace;
		state.facing = newFacing;
	}

//	grid.repr(cout, ""); cout << endl;
}

State walk(Grid &grid, const Map &map, const string &route) {
	string remain = route;
	State state { { 0, 0 }, &map.faces[0],0 };

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

	auto state = walk(grid, map, route);

	grid.repr(cout, "");
	cout << endl;

	cout << state.pos << " - " << state.facing << endl;

	auto gridPos = state.face->uv + state.pos;
	int result = (gridPos.y() + 1) * 1000 + (gridPos.x() + 1) * 4 + state.facing;
	return result;
}

int main() {
	Map testMap = initTest(false);
	assert(solve1("day22/test-input", testMap) == 6032);

	Map input = initMain(false);
	cout << solve1("day22/input", input) << endl; // 89224

	Map testMap2 = initTest(true);
	assert(solve1("day22/test-input", testMap2) == 5031);

	Map input2 = initMain(true);
	cout << solve1("day22/input", input2) << endl; // 136182
}