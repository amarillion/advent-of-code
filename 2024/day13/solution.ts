#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Point } from '../common/point.js';


type RecordType = {
	a: Point;
	b: Point;
	p: Point;
};

type Data = RecordType[];

function parse(fname: string) {
	const segments = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	const blocks = segments.map(block => block.split('\n'));
	const result: RecordType[] = [];

	for(const block of blocks) {
		const m1 = block[0].match(/Button A: X(?<ax>[-+0-9]+), Y(?<ay>[-+0-9]+)/);
		const m2 = block[1].match(/Button B: X(?<bx>[-+0-9]+), Y(?<by>[-+0-9]+)/);
		const m3 = block[2].match(/Prize: X=(?<px>[-+0-9]+), Y=(?<py>[-+0-9]+)/);
		
		console.log(block);
		assert(m1);
		assert(m2);
		assert(m3);
		
		result.push({
			a: new Point(Number(m1.groups?.ax), Number(m1.groups?.ay)),
			b: new Point(Number(m2.groups?.bx), Number(m2.groups?.by)),
			p: new Point(Number(m3.groups?.px), Number(m3.groups?.py)),
		});
	}
	console.log(result);
	return result;
}

function solve1(data: Data) {
	let result = 0;
	for (const row of data) {
		
		// stelsel van vergelijkingen
		/*
		
		1: p * ax + q * bx = px
		2: p * ay + q * by = py

		*/

		// brute force...
		for (let p = 0; p < 100; ++p) {
			for (let q = 0; q < 100; ++q) {
				if ((p * row.a.x + q * row.b.x === row.p.x) && 
					(p * row.a.y + q * row.b.y === row.p.y)
				) {
					console.log({p, q}, p + q * 3);
					result += p * 3 + q;
					break;
				}
			} 
		}
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
