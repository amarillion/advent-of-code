//usr/bin/clang++ -O3 -std=c++20 "$0" && ./a.out; exit

#include <cassert>
#include <iostream>
#include <fstream>
#include <list>
#include <utility>
#include "../common/strutil.h"
#include <ranges>

using namespace std;

class Node {
public:
	Node(string _name, bool _isDir, Node *_parent = nullptr, size_t _size = 0) : name(std::move(_name)), isDir(_isDir), parent(_parent), size(_size) {}
	string name;
	bool isDir;
	list<Node> children;
	size_t size;
	Node *parent = nullptr;

	Node *navigate(const string &dest) {
//		cout << "Navigating to [" << dest << "]" << endl;
		if (dest == "..") {
			return parent;
		}
		else {
			for (auto &child: children) {
				if (child.name == dest) return &child;
			}
		}
		return nullptr;
	}
};

// print for debugging
void printNode(ostream &os, const Node &n, int indent = 0) {
	for (int i = 0; i < indent; ++i) {
		os << "  ";
	}
	os << n.name << ' ';
	if (n.isDir) {
		os << "(dir)";
	}
	else {
		os << "(file, size=" << n.size << ")";
	}
	os << endl;
	for (const auto &child : n.children) {
		printNode(os, child, indent + 1);
	}
}

ostream &operator<< (ostream &os, const Node &n) {
	printNode(os, n, 0);
	return os;
}

Node readInput(const string &fname) {
	ifstream infile(fname);
	string line;
	Node root("/", true);
	Node *current = &root;

	while (getline(infile, line)) {
		if (startsWith("$ cd ", line)) {
			string dest = line.substr(5);
			// change pointer.
			if (dest == "/") {
				current = &root;
			}
			else {
				current = current->navigate(dest);
			}
		}
		else if (startsWith("$ ls", line)) {
			// ignore - we can detect listings easily
		}
		else if (startsWith("dir ", line)) {
			// dir entry
			string name = line.substr(4);
			Node newDir(name, true, current);
			current->children.push_back(newDir);
		}
		else {
			// file entry
			auto fields = split(line, ' ');
			Node newDir(fields[1], false, current, stol(fields[0]));
			current->children.push_back(newDir);
		}

	}
	return root;
}

size_t getDirectorySize(const Node &node, vector<size_t> &result) {
	size_t sum = 0;
	for (const auto &child: node.children) {
		if(child.isDir) {
			sum += getDirectorySize(child, result);
		}
		else {
			sum += child.size;
		}
	}
	result.push_back(sum);
	return sum;
}

size_t solve1(const Node &root) {
	vector<size_t> sizes;
	getDirectorySize(root, sizes);
	size_t sum = 0;
	for (size_t val: sizes | views::filter([=](size_t s){ return s < 100'000; })) {
		sum += val;
	}
	return sum;
}

size_t solve2(const Node &root) {
	vector<size_t> sizes;
	size_t rootSize = getDirectorySize(root, sizes);
	size_t base = rootSize - 40'000'000;
	bool first = true;
	size_t min = 0;
	for (size_t size : sizes) {
		if (size < base) continue;
		if (first || size < min) {
			min = size;
			first = false;
		}
	}
	return min;
}

int main() {
	Node testInput = readInput("day7/test-input");
	assert(solve1(testInput) == 95437);
	assert(solve2(testInput) == 24933642);

	Node input = readInput("day7/input");
	cout << solve1(input) << endl;
	cout << solve2(input) << endl;
}