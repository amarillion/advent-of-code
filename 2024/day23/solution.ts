#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = DefaultMap<string, Set<string>>;

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	const result = new DefaultMap<string, Set<string>>(() => new Set());
	for (const row of data) {
		const [ from, to ] = row.split('-');
		// console.log({ from, to });
		result.get(from).add(to);
		result.get(to).add(from);
	}

	return result;
}

// TODO: obsoleted by es2024 Set.interset
function intersect<T>(a: Set<T>, b: Set<T>) {
	return new Set([...a].filter(x => b.has(x)));
}

function solve1(data: Data) {
	let result = 0;

	console.log(data);

	const sets = new Set<string>();
	for (const first of [...data.keys()].filter(name => name.startsWith('t'))) {
		for (const second of data.get(first)) {
			const overlap = intersect(data.get(first), data.get(second));

			for (const third of overlap) {
				const set = [first, second, third].sort();
				sets.add(JSON.stringify(set))
			}
		}
	}

	result = sets.size;
	console.log(sets);
	return result;
}

function solve2(data: Data) {
	let result = 0;

	const sets = new Set<string>();
	const partials = new Set<string>();

	function drillDown(parents: string[], overlap: Set<string>, indent: string, level: number) {
		const verify = [...parents].sort();
		if (partials.has(verify.join(','))) { return; } // this branch is already checked.

		// console.log(`${indent}Calling drillDown ${parents} Set: ${[...overlap]}`)
		for (const third of overlap) {
			const overlap3 = intersect(overlap, data.get(third));
			// console.log(`${indent}  third: ${third} overlap: ${[...overlap3]}`);
			if (overlap3.size === 0) {
				const sorted = [...parents, third].sort();
				sets.add(sorted.join(','));
			}
			else {
				drillDown([...parents, third], overlap3, indent + '  ', level + 1);
				const sorted = [...parents, third].sort();
				partials.add(sorted.join(','));
			}
		}
	}

	for (const first of data.keys()) {
		drillDown([first], data.get(first), '  ', 1);
	}

	// for (const first of data.keys()) {
	// 	for (const second of data.get(first)) {
	// 		const overlap = intersect(data.get(first), data.get(second));
	// 		drillDown([first, second], overlap, '  ', 1);
	// 	}
	// }

	console.log(sets);
	let maxSet = '';
	for (const set of sets) {
		if (set.length > maxSet.length) {
			maxSet = set;
		}
	}
	console.log(maxSet);
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
// console.log(solve1(data));
console.log(solve2(data));

