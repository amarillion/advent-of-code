#!/usr/bin/env tsx

import { readFileSync } from 'fs';

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(l => l.split(/\s+/).map(Number));
	const left = data.map(row => row[0]).sort((a, b) => a - b);
	const right = data.map(row => row[1]).sort((a, b) => a - b);
	return { left, right };
}

function solve1({ left, right } : { left: number[], right: number[] }) {
	let result = 0;
	for(let i = 0; i < left.length; ++i) {
		result += Math.abs(left[i] - right[i]);
	}
	return result;
}

function solve2({ left, right } : { left: number[], right: number[] }) {
	const frqMap = new Map<number, number>()
	for(const i of right) {
		const oldFrq = frqMap.get(i) || 0;
		frqMap.set(i, oldFrq + 1);
	}
	let result = 0;
	for (const i of left) {
		const frq = frqMap.get(i) || 0;
		result += i * frq;
	}
	return result;
}

const testData = parse('test-input');
console.log(solve2(testData));
const data = parse('input');
console.log(solve1(data));
console.log(solve2(data));