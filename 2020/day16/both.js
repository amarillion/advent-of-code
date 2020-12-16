#!/usr/bin/env node

import { assert } from '../common/assert.js';
import { betweenInclusive } from '../common/bounds.js';
import { paragraphGenerator } from '../common/readers.js';

function fieldMatch (number, field) {
	return betweenInclusive(number, field[0], field[1]) || betweenInclusive(number, field[2], field[3]);
}

function parseField(field) {
	const m = field.match(/^(\d+)-(\d+) or (\d+)-(\d+)$/); 
	assert(m);
	return m.slice(1,5);
}

async function main() {	
	
	const groups = await paragraphGenerator('input');
	const fieldGroup = (await groups.next()).value;
	const yourticketGroup = (await groups.next()).value;
	const ticketsGroup = (await groups.next()).value;

	const fields = fieldGroup.map(f => f.split(': ')).reduce((acc, cur) => { acc[cur[0]] = parseField(cur[1]); return acc; }, {});
	const yourticket = yourticketGroup[1].split(',').map(a => +a);
	const tickets = ticketsGroup.slice(1).map(t => t.split(',').map(a => +a));

	console.log(fields, yourticket);

	const validTickets = [];
	let sum = 0;
	for (const ticket of tickets) {
		let ticketOk = true;
		for (const value of ticket) {
			let fieldOk = false;
			for (const field of Object.values(fields)) {
				if (fieldMatch(value, field)) {
					fieldOk = true;
					break;
				}
			}
			if (!fieldOk) {
				// console.log(`${value} doesn't match any field`);
				sum += value;
				ticketOk = false;
				break;
			}
		}
		if (ticketOk) {
			validTickets.push(ticket);
		}
	}

	console.log('Part 1:', sum);

	const couldBeRow = Object.keys(fields).reduce((acc, cur) => { acc[cur] = []; return acc; }, {});
	
	// collect values per field
	for (let i = 0; i < validTickets[0].length; ++i) {
		const valuesPerField = validTickets.map(t => t[i]);
		for (const [key, field] of Object.entries(fields)) {
			// console.log(i, key, field, valuesPerField);
			let fieldMatches = valuesPerField.reduce((acc, cur) => acc && fieldMatch(cur, field), true);
			if (fieldMatches) {
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

		// delete that row from all other entries
		const noChoiceIdx = noChoice[1][0];

		fullyDetermined[noChoice[0]] = noChoiceIdx;
		delete couldBeRow[noChoice[0]];

		for (let k of Object.keys(couldBeRow)) {
			couldBeRow[k] = couldBeRow[k].filter(v => v !== noChoiceIdx);
		}
	}

	console.log(fullyDetermined);
 
	const departureProduct = Object.keys(fullyDetermined)
		.filter(k => k.startsWith('departure'))
		.map(v => fullyDetermined[v])
		.map(idx => yourticket[idx])
		.reduce((acc, cur) => acc * cur, 1);
	console.log('Part2', departureProduct);
}

main();
