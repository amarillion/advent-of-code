///usr/bin/env make -s ${0%%.cpp} CXXFLAGS="-g -Wall -Wextra -std=c++20 -O3" && exec ./${0%%.cpp} "$@"

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <cmath>

using namespace std;

vector<int> parseNumbers(const string &arg) {
	vector<int> result;
	for (int i = 1; i < arg.length(); i += 3) {
		auto s = arg.substr(i, 2);
		result.push_back(stoi(s));
	}
	sort(result.begin(), result.end());
	return result;
}

vector<int> process(const string &fname) {
	ifstream fin(fname);
	string line;
	vector<int> result;

	while(getline(fin, line)) {
		string cardContents = line.substr(line.find(':') + 1, line.length());

		int pos = cardContents.find('|');
		vector<int> having = parseNumbers(cardContents.substr(0, pos - 1));
		vector<int> winning = parseNumbers(cardContents.substr(pos + 1, cardContents.length()));

		vector<int> intersection;
		set_intersection(having.begin(), having.end(), winning.begin(), winning.end(), back_inserter(intersection));
		result.push_back(intersection.size());
	}
	return result;
}

int solve1(const vector<int> &data) {
	int result = 0;
	for (int d: data) {
		result += d == 0 ? 0 : 1 << (d-1);
	}
	return result;
}

int solve2(const vector<int> &matches) {
	int num = matches.size();
	vector<int> counts (num, 1);
	int result = 0;
	for (int i = 0; i < num; ++i) {
		int numCopies = counts[i];
		result += counts[i];
		for (int j = 0; j < matches[i]; ++j) {
			int followingCard = j + i + 1;
			if (followingCard >= num) break;
			counts[followingCard] += numCopies;
		}
	}
	return result;
}

int main(int argc, char *argv[]) {
	assert(argc == 2 && "Expected one argument: input file");
	auto data = process(argv[1]);
	cout << solve1(data) << endl;
	cout << solve2(data) << endl;
}