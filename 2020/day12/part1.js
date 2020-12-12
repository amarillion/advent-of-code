#!/usr/bin/env node

import { readLines } from '../common/readers.js';

async function main() {	
	
	let xco = 0;
	let yco = 0;
	let facing = 0; // 0 degrees = east, on 360 degree circle.
	for (const line of await readLines('input')) {
		let code = line[0];
		let param = +(line.substr(1));
		switch (code) {
			case 'N': yco -= param; break;
			case 'E': xco += param; break;
			case 'S': yco += param; break;
			case 'W': xco -= param; break;
			case 'L': facing = (facing + 360 - param) % 360; break;
			case 'R': facing = (facing + param) % 360; break;
			case 'F': yco += Math.round(param * Math.sin(facing / 180 * Math.PI)); 
				xco += Math.round(param * Math.cos(facing / 180 * Math.PI)); 
				break; 
		}
		console.log(code, param, ' => ', xco, yco, facing);
	}
	console.log(Math.abs(xco) + Math.abs(yco));
}

main();
