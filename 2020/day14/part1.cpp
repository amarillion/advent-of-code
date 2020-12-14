//usr/bin/clang++ -O3 -std=c++11 "$0" && ./a.out; exit
#include <string>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <bitset>
#include <vector>

using namespace std;

int main() {

	vector<unsigned long> data;

	const char *fname = "input";
	string line;
	int lineno = 0;

	ifstream infile(fname);

	string mask, lval, rval;
	unsigned long ones, zeroes;

	while (getline(infile, line))
	{
		lineno++;
		int equalsPos = line.find('=');
		string lval = line.substr(0, equalsPos - 1);
		string rval = line.substr(equalsPos + 2);
		
		if (lval == "mask") {
			mask = rval;
			ones = 0;
			zeroes = 0;
			for (int i = 0; i < mask.length(); ++i) {
				ones *= 2;
				zeroes *= 2;
				if (mask[i] != '0') {
					zeroes += 1;
				}
				if (mask[i] == '1') {
					ones += 1;
				}
			}

			std::bitset<36> onesb(ones);
			std::cout << "MASK: " << mask << '\n';
			std::cout << "      " << onesb << '\n';
			std::bitset<36> zeroesb(zeroes);
			std::cout << "      " << zeroesb << '\n';
		}
		else {
			unsigned int addr = stoi(line.substr(4, equalsPos - 2));
			unsigned long val = stoi (rval);

			std::bitset<36> valb(val);
			std::cout << "befor " << valb << '\n';

			val &= zeroes;
			val |= ones;

			std::bitset<36> val2(val);
			std::cout << "after " << val2 << '\n';

			if (addr >= data.size()) {
				data.resize(addr + 1, 0);
			}

			data[addr] = val;
		}
		
	}

	unsigned long sum = 0;
	for (int i = 0; i < data.size(); ++i) {
		sum += data[i];
	}
	cout << "Part 1: " << sum << endl;

	return 0;
}