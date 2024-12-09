#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = number[];

function parse(fname: string) {
	const raw = readFileSync(fname, { encoding: 'utf-8' }).split('\n')[0];
	return [...raw].map(Number);
}

type BlockType = { free: boolean, id: number, length: number };

function solve1(data: Data) {
	// first identify all blocks and block Ids
	const blocks: BlockType[] = []; 
	let free = false;
	let id = 0;
	for (const length of data) {
		blocks.push({
			id: (free ? -1 : id),
			free,
			length
		});
		if (!free) {
			id++;
		}
		free = !free;
	}

	// now take all the free bits and pop from the back.
	for (let pos = 0; pos < blocks.length - 1; ++pos) {
		if (blocks[pos].free) {
			// freeBlock will always be replaced
			const freeBlock = blocks[pos];
			
			const lastBlock = blocks[blocks.length-1];
			assert(!lastBlock.free);

			const newItems: BlockType[] = [];
			if (freeBlock.length >= lastBlock.length) {
				let remain = freeBlock.length - lastBlock.length;
				newItems.push({
					id: lastBlock.id,
					length: lastBlock.length,
					free: false
				});
				if (remain > 0) {
					newItems.push({
						id: -1,
						length: remain,
						free: true
					});
				}
				blocks.pop();
			}
			else {
				lastBlock.length -= freeBlock.length;
				newItems.push({
					length: freeBlock.length,
					id: lastBlock.id,
					free: false
				});
			}
			blocks.splice(pos, 1, ...newItems);
			
			// discard free ends
			while (blocks[blocks.length-1].free) {
				blocks.pop();
			}
		}
		// console.log(blocks);
	}
	// calculate checksum
	let result = 0;
	let pos = 0;
	for (const block of blocks) {
		for (let i = 0; i < block.length; ++i) {
			assert(!block.free);
			result += pos * block.id;
			pos++;
		}
	}
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
