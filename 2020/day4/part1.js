#!/usr/bin/env node

// Of course this works only in NodeJS, not in the Browswer.
import fs from 'fs/promises';
import { readLinesGenerator } from '../common/readers.js';

async function *passportGenerator() {
	let group = []
	for await (const line of readLinesGenerator('input')) {
		if (line === '') {
			yield group;
			group = [];
			continue;
		}
		group = group.concat(line.split(' '))
	}
	yield group;
}

function checkKeys(keys) {
	keys.sort();
	if (keys.length < 7) return false;
	if (keys.length > 8) return false;
	
	for (const exp of [
			'byr', 
			// 'cid', 
			'ecl', 'eyr', 'hcl', 'hgt', 'iyr', 'pid'
		]) {
		if (keys.indexOf(exp) < 0) {
			return false;
		}
	}
	return true;
}

async function main() {
	
	let count = 0;
	for await (const group of passportGenerator()) {
		const keys = group.map(v => v.split(":")[0]);
		let valid = checkKeys(keys);
		console.log(keys, valid);
		if (valid) count++;
	}
	console.log(count);

}

main();
