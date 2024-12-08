#!/usr/bin/env tsx
import { readFileSync } from 'fs';
const [ raw, updates ] = readFileSync(process.argv[2], { encoding: 'utf-8' }).split('\n\n');
console.log(updates.split('\n').map(l => {
	const sorted = l.split(',').sort((a, b) => - +raw.includes(`${a}|${b}`));
	return { bad: l === sorted.join(','), mid: sorted[(sorted.length - 1) / 2] };
}).reduce((acc, i) => { acc[+i.bad] += +i.mid; return acc }, [0, 0]).join('\n'));

/*
Explanations:

#!/usr/bin/env tsx

import { readFileSync } from 'fs';

const [ raw, updates ] = readFileSync(process.argv[2], { encoding: 'utf-8' }).split('\n\n');

// do not attempt to parse rules, we'll check their existence as full strings

// the following line can be omitted, and we can search raw directly. Faster at the expense of one line extra.
// const rules = new Set(raw.split('\n'));

console.log(updates.split('\n').map(l => {

	// the rules indicate a partial sort order. Cast to int, then negate. Returning -1 means that some part will be re-ordered.
	// Either a|b is a rule or b|a, but never both.
	// In practice, the input is such that we don't need to check the opposite (i.e. return +1 if rules.has(`${b}|${a}`))
	// No need to parse anything as numbers

	// if we're using a Set
	// const sorted = l.split(',').sort((a, b) => - +rules.has(`${a}|${b}`));

	// if we're skipping the set
	const sorted = l.split(',').sort((a, b) => - +raw.includes(`${a}|${b}`));

	// rejoin after sorting, and compare with the string input. If they are not the same, then the line was invalid (bad).
	// get the middle value out, still keeping it as string
	
	return { bad: l !== sorted.join(','), mid: sorted[(sorted.length - 1) / 2] };

	// aggregate results separately for the case where ok is true vs false.
	// Here we're finally casting the mid value to number, to be able to add it up.

}).reduce((acc, i) => { acc[+i.bad] += +i.mid; return acc }, [0, 0]).join('\n'));

*/