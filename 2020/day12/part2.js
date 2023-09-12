#!/usr/bin/env node

import { readLines } from '../common/readers.js';

async function main() {	
	
	let xco = 0;
	let yco = 0;
	let wx = 10;
	let wy = -1;

	function rotateLeft(degrees) {
		let temp;
		switch(degrees) {
			case 270: temp = wy; wy = wx; wx = -temp; break;
			case 180: wx = -wx; wy = -wy; break;
			case 90: temp = wx; wx = wy; wy = -temp; break;
		}
	}

	for (const line of await readLines('input')) {
		let code = line[0];
		let param = +(line.substr(1));
		switch (code) {
			case 'N': wy -= param; break;
			case 'E': wx += param; break;
			case 'S': wy += param; break;
			case 'W': wx -= param; break;
			case 'L': rotateLeft(param); break;
			case 'R': rotateLeft(360-param); break;
			case 'F': xco += (param * wx); yco += (param * wy); break; 
		}
		console.log(code, param, ' => ', { xco, yco, wx, wy });
	}
	console.log(Math.abs(xco) + Math.abs(yco));
}

main();
