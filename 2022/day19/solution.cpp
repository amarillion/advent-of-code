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

enum Res { ORE, CLAY, OBSIDIAN, GEODE, ORE_ROBOT, CLAY_ROBOT, OBSIDIAN_ROBOT, GEODE_ROBOT };
using Recipe = map<Res, int>;

using Resources = array<short, 8>; // this is the Node type
using Option = Res;

struct State {
	Resources prev { 0, 0, 0, 0, 1, 0, 0, 0 };
	Resources resources { 0, 0, 0, 0, 1, 0, 0, 0 };
	short minute = 1;
//	string history;

	bool operator==(const State &other) const noexcept {
		return prev == other.prev && resources == other.resources && minute == other.minute;
	}

	// custom hash function
	size_t operator()(const State& state) const noexcept {
//		size_t hash = 5 * resources[0] + 7 * resources[1] + 11 * resources[2] + 13 * resources[3] + 17 * resources[4] +
//			   19 * resources[5]
//			   + 23 * resources[6] + 29 * resources[7] +
//			   31 * prev[0] + 37 * prev[1] + 39 * prev[2] + 41 * prev[3] + 43 * prev[4] + 47 * prev[5] +
//			   51 * prev[6] + 53 * prev[7] +
//			   57 * minute;
		std::hash<short> hasher;
		size_t result = 0;
		for(size_t i = 0; i < 8; ++i) {
			result = result * 31 + hasher(state.resources[i]); // ??
			result = result * 31 + hasher(state.prev[i]); // ??
		}
		result = result + 31 * hasher(state.minute);
		return result;
	};
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

vector<Option> getOptions(const Blueprint &bp, const State &state) {

//	if (state.minute < 5)  {
//		return vector<Option> { Res::ORE_ROBOT };
//	}
//	else if (state.minute < 8) {
//		return vector<Option> { Res::CLAY_ROBOT };
//	}
//	else if (state.minute < 10) {
//		return vector<Option> { Res::ORE_ROBOT };
//	}
//	else if (state.minute < 15) {
//		return vector<Option> { Res::CLAY_ROBOT, Res::OBSIDIAN_ROBOT };
//	}
//	else if (state.minute < 19) {
//		return vector<Option> { Res::CLAY_ROBOT, Res::OBSIDIAN_ROBOT };
//	}
//	else {
//		return vector<Option> { Res::OBSIDIAN_ROBOT, Res::GEODE_ROBOT };
//	}

	const Resources &resources = state.resources;
	const Resources &prev = state.prev;
	vector<Option> result;
	// it seems to be an extra restriction that we can't build two of the same robot in the same minute.
	if(resources[Res::ORE] < 12) {
		result.push_back(Res::ORE_ROBOT);
	}
	if (resources[Res::CLAY] < 28) {
		result.push_back(Res::CLAY_ROBOT);
	}
	if (resources[Res::CLAY_ROBOT] > 0) {
		result.push_back(Res::OBSIDIAN_ROBOT);
	}
	if (resources[Res::OBSIDIAN_ROBOT] > 0) {
		result.push_back(Res::GEODE_ROBOT);
	}
	return result;
};

const int MAX_MINUTES = 24;

int score(const State &s) {
	int minutesLeft = MAX_MINUTES - s.minute;
//	return
//			s.resources[GEODE] * 100 +
//			s.resources[GEODE_ROBOT] * minutesLeft * 16 +
//			s.resources[OBSIDIAN] * 1 +
//			s.resources[OBSIDIAN_ROBOT] * minutesLeft * 8 +
//			s.resources[CLAY] * 1 +
//			s.resources[CLAY_ROBOT] * minutesLeft * 4 +
//			s.resources[ORE] * 1 +
//			s.resources[ORE_ROBOT] * minutesLeft * 2;
	return
			s.resources[GEODE] * 100 +
			s.resources[GEODE_ROBOT] * 16 +
//			s.resources[OBSIDIAN] * 1 +
			s.resources[OBSIDIAN_ROBOT] * 8 +
//			s.resources[CLAY] * 1 +
			s.resources[CLAY_ROBOT] * 4 +
//			s.resources[ORE] * 1 +
			s.resources[ORE_ROBOT] * 2;
}

void advanceMinute(State &result) {
	// mining takes place after crafting, but with old robot counts.
	result.resources[Res::ORE] += result.prev[Res::ORE_ROBOT];
	result.resources[Res::CLAY] += result.prev[Res::CLAY_ROBOT];
	result.resources[Res::OBSIDIAN] += result.prev[Res::OBSIDIAN_ROBOT];
	result.resources[Res::GEODE] += result.prev[Res::GEODE_ROBOT];
//		cout << "Minute: " << result.minute << ", " <<
//			result.resources[Res::ORE] << " Ore, " <<
//			result.resources[Res::CLAY] << " Clay, " <<
//			result.resources[Res::OBSIDIAN] << " Obsidian, and " <<
//			result.resources[Res::GEODE] << " Geodes. Score: " << score(state) << endl;
	result.minute++;
//	result.history += string_format("Minute %i\n", result.minute);
	result.prev = result.resources;
}

State applyOption(const Blueprint &bp, const State &state, const Option &opt) {
	// option is: next I'll buy X, waiting as many minutes as necessary...
	State result = state; // make copy

//	cout << "Mining until we can buy " << opt << endl;
	while (!canApply(bp.at(opt), result.resources)) {
		advanceMinute(result);
		if (result.minute > MAX_MINUTES) {
			return result; // end reached.
		}
	}

	bool success = applyIfPossible(bp.at(opt), result.resources);
//	result.history += string_format("Bought: %s\n", toString(opt));
//	cout << "After crafting an " << opt << " we have " << result.resources[opt] << endl;
	assert(success);

	advanceMinute(result);

	return result;
}

bool greedyCmp(const State &a, const State &b) {
	return score(a) < score(b);
}

int search(const Blueprint &bp) {
	vector<State> open { {} };
	int max = -1;
	int maxIt = 100'000'000;
	int it = 0;
	unordered_set<State, State> visited { {} };
	while(!open.empty()) {

		pop_heap(open.begin(), open.end(), greedyCmp);
		State current = open.back();
		open.pop_back();

		if (++it == maxIt) {
			cout << "Max iterations reached " << endl;
			return max; // NOTE - if there are lots of branches at the start, may not have set max at all...
		}

		if (current.minute >= MAX_MINUTES) {
			int val = current.resources[GEODE];
			if (val > max) {
				max = val;
//				cout << "new record: " << max << " at iteration " << it << endl;
//				cout << current.history << "=============================\n";
			}
		}
		else {
			for (auto option: getOptions(bp, current)) {
				State newState = applyOption(bp, current, option);

				if (!visited.contains(newState)) {
					open.push_back(newState);
					push_heap(open.begin(), open.end(), greedyCmp);
					visited.insert(newState);
				}
			}
		}
	}
//	cout << "Completed after " << it << " iterations." << endl;
	return max;
}

int getMaxRecursively(const Blueprint &bp, const State &state) {
	if (state.minute >= MAX_MINUTES) {
		return state.resources[GEODE];
	}
	else {
		// get max...
		int max = 0;
		for (auto option: getOptions(bp, state)) {
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

int solve1(const vector<Blueprint> &bps) {
	int sum = 0;
	for (int i = 0; i < bps.size(); ++i) {
		int value = search(bps[i]);
		sum += value * (i + 1);
		cout << "Blueprint " << i + 1 << " " << value << endl;
	}
	return sum;
}

/*
 * BIG misconception: you can only produce one robot per day, no matter which type?
 *
 * Maybe rewrite with this idea in mind?
 */

/*
 *
 * Current best solution:
Blueprint 1 0
Blueprint 2 0
Blueprint 3 0
Blueprint 4 0
Blueprint 5 0
Blueprint 6 0
Blueprint 7 0
Blueprint 8 0
Blueprint 9 9
Blueprint 10 4
Blueprint 11 3
Blueprint 12 4
Blueprint 13 3
Blueprint 14 0
Blueprint 15 0
Blueprint 16 4
Blueprint 17 8
Blueprint 18 7
Blueprint 19 3
Blueprint 20 4
Blueprint 21 0
Blueprint 22 0
Blueprint 23 15
Blueprint 24 12
Blueprint 25 6
Blueprint 26 3
Blueprint 27 2
Blueprint 28 0
Blueprint 29 0
Blueprint 30 13
2009
 But this answer is too low...
 */
int main() {
	auto testInput = readData("day19/test-input");
	assert(solve1(testInput) == 33);
	auto input = readData("day19/input");
//	cout << input << endl;
	cout << solve1(input);
	// answer 2009 is too low
}