#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { IPoint, Point } from '../common/point.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = { p: Point, v: Point }[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data.map(line => {
		const m = line.match(/p=(?<px>-?\d+),(?<py>-?\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)/);
		
		assert(m && m.groups);
		const { px, py, vx, vy } = m.groups;
		return { p : new Point(Number(px), Number(py)), v: new Point(Number(vx), Number(vy)) };
	});
}

function solve1(data: Data, area: Point) {
	for (let i = 0; i < 100; ++i) {
		console.log(i, data);
		for (const row of data) {
			row.p = row.p.plus(row.v).wrap(area);
		}
	}

	// assign quadrant to each
	const frqMap = new DefaultMap<number, number>(0);
	const middle = area.minus({x : 1, y: 1}).mul(0.5);
	console.log(middle);
	for (const row of data) {
		// skip the ones on the center
		if (row.p.x === middle.x) continue;
		if (row.p.y === middle.y) continue;
		let idx = 0;
		if (row.p.x > middle.x) idx += 1;
		if (row.p.y > middle.y) idx += 2;
		frqMap.update(idx, val => val + 1);
	}

	console.log(frqMap);

	let result = 1;
	for (const val of frqMap.values()) {
		result *= val;
	}

	return result;
}

class ValueGrid<T> {
	data: T[][] = [];

	constructor (size: Point, init: (p: IPoint) => T) {
		for (let y = 0; y < size.y; ++y) {
			const row: T[] = [];
			for (let x = 0; x < size.x; ++x) {
				row.push(init({ x, y }));
			}
			this.data.push(row);
		}
	}

	toString() {
		return this.data.map(row => row.map(cell => `${cell}`).join('')).join('\n');
	}
}

function solve2(data: Data, area: Point) {
	let max = 0;
	let maxIdx = 0;
	
	for (let i = 0; true; i++) {
		const grid = new ValueGrid<string>(area, () => '.');
		const map = new Set<string>();
		for (const row of data) {
			row.p = row.p.plus(row.v).wrap(area);
			map.add(row.p.toString());
			grid.data[row.p.y][row.p.x] = '#';
		}

		// count # symmetrical around central-axis
		for (let axis = 10; axis < area.x - 10; ++axis) {
			let symmetryCount = 0;
			for (const row of data) {
				let symmetrical = new Point(axis + (axis - row.p.x), row.p.y);
				if (map.has(symmetrical.toString())) {
					symmetryCount++;
				}
			}

			if (symmetryCount > max) {
				max = symmetryCount;
				maxIdx = i;
				console.log({ symmetryCount, i }, data.length);
				console.log(grid.toString());
				if (symmetryCount === data.length) { break; }
			}
	
		}

		if (i % 100000 === 0) console.log(i);

	return maxIdx;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);

const area = process.argv[2].startsWith('test') ? new Point(11, 7) : new Point(101, 103);
console.log(solve1(data, area));
console.log(solve2(data, area));

// Found xmas tree at iteration 7791, but is not correct answer.
// Must be something with *all* robots falling within the borders of the tree
// attempt reverse calculation...