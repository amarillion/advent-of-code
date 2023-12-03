//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include "../common/map2d.h"
#include "../common/area.h"

using namespace std;

using Grid = Map2D<char>;

bool isDigit(char ch) {
	return ch >= '0' && ch <= '9';
}

Grid parseInput(const string &fname) {
	ifstream fin(fname);
	string line;

	vector<string> lines;
	while(getline(fin, line)) {
		lines.push_back(line);
	}
	int height = lines.size();
	int width = lines[0].length();

	Grid result { width, height };

	for(int y = 0; y < height; ++y) {
		for(int x = 0; x < width; ++x) {
			result(x, y) = lines[y][x];
		}
	}
	return result;
}

struct PartNumber {
	Point pos;
	int w;
	int value;
};

vector<PartNumber> extractNumbers(const Grid &grid) {
	vector<PartNumber> result;
	bool numberState = false;
	int current = 0;
	Point pos;
	int w = 1;
	// NOTE: callback is stateful and relies on x being in the inner loop, y in the outer loop.
	forArea(0, 0, grid.getDimMX(), grid.getDimMY(), [&](int x, int y){
		char ch = grid(x, y);
		bool isEol = x == grid.getDimMX() - 1;
		if (isDigit(ch)) {
			int digit = ch - '0';
			if (!numberState) {
				current = digit;
				numberState = true;
				pos = { x, y };
				w = 1;
			}
			else {
				w++;
				current = current * 10 + digit;
			}
		}
		if (!isDigit(ch) || isEol) {
			if (numberState) {
				result.push_back(PartNumber{pos, w, current});
				numberState = false;
			}
		}
	});
	return result;
}

bool surroundingSymbol(const Grid &grid, const PartNumber &part) {
	auto isSymbol = [&](int x, int y){
		if (!grid.inBounds(x, y)) return false;
		char ch = grid.get(x, y);
		return (!isDigit(ch) && ch != '.');
	};
	return someArea(part.pos.x() - 1, part.pos.y() - 1, part.w + 2, 3, isSymbol);
}

int solve1(const Grid &grid, const vector<PartNumber> &parts) {
	int sum = 0;
	for (const auto &part : parts) {
		if (surroundingSymbol(grid, part)) {
			sum += part.value;
		}
	}
	return sum;
}

bool isAdjacent(const Point &pos, const PartNumber &part) {
	return
		pos.x() >= part.pos.x() - 1 &&
		pos.y() >= part.pos.y() - 1 &&
		pos.x() <= part.pos.x() + part.w &&
		pos.y() <= part.pos.y() + 1;
}

vector<PartNumber> findAdjacentParts(const Point &pos, const vector<PartNumber> &parts) {
	vector<PartNumber> result;
	copy_if(parts.begin(), parts.end(), back_inserter(result), [=](PartNumber n){ return isAdjacent(pos, n); });
	return result;
}

long solve2(const Grid &grid, const vector<PartNumber> &parts) {
	long result = 0;
	forArea(0, 0, grid.getDimMX(), grid.getDimMY(), [&](int x, int y) {
		char ch = grid.get(x, y);
		if (ch == '*') {
			Point p{x, y};
			auto adj = findAdjacentParts(p, parts);
			if (adj.size() == 2) {
				result += (adj[0].value * adj[1].value);
			}
		}
	});
	return result;
}

int main() {
	auto testData = parseInput("test-input");
	auto testParts = extractNumbers(testData);
	assert(solve1(testData, testParts) == 4361);
	assert(solve2(testData, testParts) == 467835);

	auto data = parseInput("input");
	auto parts = extractNumbers(data);
	assert(solve1(data, parts) == 521515);
	assert(solve2(data, parts) == 69527306);
	cout << "DONE" << endl;
}