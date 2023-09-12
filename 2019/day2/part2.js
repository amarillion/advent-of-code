#!/usr/bin/env node

import { readLines, readLinesGenerator } from '../common/readers.js';

function intcode(input) {
	const data = [...input];
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
	return data;
}

async function main() {	
	
	const program = await readLines('./input');
	const data = program[0].split(',').map(i => +i);
	for (let i = 0; true; ++i) {
		for (let j = 0; j < 100; ++j) {
			data[1] = i;
			data[2] = j;
			const output = intcode(data);
			if (output[0] === 19690720) {
				console.log(output);
				return;
			}
		}
	}
}

main();
