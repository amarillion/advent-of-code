#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js'
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { DefaultMap } from '../common/DefaultMap.js';
import { Point } from '../common/point.js';
import { breadthFirstSearch, bfsGenerator, trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';

function printMapSortedByKey<K, V>(map: { keys(): Iterable<K>, get(key: K): V }, comparator: (a: K, b: K) => number) {
	const keys = [...map.keys()];
	keys.sort(comparator);
	for (const key of keys) {
		console.log(`${key} ${map.get(key)}`);
	}
}

function find<T>(grid: TemplateGrid<T>, predicate: (t: T) => boolean) {
	for (let y = 0; y < grid.height; ++y) {
		for (let x = 0; x < grid.width; ++x) {
			const cell = grid.get(x, y);
			if (predicate(cell)) {
				return cell;
			}
		}
	}
	return null;
}

type Data = TemplateGrid<Cell>;
class Cell {
	x: number;
	y: number;
	char: string;
	constructor(_x: number, _y: number, _char: string) { this.x = _x; this.y = _y; this.char = _char; }
	toString() { 
		return `Cell(${this.x},${this.y} '${this.char}')`;
	}
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');

	// TODO: Grid type that tracks <Point, value> instead of <Cell>. Do I need separate Grid classes for reference types and value types?
	return new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, data[y][x]));
}


function solve(grid: Data, limit: number) {
	let result = 0;
	// find S and E
	const startCell = notNull(find(grid, cell => cell.char === 'S'));
	const endCell = notNull(find(grid, cell => cell.char === 'E'));

	const freePaths = function *(cell: Cell) {
		for (const [dir, other] of grid.getAdjacent(cell)) {
			if (other.char !== '#') {
				yield [dir, other] as [number, Cell];
			}
		}
	}

	// find shortest path from S to E
	const distanceToEnd = breadthFirstSearch(endCell, [], freePaths);

	// console.log({distanceToEnd});
	const relevantNodes = trackbackNodes(endCell, startCell, distanceToEnd).reverse();
	// console.log(noShortcutsMap);
	// const originalCost = distanceToStart.get(startCell)?.cost!;

	const frqMap = new DefaultMap<number, number>(0);
	for (const currentCell of relevantNodes) {
		// repeat, but activate invincibility after i picoseconds.
		
		// get all neighboring cells crossing a '#'
		const possibilities = new Set<Cell>();
		/*
		for (const [, second] of grid.getAdjacent(currentCell)) {
			if (second.char === '#') {
				for (const [, third] of grid.getAdjacent(second)) {
					if (third.char !== '#' && third !== currentCell) {
						possibilities.add(third);
					}
				}
			}
		}
		*/
		for (const possibility of bfsGenerator(currentCell, function *(cell) {
			const distance = Point.manhattan(Point.minus(currentCell, cell));
			if (distance >= limit) return;
			for (const [dir, other] of grid.getAdjacent(cell)) {
				// must start with a '#'
				if (distance === 0 && other.char !== '#') continue;
				yield [dir, other];
			}
		})) {
			if (possibility.char !== '#' && possibility !== currentCell) {
				possibilities.add(possibility);
			}
		}

		for (const cheatEnd of possibilities) {
			const cheatCost = Point.manhattan(Point.minus(currentCell, cheatEnd)); 
			// find shortest path from possibilites to E with two seconds invisibility
			// const newCost = distanceToEnd.get(cheatEnd)!.cost + distanceToStart.get(currentCell)!.cost + 1 /** add two for the cheat steps */;
			// let cheatSavings = originalCost - newCost;
			const cheatSavings = distanceToEnd.get(currentCell)!.cost - distanceToEnd.get(cheatEnd)!.cost - cheatCost /** two for cost of cheat itself */;
			if (cheatSavings > 0) {
				// console.log(`cheat start: ${currentCell}, distance to end: ${distanceToEnd.get(currentCell)?.cost}, cheat end: ${cheatEnd}, distance to end: ${distanceToEnd.get(cheatEnd)?.cost}, cheat length: ${cheatCost}, savings: ${cheatSavings}`);
				frqMap.update(cheatSavings, i => i + 1);
				if (cheatSavings >= 100) {
					result++;
				}
			}
		}
	}

	// console.log(frqMap.toString())
	printMapSortedByKey(frqMap, (a, b) => a - b);

	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data, 2));
console.log(solve(data, 20));

// answer part 2: 985374 too low.
// with 21 - 1115541 - not correct