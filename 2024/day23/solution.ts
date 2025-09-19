#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = DefaultMap<string, string[]>;

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	const result = new DefaultMap<string, string[]>(() => []);
	for (const row of data) {
		const [ from, to ] = row.split('-');
		console.log({ from, to });
		result.get(from).push(to);
		result.get(to).push(from);
	}

	return result;
}

function solve1(data: Data) {
	let result = 0;

	console.log(data);

	const sets = new Set<string>();
	for (const key of [...data.keys()].filter(name => name.startsWith('t'))) {
		for (const second of data.get(key)) {
			for (const third of (data.get(second))) {
				for (const back of (data.get(third))) {
					if (back === key) {
						const set = [key, second, third].sort();
						sets.add(JSON.stringify(set))
					}
				}
			}
		}
	}

	result = sets.size;
	console.log(sets);
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
