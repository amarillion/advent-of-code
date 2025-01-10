#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { astar } from '@amarillion/helixgraph';
import { astarEx } from '../common/astar.js';

type Data = ReturnType<typeof parse>;

function parse(fname: string) {
	const [ registersRaw, programRaw ] = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	const registers = registersRaw.split('\n')
		.map(line => line.substring('Register '.length)
		.split(': '))
		.reduce((arr, [key, val]) => { arr[key] = BigInt(val); return arr; }, {} as Record<string, bigint>);
	const program = programRaw.split('\n')[0].substring('Program: '.length).split(',').map(BigInt);
	return { registers, program };
}

function solve1({ program, registers }: Data) {
	let ip = 0;
	function asCombo(operand: bigint) {
		if (operand < 4n) return operand;
		switch(operand) {
			case 4n: return registers.A;
			case 5n: return registers.B;
			case 6n: return registers.C;
			default: assert(false);
		}
	}

	let out: bigint[] = [];

	while(ip < program.length) {

		const inst = program[ip];
		const operand = program[ip + 1];

		// TODO: simplify by using bigints and shift operations, like the hardcoded program...
		switch(inst) {
			case 0n: // adv
				registers.A = registers.A >> asCombo(operand);
				ip += 2;
				break;
			case 1n: // bxl 
				registers.B = registers.B ^ operand;
				ip += 2;
				break;
			case 2n: // bst
				registers.B = asCombo(operand) % 8n;
				ip += 2;
				break;
			case 3n: // jnz
				if (registers.A === 0n) {
					ip += 2;
				}
				else {
					ip = Number(operand);
				}
				break;
			case 4n: // bxc
				registers.B = registers.B ^ registers.C;
				ip += 2;
				break;
			case 5n: // out
				out.push(asCombo(operand) % 8n);
				ip += 2;
				break;
			case 6n: // bdv
				registers.B = registers.A >> asCombo(operand)
				ip += 2;
				break;
			case 7n: // cdv 
				registers.C = registers.A >> asCombo(operand)
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
	
	// astar will find the minimum number of bits to flip to get to the result, i.e. the lowest number
	let a = 0n;

	const { dest } = astarEx(a, n => countResult(data, n) === 16, function *(a: bigint) {
			// try flipping each bit between position 0 and 48
			for (let i = 0n; i < 48n; ++i) {
				let y = a ^ (1n << i);
				yield [i, y];
			}
		}, { 
			getWeight: () => 0, 
			getHeuristic: (a: bigint) => {
				let matches = countResult(data, a);
				return 16 - matches;
			}
		}
	);
	return dest;
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
if (!process.argv[2].startsWith('test')) {
	console.log(Number(solve2(data)));
}