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

template <typename T, T DefaultValue = T(0)>
class SparseGrid  {
private:
	map<Point, T> data;
	T defaultValue = DefaultValue;
	Point _min;
	Point _max;
	bool first = true;
public:
	const Point &min() {
		return _min;
	}

	const Point &max() {
		return _max;
	}

	const T& operator[](const Point &p) const {
		if (data.contains(p)) {
			return data.at(p);
		}
		else {
			return defaultValue;
		}
	}

	void set(Point &p, const T &value) {
		// TODO: if value == defaultValue, remove from sparse grid to save space.
		if (first) {
			_min = p;
			_max = p;
			first = false;
		}
		else {
			_min.x(std::min(_min.x(), p.x()));
			_min.y(std::min(_min.y(), p.y()));
			_max.x(std::max(_max.x(), p.x()));
			_max.y(std::max(_max.y(), p.y()));
		}
		data[p] = value;
	}

	void toStream(ostream &os, const string &cellSep = "", const string &lineTerm = "\n") {
		for (int y = _min.y(); y <= _max.y(); ++y) {
			bool firstCol = true;
			for (int x = _min.x(); x <= _max.x(); ++x) {
				if (firstCol) {
					firstCol = false;
				}
				else {
					os << cellSep;
				}
				os << (*this)[Point(x, y)];
			}
			cout << lineTerm;
		}

	}
};

using Grid = SparseGrid<char, '.'>;

vector<Point> parseLine(const string &line) {
	auto words = split(line, ' ');
	vector<Point> result;
	for (const auto &word : words) {
		if (word == "->") continue;
		auto coords = split(word, ',');
		result.push_back({stoi(coords[0]), stoi(coords[1])});
	}
	return result;
}

void drawLine(Grid &grid, const string &line) {
	vector<Point> corners = parseLine(line);

	Point current = corners[0];
	for (int i = 1; i < corners.size(); ++i) {
		Point delta = (corners[i] - corners[i-1]).sign();
		while (current != corners[i]) {
			grid.set(current, '#');
			current += delta;
		}
	}
	grid.set(current, '#');
}

auto readGrid(const string &fname) {
	string line;
	ifstream infile(fname);

	Grid grid;
	while (getline(infile, line)) {
		drawLine(grid, line);
	}
	return grid;
}

bool simulateSingleSand(Grid &grid, bool hasFloor, int floorLevel) {
	Point sand { 500, 0 };
	const Point down { 0, 1 };
	const Point downLeft { -1, 1 };
	const Point downRight { 1, 1 };

	if (grid[sand] == 'o') {
		return false; // input blocked.
	}

	while(true) {
		if (hasFloor) {
			if (sand.y() == floorLevel) {
				// come to rest.
				grid.set(sand, 'o');
				return true;
			}
		}
		else {
			if (sand.y() > grid.max().y()) {
				return false; // fell out the bottom
			}
		}

		// falling?
		if (grid[sand + down] == '.') {
			sand += down;
		}
		else if (grid[sand + downLeft] == '.') {
			sand += downLeft;
		}
		else if (grid[sand + downRight] == '.') {
			sand += downRight;
		}
		else {
			// come to rest.
			grid.set(sand, 'o');
			return true;
		}
	}
}

int simulateSand(Grid &grid, bool hasFloor) {
	int count = 0;
	int floorLevel = grid.max().y() + 1;
	while (simulateSingleSand(grid, hasFloor, floorLevel)) {
		count++;
	}
	grid.toStream(cout);
	cout << endl;
	return count;
}

int solve(const string &fname, bool hasFloor) {
	auto grid = readGrid(fname);
	return simulateSand(grid, hasFloor);
}

int main() {
	assert(solve("day14/test-input", false) == 24);
	assert(solve("day14/test-input", true) == 93);

	cout << solve("day14/input", false) << endl;
	cout << solve("day14/input", true) << endl;
}