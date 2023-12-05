//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include "../common/strutil.h"
#include "../common/collectionutil.h"

using namespace std;

struct Range {
	long x;
	long w;

	bool inRange(long i) const {
		return i >= x && i < x + w;
	};

};

struct Mapping {
	Range range;
	long dest;
};

using MappingSet = vector<Mapping>;

long mapRange(const MappingSet &ranges, long in) {
	for (const auto &i : ranges) {
		if (i.range.inRange(in)) {
			return in - i.range.x + i.dest;
		}
	}
	return in;
}

struct Data {
	vector<long> seeds;
	vector<MappingSet> mappings;
};

vector<long> readLongs(const string &line) {
	cout << "Reading longs: " << line << endl;
	vector<long> result;
	for (const string &field: split(line, ' ')) {
		result.push_back(stol(field));
	}
	return result;
}

Data parse(const string &fname) {
	ifstream fin(fname);
	string line;
	Data result;

	getline(fin, line);
	result.seeds = readLongs(line.substr(7));

	getline(fin, line); // skip line
	getline(fin, line); // read header

	MappingSet mapping;
	while(getline(fin, line)) {
		if (line == "") {
			result.mappings.push_back(mapping);
			mapping = {};
			getline(fin, line); // read header
		}
		else {
			vector<long> data = readLongs(line);
			mapping.push_back({{data[1], data[2] }, data[0] });
		}
	}
	result.mappings.push_back(mapping);
	return result;
}

long solve1(const Data &data) {
	vector<long> current = data.seeds;
	cout << current << endl;
	for (const auto &mapping: data.mappings) {
		vector<long> next;
		transform(current.begin(), current.end(), back_inserter(next), [&](long i){ return mapRange(mapping, i); });
		current = next;
		cout << current << endl;
	}
	bool first = true;
	long min = 0;
	// TODO: min on vector...
	for (long i: current) {
		if (first || min > i) {
			min = i;
			first = false;
		}
	}
	return min;
}

long solve2(const Data &data) {
	long result = 0;
	return result;
}

int main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 35);
//	assert(solve2(testData) == 30);
	auto data = parse("input");
	cout << solve1(data) << endl;
	cout << "DONE" << endl;
}