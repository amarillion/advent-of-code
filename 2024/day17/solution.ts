#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { astar } from '@amarillion/helixgraph';

type Data = ReturnType<typeof parse>;

function parse(fname: string) {
	const [ registersRaw, programRaw ] = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	const registers = registersRaw.split('\n')
		.map(line => line.substring('Register '.length)
		.split(': '))
		.reduce((arr, [key, val]) => { arr[key] = Number(val); return arr; }, {} as Record<string, number>);
	const program = programRaw.split('\n')[0].substring('Program: '.length).split(',').map(Number);
	return { registers, program };
}

function solve1({ program, registers }: Data) {
	let ip = 0;
	function asCombo(operand: number) {
		if (operand < 4) return operand;
		switch(operand) {
			case 4: return registers.A;
			case 5: return registers.B;
			case 6: return registers.C;
			default: assert(false);
		}
	}

	let out: number[] = [];

	while(ip < program.length) {

		const inst = program[ip];
		const operand = program[ip + 1];

		switch(inst) {
			case 0: // adv
				registers.A = Math.floor(registers.A / Math.pow(2, asCombo(operand)))
				ip += 2;
				break;
			case 1: // bxl 
				registers.B = registers.B ^ operand;
				ip += 2;
				break;
			case 2: // bst
				registers.B = asCombo(operand) % 8;
				ip += 2;
				break;
			case 3: // jnz
				if (registers.A === 0) {
					ip += 2;
				}
				else {
					ip = operand;
				}
				break;
			case 4: // bxc
				registers.B = registers.B ^ registers.C;
				ip += 2;
				break;
			case 5: // out
				out.push(asCombo(operand) % 8);
				ip += 2;
				break;
			case 6: // bdv
				registers.B = Math.floor(registers.A / Math.pow(2, asCombo(operand)))
				ip += 2;
				break;
			case 7: // cdv 
				registers.C = Math.floor(registers.A / Math.pow(2, asCombo(operand)))
				ip += 2;
				break;
			default: assert(false);
		}
		// console.log(`A=${registers.A.toString(2)}, B=${registers.B.toString(2)}, C=${registers.C.toString(2)} ${out}`)
	}
	return out.join(',');
}

// hard-coded version of my program input.
function solve1b(initial: bigint) {
	let a = initial, b = 0n, c = 0n;
	let out: bigint[] = [];
	while (a !== 0n) {
		b = a % 8n;
		b = b ^ 2n;
		c = a >> b;
		b = b ^ c;
		a = a >> 3n;
		b = b ^ 7n;
		out.push(b % 8n);
	}
	return out;
}

function solve2(data: Data) {
	let a = (1n << 47n);
	astar(a, 0n, function *(a: bigint) {
			for (let i = 0n; i < 48n; ++i) {
				let y = a ^ (1n << i);
				yield [i, y];
			}
		}, { getWeight: () => 0, getHeuristic: (a: bigint) => {			
			let matches = countResult(data, a);
			assert (matches < 16, `${a}`);
			return 16 - matches;
		}}
	);
}

function countResult(data: Data, a: bigint) {
	let matches = 0;
	let result = solve1b(a);
	for(let i = data.program.length - 1; i >= 0; i--) {
		if (result[i] === BigInt(data.program[i])) { matches++; }
		// else { break; }
	}
	// console.log(`${a.toString(2)} ${a} ${result.join(',')} ${matches}`);
	return matches;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);

console.log(solve1(structuredClone(data)));
console.log(solve2(data));