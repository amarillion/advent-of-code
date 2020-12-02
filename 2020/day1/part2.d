#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

void main()
{
	// https://www.tutorialspoint.com/d_programming/d_programming_file_io.htm

	int[] data = [];

	File file = File("input", "rt");
	while (!file.eof()) { 
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		int i = to!int(line);
		data ~= [ i ];
	}

	foreach (int i; data) {
		foreach (int j; data) {
			foreach (int k; data) {
				if (i+j+k == 2020) {
					writeln(i, " " , j, " ", k, " ", i+j+k, " ", i*j*k);
				}
			}
		}
	}
}