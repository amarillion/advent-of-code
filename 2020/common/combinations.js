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
