#!/usr/bin/env -S rdmd -I..

module day21.part1;

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;

void main() {
	
	int[string][string] implicatedByAllergen;
	int[string] allergenFrq;
	int[string] ingredientFrq;

	foreach (line; readLines("input")) {
		string[] fields = line.split(" (contains ");
		string[] ingredients = fields[0].split(" ");
		string[] allergens = fields[1][0..$-1].split(", ");
		writeln(ingredients, allergens);

		foreach(i; ingredients) {
			ingredientFrq[i]++;
		}
		foreach(a; allergens) {
			allergenFrq[a]++;
			foreach(i; ingredients) {
				implicatedByAllergen[a][i]++;
			}
		}
	}

	writeln(implicatedByAllergen);

	string[][string] suspectedByAllergen;
	bool[string] suspectedByIngredient;
	foreach(a, v; implicatedByAllergen) {
		foreach(i, num; v) {
			assert(num <= allergenFrq[a]);
			if (num == allergenFrq[a]) {
				suspectedByAllergen[a] ~= i;
				suspectedByIngredient[i] = true;
			}
		}
	}

	writeln(suspectedByAllergen);

	long sum = 0;
	foreach(i, num; ingredientFrq) {
		if (!(i in suspectedByIngredient)) {
			writefln("%s not suspected, count %s", i, num);
			sum += num;
		}
	}
	writeln("Part 1", sum);

	string[string] definiteByAllergen;

	while(suspectedByAllergen.length > 0) {
		// find an ingredient that is suspected only once
		string singularAllergen = "";
		foreach(a, v; suspectedByAllergen) {
			if (v.length == 1) {
				singularAllergen = a;
				// remove our singular ingredient...
				break;
			}
		}
		assert (singularAllergen != "");
		string singularIngredient = suspectedByAllergen[singularAllergen][0];
		definiteByAllergen[singularAllergen] = singularIngredient;

		// writeln(suspectedByAllergen, " removing: ", singularAllergen, " -> ", singularIngredient);

		foreach(a, ref v; suspectedByAllergen) {
			v = v.filter!(s => s != singularIngredient)().array;
		}
		suspectedByAllergen.remove(singularAllergen);
	}

	string sep = "";
	foreach(a; definiteByAllergen.keys.sort()) {
		write(sep, definiteByAllergen[a]);
		sep = ",";
	}
	writeln();

}