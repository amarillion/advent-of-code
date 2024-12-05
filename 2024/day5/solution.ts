#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = { rules: Record<string, boolean>, updates: number[][] };

function parse(fname: string) {
	const raw = readFileSync(fname, { encoding: 'utf-8' });
	const [ rulesRaw, updatesRaw ] = raw.split('\n\n');
	const rules: Record<string, boolean> = {};
	for(const rule of rulesRaw.split('\n').filter(l => l !== '')) {
		rules[rule] = true;
	}
	// const rules = new Map<number, number[]>();
	// for(const [key, value] of rulesRaw.split('\n').map(l => l.split('|').map(Number))) {
	// 	if (!rules.has(key)) {
	// 		rules.set(key, [ value ]);
	// 	}
	// 	else {
	// 		rules.get(key)?.push(value);
	// 	}
	// }
	const updates = updatesRaw.split('\n').filter(l => l !== '').map(l => l.split(',').map(Number));
	return { rules, updates };
}

function orderCorrect(line: number[], rules: Record<string, boolean> ) {
	let valid = true;
	// check if any rule violates

	for (let i = 0; i < line.length; ++i) {
		for (let j = i + 1; j < line.length; ++j) {
			const invalidatingRule = `${line[j]}|${line[i]}`;
			if (invalidatingRule in rules) {
				console.log(`Rule violation in ${line} ${invalidatingRule}`);
				valid = false;
				break;
			}
		}
		if (!valid) { break; }
	}
	return valid;
}

function solve1({ rules, updates }: Data) {
	let result = 0;
	for (const line of updates) {
		if (orderCorrect(line, rules)) {
			const middle = line[Math.floor(line.length / 2)];
			console.log('Adding: ', middle)
			result += middle;
		}
	}
	return result;
}

function solve2({ rules, updates }: Data) {
	let result = 0;
	for (const line of updates) {
		if (!orderCorrect(line, rules)) {
			
			// fix by abusing custom sort
			line.sort((a, b) => {
				if (`${a}|${b}` in rules) return -1;
				if (`${b}|${a}` in rules) return 1;
				return 0;
			});

			assert(orderCorrect(line, rules));

			const middle = line[Math.floor(line.length / 2)];
			console.log('Adding: ', middle)
			result += middle;
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
// console.log(solve1(data));
console.log(solve2(data));
