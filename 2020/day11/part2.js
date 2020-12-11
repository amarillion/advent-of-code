#!/usr/bin/env node

import { assert } from '../common/assert.js';
import { readLines } from '../common/readers.js';

class Grid {

	constructor(width, height) {
		this.width = width; 
		this.height = height;
		this.data = [];
	}

	indexOf(x, y) {
		return (this.width * y) + x;
	}

	inRange(x, y) {
		return x >= 0 && y >= 0 && x < this.width && y < this.height;
	}

	get(x, y) {
		assert(this.inRange(x, y));
		return this.data[this.indexOf(x, y)];
	}

	set(x, y, val) {
		assert(this.inRange(x, y));
		this.data[this.indexOf(x, y)] = val;
	}

	*neighbors(x, y) {
		const n = [
			{ dx: +1, dy: +1 },
			{ dx: +1, dy:  0 },
			{ dx: +1, dy: -1 },
			{ dx:  0, dy: +1 },
			{ dx:  0, dy: -1 },
			{ dx: -1, dy: +1 },
			{ dx: -1, dy:  0 },
			{ dx: -1, dy: -1 },
		];
		for (const {dx, dy} of n) {
			if (this.inRange(x + dx, y + dy)) {
				yield this.get(x + dx, y + dy);
			}
		}
	}

	static async fromFile(fname) {
		const lines = await readLines(fname);
		const width = lines[0].length;
		const height = lines.length;
		const result = new Grid(width, height);
		result.data = lines.join('').split('');
		return result;
	}

	print() {
		for (let y = 0; y < this.height; ++y) {
			let row = this.data.slice(y * this.width, (y + 1) * this.width);
			console.log(row.join(''));
		}
	}
}


// note, doesn't check for match at x, y
function look(grid, x, y, dx, dy) {
	let xx = x;
	let yy = y;
	xx += dx;
	yy += dy;
		
	while(grid.inRange(xx, yy)) {
		if (grid.get(xx, yy) === '#') {
			return true;
		}
		if (grid.get(xx, yy) === 'L') {
			return false;
		}
		xx += dx;
		yy += dy;
	}
	return false;
}

function look8(grid, x, y) {
	const n = [
		{ dx: +1, dy: +1 },
		{ dx: +1, dy:  0 },
		{ dx: +1, dy: -1 },
		{ dx:  0, dy: +1 },
		{ dx:  0, dy: -1 },
		{ dx: -1, dy: +1 },
		{ dx: -1, dy:  0 },
		{ dx: -1, dy: -1 },
	];
	let count = 0;
	for (const {dx, dy} of n) {
		if (look(grid, x, y, dx, dy)) { count++; }
	}
	return count;
}

function tick(grid) {
	let newGrid = new Grid(grid.width, grid.height); 

	for (let x = 0; x < grid.width; ++x) {
		for (let y = 0; y < grid.height; ++y) {
			let count = look8(grid, x, y);
			let seat = grid.get(x, y);
			let newSeat = seat;
			if (seat === 'L' && count === 0) {
				newSeat = '#';	
			}
			else if (seat === '#' && count >= 5) {
				newSeat = 'L';
			}
			newGrid.set(x, y, newSeat);
		}
	}
	return newGrid;
}

async function main() {	
	// let result = 0;
	let grid = await Grid.fromFile('input');
	grid.print();

	const history = {};
	let running = true;
	console.log('='.repeat(20));
	while(running) {
		const key = grid.data.join('');
		if (key in history) {
			console.log('Repeating!');
			running = false;
		}
		history[key] = 1;
		grid = tick(grid);
		grid.print();
		console.log('='.repeat(20));
	}

	console.log(grid.data.filter(ch => ch === '#').length);
	// console.log(history);
}

main();
