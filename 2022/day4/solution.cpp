//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include "../common/strutil.h"

using namespace std;

struct Range {
	int start;
	int end;
};

using RangePair = pair<Range, Range>;

ostream &operator<<(ostream &os, const RangePair &p) {
	os << p.first.start << "-" << p.first.end << ";" << p.second.start << "-" << p.second.end;
	return os;
}

auto parseInput(const string &fname) {
	vector<RangePair> result;
	ifstream fin(fname);
	string line;
	while(getline(fin, line)) {
		RangePair p;
		stringstream ss(line);
		auto ranges = split(line, ',');
		auto range1 = split(ranges[0], '-');
		p.first.start = stoi(range1[0]);
		p.first.end = stoi(range1[1]);
		auto range2 = split(ranges[1], '-');
		p.second.start = stoi(range2[0]);
		p.second.end = stoi(range2[1]);
		result.push_back(p);
	}
	fin.close();
	return result;
}

bool fullyContains(const RangePair &p) {
	return (p.first.start >= p.second.start && p.first.end <= p.second.end) ||
	       (p.second.start >= p.first.start && p.second.end <= p.first.end);
}

auto countContains(const vector<RangePair> &data) {
	return count_if(data.begin(), data.end(), [=](const RangePair &p){ return fullyContains(p); });
}

int main() {
	auto testInput = parseInput("test-input");
	assert(countContains(testInput) == 2);
	auto input = parseInput("input");
	cout << countContains(input) << '\n';
}