#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = string[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data;
}

function solve1(data: Data) {
	let result = 0;
	return result;
}

function solve2(data: Data) {
	let result = 0;
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
