import { assert } from '../common/assert.js';
import { readLines } from '../common/readers.js';

export class Grid {

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
