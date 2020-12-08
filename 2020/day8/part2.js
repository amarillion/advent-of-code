#!/usr/bin/env node

import { paragraphGenerator, readLines } from '../common/readers.js';

function assert(condition, message) {
	if (!condition) throw new Error(message);
}

class VM {

	constructor(lines) {
		this.program = this.parse(lines); // defensive copy
		this.acc = 0;
		this.ip = 0;
	}

	parse(lines) {
		let result = [];
		for (const line of lines) {
			const [ opcode, param ] = line.split(' ');
			result.push ({ opcode, param });
		}
		return result;
	}

	step() {
		const { opcode, param } = this.program[this.ip];
		switch(opcode) {
			case 'acc': this.acc += (+param); this.ip++; break;
			case 'nop': this.ip++; break;
			case 'jmp': this.ip += (+param); break;
			default: assert(false, `Invalid ${opcode}`);
		}
	}

	doesItFinish() {
		let running = true;
		let step = 1;
		const visited = [];
		while(running) {
			visited[this.ip] = step;
			this.step();
			if (this.ip in visited) {
				return false; // infinite loop detected 
			}
			if (this.ip >= this.program.length) {
				return true; // success
			}
		}
	}
}
async function main() {	
	const program = await readLines('input');
	
	for (let i = 0; i < program.length; ++i) {
		const vm = new VM(program);
		// modify program here...
		if (vm.program[i].opcode === 'acc') continue;
		else if (vm.program[i].opcode === 'nop') {
			vm.program[i].opcode = 'jmp';
		}
		else if (vm.program[i].opcode === 'jmp') {
			vm.program[i].opcode = 'nop';
		}
		let result = vm.doesItFinish();
		if (result) {
			console.log(vm.acc);
			return;
		}
	}

}

main();
