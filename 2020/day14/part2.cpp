//usr/bin/clang++ -O3 -std=c++11 "$0" && ./a.out; exit
#include <string>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <bitset>
#include <vector>
#include <map>
#include <sstream>

using namespace std;

void setValues(map<uint64_t, uint64_t> &data, bitset<36> addr, vector<uint8_t> xes, unsigned long val) {
	if (xes.empty()) {
		cout << " mem[ " << addr << " ] ( decimal " << addr.to_ulong() << " ) = " << val << endl;
		data[addr.to_ulong()] = val;
	}
	else {
		unsigned short pos = xes[xes.size() - 1];
		xes.pop_back();
		bitset<36> addr1 = addr, addr0 = addr;
		addr1[pos-1] = 1;
		addr0[pos-1] = 0;
		setValues(data, addr0, xes, val);
		setValues(data, addr1, xes, val);
	}
}

int main() {
	map<uint64_t, uint64_t> data;

	const char *fname = "input";
	string line;
	int lineno = 0;

	ifstream infile(fname);

	string mask, lval, rval;
	bitset<36> ones;
	vector<uint8_t> xes;

	while (getline(infile, line))
	{
		lineno++;
		int equalsPos = line.find('=');
		string lval = line.substr(0, equalsPos - 1);
		string rval = line.substr(equalsPos + 2);
		
		if (lval == "mask") {
			mask = rval;
			ones = 0;
			xes.clear();
			for (int i = 0; i < mask.length(); ++i) {
				if (mask[i] == '1') {
					ones[35-i] = 1;
				}
				if (mask[i] == 'X') {
					xes.push_back(36-i);
				}
			}
		}
		else {
			uint64_t addr = stoi(line.substr(4, equalsPos - 2));
			uint64_t val = stoi (rval);

			std::bitset<36> addrb(addr);
			setValues(data, bitset<36>(addr) | ones, xes, val);
		}
	}

	uint64_t sum = 0;
	for (auto pair : data) {
		sum += pair.second;
	}
	
	cout << "Part 2: " << sum << endl;

	return 0;
}
