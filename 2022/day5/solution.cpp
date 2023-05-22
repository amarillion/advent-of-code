//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include "../common/strutil.h"
#include <deque>

using namespace std;

using Model = vector<deque<char>>;

ostream &operator<<(ostream &os, const Model &model) {
	size_t maxSize = 0;
	for (const auto &stack: model) {
		if (stack.size() > maxSize) maxSize = stack.size();
	}

	for (size_t i = 0; i < maxSize; ++i) {
		size_t pos = maxSize - i - 1;
		for (const auto &stack: model) {
			if (pos >= stack.size()) {
				os << "    ";
			}
			else {
				os << '[' << stack[pos] << "] ";
			}
		}
		os << '\n';

	}
	for (int i = 0; i < model.size(); ++i) {
		os << " " << i << "  ";
	}
	os << '\n';
	return os;
}

Model parseInitial(istream &is) {
	string line;
	Model result;
	while(true) {
		getline(is, line);
		if (startsWith(" 1", line)) break;

		for (int i = 0; i < ((line.length() + 1) / 4); ++i) {
			if (result.size() <= i) {
				result.push_back(deque<char>());

			}
			char val = line[i * 4 + 1];
			if (val != ' ') {
				result[i].push_front(val);
			}
		}
	}
	// skip empty line.
	getline(is, line);
	return result;
}

void processMoves(istream &is, Model &model) {
	string line;

	while(getline(is, line)) {

		// example: `move 5 from 4 to 9`
		auto fields = split(line, ' ');
		int num = stoi(fields[1]);
		int from = stoi(fields[3]) - 1;
		int to = stoi(fields[5]) - 1;

		for (int i = 0; i < num; ++i) {
			auto item = model[from].back();
			model[from].pop_back();
			model[to].push_back(item);
		}

	}
//	cout << model << "\n";
}

string top(const Model &model) {
	stringstream ss;
	for(const auto& stack: model) {
		ss << stack.back();
	}
	return ss.str();
}

string solve1(const string &fname) {
	ifstream fis(fname);
	Model model = parseInitial(fis);
	processMoves(fis, model);
	return top(model);
}

int main() {
	assert(solve1("day5/test-input") == "CMZ");
	cout << solve1("day5/input");
}