module helix.io;

import std.stdio;
import std.string;

string[] readLines(string fname) {
	File file = File(fname, "rt");
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		result = result ~ line;
	}
	// Remove empty line...
	if (result[$-1].length == 0) { result = result[0..$-1]; }
	return result;
}

string[] readParagraph(File file) {
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) {
			if (result.length == 0) continue;
			else break;
		}
		result = result ~ line;
	}
	return result;
}
