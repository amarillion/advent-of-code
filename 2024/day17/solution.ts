#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

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
	let result = 0;
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
	}
	return out.join(',');
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(data);
console.log(solve1(data));
// console.log(solve2(data));
