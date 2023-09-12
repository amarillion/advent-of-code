import { assert } from './assert.js';

/**
 * All possible pairs from an array of data; 
 * @param {*} data 
 */
export function* allPairs(data) {
	assert(data.length >= 2);
	for (let i = 1; i < data.length; ++i) {
		for (let j = 0; j < i; ++j) {
			yield [data[i], data[j]];
		}
	}
}

/**
 * all possible contiguous slices of an array,
 * including slices of length 1
 * starts with short slices and builds up to maximum length
 * @param {*} data 
 */
export function* allSlices(data) {
	for (let len = 1; len <= data.length; ++len) {
		for (let start = 0; start <= data.length - len; ++start) {
			yield data.slice(start, start + len);
		}
	}
}

// source: https://stackoverflow.com/a/37580979/3306
// using Heap's algorithm...
export function* permute(permutation) {
	const length = permutation.length;
	const c = Array(length).fill(0);
	let i = 1, k;

	yield permutation.slice();
	while (i < length) {
		if (c[i] < i) {
			k = i % 2 && c[i];
			[ permutation[i], permutation[k] ] = [ permutation[k], permutation[i] ]; 
			++c[i];
			i = 1;
			yield permutation.slice();
		} else {
			c[i] = 0;
			++i;
		}
	}
}
