#!/usr/bin/env node

// Of course this works only in NodeJS, not in the Browser.
import fs from 'fs/promises';
import { readLinesGenerator } from '../common/readers.js';

async function *lineGroupGenerator(file) {
	let group = []
	for await (const line of readLinesGenerator(file)) {
		if (line === '') {
			yield group;
			group = [];
			continue;
		}
		group = group.concat(line.split(' '))
	}
	yield group;
}

function betweenInclusive(data, a, b) {
	return (+data >= a && +data <= b)
}

function checkHeight(data) {
	const m = data.match(/^(?<height>\d+)(?<unit>cm|in)$/);
	if (!m) return false;
	if (m.groups.unit === 'cm') {
		return betweenInclusive(m.groups.height, 150, 193);
	}
	else {
		return betweenInclusive(m.groups.height, 59, 76);
	}
}

function checkPassport(data) {
	if (!("byr" in data)) return false;
	// if (!("cid" in data)) return false;
	if (!("ecl" in data)) return false;
	if (!("eyr" in data)) return false;
	if (!("hcl" in data)) return false;
	if (!("hgt" in data)) return false;
	if (!("iyr" in data)) return false;
	if (!("pid" in data)) return false;

	if (!betweenInclusive(data.byr, 1920, 2002)) return false;
	if (!betweenInclusive(data.iyr, 2010, 2020)) return false;
	if (!betweenInclusive(data.eyr, 2020, 2030)) return false;

	if (!checkHeight(data.hgt)) return false;
	
	if (!data.hcl.match(/^#[0-9a-f]{6}$/)) return false;
	if (!data.ecl.match(/^(amb|blu|brn|gry|grn|hzl|oth)$/)) return false;
	if (!data.pid.match(/^\d{9}$/)) return false;
	
	return true;
}

async function main() {
	
	let count = 0;
	for await (const group of lineGroupGenerator('input')) {
		
		let data = group
			.map(v => v.split(":"))
			.reduce((acc, cur) => { acc[cur[0]] = cur[1]; return acc; }, {});

		let valid = checkPassport(data);
		console.log(data, valid);
		if (valid) count++;
	}
	console.log(count);

}

main();
