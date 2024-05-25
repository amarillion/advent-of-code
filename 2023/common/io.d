module common.io;

import std.file;
import std.string;
import std.stdio;
import std.conv;
import std.range;

string[] readLines(string fname) {
	string[] result = readText(fname).stripRight.split('\n');
	return result;
}

/** 
very simple line reader abstraction...
Will one day replace with libraries like
* https://github.com/andrewlalis/streams
* https://github.com/schveiguy/iopipe
*/
interface InputReader {
	string readLine();
	@property bool eof();
}

class FileReader : InputReader {
	private File file;
	
	this(string fileName) {
		file = File(fileName, "rt");
	}

	string readLine() {
		return file.readln().chomp();
	}

	@property bool eof() {
		return file.eof;
	}
}

class StringReader : InputReader {
	private string[] data;

	this(string contents) {
		data = contents.split("\n");
	}

	string readLine() {
		if (data.length == 0) return null;
		string result = data[0];
		data = data[1..$];
		return result;
	}

	@property bool eof() {
		return data.empty;
	}
}
