#!/usr/bin/env node

import { readLinesGenerator } from '../common/readers.js';

function findSum(data, sum) {

	for (let i = 1; i < data.length; ++i) {
		for (let j = 0; j < i; ++j) {
			if (data[i] + data[j] === sum) {
				return true;
			}
		}
	}
	return false;
}


function findContiguousSum(data, expect) {

	for (let start = 0; start < data.length-1; ++start) {
		for (let end = start + 1; end < data.length; ++end) {
			let sl = data.slice(start, end);
			let sum = sl.reduce((acc, cur) => acc + cur, 0);
			if (sum === expect) {
				let max = Math.max(...sl);
				let min = Math.min(...sl);
				console.log(max + min);
			}
		}
	}
}

async function main() {	
	let data = [];
	for await (const line of readLinesGenerator('input')) {
		data.push(+line);
	}

	let preamble = 25;
	for (let i = preamble; i < data.length; ++i) {
		let check = findSum(data.slice(i - preamble, i), data[i]);
		if (!check) {
			console.log(data[i]); // 1212510616
			findContiguousSum(data.slice(0,i), data[i]);
		}
	}
}

main();
