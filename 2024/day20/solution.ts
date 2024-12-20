#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js'
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { DefaultMap } from '../common/DefaultMap.js';
import { breadthFirstSearch } from '@amarillion/helixgraph/lib/pathFinding.js';

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
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');

	// TODO: Grid type that tracks <Point, value> instead of <Cell>. Do I need separate Grid classes for reference types and value types?
	return new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, data[y][x]));
}


function solve1(grid: Data) {
	let result = 0;
	// find S and E
	const startCell = notNull(find(grid, cell => cell.char === 'S'));
	const endCell = notNull(find(grid, cell => cell.char === 'E'));

	// find shortest path from S to E
	const noShortcutsMap = breadthFirstSearch(startCell, endCell, function *(cell: Cell)  {
		for (const [dir, other] of grid.getAdjacent(cell)) {
			if (other.char !== '#') {
				yield [dir, other];
			}
		}
	});
	// console.log(noShortcutsMap);
	const originalCost = noShortcutsMap.get(endCell)?.cost!;

	const frqMap = new DefaultMap<number, number>(0);
	let currentCell = endCell;
	do {
		currentCell = notNull(noShortcutsMap.get(currentCell)?.from);
		// repeat, but activate invincibility after i picoseconds.
		
		// get all neighboring cells crossing a '#'
		const possibilities = new Set<Cell>();
		for (const [, second] of grid.getAdjacent(currentCell)) {
			if (second.char === '#') {
				for (const [, third] of grid.getAdjacent(currentCell)) {
					if (third.char !== '.' && third !== currentCell) {
						possibilities.add(third);
					}
				}
			}
		}

		for (const cheatEnd of possibilities) {
			// find shortest path from possibilites to E with two seconds invisibility
			const cheatMap = breadthFirstSearch(cheatEnd, endCell, function *(cell: Cell)  {
				for (const [dir, other] of grid.getAdjacent(cell)) {
					if (other.char !== '#') {
						yield [dir, other];
					}
				}
			});
			if (cheatMap.has(endCell)) {
				const newCost = cheatMap.get(endCell)!.cost + noShortcutsMap.get(currentCell)!.cost + 1 /** add two for the cheat steps */;
				let cheatSavings = originalCost - newCost;
				frqMap.update(cheatSavings, i => i + 1);
				if (cheatSavings >= 100) {
					result++;
				}
			}
		}
	}

	while (currentCell !== startCell)
	
	console.log(frqMap.toString())
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
