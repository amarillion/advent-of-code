#!/usr/bin/env tsx
import { readFileSync } from 'fs';
const [ raw, updates ] = readFileSync(process.argv[2], { encoding: 'utf-8' }).split('\n\n');
const rules = new Set(raw.split('\n'));
console.log(updates.split('\n').map(l => {
	const sorted = l.split(',').sort((a, b) => +rules.has(`${b}|${a}`) - +rules.has(`${a}|${b}`));
	return { ok: l === sorted.join(','), mid: sorted[(sorted.length / 2) - 0.5] };
}).reduce((acc, i) => { acc[+!(i.ok)] += +i.mid; return acc }, [0, 0]).join('\n'));
