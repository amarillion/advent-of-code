//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/vec3.h"
#include "../common/collectionutil.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include <set>

using namespace std;

using Cube = Vec3<int>;

vector<Cube> readCubes(const string &fname) {
	ifstream infile(fname);
	string line;
	vector<Cube> result;
	while(getline(infile, line)) {
		auto coords = split(line, ',');
		Cube cube { stoi(coords[0]), stoi(coords[1]), stoi(coords[2]) };
		result.push_back(cube);
	}
	return result;
}

int countExposedSides(const vector<Cube> &cubes) {
	// result is 6 * cubes minus matching faces...
	int result = 6 * cubes.size();
	for (size_t i = 0; i < cubes.size(); ++i) {
		for (size_t j = 0; j < i; ++j) {
 			Cube delta = cubes[j] - cubes[i];
			int manhattan = abs(delta.x()) + abs(delta.y()) + abs(delta.z());
			assert (manhattan > 0);

			// adjacent cubes!
			if (manhattan == 1) {
				result -= 2; // two faces hidden
			}
		}
	}
	return result;
}

int floodFill(const vector<Cube> &cubes) {
	// convert to set
	set<Cube> sparse;
	Cube maxCo = cubes[0];
	Cube minCo = cubes[0];
	for (auto const &cube: cubes) {
		sparse.insert(cube);

		maxCo.x(max(cube.x(), maxCo.x()));
		maxCo.y(max(cube.y(), maxCo.y()));
		maxCo.z(max(cube.z(), maxCo.z()));
		minCo.x(min(cube.x(), minCo.x()));
		minCo.y(min(cube.y(), minCo.y()));
		minCo.z(min(cube.z(), minCo.z()));
	}

	// now execute flood Fill, recursively...

	int result = 0;
	vector<Cube> open;
	open.push_back({ 0, 0, 0 });
	vector<Cube> faces { { 1, 0, 0 } , { -1, 0, 0 }, { 0, 1, 0 }, { 0, -1, 0 }, { 0, 0, -1 }, { 0, 0, 1} };
	set<Cube> visited({ 0, 0, 0, });

	while (!open.empty()) {
		// try each of the 6 sides...
		Cube current = open.back();
		open.pop_back();

		for (const auto &face: faces) {
			auto newPos = current + face;

			// check in bounds...
			if (newPos.x() < minCo.x() - 1 || newPos.y() < minCo.y() - 1 || newPos.z() < minCo.z() - 1) continue;
			if (newPos.x() > maxCo.x() + 1 || newPos.y() > maxCo.y() + 1 || newPos.z() > maxCo.z() + 1) continue;

			// check if already visited...
			if (visited.contains(newPos)) continue;

			// check if we hit a face...
			if (sparse.contains(newPos)) {
				result++;
			}
			else {
				visited.insert(newPos);
				open.push_back(newPos);
			}
		}
	}
	return result;
}

int main() {
	assert(countExposedSides({ {1, 1, 1}, {2, 1, 1} }) == 10);
	assert(floodFill({ {1, 1, 1}, {2, 1, 1} }) == 10);
	vector<Cube> testInput = readCubes("day18/test-input");
	assert(countExposedSides(testInput) == 64);
	assert(floodFill(testInput) == 58);
	vector<Cube> input = readCubes("day18/input");
	cout << countExposedSides(input) << endl;
	cout << floodFill(input) << endl;

	// wrong answer 2036...
}