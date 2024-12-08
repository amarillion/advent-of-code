import { readFileSync } from 'fs';

export type Grid = string[][];

/** @deprecated */
export function readGridFromFile(fname: string) {
	return readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(line => [...line]);
}

export function readGridFromFileEx(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(line => [...line]);
	return createGrid(data);
}

export function createGrid(data: string[][]) {
	return {
		data,
		width: data[0].length,
		height: data.length,
		inRange: (p: {x: number, y: number}) => inRange(data, p.x, p.y)
	};
}

export function inRange(data: string[][], x: number, y: number) {
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
	for (let y = 0; y < width; ++y) {
		for (let x = 0; x < height; ++x) {
			callback(x, y);
		}
	}
}

export function find(grid: Grid, needle: string) {
	const width = grid[0].length;
	const height = grid.length;
	for (let y = 0; y < width; ++y) {
		for (let x = 0; x < height; ++x) {
			if (grid[y][x] === needle) {
				return { x, y };
			}
		}
	}
	return null;
}

export function findAll(grid: Grid, needle: string) {
	let result: {x: number, y: number}[] = []
	eachRange(grid[0].length, grid.length, (x, y) => {
		if (grid[y][x] === needle) {
			result.push({x, y});
		}
	});
	return result;
}
