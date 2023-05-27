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

enum Res { ORE, CLAY, OBSIDIAN, GEODE, ORE_ROBOT, CLAY_ROBOT, OBSIDIAN_ROBOT, GEODE_ROBOT, SKIP };

using Recipe = map<Res, int>;
using Resources = array<short, 8>; // this is the Node type
using Option = Res;
using State = Resources;
using Blueprint = map<Res, Recipe>;

const char *toString(const Res &res) {
	switch (res) {
		case Res::ORE: return "ore";
		case Res::CLAY: return "clay";
		case Res::OBSIDIAN: return "obs";
		case Res::GEODE: return "geode";
		case Res::ORE_ROBOT: return "R.ORE";
		case Res::CLAY_ROBOT: return "R.CLAY";
		case Res::OBSIDIAN_ROBOT: return "R.OBS";
		case Res::GEODE_ROBOT: return "R.GEODE";
		case Res::SKIP: return "skip";
	}
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

vector<Option> getOptions(const Blueprint &bp, const State &state) {
	vector<Option> result;
	bool canGeode = canApply(bp.at(Res::GEODE_ROBOT), state);
	bool canObs = canApply(bp.at(Res::OBSIDIAN_ROBOT), state);
	bool canOre = canApply(bp.at(Res::ORE_ROBOT), state);
	bool canClay = canApply(bp.at(Res::CLAY_ROBOT), state);

	// smart culling...
	if (canGeode) {
		result.push_back(Res::GEODE_ROBOT);
	}
	if (canObs) {
		result.push_back(Res::OBSIDIAN_ROBOT);
	}
	if (!canGeode && !canObs) {
		if (canOre && state[Res::ORE_ROBOT] < 10) {
			result.push_back(Res::ORE_ROBOT);
		}
		if (canClay && state[Res::CLAY_ROBOT] < 10) {
			result.push_back(Res::CLAY_ROBOT);
		}
	}
	// if we can't do both, we may want to hold off...
	if (!(canClay && canOre)) {
		result.push_back(Res::SKIP);
	}

	return result;
};

State applyOption(const Blueprint &bp, const State &state, const Option &opt) {
	State next = state; // make copy

	if (opt != Res::SKIP) {
		bool success = applyIfPossible(bp.at(opt), next);
	//	result.history += string_format("Bought: %s\n", toString(opt));
	//	cout << "After crafting an " << opt << " we have " << result.resources[opt] << endl;
		assert(success);
	}

	next[Res::ORE] += state[Res::ORE_ROBOT];
	next[Res::CLAY] += state[Res::CLAY_ROBOT];
	next[Res::OBSIDIAN] += state[Res::OBSIDIAN_ROBOT];
	next[Res::GEODE] += state[Res::GEODE_ROBOT];

	return next;
}

int search(const Blueprint &bp) {
	int it = 0;
	State start { 0 };
	start[Res::ORE_ROBOT] = 1;
	vector<State> open { start };
	vector<State> next;
	for (int minute = 1; minute <= 24; ++minute) {
		next.clear();

		while(!open.empty()) {
			State current = open.back();
			open.pop_back();
			it++;

			for (auto option: getOptions(bp, current)) {
				State newState = applyOption(bp, current, option);
				next.push_back(newState);
			}
		}
//		cout << "Minute " << minute << " Open set " << next.size() << endl;
		open = next;
	}
//	cout << "Total iterations: " << it << endl;
	int max = -1;
	for (const auto &state: open) {
		int val = state[Res::GEODE];
		if (val > max) {
			max = val;
		}
	}

	return max;
}

int solve1(const vector<Blueprint> &bps) {
	int sum = 0;
	for (int i = 0; i < bps.size(); ++i) {
		int value = search(bps[i]);
		sum += value * (i + 1);
		cout << "Blueprint " << i + 1 << " " << value << endl;
	}
	return sum;
}

int main() {
	auto testInput = readData("day19/test-input");
	assert(solve1(testInput) == 33);
	auto input = readData("day19/input");
	cout << solve1(input);
}