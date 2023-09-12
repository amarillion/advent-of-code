//usr/bin/clang++ -O3 -std=c++11 "$0" && ./a.out; exit
#include <string>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <iomanip>

using namespace std;

int main() {

	const char *fname = "input";
	string line;
	int lineno = 0;

	ifstream infile(fname);
	int correctPart1Count = 0;
	int correctPart2Count = 0;

	while (getline(infile, line))
	{
		lineno++;
		int dashPos = line.find('-');
		int firstSpacePos = line.find(' ');
		int no1 = stoi(line.substr(0, dashPos));
		int no2 = stoi(line.substr(dashPos + 1, firstSpacePos - dashPos - 1));
		char letter = line.at(firstSpacePos + 1);
		string remain = line.substr(firstSpacePos + 4);

		int count = 0;
		for (int i = 0; i < remain.length(); ++i) {
			if (remain[i] == letter) count++;
		}

		if (count <= no2 && count >= no1) correctPart1Count++;
		if (remain[no1-1] == letter ^ remain[no2-1] == letter) correctPart2Count++;

		cout << setw(4) << setfill(' ')
			<< lineno << ": " << line << endl;
	}

	cout << "Part 1: " << correctPart1Count << endl
		<< "Part 2: " << correctPart2Count	<< endl;

	return 0;
}