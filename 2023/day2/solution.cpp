//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out "$@"; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <functional>
#include <map>
#include "../common/strutil.h"
#include <numeric> // accumulate, the C++ equivalent for reduce.

using namespace std;

using Draw = map<string, int>;
struct Game {
	int id;
	vector<Draw> draws;
};
using Data = vector<Game>;

Data parseInput(const string &fname) {
	Data result;
	ifstream fin(fname);
	string line;

	int id = 1;
	while(getline(fin, line)) {
		auto gameStr = split(line, ':');
		Game resultGame { id++, {} };
		for (auto draw: split(ltrim(gameStr[1]), ';')) {
			Draw resultDraw;
			for (auto colorGroup: split(draw, ',')) {
				auto colorData = split(ltrim(colorGroup), ' ');
				resultDraw[colorData[1]] = stoi(colorData[0]);
			}
			resultGame.draws.push_back(resultDraw);
		}
		result.push_back(resultGame);
	}

	return result;
}

int maxColor(const Game &game, const string &color) {
	return accumulate(
		game.draws.begin(), game.draws.end(), 0,
		[=](int acc, const Draw &draw){ return max(acc, draw.contains(color) ? draw.at(color) : 0); }
	);
}

int ifPossible(int acc, const Game &game) {
	if (
		maxColor(game, "red") <= 12 &&
		maxColor(game, "green") <= 13 &&
		maxColor(game, "blue") <= 14
	) {
		return acc + game.id;
	}
	return acc;
}

int sumPossible(const Data &data) {
	return accumulate(data.begin(), data.end(), 0, ifPossible);
}

int sumPower(const Data &data) {
	return accumulate(data.begin(), data.end(), 0,
  []( int acc, const Game &g) {
	  return acc + maxColor(g, "red") * maxColor(g, "green") * maxColor(g, "blue");
  });
}

int main(int argc, char *argv[]) {
	assert(argc == 2 && "Expected one argument: input file");
	auto data = parseInput(argv[1]);
	cout << sumPossible(data) << endl;
	cout << sumPower(data) << endl;
}