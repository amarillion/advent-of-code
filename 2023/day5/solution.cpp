///usr/bin/env make -s ${0%%.cpp} CXXFLAGS="-g -Wall -Wextra -std=c++20 -O3" && exec ./${0%%.cpp} "$@"

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include "../common/strutil.h"
#include "../common/collectionutil.h"

using namespace std;

struct Bound {
	long x;
	long value;
};

struct Range {
	long x;
	long w;

	bool inRange(long i) const {
		return i >= x && i < x + w;
	};

};

ostream &operator<<(ostream &os, const Bound &b) {
	os << b.x << ':' << b.value;
	return os;
}

ostream &operator<<(ostream &os, const Range &r) {
	os << r.x << '-' << r.x + r.w;
	return os;
}

struct Mapping {
	Range range;
	long dest;
};

ostream &operator<<(ostream &os, const Mapping &m) {
	os << '{' << m.range << " delta " << m.dest << '}';
	return os;
}

using MappingSet = vector<Bound>;

long mapRange(const MappingSet &bounds, long in) {
	long offset = 0;
	for (const auto &b : bounds) {
		if (in > b.x) {
			offset = b.value;
		}
		else {
			break;
		}
	}
	return in + offset;
}

vector<Range> mapRange2(const MappingSet &bounds, Range in) {
	// take input range...

	// bounds:  0     |   |      |   |
	// range:           <----->
	//
	// bounds:  0     |   |        |   |
	// range:               <----->
	//
	vector<Range> result;
	Bound prev {0, 0};
	for (const auto &b: bounds) {
		if (in.x + in.w <= b.x) {
			// we've past the complete range.
			long start = max(prev.x, in.x);
			long end = in.x + in.w;
			long w = end - start;
			Range newRange{start + prev.value, w};
			// Range oldRange{start, w};
			// cout << "Final range " << oldRange << " mapped to " << newRange << endl;
			result.push_back(newRange);
			break;
		} else if (in.x <= b.x) {
			// our range is overlapping the current boundary.
			long start = max(prev.x, in.x);
			long end = b.x;
			long w = end - start;
			Range newRange{start + prev.value, w};
			// Range oldRange{start, w};
			// cout << "Overlapping range " << oldRange << " mapped to " << newRange << endl;
			result.push_back(newRange);
		} else {
			// we're still before...
		}
		prev = b;
	}
	Bound last = bounds[bounds.size()-1];
	if (in.x + in.w > last.x) {
		// long start = max(last.x, in.x);
		// long end = in.x + in.w;
		// long w = end - start;
		// Range oldRange{start, w};
		// Range newRange{start + last.value, end - start};
		// cout << "Remainder " << oldRange << " mapped to " << newRange << endl;
		result.push_back(in);
	}
	return result;
}

vector<Range> mapRange3(const MappingSet &bounds, vector<Range> in) {
	// cout << "mapRange3(" << bounds << ", " << in << ");" << endl;
	vector<Range> result;
	for (const auto &range: in) {
		vector<Range> mapped = mapRange2(bounds, range);
		for (const auto &i: mapped) { result.push_back(i); }
	}
	return result;
}

struct Data {
	vector<long> seeds;
	vector<MappingSet> mappings;
};

vector<long> readLongs(const string &line) {
	vector<long> result;
	for (const string &field: split(line, ' ')) {
		result.push_back(stol(field));
	}
	return result;
}

MappingSet readMappings(ifstream &fin) {
	MappingSet bounds;
	string line;

	getline(fin, line); // read header
	while(getline(fin, line)) {
		if (line == "") {
			break;
		}
		else {
			vector<long> data = readLongs(line);
			bounds.push_back({data[1], data[0] - data[1]});
			bounds.push_back({data[1] + data[2], 0});
		}
	}
	auto comparator =  [](const Bound &a, const Bound &b){ return a.x == b.x ? b.value != 0 : b.x > a.x; };
	sort(bounds.begin(), bounds.end(), comparator);

	// filter consecutive x'es
	vector<Bound> result;
	for (size_t i = 0; i < bounds.size(); ++i) {
		if (i < bounds.size() - 1 && bounds[i].x == bounds[i+1].x) continue;
		result.push_back(bounds[i]);
	}

	// TODO filter zeroes...
	return result;
}

Data parse(const string &fname) {
	ifstream fin(fname);
	string line;
	Data result;

	getline(fin, line);
	result.seeds = readLongs(line.substr(7));

	getline(fin, line); // skip line

	while (!fin.eof()) {
		auto mapping = readMappings(fin);
		result.mappings.push_back(mapping);
	}

	return result;
}

long solve1(const Data &data) {
	vector<long> current = data.seeds;
	for (const auto &mapping: data.mappings) {
		vector<long> next;
		transform(current.begin(), current.end(), back_inserter(next), [&](long i){ return mapRange(mapping, i); });
		current = next;
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
	vector<Range> current;
	for (size_t i = 0; i < data.seeds.size(); i += 2) {
		current.push_back({ data.seeds[i], data.seeds[i+1] });
	}

	// cout << current << endl;
	for (const auto &mapping: data.mappings) {
		vector<Range> next;
		for (const auto &j: mapRange3(mapping, current)) {
			if (j.w == 0) continue;
			next.push_back(j);
		}
		current = next;
		// cout << current << endl;
	}
	bool first = true;
	long min = 0;
	// TODO: min on vector...
	for (auto &i: current) {
		if (first || min > i.x) {
			min = i.x;
			first = false;
		}
	}
	return min;
}

int main(int argc, char *argv[]) {
	assert(argc == 2 && "Expected one argument: input file");
	auto data = parse(argv[1]);
	cout << solve1(data) << endl;
	cout << solve2(data) << endl;
}