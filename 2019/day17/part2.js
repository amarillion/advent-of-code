#!/usr/bin/env node

import { readLines, readLinesGenerator } from '../common/readers.js';
import fs from 'fs';
import { assert } from '../common/assert.js';

/* 
read a single char from STDIN 

*/
function readChar() {
	// source: https://stackoverflow.com/a/64235311/3306
	let buffer = Buffer.alloc(1);
	let num = fs.readSync(0, buffer, 0, 1);
	assert(num === 1);
	console.log("Read char:" , buffer[0], num);
	return buffer[0];
}

class Intcode {

	constructor(program) {
		// make defensive copy
		this.data = [...program];
		this.input = [];
		this.output = [];
		this.running = true;
		this.base = 0;
		this.ip = 0;
	}

	getAddressMode(idx) {
		let instr = this.data[this.ip];
		switch(idx) {
			case 1: return Math.floor((instr % 1000) / 100);
			case 2: return Math.floor((instr % 10000) / 1000);
			case 3: return Math.floor((instr % 100000) / 10000);
			default: throw new Error(`Unkown idx ${idx}`);
		}
	}

	getArg(idx) {
		let addressMode = this.getAddressMode(idx);
		let addr;
		switch(addressMode) {
			case 0: addr = this.data[this.ip + idx]; break;
			case 1: addr = this.ip + idx; break;
			case 2: addr = this.base + this.data[this.ip + idx]; break;
			default: throw new Error(`Unrecognized opcode ${this.data[this.ip]}`);
		}
		const result = addr in this.data ? this.data[addr] : 0;
		// console.log("GET", { idx, addressMode, addr, result })
		return result;
	}

	setArg(idx, val) {
		let addressMode = this.getAddressMode(idx);
		let addr;
		switch(addressMode) {
			case 0: addr = this.data[this.ip + idx]; break;
			case 1: throw new Error(`Can't assign in addressmode 1 at ${this.ip}`);
			case 2: addr = this.base + this.data[this.ip + idx]; break;
			default: throw new Error(`Unrecognized addressMode ${idx} ${addressMode} ${this.data[this.ip]}`);
		}
		this.data[addr] = val;
		// console.log("SET", { idx, addressMode, addr, val })
	}

	step() {
		let instr = this.data[this.ip];
		const opcode = instr % 100;

		switch (opcode) {
			case 1: /* add */ 
				this.setArg(3, this.getArg(1) + this.getArg(2)); 
				this.ip += 4; 
				break;
			case 2: /* mul */ 
				this.setArg(3, this.getArg(1) * this.getArg(2)); 
				this.ip += 4; 
				break;
			case 3: /* IN */ 
				// if (this.input.length === 0) throw new Error("Empty input"); 
				// this.setArg(1, this.input.shift()); 				
				this.setArg(1, readChar());
				this.ip += 2;
				break;
			case 4: /* OUT */
				// this.output.push(this.getArg(1));
				let arg = this.getArg(1);
				if (arg > 255) {
					console.log("Large value: ", arg);
				}
				else {
					process.stdout.write(String.fromCharCode());
				}
				this.ip += 2; 
				break;
			case 5: /* jump-if-true */
				if (this.getArg(1) !== 0) {
					this.ip = this.getArg(2);
				}
				else {
					this.ip += 3;
				}
				break;
			case 6: /* jump-if-false */
				if (this.getArg(1) === 0) {
					this.ip = this.getArg(2);
				}
				else {
					this.ip += 3;
				}
				break;
			case 7: /* less than */
				this.setArg(3, this.getArg(1) < this.getArg(2) ? 1 : 0);
				this.ip += 4;
				break;
			case 8: /* equals */
				this.setArg(3, this.getArg(1) === this.getArg(2) ? 1 : 0);
				this.ip += 4;
				break;
			case 9:
				this.base += this.getArg(1);
				this.ip += 2;
				break;
			case 99: /* halt */ this.ip++; return false;
			default: throw new Error(`Unrecognized opcode ${data[ip]}`);
		}
		return true;
	}

	process() {
		let running = true;
		while(running) {
			running = this.step();
		}
		return this.data;
	}
	
}

async function main() {	
	const program = await readLines('./input');
	const data = program.join('').split(',').map(i => +i);
	const intCode = new Intcode(data);
	intCode.data[0] = 2; // to wake robot up
	intCode.process();
}

main();
