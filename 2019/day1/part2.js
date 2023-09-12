#!/usr/bin/env node

import { readLinesGenerator } from '../common/readers.js';

function fuelReq(mass) {
	let result = Math.floor((+mass) / 3) - 2;
	if (result > 0)
	{
		return result + fuelReq(result);
	}
	else {
		return 0;
	}
}

async function main() {	
	let sum = 0;
	for await (const line of readLinesGenerator('input')) {
		sum += fuelReq(+line); 
	}
	console.log(sum);
}

main();
