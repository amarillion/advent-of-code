#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Point } from '../common/geom/point.js';

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
		
		assert(m1);
		assert(m2);
		assert(m3);
		
		result.push({
			a: new Point(Number(m1.groups?.ax), Number(m1.groups?.ay)),
			b: new Point(Number(m2.groups?.bx), Number(m2.groups?.by)),
			p: new Point(Number(m3.groups?.px), Number(m3.groups?.py)),
		});
	}
	return result;
}

function solve2(data: Data, part2 = false) {
	let result = 0;
	for (const row of data) {
		
		const { a, b } = row;
		const p = part2 ? new Point (row.p.x + 10000000000000, row.p.y + 10000000000000) : row.p;

		// stelsel van vergelijkingen
		// system of equations
		// TODO: generic matrix solver
		/*
		1: u * ax + v * bx = px
		2: u * ay + v * by = py
		
		u * 94 + v * 22 = 8400
		u * 34 + v * 67 = 5400
		
		u = 8400/94 - v * 22/94
		8400/94*34 - v *22/94*34 + v * 67 = 5400
		v * (67 - 22/94*34) = 5400 - 8400/94*34
		v = (5400 - 8400/94*34) / (67 - 22/94*34)
		v = p.y - (p.x/a.x*a.y) / (b.y - (b.x / a.x * a.y))
		*/

		const v = Math.round((p.y - (p.x /a.x *a.y)) / (b.y - (b.x / a.x * a.y)));
		const u = Math.round((p.x / a.x) - (v * b.x / a.x));

		if ((u * a.x + v * b.x === p.x) && 
			(u * a.y + v * b.y === p.y)
		) {
			result += u * 3 + v;
		}
		// else: no integer solution

	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve2(data, false));
console.log(solve2(data, true));
