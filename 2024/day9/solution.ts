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

function solve2(data: Data) {
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

	console.log(blocks);
	const maxId = id - 1;
	// now take all the blocks and try to move earlier, move only once.
	for (let i = maxId; i >= 0; i--) {
		// find the block with the id...
		const blockPos = blocks.findIndex(j => j.id === i);
		assert(blockPos >= 0);
		// find a space that will take it
		const moveBlock = blocks[blockPos];
		console.log({ moveBlock });
		const freeSpacePos = blocks.findIndex(j => (j.free) && (j.length >= moveBlock.length));
		console.log({blockPos, freeSpacePos});
		if (freeSpacePos >= 0 && freeSpacePos < blockPos) {
			const newItems : BlockType[] = []; 
			const freeBlock = blocks[freeSpacePos];
			let remain = freeBlock.length - moveBlock.length;
			newItems.push({
				id: moveBlock.id,
				length: moveBlock.length,
				free: false
			});
			if (remain > 0) {
				newItems.push({
					id: -1,
					length: remain,
					free: true
				});
			}
			blocks.splice(freeSpacePos, 1, ...newItems);
			moveBlock.id = -1;
			moveBlock.free = true;

			// // merge contiguous free space...
			// if (blockPos + 1 < blocks.length && blocks[blockPos+1].free) {
			// 	// merge
			// 	moveBlock.length += blocks[blockPos+1].length;
			// 	blocks.splice(blockPos+1, 1);
			// }
			// if (blocks[blockPos-1].free) {
			// 	// merge
			// 	moveBlock.length += blocks[blockPos-1].length;
			// 	blocks.splice(blockPos-1, 1);
			// }
		}
		// console.log(blocks);
	}

	// calculate checksum
	let result = 0;
	let pos = 0;
	for (const block of blocks) {
		for (let i = 0; i < block.length; ++i) {
			if (!block.free) {
				result += pos * block.id;
			}
			pos++;
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
// console.log(solve1(data));
console.log(solve2(data));
