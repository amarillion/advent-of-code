//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/map2d.h"
#include "../common/point.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <set>

using namespace std;

Map2D<short> readGrid(const string &fname) {
	string line;
	vector<string> lines;
	ifstream infile(fname);
	while(getline(infile, line)) {
		lines.push_back(line);
	}

	size_t w = lines[0].length();
	size_t h = lines.size();
	Map2D<short> result(w, h);
	for (int y = 0; y < h; ++y) {
		string &row = lines[y];
		for (int x = 0; x < w; ++x) {
			result(x, y) = (row[x] - '0');
		}
	}
	return result;
}

template<typename T>
ostream &operator<<(ostream &os, const Map2D<T> &map) {
	for (int y = 0; y < map.getDimMY(); ++y) {
		bool rowFirst = true;
		for (int x = 0; x < map.getDimMX(); ++x) {
			if (rowFirst) { rowFirst = false; } else { os << ", "; }
			os << map(x, y);
		}
		os << '\n';
	}
	return os;
}

void scan(Point start, Point delta, const Map2D<short> &grid, set<Point> &result) {
	Point pos = start;
	int min = -1;
	while(grid.inBounds(pos)) {
		if (grid[pos] > min) {
			min = grid[pos];
			result.insert(pos);
		}
		pos += delta;
	}
}

int countVisible(const Map2D<short> &grid) {
	set<Point> result;

	for (int x = 0; x < grid.getDimMX(); ++x) {
		scan(Point(x, 0), Point(0, 1), grid, result);
		scan(Point(x, grid.getDimMY()-1), Point(0, -1), grid, result);
	}

	for (int y = 0; y < grid.getDimMY(); ++y) {
		scan(Point(0, y), Point(1, 0), grid, result);
		scan(Point(grid.getDimMX()-1, y), Point(-1, 0), grid, result);
	}

	return result.size();
}

int scan2(Point start, Point delta, const Map2D<short> &grid) {
	Point pos = start;
	int count = 0;
	int min = grid[pos];
	pos += delta;
	while(grid.inBounds(pos)) {
		count++;
		if (grid[pos] < min) {
			pos += delta;
		}
		else {
			break;
		}
	}
	return count;
}

int getScenicScore(const Point &p, const Map2D<short> &grid) {
	return scan2(p, Point(0, 1), grid) *
			scan2(p, Point(0, -1), grid) *
			scan2(p, Point(1, 0), grid) *
			scan2(p, Point(-1, 0), grid);
}


int getMaxScenicScore(const Map2D<short> &grid) {
	int max = 0;
	for(int x = 0; x < grid.getDimMX(); ++x) {
		for(int y = 0; y < grid.getDimMY(); ++y) {
			int score = getScenicScore(Point(x, y), grid);
			if (score > max) { max = score; }
		}
	}
	return max;
}

int main() {
	Map2D<short> testInput = readGrid("day8/test-input");
	assert(countVisible(testInput) == 21);
	assert(getMaxScenicScore(testInput) == 8);
	Map2D<short> input = readGrid("day8/input");
	cout << countVisible(input) << endl;
	cout << getMaxScenicScore(input) << endl;
}