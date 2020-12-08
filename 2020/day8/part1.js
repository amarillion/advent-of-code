#!/usr/bin/env node

import { paragraphGenerator, readLines } from '../common/readers.js';

function assert(condition, message) {
	if (!condition) throw new Error(message);
}

class VM {

	constructor(program) {
		this.program = [ ...program ]; // defensive copy
		this.acc = 0;
		this.ip = 0;
	}

	step() {
		// parse line
		const line = this.program[this.ip];
		const [ opcode, param ] = line.split(' ');
		switch(opcode) {
			case 'acc': this.acc += (+param); this.ip++; break;
			case 'nop': this.ip++; break;
			case 'jmp': this.ip += (+param); break;
			default: assert(false, `Invalid ${opcode}`);
		}
	}

	run() {
		let running = true;
		let step = 1;
		const visited = [];
		while(running) {
			visited[this.ip] = step;
			this.step();
			if (this.ip in visited) {
				return this.acc;
			}
		}
	}
}
async function main() {	
	const program = await readLines('input');
	const vm = new VM(program);
	const result = vm.run();

	console.log(result);
}

main();
