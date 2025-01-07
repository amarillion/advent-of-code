import { readFileSync } from 'fs';
import { IPoint } from './point';

/**
 * Distinct from TemplateGrid because it stores literal values rather than objects...
 */
class ValueGrid<T> {
	data: T[][];
	width: number;
	height: number;

	constructor(data: T[][], width: number, height: number) {
		this.data = data;
		this.width = width;
		this.height = height;
	}

	inRange (p: {x: number, y: number}) {
		return inRange(this.data, p.x, p.y)
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

	findAll(needle: T) {
		return findAll(this.data, needle);
	}
}

export type Grid = ReturnType<typeof createGrid>

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

export function inRange<T>(data: T[][], x: number, y: number) {
	return x >= 0 && y >= 0 && x < data[0].length && y < data.length; 
}

export function *walk(data: string[][], x: number, y: number, dx: number, dy: number) {
	let xx = x;
	let yy = y;
	while (inRange(data, xx, yy)) {
		yield data[yy][xx]
		xx += dx;
		yy += dy;	
	}
}

// TODO: iterator utils
export function take<T>(generator: Generator<T>, num: number) {
	const result: T[] = [];
	let i = 0;
	for (const val of generator) {
		result.push(val);
		i++;
		if (i === num) { return result; }
	}
	return result;
}

export function eachRange(width: number, height: number, callback: (x: number, y: number) => void) {
	for (let y = 0; y < height; ++y) {
		for (let x = 0; x < width; ++x) {
			callback(x, y);
		}
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
	eachRange(width, height, (x, y) => {
		if (grid[y][x] === needle) {
			result.push({x, y});
		}
	});
	return result;
}
