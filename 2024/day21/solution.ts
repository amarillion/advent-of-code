#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Point } from '../common/geom/point.js';
import { ValueGrid } from '../common/grid.js';
import { dijkstraEx } from '../day16/dijkstraEx.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = string[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data;
}

type NodeType = `${number},${number}`;
type DirType = '^' | '<' | '>' | 'v';

class MaskedGrid extends ValueGrid<string> {

	private readonly mask: string[][];
	
	constructor (values: string, mask: string) {
		const rows = values.split('\n')
		super(rows.map(s => [...s]), rows[0].length, rows.length);
		this.mask = mask.split('\n').map(s => [...s]);
	}

	inRangeMasked ({ x, y }: {x: number, y: number}) {
		const inside = x >= 0 && y >= 0 && x < this.width && y < this.height;
		if (!inside) return false;
		return this.mask[y][x] === ' ';
	}

	*adjacent(node: NodeType): Iterable<[DirType, NodeType]> {
		const [x, y] = node.split(',').map(s => Number(s));
		const DELTA = {
			'>': { x: 1, y: 0 },
			'v': { x: 0, y: 1 },
			'<': { x: -1, y: 0 },
			'^': { x: 0, y: -1 },
		}
		for (const [dir, delta] of Object.entries(DELTA)) {
			const npos = Point.plus({x, y}, delta);
			if (this.inRangeMasked(npos)) {
				yield [dir as DirType, Point.toString(npos)];
			}
		}
	}
}

function createMaskedGrid(values: string, mask: string): MaskedGrid {
	return new MaskedGrid(values, mask);
}

function trackbackAll(src: NodeType, dest: NodeType, map: DefaultMap<NodeType, { edge: DirType, from: NodeType, to: NodeType, cost: number }[]>) {
	
	function recursiveHelper(partials: string[], src: NodeType, pos: NodeType, map: DefaultMap<NodeType, { edge: DirType, from: NodeType, to: NodeType, cost: number }[]>) {
		let result: string[] = [];
		const edges = map.get(pos);
		for (const edge of edges) {
			
			let child = edge.from;
			let appended = partials.map(l => edge.edge + l)
			if (child !== src) {
				appended = recursiveHelper(appended, src, child, map);
			}

			result = result.concat(appended)
		}
		return result;
	}

	return recursiveHelper([ '' ], src, dest, map);
	// TODO: recursively find all paths...
}

function findAllSequences(grid: MaskedGrid, code: string) {
	let pos = grid.find('A')
	assert(pos !== null, `Expected 'A' to be found`)

	let result: string[] = [''];

	for (const digit of code) {
		const dest = grid.find(digit);
		assert(dest !== null, `Expected '${digit}' to be found`);
		
		// TODO: return all possible sequences, because it might give better results!
		const prevMap = dijkstraEx<NodeType, DirType>(Point.toString(pos), Point.toString(dest), (n) => grid.adjacent(n));
	
		// console.log(`From ${Point.toString(pos)} ${grid.get(pos)} to ${Point.toString(dest)} ${grid.get(dest)}`);
		// for (const key of prevMap.keys()) {
		// 	console.log(key, prevMap.get(key));
		// }

		if (Point.toString(pos) === Point.toString(dest)) {
			result = result.map(line => line + 'A');
		}
		else {
			const paths = trackbackAll(Point.toString(pos), Point.toString(dest), prevMap);

			// TODO: should just return an empty list when source === dest

			// console.log(paths);
			// result += path.join('') + 'A';
			result = result.flatMap(line => paths.map(p => line + p + 'A'));
		}

		pos = dest;
	}
	
	return result;
}

function solve1(data: Data) {
	let result = 0;

	const mainKeyPad = createMaskedGrid(`\
789
456
123
 0A`, `\
   
   
   
X  `);

	const directionalKeyPad = createMaskedGrid(`\
 ^A
<v>`, `\
X  
   `);

	const isDigit = (ch: string) => ch >= '0' && ch <= '9';
	for (const code of data) {
		console.log(code);
		const sequences = findAllSequences(mainKeyPad, code);
		// console.log(sequences);
		const robot1 = sequences.flatMap(sequence => findAllSequences(directionalKeyPad, sequence));
		// console.log(robot1);
		const manualEntry = robot1.flatMap(rr => findAllSequences(directionalKeyPad, rr));

		let minLen = manualEntry[0].length;
		let minEntry = manualEntry[0];
		for (const entry of manualEntry) {
			if (entry.length < minLen) { 
				minLen = entry.length; 
				minEntry = entry;
			}
		}
		console.log(minLen, minEntry);
		const id = Number([...code].filter(isDigit).join(''));
		const complexity = minLen * id;

		console.log(`${id} * ${minLen} = ${complexity}`)

		result += complexity;
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
