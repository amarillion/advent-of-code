//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include "../common/strutil.h"
#include <cmath>

using namespace std;

vector<int> processNumbers(const string &arg) {
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

	int i = 1;
	while(getline(fin, line)) {
		if (line.length() == 0) continue;

		string cardContents = line.substr(line.find(':') + 1, line.length());
		int pos = cardContents.find('|');
		string havingStr = cardContents.substr(0, pos - 1);
		vector<int> having = processNumbers(havingStr);

		string winningStr = cardContents.substr(pos + 1, cardContents.length());
		vector<int> winning = processNumbers(winningStr);

		vector<int> intersection;
		set_intersection(having.begin(), having.end(), winning.begin(), winning.end(), back_inserter(intersection));

		result.push_back(intersection.size());
	}

	return result;
}

int solve1(const string &fname) {
	vector<int> data = process(fname);
	int result = 0;
	int i = 1;
	for (int d: data) {
		int points = d == 0 ? 0 : 1 << (d-1);
		cout << "Card: " << i++ << " intersection: " << d << " points: " << points << endl;
		result += points;
	}
	return result;
}

int solve2(const string &fname) {
	int result = 0;
	vector<int> data = process(fname);

	vector<int> counts;

	for (int d: data) {
		counts.push_back(1);
	}

	for (int i = 0; i < data.size(); ++i) {
		int matches = data[i];
		int multiplier = counts[i];

//		cout << "Card " << i + 1 << " count: " << counts[i] << endl;
		result += counts[i];
		for (int j = i + 1; j < min((int)data.size(), i + matches + 1); ++j) {
//			cout << "Adding " << multiplier  << " to " << j << endl;
			counts[j] += (multiplier);
		}
	}

	return result;
}

int main() {
	assert(solve1("test-input") == 13);
	assert(solve2("test-input") == 30);
	cout << solve1("input") << endl; // 21158
	cout << solve2("input") << endl; // 6050769
	cout << "DONE" << endl;
}