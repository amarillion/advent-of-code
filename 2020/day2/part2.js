#!/usr/bin/env node


// Source: https://stackoverflow.com/questions/6156501/read-a-file-one-line-at-a-time-in-node-js
import fs from "fs";
import readline from "readline";

async function *processLineByLine() {
	const fileStream = fs.createReadStream('./input');

	const rl = readline.createInterface({
		input: fileStream,
		crlfDelay: Infinity
	});
	// Note: we use the crlfDelay option to recognize all instances of CR LF
	// ('\r\n') in input.txt as a single line break.

	for await (const line of rl) {
		// Each line in input.txt will be successively available here as `line`.
		yield line;
	}
}

// https://adventofcode.com/2020/day/2#part2

let correctCount = 0;
for await (const line of processLineByLine()) {
	const res = line.match(/^(?<start>\d+)-(?<end>\d+) (?<letter>\w): (?<pass>\w+)$/);
	const { pass, start, end, letter } = res.groups;
	const pass2 = pass.split('');
	const fit1 = pass2[start-1];
	const fit2 = pass2[end-1]
	const correct = (fit1 === letter) ^ (fit2 === letter);
	console.log(pass, start, end, letter, fit1, fit2, correct)
	if (correct) correctCount++;
}
console.log(correctCount);