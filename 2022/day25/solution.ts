#!/usr/bin/env tsx-esm

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

function fromSNAFU(snafu: string): number {
	let positional = 1;
	let sum = 0;
	
	const DIGIT_VALUES = {
		'=': -2,
		'-': -1,
		'0': 0,
		'1': 1,
		'2': 2
	};
	for (const digit of [...snafu].reverse()) {
		sum += DIGIT_VALUES[digit] * positional;
		positional *= 5;
	}
	return sum;
}

function toSNAFU(value: number): string {

	let remain = value;
	let positional = 1;
	let result = '';
	let carry = false;

	const DIGITS = {
		[ 0]: '0',
		[ 1]: '1',
		[ 2]: '2',
		[ 3]: '=',
		[ 4]: '-',
	};
	
	while (remain > 0) {
		let digit = (remain % (positional * 5)) / positional;
		
		remain -= (digit * positional)
		result = DIGITS[digit] + result;
		if (digit > 2) { 
			remain += (5 * positional)
		}

		positional *= 5;
		console.log({ result, remain });
	}

	return result;
}

function solve(fname: string) {
	const raw = readFileSync(fname, { encoding: 'utf-8' });
	let sum = 0;
	for (const line of raw.split('\n')) {
		const val = fromSNAFU(line);
		console.log(`${line}\t\t${val}`);
		sum += val;
	}
	const result = toSNAFU(sum);
	console.log(sum, result);
	return result;
}


assert(fromSNAFU("1=-0-2") === 1747);
assert(fromSNAFU("20012") === 1257);
assert(toSNAFU(63) === "1===");

assert(solve('test-input') === '2=-1=0');
console.log(solve('input'));