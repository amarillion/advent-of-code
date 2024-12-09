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
	const { blocks } = parseBlocks(data);

	// now take all the free bits and pop from the back.
	for (let pos = 0; pos < blocks.length - 1; ++pos) {
		if (blocks[pos].free) {
			const lastBlock = blocks[blocks.length-1];
			assert(!lastBlock.free);

			moveBlockToFreeSpace(blocks, pos, blocks.length-1);
			
			// discard free ends
			while (blocks[blocks.length-1].free) {
				blocks.pop();
			}
		}
		// console.log(blocks);
	}

	return checkSum(blocks);
}

function checkSum(blocks: BlockType[]) {
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

function parseBlocks(data: Data) {
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

	const maxId = id - 1;
	return { maxId, blocks };
}

/** move into free space, with space available */
function moveBlockToFreeSpace(blocks: BlockType[], freePos: number, movePos: number) {
	const newItems : BlockType[] = []; 
	const freeBlock = blocks[freePos];
	const moveBlock = blocks[movePos];
	if (freeBlock.length >= moveBlock.length) {
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
		moveBlock.id = -1;
		moveBlock.free = true;
	}
	else {
		moveBlock.length -= freeBlock.length;
		newItems.push({
			length: freeBlock.length,
			id: moveBlock.id,
			free: false
		});
	}
	blocks.splice(freePos, 1, ...newItems);
}

function solve2(data: Data) {
	const { blocks, maxId } = parseBlocks(data);
	// now take all the blocks and try to move earlier, move only once.
	for (let i = maxId; i >= 0; i--) {
		// find the block with the id...
		// TODO: linear search can be optimized
		const blockPos = blocks.findIndex(j => j.id === i);
		assert(blockPos >= 0);
		// find a space that will take it
		const moveBlock = blocks[blockPos];
		// TODO: linear search can be optimized
		const freeSpacePos = blocks.findIndex(j => (j.free) && (j.length >= moveBlock.length));
		if (freeSpacePos >= 0 && freeSpacePos < blockPos) {
			moveBlockToFreeSpace(blocks, freeSpacePos, blockPos);
		}
	}

	// calculate checksum
	return checkSum(blocks);
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
