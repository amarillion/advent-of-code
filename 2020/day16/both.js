#!/usr/bin/env node

import { assert } from '../common/assert.js';
import { betweenInclusive } from '../common/bounds.js';
import { allMatch, noneMatch, product, sum } from '../common/iteratorUtil.js';
import { paragraphGenerator } from '../common/readers.js';

function fieldMatch (number, field) {
	return betweenInclusive(number, field[0], field[1]) || betweenInclusive(number, field[2], field[3]);
}

function parseRestriction(field) {
	const m = field.match(/^(\d+)-(\d+) or (\d+)-(\d+)$/); 
	assert(m);
	return (number) => fieldMatch(number, m.slice(1,5));
}

async function main() {	
	
	const groups = await paragraphGenerator('input');
	const fieldGroup = (await groups.next()).value;
	const yourticketGroup = (await groups.next()).value;
	const ticketsGroup = (await groups.next()).value;

	const fieldRestrictions = fieldGroup.map(f => f.split(': ')).reduce((acc, cur) => { acc[cur[0]] = parseRestriction(cur[1]); return acc; }, {});
	const yourticket = yourticketGroup[1].split(',').map(a => +a);
	const tickets = ticketsGroup.slice(1).map(t => t.split(',').map(a => +a));

	const validTickets = [];
	let part1sum = 0;
	for (const ticket of tickets) {
		// which values on the ticket don't match any field restriction?
		const invalidValues = ticket.filter(
			value => noneMatch(Object.values(fieldRestrictions), restriction => restriction(value))
		);
		if (invalidValues.length === 0) {
			validTickets.push(ticket);
		}
		else {
			part1sum += sum(invalidValues);
		}		
	}
	console.log('Part 1:', part1sum);

	const couldBeRow = {};
	const FIELDS = Object.keys(fieldRestrictions);
	FIELDS.forEach(key => couldBeRow[key] = []);
	
	for (let i = 0; i < validTickets[0].length; ++i) {
		// collect all values for field[i]
		const valuesPerField = validTickets.map(t => t[i]);
		for (const [key, restriction] of Object.entries(fieldRestrictions)) {
			if (allMatch(valuesPerField, val => restriction(val))) {
				// console.log(`${key} matches the ${i}th field of the ticket`);
				couldBeRow[key].push(i);
			}
		}
	}

	const fullyDetermined = {};

	while(true) {
		// find a key with a single entry
		const noChoice = Object.entries(couldBeRow).find(([, v]) => v.length === 1);
		
		if (!noChoice) {
			// can't continue
			break;
		}

		const noChoiceIdx = noChoice[1][0];

		fullyDetermined[noChoice[0]] = noChoiceIdx;
		// delete that row from all other entries
		delete couldBeRow[noChoice[0]];

		for (let k in couldBeRow) {
			couldBeRow[k] = couldBeRow[k].filter(v => v !== noChoiceIdx);
		}
	}

	const departureProduct = product(
		FIELDS.filter(k => k.startsWith('departure'))
			.map(v => fullyDetermined[v])
			.map(idx => yourticket[idx])
	);
	console.log('Part 2:', departureProduct);
}

main();
