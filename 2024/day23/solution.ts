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

// TODO: obsoleted by es2024 Set.intersect
function intersect<T>(a: Set<T>, b: Set<T>) {
	return new Set([...a].filter(x => b.has(x)));
}

function solve1(data: Data) {
	let result = 0;

	const sets = new Set<string>();
	for (const first of [...data.keys()].filter(name => name.startsWith('t'))) {
		for (const second of data.get(first)) {
			const overlap = intersect(data.get(first), data.get(second));

			for (const third of overlap) {
				const set = [first, second, third].sort();
				sets.add(set.join(','));
			}
		}
	}

	result = sets.size;
	return result;
}

function solve2(data: Data) {
	let maxSet = '';

	function drillDown(parents: string[], overlap: Set<string>) {
		const treshold = parents[parents.length-1];
		for (const third of [...overlap].sort()) {
			// since we go in alphabetical order
			// every node that is smaller has been already checked
			if (third <= treshold) continue;

			const overlap3 = intersect(overlap, data.get(third));
			if (overlap3.size === 0) {
				// we've reached the end of this branch
				// we detected a new fully connected subgraph
				const subgraph = [...parents, third].join(',');
				if (subgraph.length > maxSet.length) {
					maxSet = subgraph;
				}
			}
			else {
				drillDown([...parents, third], overlap3);
			}
		}
	}

	for (const first of [...data.keys()].sort()) {
		drillDown([first], data.get(first));
	}

	return maxSet;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));

