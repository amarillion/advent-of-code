import { readFileSync } from 'fs';
import { IPoint } from './point';
import { pointRange } from './pointRange';

/**
 * Distinct from TemplateGrid because it stores literal values rather than objects...
 */
export class ValueGrid<T> {
	data: T[][];
	width: number;
	height: number;

	constructor(data: T[][], width: number, height: number) {
		this.data = data;
		this.width = width;
		this.height = height;
	}

	inRange ({ x, y }: {x: number, y: number}) {
		return x >= 0 && y >= 0 && x < this.width && y < this.height;
	}

	find (needle: T) {
		return find(this.data, needle)
	}

	set(p: IPoint, value: T) {
		this.data[p.y][p.x] = value;
	}

	get(p: IPoint) {
		return this.data[p.y][p.x];
	}

	toString () {
		return this.data.map(line => line.join('')).join('\n');
	}

	forEach(callback: (val: T, pos: { x: number, y: number }) => void) {
		pointRange(this.width, this.height, (x, y) => {
			const p = { x, y };
			callback(this.get(p), p);
		});
	}

	findAll(needle: T) {
		return findAll(this.data, needle);
	}
}

export function readGridFromFile(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(line => [...line]);
	return createGrid(data);
}

export function createEmptyGrid<T>(size: IPoint, init: (p: IPoint) => T) {
	const data: T[][] = [];

	for (let y = 0; y < size.y; ++y) {
		const row: T[] = [];
		for (let x = 0; x < size.x; ++x) {
			row.push(init({ x, y }));
		}
		data.push(row);
	}

	return createGrid(data);
}

export function createGrid<T>(data: T[][]): ValueGrid<T> {
	return new ValueGrid(data, data[0].length, data.length);
}

export function *walk<T>(grid: ValueGrid<T>, ix: number, iy: number, dx: number, dy: number) {
	let x = ix;
	let y = iy;
	while (grid.inRange({ x, y })) {
		yield grid.get({ x, y });
		x += dx;
		y += dy;	
	}
}

export function find<T>(grid: T[][], needle: T) {
	const width = grid[0].length;
	const height = grid.length;
	for (let y = 0; y < height; ++y) {
		for (let x = 0; x < width; ++x) {
			if (grid[y][x] === needle) {
				return { x, y };
			}
		}
	}
	return null;
}

export function findAll<T>(grid: T[][], needle: T) {
	let result: {x: number, y: number}[] = [];
	const width = grid[0].length;
	const height = grid.length;
	pointRange(width, height, (x, y) => {
		if (grid[y][x] === needle) {
			result.push({x, y});
		}
	});
	return result;
}
