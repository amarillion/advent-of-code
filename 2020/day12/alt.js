#!/usr/bin/env node

import { Point } from '../common/point.js';
import { readLines } from '../common/readers.js';

async function main() {	

	let pos = new Point(0, 0);
	let wp = new Point(10, -1);

	for (const line of await readLines('input')) {
		let code = line[0];
		let param = +(line.substr(1));
		switch (code) {
			case 'N': wp.y -= param; break;
			case 'E': wp.x += param; break;
			case 'S': wp.y += param; break;
			case 'W': wp.x -= param; break;
			case 'L': wp = wp.rotate(param); break;
			case 'R': wp = wp.rotate(-param); break;
			case 'F': pos = pos.plus(wp.mul(param)); break; 
		}
		console.log(code, param, ' => ', { wp, pos });
	}
	console.log(pos.manhattan());
}

main();
