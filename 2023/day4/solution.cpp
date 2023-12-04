//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include "../common/strutil.h"

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

int solve1(const string &fname) {
	ifstream fin(fname);
	string line;

	int result = 0;

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


		int points = intersection.size() == 0 ? 0 : 1 << (intersection.size()-1);
		cout << "Card: " << i++ << " intersection: " << intersection.size() << " points: " << points << endl;

		result += points;
	}
	return result;
}

int main() {
	assert(solve1("test-input") == 13);

	cout << solve1("input") << endl;
	cout << "DONE" << endl;
}