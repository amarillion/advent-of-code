//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <functional>
#include <sstream>
#include <algorithm>
#include <map>

using namespace std;

// trim from start
static inline std::string &ltrim(std::string &s) {
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
        return s;
}

static inline std::vector<std::string> split(const std::string &s, char delim)
{
	std::vector<std::string> result;
	std::stringstream ss;
	ss.str(s);
	std::string item;

	while (std::getline(ss, item, delim))
	{
		result.push_back (item);
	}
	return result;
}

using Draw = map<string, int>;
using Game = vector<Draw>;
using Data = vector<Game>;

Data parseInput(const string &fname) {
	Data result;
	ifstream fin(fname);
	string line;

	while(getline(fin, line)) {
		auto gameStr = split(line, ':');
		Game resultGame;
		for (auto draw: split(ltrim(gameStr[1]), ';')) {
			Draw resultDraw;
			resultDraw["red"] = 0;
			resultDraw["green"] = 0;
			resultDraw["blue"] = 0;
			for (auto colorGroup: split(draw, ',')) {
				auto colorData = split(ltrim(colorGroup), ' ');
				resultDraw[colorData[1]] = stoi(colorData[0]);
			}
			resultGame.push_back(resultDraw);
		}
		result.push_back(resultGame);
	}

	return result;
}

int sumPossible(const Data &data) {
	int sum = 0;
	int id = 1;
	for (auto &game: data) {
		bool possible = true;
		for (auto &draw: game) {
			int red = draw.at("red");
			int green = draw.at("green");
			int blue = draw.at("blue");
			if (red > 12 || green > 13 || blue > 14) {
				possible = false;
			}
		}
		if (possible) {
			sum += id;
		}
		id++;
	}
	return sum;
}

int main() {
	auto data = parseInput("test-input");
	assert(sumPossible(data) == 8);
	cout << sumPossible(parseInput("input"));
}