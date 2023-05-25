//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include "../common/strutil.h"
#include "../common/vec3.h"
#include <cassert>
#include <iostream>
#include <fstream>
#include <string>

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

int main() {
	assert(countExposedSides({ {1, 1, 1}, {2, 1, 1} }) == 10);
	vector<Cube> testInput = readCubes("day18/test-input");
	assert(countExposedSides(testInput) == 64);
	vector<Cube> input = readCubes("day18/input");
	cout << countExposedSides(input) << endl;
}