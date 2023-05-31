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
//		cout << "Skipping sensor " << sensor << endl;
	}
}

size_t rangeSum(const vector<Range> &ranges) {
	size_t sum = 0;
	for (const auto &range: ranges) {
		sum += (range.end - range.start) + 1;
	}
	return sum;
}

vector<Range> mergeOverlapping(const vector<Range> &ranges) {
	vector<Range> open = ranges;
	sort(open.begin(), open.end(), [&](const Range &a, const Range &b){ return a.start < b.start; });
	vector<Range> result;

	int it = 0;
	while (!open.empty()) {
		size_t sum = rangeSum(open) + rangeSum(result);
//		cout << "Iteration: " << (++it) << " Open: " << open << " Result: " << result << " total covered " << sum << endl;
		Range current = open.back();
		open.pop_back();

		bool keep = true;
		for (const auto &needle : open) {
			if (current.start >= needle.start && current.end <= needle.end) {
				// current is completely contained by needle, we can drop current from the list.
				keep = false;
			}
			// current is left of needle...
			else if (current.start < needle.start && current.end >= needle.start) {
				open.push_back({current.start, needle.start - 1});
				keep = false;
				break;
			}
			// current is right of needle
			else if (current.start <= needle.end && current.end > needle.end) {
				open.push_back({needle.end + 1, current.end });
				keep = false;
				break;
			}
			// no overlap
		}
		if (keep) {
			result.push_back(current);
		}
		sort(open.begin(), open.end(), [&](const Range &a, const Range &b){ return a.start < b.start; });
		sort(result.begin(), result.end(), [&](const Range &a, const Range &b){ return a.start < b.start; });
	}
	size_t sum = rangeSum(open) + rangeSum(result);
//	cout << "Iteration: " << (++it) << " Open: " << open << " Result: " << result << " total covered " << sum << endl;
	return result;
}

size_t solve1(const vector<Sensor> &sensors, int y) {
	vector<Range> ranges;
	for (const auto &s: sensors) {
		crossSection(s, y, ranges);
	}

	auto nonOverlappingSet = mergeOverlapping(ranges);

	return rangeSum(nonOverlappingSet);
}

Point find(const vector<Sensor> &sensors, int maxCoord) {
	set<Point> knownBeacons;
	for (const auto &s: sensors) {
		knownBeacons.insert(s.nearestBeacon);
	}
	for (int y = 0; y < maxCoord; ++y) {
		vector<Range> ranges;
		for (const auto &s: sensors) {
			crossSection(s, y, ranges);
		}
		auto nonOverlappingSet = mergeOverlapping(ranges);

		// assuming sorted...
		for (int i = 1; i < nonOverlappingSet.size(); ++i) {
			const auto &r1 = nonOverlappingSet[i-1];
			const auto &r2 = nonOverlappingSet[i];
			if (r1.end > 0 && r2.start < maxCoord && r2.start - r1.end == 2) {
				Point result { r1.end + 1, y };
				if (!knownBeacons.contains(result)) {
					cout << "Found! " << result << endl;
					return result;
				}
			}
		}
	}

	assert(false); // we must find something
}

long solve2(const Point &p) {
	return p.x() * 4'000'000L + p.y();
}

int main() {
	auto testInput = read("day15/test-input");
	assert(solve1(testInput, 10) == 26);
	auto input = read("day15/input");
	assert(solve1(input, 2'000'000) == 5'166'077); // solution part 1.

	assert(solve2(find(testInput, 20)) == 56'000'011);
	assert(solve2(find(input, 4'000'000)) == 13'071'206'703'981L); // solution part 2.
}