#!/usr/bin/env node

import { readLines, readLinesGenerator } from '../common/readers.js';

async function main() {	
	
	const program = await readLines('./input');
	const data = program[0].split(',').map(i => +i);
	data[1] = 12;
	data[2] = 2;
	let ip = 0;
	let running = true;
	while(running) {
		switch (data[ip]) {
			case 1: /* add */ data[data[ip + 3]] = data[data[ip + 1]] + data[data[ip + 2]]; ip += 4; break;
			case 2: /* mul */ data[data[ip + 3]] = data[data[ip + 1]] * data[data[ip + 2]]; ip += 4; break;
			case 99: /* halt */ running = false; break;
			default: throw new Error(`Unrecognized opcode ${data[ip]}`);
		}
	}

	console.log(data);
}

main();
