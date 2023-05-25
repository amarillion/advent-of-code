//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/map2d.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

enum Res { ORE, CLAY, OBSIDIAN, GEODE, ORE_ROBOT, CLAY_ROBOT, OBSIDIAN_ROBOT, GEODE_ROBOT };
using Recipe = map<Res, int>;

using Resources = array<short, 8>; // this is the Node type
using Option = Res;

struct State {
	Resources prev { 0, 0, 0, 0, 1, 0, 0, 0 };
	Resources resources { 0, 0, 0, 0, 1, 0, 0, 0 };
	int minute = 1;
};

using Blueprint = map<Res, Recipe>;

ostream &operator<<(ostream &os, const Res &res) {
	switch (res) {
		case Res::ORE: os << "ore"; break;
		case Res::CLAY: os << "clay"; break;
		case Res::OBSIDIAN: os << "obs"; break;
		case Res::GEODE: os << "geode"; break;
		case Res::ORE_ROBOT: os << "R.ORE"; break;
		case Res::CLAY_ROBOT: os << "R.CLAY"; break;
		case Res::OBSIDIAN_ROBOT: os << "R.OBS"; break;
		case Res::GEODE_ROBOT: os << "R.GEODE"; break;
	}
	return os;
};
vector<Blueprint> readData(const string &fname) {
	vector<Blueprint> result;
	ifstream infile(fname);
	string line;
	while(getline(infile, line)) {
		regex re (R"(Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.)");
		smatch m;
		regex_match(line, m, re);

		Blueprint blueprint;
		blueprint[Res::ORE_ROBOT] = { { Res::ORE_ROBOT, 1 }, { Res::ORE, -stol(m[2]) } };
		blueprint[Res::CLAY_ROBOT] = { { Res::CLAY_ROBOT, 1 }, { Res::ORE, -stol(m[3]) } };
		blueprint[Res::OBSIDIAN_ROBOT] = { { Res::OBSIDIAN_ROBOT, 1 }, { Res::ORE, -stol(m[4]) },  { Res::CLAY, -stol(m[5]) } };
		blueprint[Res::GEODE_ROBOT] = { { Res::GEODE_ROBOT, 1 }, { Res::ORE, -stol(m[6]) },  { Res::OBSIDIAN, -stol(m[7]) } };
		result.push_back(blueprint);
	}
	return result;
}

bool canApply(const Recipe &r, const Resources &resources) {
	for(const auto &[k, v]: r) {
		if (v < 0) {
			int avail = resources[k];
			if (avail < -v) return false;
		}
	}
	return true;
}

bool applyIfPossible(const Recipe &r, Resources &resources) {
	if (canApply(r, resources)) {
		for(const auto &[k, v]: r) {
			resources[k] += v;
		}
		return true;
	}
	return false;
}

/*
int countProduct(const Recipe &rp, const Resources &resources) {
	int sum = 0;
	for (const auto &[k, v]: rp) {
		if (v > 0) {
			if (resources.contains(k)) {
				sum += resources.at(k) * v;
			}
		}
	}
	return sum;
}

void sortByProduct(Blueprint &bp, const Resources &resources) {
	sort(bp.begin(), bp.end(), [&](const Recipe &a, const Recipe &b){
		return countProduct(b, resources) - countProduct(a, resources);
	});
}
*/

vector<Option> getOptions(const Blueprint &bp, const Resources &resources) {
	return vector<Option> { Res::ORE_ROBOT, Res::CLAY_ROBOT, Res::OBSIDIAN_ROBOT, Res::GEODE_ROBOT };
};

const int MAX_MINUTES = 24;

State applyOption(const Blueprint &bp, const State &state, const Option &opt) {
	// option is: next I'll buy X, waiting as many minutes as necessary...
	State result = state; // make copy

//	cout << "Mining until we can buy " << opt << endl;
	while (!canApply(bp.at(opt), result.resources)) {

		// mining takes place after crafting, but with old robot counts.
		result.resources[Res::ORE] += result.prev[Res::ORE_ROBOT];
		result.resources[Res::CLAY] += result.prev[Res::CLAY_ROBOT];
		result.resources[Res::OBSIDIAN] += result.prev[Res::OBSIDIAN_ROBOT];
		result.resources[Res::GEODE] += result.prev[Res::GEODE_ROBOT];
//		cout << "After mining, you have: " <<
//			result.resources[Res::ORE] << " Ore, " <<
//			result.resources[Res::CLAY] << " Clay, " <<
//			result.resources[Res::OBSIDIAN] << " Obsidian, and " <<
//			result.resources[Res::GEODE] << " Geodes." << endl << endl;
		result.minute++;
		result.prev = result.resources;
//		cout << "== Minute " << result.minute << " ==\n";

		if (result.minute == MAX_MINUTES) {
			return result; // end reached.
		}
	}

	bool success = applyIfPossible(bp.at(opt), result.resources);
//	cout << "After crafting an " << opt << " we have " << result.resources[opt] << endl;
	assert(success);

	return result;
}

int getMaxRecursively(const Blueprint &bp, const State &state) {
	if (state.minute >= MAX_MINUTES) {
		return state.resources[GEODE];
	}
	else {
		// get max...
		int max = 0;
		for (auto option: getOptions(bp, state.resources)) {
			State newState = applyOption(bp, state, option);
			int result = getMaxRecursively(bp, newState);
			if (result > max) max = result;
		}
		return max;
	}
}

int simulate(const Blueprint &bp) {
	State state {};
	return getMaxRecursively(bp, state);
}

int main() {
	auto testInput = readData("day19/test-input");
	cout << testInput << endl;
	cout << "Blueprint1: " << simulate(testInput[0]) << endl;
	cout << "Blueprint2: " << simulate(testInput[1]) << endl;

	auto input = readData("day19/input");
//	cout << input << endl;
}