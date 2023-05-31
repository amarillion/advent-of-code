#include "../common/strutil.h"
#include "../common/map2d.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

struct Sensor {
	Point pos;
	Point nearestBeacon;
};

ostream &operator<< (ostream &os, const Sensor &s) {
	os << "[pos: " << s.pos << ", b: " << s.nearestBeacon << ']';
	return os;
}

vector<Sensor> read(const string &fname) {
	ifstream infile(fname);
	string line;
	vector<Sensor> result;
	while(getline(infile, line)) {
		regex re (R"(Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+))");
		smatch m;
		regex_match(line, m, re);
		result.push_back({
			{ stoi(m[1]), stoi(m[2])}, { stoi(m[3]), stoi(m[4])}
		});
	}
	cout << result << endl;
	return result;
}

// same as day 4...
struct Range {
	int start;
	int end;
};

ostream &operator<< (ostream &os, const Range &r) {
	os << r.start << "-" << r.end;
	return os;
}

void crossSection(const Sensor &sensor, int y, vector<Range> &ranges) {
	// get the manhattan distance
	int manhattan = (sensor.pos - sensor.nearestBeacon).manhattan();
	int yDist = abs(y - sensor.pos.y());
	int width = manhattan - yDist;
	if (width > 0) {
		Range range {sensor.pos.x() - width, sensor.pos.x() + width};
		// check for overlap of the beacon with this range.
		if (sensor.nearestBeacon.y() == y) {
			if (sensor.nearestBeacon.x() == range.start) {
				range.start++;
			}
			else if (sensor.nearestBeacon.x() == range.end) {
				range.end--;
			}
		}
		if ((range.end - range.start) > 0) {
			ranges.push_back(range);
		}
	}
	else {
		cout << "Skipping sensor " << sensor << endl;
	}
}

size_t solve(const string &fname, int y) {
	auto sensors = read(fname);
	vector<Range> ranges;
	for (const auto &s: sensors) {
		crossSection(s, y, ranges);
	}

	set<int> nonBeacon;
	for (const auto &range: ranges) {
		for (int i = range.start; i <= range.end; ++i) {
			nonBeacon.insert(i);
		}
	}
//	cout << ranges << " -> " << nonBeacon << endl;
	return nonBeacon.size();
}

int main() {
	assert(solve("day15/test-input", 10) == 26);
	cout << solve("day15/input", 2'000'000) << endl;
}