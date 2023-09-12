#!/usr/bin/env ts-node
import { readFileSync } from 'fs';

let raw = readFileSync('input').toString('utf-8');

const win = {
	"A X": 0 + 3,
	"A Y": 3 + 1,
	"A Z": 6 + 2,
	
	"B X": 0 + 1,
	"B Y": 3 + 2,
	"B Z": 6 + 3,

	"C X": 0 + 2,
	"C Y": 3 + 3,
	"C Z": 6 + 1
}

let sum = 0;
for (const line of raw.split("\n")) {
	sum += win[line];
	console.log(line, sum);
}
console.log(sum);