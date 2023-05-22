//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <string>
#include "../common/strutil.h"
#include <deque>

using namespace std;

using Model = vector<deque<char>>;
using MoveFunc = void(int, deque<char>&, deque<char>&);

// debugging function, outputs state in neat format.
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

void move1(int num, deque<char> &from, deque<char> &to) {
	for (int i = 0; i < num; ++i) {
		auto item = from.back();
		from.pop_back();
		to.push_back(item);
	}
}

void move2(int num, deque<char> &from, deque<char> &to) {
	deque<char> temp;
	for (int i = 0; i < num; ++i) {
		auto item = from.back();
		from.pop_back();
		temp.push_front(item);
	}
	for (char item: temp) {
		to.push_back(item);
	}
}


void processMoves(istream &is, Model &model, MoveFunc *moveFunc) {
	string line;

	while(getline(is, line)) {

		// example: `move 5 from 4 to 9`
		auto fields = split(line, ' ');
		int num = stoi(fields[1]);
		int from = stoi(fields[3]) - 1;
		int to = stoi(fields[5]) - 1;

		moveFunc(num, model[from], model[to]);

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

string solve(const string &fname, MoveFunc *moveFunc) {
	ifstream fis(fname);
	Model model = parseInitial(fis);
	processMoves(fis, model, moveFunc);
	return top(model);
}

auto solve1(const string &fname) {
	return solve(fname, &move1);
}

auto solve2(const string &fname) {
	return solve(fname, &move2);
}

int main() {
	assert(solve1("test-input") == "CMZ");
	assert(solve2("test-input") == "MCD");
	cout << solve1("input") << '\n';
	cout << solve2("input") << '\n';
}