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

let correctCount = 0;
for await (const line of processLineByLine()) {
	const res = line.match(/^(?<start>\d+)-(?<end>\d+) (?<letter>\w): (?<pass>\w+)$/);
	const { pass, start, end, letter } = res.groups;
	const observed = pass.split('').filter(i => i == letter).length;
	const correct = observed >= +start && observed <= +end; 
	console.log(pass, letter, start, end, observed, correct);
	if (correct) correctCount++;
}
console.log(correctCount);