#!/usr/bin/env tsx
import { readFileSync } from 'fs';

let raw = readFileSync('input').toString('utf-8');

const win = {
	"A X": 3 + 1,
	"A Y": 6 + 2,
	"A Z": 0 + 3,
	
	"B X": 0 + 1,
	"B Y": 3 + 2,
	"B Z": 6 + 3,

	"C X": 6 + 1,
	"C Y": 0 + 2,
	"C Z": 3 + 3
}

let sum = 0;
for (const line of raw.split("\n")) {
	sum += win[line];
	console.log(line, sum);
}
console.log(sum);