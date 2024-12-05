#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = { rules: Set<string>, updates: number[][] };

function parse(fname: string) {
	const raw = readFileSync(fname, { encoding: 'utf-8' });
	const [ rulesRaw, updatesRaw ] = raw.split('\n\n');
	const rules = new Set<string>();
	for(const rule of rulesRaw.split('\n').filter(l => l !== '')) {
		rules.add(rule);
	}
	const updates = updatesRaw.split('\n').filter(l => l !== '').map(l => l.split(',').map(Number));
	return { rules, updates };
}

function orderCorrect(line: number[], rules: Set<string> ) {
	// check if any rule violates

	// TODO: use allPairs function
	for (let i = 0; i < line.length; ++i) {
		for (let j = i + 1; j < line.length; ++j) {
			const invalidatingRule = `${line[j]}|${line[i]}`;
			if (rules.has(invalidatingRule)) {
				return false;
			}
		}
	}
	return true;
}

function solveLine(line: number[], rules: Set<string>) {
	const valid = orderCorrect(line, rules);

	if (!valid) {
		// fix by abusing custom sort
		line.sort((a, b) => {
			if (rules.has(`${a}|${b}`)) return -1;
			if (rules.has(`${b}|${a}`)) return 1;
			return 0;
		});
	}

	const middle = line[Math.floor(line.length / 2)];
	return { valid, middle };
}

function solve1(data: { valid: boolean, middle: number }[]) {
	let result = 0
	//TODO: use common sum function
	for (const value of data.filter(line => line.valid).map(line => line.middle)) {
		result += value;
	}
	return result;
}

function solve2(data: { valid: boolean, middle: number }[]) {
	let result = 0
	//TODO: use common sum function
	for (const value of data.filter(line => !line.valid).map(line => line.middle)) {
		result += value;
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
const solved = data.updates.map(line => solveLine(line, data.rules));
console.log(solve1(solved));
console.log(solve2(solved));
