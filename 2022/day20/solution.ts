#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Node, Dlist, skip } from '../common/dlist.js';

function shiftDown<T>(ptr: Node<T>, num: number) {
	for(let i = 0; i < num; ++i) {
		let a = ptr.prev.prev;
		let b = ptr.prev;
		let c = ptr;
		let d = ptr.next;

		a.next = c;
				
		b.prev = c;
		b.next = d;

		c.prev = a;
		c.next = b;

		d.prev = b;
	}
}

function shiftUp<T>(ptr: Node<T>, num: number) {
	for(let i = 0; i < num; ++i) {
		let a = ptr.prev;
		let b = ptr;
		let c = ptr.next;
		let d = ptr.next.next;

		a.next = c;
				
		b.prev = c;
		b.next = d;

		c.prev = a;
		c.next = b;

		d.prev = b;
	}
}

function solve1(raw: number[], key = 1, times = 1) {
	const length = raw.length;
	let begin = new Node<number>(raw[0] * key);
	begin.prev = begin;
	begin.next = begin;

	const order = [ begin ];
	const dlist = new Dlist<number>();
	for (const n of raw) {
		const node = dlist.push(n * key);
		order.push(node);
	}

	for (let i = 0; i < times; ++i) {

		// function mix:
		for (const pos of order) {
			let keep = (pos === begin) ? begin.next : begin;

			const value = pos.value;

			if (value < 0) {
				shiftDown(pos, (-value) % (length - 1));
			}
			else {
				shiftUp(pos, (value) % (length - 1));
			}

			begin = keep;
		}
	}

	let ptr = dlist.find(i => i === 0);
	let result = 0
	for (let i = 0; i < 3; ++i) {
		ptr = skip(ptr, 1000);
		result += ptr.value;
		// console.log(ptr.value);
	}
	return result;
}

function read(fname: string) {
	const raw = readFileSync(fname).toString('utf-8');
	const result = raw.split('\n').filter(l => l !== "").map(Number);
	return result;
}

const testInput = read("test-input");
const input = read("input");
const KEY = 811589153;

assert(solve1(testInput) === 3);
assert(solve1(testInput, KEY, 10) === 1623178306);

let result1 = solve1(input);
assert(result1 === 7278);

let result2 = solve1(input, KEY, 10); 
assert(result2 === 14375678667089);

console.log(result1, result2);
