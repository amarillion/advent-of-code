#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

function read(fname: string) {
	const raw = readFileSync(fname).toString('utf-8');
	const result = raw.split('\n').filter(l => l !== "").map(Number);
	return result;
}

function *iterate(head: Node<Payload>) {
	let current = head;
	do {
		yield current.payload;
		current = current.next;
	}
	while (current !== head)
}

function skip(ptr: Node<Payload>, num: number) {
	let current = ptr;
	for (let i = 0; i < num; ++i) {
		current = current.next;
	}
	return current;
}

class Payload {
	n: number;
	processed = false;
}

class Node<T> {
	prev: Node<T>;
	next: Node<T>;
	payload: T

	constructor(value: T) {
		this.payload = value;
	}
}

class MyNode extends Node<Payload> {
	constructor(n: number) {
		super({ n, processed: false });
	}
}

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

function shiftUp(ptr: Node<Payload>, num: number) {
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

function toArray(begin: MyNode) {
	let result = [];
	let j = 0;
	for (const i of iterate(begin)) {
		result.push(i.n);
		if (++j > 100) break;
	}
	return result;
}

function find(begin: MyNode, value: number) {
	let current = begin;

	while (current.payload.n !== value) {
		current = current.next; // TODO: No protection against infinite loops
	}
	return current;
}

function solve1(raw: number[], key = 1, times = 1) {
	const length = raw.length;
	let begin = new MyNode(raw[0] * key);
	begin.prev = begin;
	begin.next = begin;

	const order = [ begin ];
	let head = begin;
	for (const n of raw.slice(1, raw.length)) {
		const node = new MyNode(n * key);
		head.next = node;
		node.prev = head;
		node.next = begin;
		begin.prev = node;
		head = node;

		order.push(node);
	}

	for (let i = 0; i < times; ++i) {

		// function mix:
		for (const pos of order) {
			pos.payload.processed = true;
			let keep = (pos === begin) ? begin.next : begin;

			const value = pos.payload.n;

			if (value < 0) {
				shiftDown(pos, (-value) % (length - 1));
			}
			else {
				shiftUp(pos, (value) % (length - 1));
			}

			begin = keep;
		}
	}

	let ptr = find(begin, 0);
	let result = 0
	for (let i = 0; i < 3; ++i) {
		ptr = skip(ptr, 1000);
		result += ptr.payload.n;
		console.log(ptr.payload.n);
	}
	return result;
}

assert(solve1(read("test-input")) === 3);
let result1 = solve1(read("input"));
assert(result1 === 7278);

assert(solve1(read("test-input"), 811589153, 10) === 1623178306);
let result2 = solve1(read("input"), 811589153, 10); 
assert(result2 === 14375678667089);

console.log(result1, result2);
