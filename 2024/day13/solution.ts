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
		
		// brute force...
		for (let u = 0; u < 100; ++u) {
			for (let v = 0; v < 100; ++v) {
				if ((u * row.a.x + v * row.b.x === row.p.x) && 
					(u * row.a.y + v * row.b.y === row.p.y)
				) {
					console.log({p: u, q: v}, u + v * 3);
					result += u * 3 + v;
					break;
				}
			} 
		}
	}
	return result;
}

function solve2(data: Data) {
	let result = 0;
	for (const row of data) {
		
		row.p.x += 10000000000000;
		row.p.y += 10000000000000;
		
		console.log(row);

		// stelsel van vergelijkingen
		// system of equations
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

		const { p, a, b } = row;
		const v = Math.round((p.y - (p.x /a.x *a.y)) / (b.y - (b.x / a.x * a.y)));
		const u = Math.round((p.x / a.x) - (v * b.x / a.x));
		console.log(`${u} * ${a.x} + ${v} * ${b.x} = ${u * a.x + v * b.x} (expected ${p.x})`, u * 3 + v);

		if ((u * a.x + v * b.x === p.x) && 
		(u * a.y + v * b.y === p.y)
		) {
			console.log({p: u, q: v}, u + v * 3);
			result += u * 3 + v;
		}

	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
