#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = string;

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' });
	return data;
}

function solve1(data: Data) {
	let result = 0;
	for (const m of data.matchAll(/mul\((\d+),(\d+)\)/g)) {
		result += Number(m[1]) * Number(m[2]);
	}
	return result;
}

function solve2(data: Data) {
	/* 
		NOTE: 
		replaceAll don't().?*do() doesn't work, because it doesn't properly
		disable the trailing instructions at the end, after the final don't()
	*/
	let result = 0;
	let enabled = true;
	for (const m of data.matchAll(/(don't\(\)|do\(\)|mul\((?<op1>\d+),(?<op2>\d+)\))/g)) {
		if (m[0] === "don't()") {
			enabled = false;
		}
		else if (m[0] === 'do()') {
			enabled = true;
		}
		else {
			if (enabled) {
				const { op1, op2 } = m.groups!;
				result += Number(op1) * Number(op2);		
			}
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));