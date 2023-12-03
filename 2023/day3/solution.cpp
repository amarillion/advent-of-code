//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <functional>
#include "../common/map2d.h"
#include <ranges>

using namespace std;

using Grid = Map2D<char>;

bool isDigit(char ch) {
	return ch >= '0' && ch <= '9';
}

Grid parseInput(const string &fname) {
	ifstream fin(fname);
	string line;

	int id = 1;

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
	vector<PartNumber> result {};

	bool numberState = false;
	int current = 0;
	Point pos;
	int w = 1;
	for (int y = 0; y < grid.getDimMY(); ++y) {
		for (int x = 0; x < grid.getDimMX(); ++x) {
			// scan for numbers
			char ch = grid(x, y);
			int digit = ch - '0';
			if (isDigit(ch)) {
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
			else {
				if (numberState) {
					result.push_back(PartNumber{pos, w,current});
					numberState = false;
				}
			}
		}

		if (numberState) {
			result.push_back(PartNumber { pos, w, current });
			numberState = false;
		}
	}

	return result;
}

bool surroundingSymbol(const Grid &grid, const PartNumber &part) {
	int y = part.pos.y() - 1;
	int x = part.pos.x() - 1;
	int h = 3;
	int w = part.w + 2;

	for (int dx = 0; dx < w; ++dx) {
		for (int dy = 0; dy < h; ++dy) {
			if (grid.inBounds(x + dx, y + dy)) {
				char ch = grid.get(x + dx, y + dy);
				if (!isDigit(ch) && ch != '.') {
					return true;
				}
			}
		}
	}
	return false;
}

int solve1(const Grid &grid) {
	// extract numbers + positions
	// for each number, filter with a surrounding check
	auto parts = extractNumbers(grid);
//	auto hasSurroundingSymbol = [=](PartNumber &p){ return surroundingSymbol(grid, p); };
//	for (const auto &part : parts | std::views::filter(hasSurroundingSymbol)) {
//		cout << part.pos << ": " << part.value << " " << surroundingSymbol(grid, part) << endl;
//	}

	int sum = 0;
	for (const auto &part : parts) {
		if (surroundingSymbol(grid, part)) {
			sum += part.value;
		}
	}
	return sum;
}

int main() {
	auto testData = parseInput("test-input");
	assert(solve1(testData) == 4361);

	auto data = parseInput("input");
	cout << solve1(data) << endl;

	cout << "DONE" << endl;
}