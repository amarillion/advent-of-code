#!/usr/bin/env node

import { paragraphGenerator, readLinesGenerator } from '../common/readers.js';

function parseLine(bagMap, line) {
	const m = line.match(/^(?<parent>.*) bags contain (?<children>.*)\.$/);
	if (!m) throw new Error(`NO MATCH: ${line}`);
	const { parent, children } = m.groups;
	
	if (parent in bagMap) {
		throw new Error("Duplicate key");
	}

	bagMap[parent] = {};
	if (children === "no other bags") {
		return;
	}
	else {
		bagMap[parent] = {};
		for (const child of children.split(", ")) {
			const m = child.match(/^(?<count>\d+) (?<type>\w+ \w+) bags?$/)
			if (!m) throw new Error(`CHILD NO MATCH: ${child}`);
			const { count, type } = m.groups;
			bagMap[parent][type] = count;
		}
	}
}

function containsRecursive(bagMap, key, needle) {
	if (needle in bagMap[key]) return true;
	for (const child in bagMap[key]) {
		if (containsRecursive(bagMap, child, needle)) return true;
	}
	return false;
}

function countRecursive(bagMap, depth, key) {
	let result = 1;
	for (const [child, value] of Object.entries(bagMap[key])) {
		console.log("  ".repeat(depth), `${value}: ${child}`);
		result += value * countRecursive(bagMap, depth + 1, child);
	}
	return result;
}

async function main() {	
	
	let bagMap = {};
	for await (const line of readLinesGenerator('input')) {
		parseLine(bagMap, line);
	}
	// console.log(bagMap);

	let result = 0;
	for (const key in bagMap) {
		if (containsRecursive(bagMap, key, "shiny gold")) {
			result++;
		}
	}
	console.log("Part 1: ", result);
	
	const result2 = countRecursive(bagMap, 0, "shiny gold");
	console.log("Part2", result2-1);
}

main();
