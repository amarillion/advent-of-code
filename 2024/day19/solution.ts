#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { truthy } from '../common/iterableUtils.js';
import { memoize } from '../common/functional/memoize.js';

type Data = ReturnType<typeof parse>;

function parse(fname: string) {
	const [ rawAvailable, rawDesired ] = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	return {
		available: new Set(rawAvailable.split('\n')[0].split(', ')),
		desired: rawDesired.split('\n').filter(truthy)
	}
}

// dynamic programming approach, with memoization
function isPossibleDyn(startPattern: string, available: Set<string>) {
	
	const minLength = [...data.available].map(str => str.length).reduce((cur, acc) => Math.min(cur, acc), Infinity);

	const helper = memoize((pattern: string) => {
		if (available.has(pattern)) {
			return true;
		}
		if (pattern.length > minLength) {
			for (let i = minLength; i <= pattern.length - minLength; ++i) {
				const pat1 = pattern.substring(0, i);
				const pat2 = pattern.substring(i);
				if (helper(pat1) && helper(pat2)) {
					return true;
				}
			}
		}
		return false;
	
	});

	return helper(startPattern);
}

function countRecursive(startPattern: string, available: Set<string>) {
	
	const minLength = [...data.available].map(str => str.length).reduce((cur, acc) => Math.min(cur, acc), Infinity);

	const helper = memoize((pattern: string) => {
		let result = 0;
		if (available.has(pattern)) {
			result += 1;
		}

		if (pattern.length > minLength) {
			for (let i = minLength; i <= pattern.length - minLength; ++i) {
				const pat1 = pattern.substring(0, i);
				const pat2 = pattern.substring(i);
				if (available.has(pat1)) {
					const count = helper(pat2);
					result += count;
				}
			}
		}
		return result;
	
	});

	return helper(startPattern);
}

function solve1(data: Data) {
	let result = 0;
	for (const pattern of data.desired) {
		const flag = isPossibleDyn(pattern, data.available);
		// console.log(pattern, flag);
		if (flag) { result++; }
	}
	return result;
}

function solve2(data: Data) {
	let result = 0;
	for (const pattern of data.desired) {
		const count = countRecursive(pattern, data.available);
		// console.log(pattern, count);
		result += count;
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
