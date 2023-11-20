#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { SparseGrid } from '../common/sparsegrid.js';
import { Point } from '../common/point.js';
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

		// console.log(`Before: ${ptr.prev.prev.payload.n} ${ptr.prev.payload.n}, ${ptr.payload.n}, ${ptr.next.payload.n} ${ptr.next.next.payload.n}`);
		a.next = c;
				
		b.prev = c;
		b.next = d;

		c.prev = a;
		c.next = b;

		d.prev = b;

		// console.log(`After: ${ptr.prev.prev.payload.n} ${ptr.prev.payload.n}, ${ptr.payload.n}, ${ptr.next.payload.n} ${ptr.next.next.payload.n}`);
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

function print(begin: MyNode) {
	console.log(toArray(begin).join(', '));
}

function find(begin: MyNode, value: number) {
	let current = begin;

	while (current.payload.n !== value) {
		current = current.next; // TODO: No protection against infinite loops
	}
	return current;
}

function solve1(raw: number[]) {

	let begin = new MyNode(raw[0]);
	begin.prev = begin;
	begin.next = begin;

	let head = begin;
	for (const n of raw.slice(1, raw.length)) {
		const node = new MyNode(n);
		head.next = node;
		node.prev = head;
		node.next = begin;
		begin.prev = node;
		head = node;
	}

	let pos = begin;
	let remain = raw.length;

	print(begin);

	while (remain > 0) {
		while (pos.payload.processed) pos = pos.next;

		pos.payload.processed = true;
		remain--;
		let next = pos.next;
		let keep = (pos === begin) ? begin.next : begin;

		const value = pos.payload.n;
		console.log(`Processing ${value}`);

		if (value < 0) {
			shiftDown(pos, -value);
		}
		else {
			shiftUp(pos, value);
		}

		begin = keep;

		pos = next;
		print(begin);
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
console.log(solve1(read("input")));