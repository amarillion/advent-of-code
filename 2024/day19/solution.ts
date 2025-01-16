#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { truthy } from '../common/iterableUtils.js';

type Data = ReturnType<typeof parse>;

function parse(fname: string) {
	const [ rawAvailable, rawDesired ] = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	return {
		available: new Set(rawAvailable.split('\n')[0].split(', ')),
		desired: rawDesired.split('\n').filter(truthy)
	}
}

// recursive approach
function isPossible(pattern: string, available: Set<string>) {
	for (const a of available) {
		if (pattern === a) {
			return true;
		}
		if (pattern.startsWith(a)) {
			if (isPossible(pattern.substring(a.length), available)) {
				return true;
			}
			// otherwise check next pattern...
		}
	}
	return false;
}

// dynamic programming approach
// with manual memoization
// TODO: extract memoization...
function isPossibleDyn(startPattern: string, available: Set<string>) {
	
	const cache = new Map<string, boolean>();
	const minLength = [...data.available].map(str => str.length).reduce((cur, acc) => Math.min(cur, acc), Infinity);

	function helper(pattern: string) {
		if (cache.has(pattern)) {
			return cache.get(pattern);
		}

		if (available.has(pattern)) {
			cache.set(pattern, true);
			return true;
		}
		
		if (pattern.length > minLength) {
			for (let i = minLength; i <= pattern.length - minLength; ++i) {
				const pat1 = pattern.substring(0, i);
				const pat2 = pattern.substring(i);
				// console.log(`${indent}${i}: Checking ${pat1} - ${pat2}`);
				if (helper(pat1) && helper(pat2)) {
					cache.set(pattern, true);
					return true;
				}
			}
		}
		// console.log(`${indent}${pattern} Not found`);
		cache.set(pattern, false);
		return false;
	
	}

	return helper(startPattern);
}

function solve1(data: Data) {
	let result = 0;
	for (const pattern of data.desired) {
		const flag = isPossibleDyn(pattern, data.available);
		console.log(pattern, flag);
		if (flag) { result++; }
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
