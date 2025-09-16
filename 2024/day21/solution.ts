#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Point } from '../common/geom/point.js';
import { ValueGrid } from '../common/grid.js';
import { dijkstraEx } from '../day16/dijkstraEx.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = string[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').filter(l => !l.startsWith('#'));
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

function trackbackAll(src: NodeType, dest: NodeType, map: ReturnType<typeof dijkstraEx<NodeType, DirType>>) {
	
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

// TODO: make more generic!
function memoize1<F extends (a: string) => string[][]>(func: F): F {
	const cache = new Map<string, string[][]>();
	return ((a: string): string[][] => {
		if (cache.has(a)) {
			return cache.get(a)!;
		}
		else {
			const result = func(a);
			cache.set(a, result);
			return result;
		}
	}) as F; //TODO - how to avoid cast here?
}

function memoize2<F extends (a: string, b: number) => number>(func: F): F {
	const cache = new Map<number, Map <string, number>>();
	return ((a: string, b: number): number => {
		if (!cache.has(b)) {
			cache.set(b, new Map<string, number>());
		}
		
		const elt = cache.get(b)!;
		if (!elt.has(a)) {
			elt.set(a, func(a, b));
		}

		return elt.get(a)!;
	}) as F; //TODO - how to avoid cast here?
}

function findAllSequences(grid: MaskedGrid, code: string): string[][] {
	let pos = grid.find('A')
	assert(pos !== null, `Expected 'A' to be found`)

	let result: string[][] = [];

	for (const digit of code) {
		const dest = grid.find(digit);
		assert(dest !== null, `Expected '${digit}' to be found`);
		
		if (Point.toString(pos) === Point.toString(dest)) {
			result.push (['A']);
		}
		else {
			// TODO: return all possible sequences, because it might give better results!
			const prevMap = dijkstraEx<NodeType, DirType>(Point.toString(pos), Point.toString(dest), (n) => grid.adjacent(n));
			// TODO: should just return an empty list when source === dest
			const paths = trackbackAll(Point.toString(pos), Point.toString(dest), prevMap);
			result.push(paths.map(p => p + 'A'));
		}
		pos = dest;
	}
	
	return result;
}

function solver(data: Data, nesting: number) {
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

	const mainKeyPadSequence = memoize1((code: string) => findAllSequences(mainKeyPad, code));
	const dirKeyPadSequence = memoize1((code: string) => findAllSequences(directionalKeyPad, code));

	const isDigit = (ch: string) => ch >= '0' && ch <= '9';
	
	function getChoice(choice: string, level: number): number {
		assert(level >= 0, "Unnested beyond root");
		if (level === 0) {
			return choice.length;
		}
		else {
			const sections = dirKeyPadSequence(choice);
			let result = 0;
			for (const elt of sections.map(section => getMinChoice(section, level - 1))) {
				result += elt;
			}
			return result;
		}
	}

	const choiceGetter = memoize2(getChoice);

	function getMinChoice(choices: string[], level: number) {
		const expanded = choices.flatMap(c => choiceGetter(c, level));
		let minElt = expanded[0];
		for (const elt of expanded) {
			if (elt < minElt) {
				minElt = elt;
			}
		}
		return minElt;
	}

	for (const code of data) {		
		// console.log(code);
		const sections = mainKeyPadSequence(code);
		
		const minLen = sections.map(section => getMinChoice(section, nesting)).reduce((acc, cur) => cur + acc, 0);
		// console.log(minLen);

		const id = Number([...code].filter(isDigit).join(''));
		const complexity = minLen * id;

		result += complexity;
	}

	return result;
}

function solve2(data: Data) {
	return solver(data, 25);
}

function solve1(data: Data) {
	return solver(data, 2);
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
