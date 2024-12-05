#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = { rules: string[], updates: number[][] };

function parse(fname: string) {
	const raw = readFileSync(fname, { encoding: 'utf-8' });
	const [ rulesRaw, updatesRaw ] = raw.split('\n\n');
	const rules = rulesRaw.split('\n').filter(l => l !== '');
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

function solve1({ rules, updates }: Data) {
	let result = 0;
	let row = 0;
	for (const line of updates) {
		let valid = true;
		// check if any rule violates

		for (let i = 0; i < line.length; ++i) {
			for (let j = i + 1; j < line.length; ++j) {
				const invalidatingRule = `${line[j]}|${line[i]}`;
				if (rules.includes(invalidatingRule)) {
					console.log(`Rule violation in ${row} ${invalidatingRule}`);
					valid = false;
					break;
				}
				// does pair violate any rule?
				// const mustComeAfter = rules.get(pair[1]) || [];
				// if (mustComeAfter.includes(pair[0])) {
				// 	console.log(`Rule violation in ${row} ${i} ${j} ${invalidRule}`)
				// 	valid = false;
				// 	break;
				// }
			}
			if (!valid) { break; }
		}

		if (valid) {
			const middle = line[Math.floor(line.length / 2)];
			console.log('Adding: ', middle)
			result += middle;
		}
	}
	return result;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
