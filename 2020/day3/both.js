#!/usr/bin/env node

// Of course this works only in NodeJS, not in the Browswer.
import fs from 'fs/promises';

async function readLines(file) {
	const data = await fs.readFile(file, "UTF-8")
	const lines = data.split("\n"); 
	// remove last line if it's empty
	if (lines[lines.length-1] === '') lines.splice(lines.length-1);
	return lines;
}

async function readMatrix(file) {
	const lines = await readLines(file); 
	return lines.map(line => line.split(''));
}

function countSlope(data, right, down) {
	const height = data.length;
	const width = data[0].length;

	let trees = 0;	
	let xco = 0;
	for (let yco = 0; yco < height; yco += down) {
		let pos = data[yco][xco];
		if (pos === '#') trees++;
		xco = (xco + right) % width;
	}
	return trees;
}

async function main() {
	const data = await readMatrix('input');
	const all = [
		countSlope(data, 1, 1),
		countSlope(data, 3, 1),
		countSlope(data, 5, 1),
		countSlope(data, 7, 1),
		countSlope(data, 1, 2)
	];
	console.log("Part 1", all[1]);
	console.log("Part 2", all.reduce((cur, acc) => cur * acc, 1));
}

main();
