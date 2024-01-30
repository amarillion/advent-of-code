#!/usr/bin/env tsx
import { breadthFirstSearch } from '@amarillion/helixgraph';
import { trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { readFileSync } from 'fs';

let raw = readFileSync('input').toString('utf-8');

let lines = raw.split('\n');
const width = lines[0].length;
const height = lines.length;

function find(needle: string) {
	const rawIndex = raw.indexOf(needle)
	const x = rawIndex % (width + 1);
	const y = Math.floor (rawIndex / (width + 1));
	return (x + y * width);
}

function *getAdjacent(node: number) {
	const x = node % width;
	const y = Math.floor (node / width);

	const dd = [
		{ dx: 0, dy: -1 },
		{ dx: 0, dy: 1 },
		{ dx: 1, dy: 0 },
		{ dx: -1, dy: 0 }
	]
	for (let i = 0; i < 4; ++i) {
		const { dx, dy } = dd[i];
		const nx = x + dx;
		const ny = y + dy;

		console.log(i, x, y, dx, dy, nx, ny);
		if (nx < 0) continue;
		if (ny < 0) continue;
		if (nx >= width) continue;
		if (ny >= height) continue;

		const char = lines[y][x];
		const neighbourChar = lines[ny][nx];

		const delta = neighbourChar.charCodeAt(0) - char.charCodeAt(0);
		if (delta >= -1) {
			const idx = nx + ny * width;
			yield [ i, idx ] as [ number, number ];
		}
	}

}

const start = find("S");
const dest = find("E");
raw = raw.replace("S", "a").replace("E", "z");
lines = raw.split("\n");

const prevMap = breadthFirstSearch(
	dest, [], getAdjacent
)

console.log(prevMap);

let min = Number.MAX_SAFE_INTEGER;

for (let i = 0; i < width * height; ++i) {
	let x = i % width;
	let y = Math.floor(i / width);
	let char = lines[y][x];
	if (char === "a") {
		const result = trackbackNodes(dest, i, prevMap);
		console.log(i, result && result.length-1);
		if (result) {
			if (result.length-1 < min) {
				min = result.length-1;
			}
		}

	}
}
console.log("MIN", min);