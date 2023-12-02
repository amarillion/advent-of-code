//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <vector>
#include <functional>
#include "../common/strutil.h" // reverseString, startsWith

using namespace std;

vector<string> reverseStrings(const vector<string> &data) {
	vector<string> result;
	transform(data.begin(), data.end(), back_inserter(result), reverseString);
	return result;
}

vector<string> digits {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
vector<string> numberStrings {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

int detectStartPattern(const string &s, const vector<string> &patterns) {
	for (int j = 0; j < patterns.size(); ++j) {
		if (startsWith(patterns[j], s)) {
			return j;
		}
	}
	return -1;
}

int scanPattern(const string &line, const vector<string> &patterns) {
	int result = -1;
	for (int i = 0; i < line.length(); ++i) {
		auto subLine = line.substr(i);
		result = detectStartPattern(subLine, patterns);
		if (result >= 0) { break; }
	}
	return result;
}

auto calculate(const string &fname, bool secondPart) {
	ifstream fin(fname);
	string line;
	int result = 0;

	vector<string> patterns = digits;
	if (secondPart) for(const auto &i: numberStrings) { patterns.push_back(i); }
	vector<string> reversePatterns = reverseStrings(patterns);
	
	while(getline(fin, line)) {
		int first = scanPattern(line, patterns) % 10;
		string reverseLine = reverseString(line);
		int last = scanPattern(reverseLine, reversePatterns) % 10;
		result += first * 10 + last;
	}
	fin.close();
	return result;
}

int main() {
	assert(calculate("test-input", false) == 142);
	assert(calculate("test-input2", true) == 281);
	
	assert(calculate("input", false) == 56397);
	assert(calculate("input", true) == 55701);

	cout << "DONE" << endl;
}