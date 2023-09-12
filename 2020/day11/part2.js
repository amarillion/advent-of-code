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

	*scan(x, y, dx, dy) {
		let xx = x;
		let yy = y;
		while (this.inRange(xx, yy)) {
			yield(this.get(xx, yy));
			xx += dx;
			yy += dy;
		}
	}

	static async fromFile(fname) {
		const lines = await readLines(fname);
		const width = lines[0].length;
		const height = lines.length;
		const result = new Grid(width, height);
		result.data = lines.join('').split('');
		assert(result.data.length === width * height);
		return result;
	}

	/** create a copy of the grid, applying the transform function to each (x,y) pair */
	transform(cellFunc) {
		let result = new Grid(this.width, this.height);
		for (let y = 0; y < this.height; ++y) {
			for (let x = 0; x < this.width; ++x) {
				result.set(x, y, cellFunc(x, y));
			}
		}
		return result;
	}

	print() {
		for (let y = 0; y < this.height; ++y) {
			let row = this.data.slice(y * this.width, (y + 1) * this.width);
			console.log(row.join(''));
		}
	}
}


function look(grid, x, y, dx, dy) {
	// note: we skip position at x, y
	for (const ch of grid.scan(x + dx, y + dy, dx, dy)) {
		if (ch === '#') return true;
		if (ch === 'L') return false;
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
	return grid.transform(
		(x, y) => {
			let count = look8(grid, x, y);
			let seat = grid.get(x, y);
			if (seat === 'L' && count === 0) {
				return '#';	
			}
			else if (seat === '#' && count >= 5) {
				return 'L';
			}
			return seat;
		}
	);
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
