#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js'
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { breadthFirstSearch, trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { find } from '../common/objectGrid.js';
import { diamondRange } from '../common/pointRange.js';

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

function solve(grid: Data, limit: number, cutoff: number) {	
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

	// calculate distances from any node to end
	const distanceToEnd = breadthFirstSearch(endCell, [], freePaths);
	
	const relevantNodes = trackbackNodes(endCell, startCell, distanceToEnd).reverse();

	// const frqMap = new DefaultMap<number, number>(0);
	for (const currentCell of relevantNodes) {
		
		const currentCost = distanceToEnd.get(currentCell)!.cost; 

		// get all neighboring cells in a diamond shape
		for (const delta of diamondRange(limit)) {

			const pos = delta.plus(currentCell);
			if (!grid.inRange(pos.x, pos.y)) continue;
			
			const cheatEnd = grid.get(pos.x, pos.y);
			if (cheatEnd.char !== '#' && cheatEnd !== currentCell) {
				const cheatCost = delta.manhattan(); 
				const cheatSavings = currentCost - distanceToEnd.get(cheatEnd)!.cost - cheatCost;
				// if (cheatSavings > 0) {
				// 	frqMap.update(cheatSavings, i => i + 1);
				// }
				if (cheatSavings >= cutoff) {
					result++;
				}
			}
		}
	}

	// console.log(sortedMapToString(frqMap, (a, b) => a - b));
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
const cutoff = process.argv[2].startsWith('test') ? 50: 100;
console.log(solve(data, 2, cutoff));
console.log(solve(data, 20, cutoff));
