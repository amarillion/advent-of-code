#!/usr/bin/env node

import { readLines, readLinesGenerator } from '../common/readers.js';

class Intcode {

	constructor(program) {
		this.data = [...program];
		this.input = [];
		this.output = [];
		this.running = true;
		this.ip = 0;
	}

	getArg(idx, addressMode) {
		let addr;
		switch(addressMode) {
			case 0: addr = this.data[this.ip + idx]; break;
			case 1: addr = this.ip + idx; break;
			default: throw new Error(`Unrecognized opcode ${this.data[this.ip]}`);
		}
		const result = this.data[addr];
		console.log("GET", { idx, addressMode, addr, result })
		return result;
	}

	setArg(idx, addressMode, val) {
		let addr;
		switch(addressMode) {
			case 0: addr = this.data[this.ip + idx]; break;
			case 1: throw new Error(`Can't assign in addressmode 1 at ${this.ip}`);
			default: throw new Error(`Unrecognized opcode ${this.data[this.ip]}`);
		}
		this.data[addr] = val;
		console.log("SET", { idx, addressMode, addr, val })
	}

	step() {
		let instr = this.data[this.ip];
		const opcode = instr % 100;
		instr = Math.floor(instr / 100);
		const addrMode1 = instr % 10;
		instr = Math.floor(instr / 10);
		const addrMode2 = instr % 10;
		const addrMode3 = Math.floor(instr / 10);

		switch (opcode) {
			case 1: /* add */ 
				this.setArg(+3, addrMode3, 
					this.getArg(+1, addrMode1) 
					+ this.getArg(+2, addrMode2)
				); 
				this.ip += 4; 
				break;
			case 2: /* mul */ 
				this.setArg(+3, addrMode3, 
					this.getArg(+1, addrMode1) 
					* this.getArg(+2, addrMode2)
				); 
				this.ip += 4; 
				break;
			case 3: /* IN */ 
				if (this.input.length === 0) throw new Error("Empty input"); 
				this.setArg(+1, addrMode1, this.input.shift()); 
				this.ip += 2; 
				break;
			case 4: /* OUT */
				this.output.push(
					this.getArg(+1, addrMode1)
				); 
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
	const data = program[0].split(',').map(i => +i);
	const intCode = new Intcode(data);
	intCode.input.push(1)
	const result = intCode.process();
	console.log(result);
	console.log(intCode.output);
}

main();
