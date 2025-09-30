#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { breadthFirstSearch, trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { DefaultMap } from '../common/DefaultMap.js';
import { memoize } from '../common/functional/memoize.js';
import { AdjacencyFunc } from '@amarillion/helixgraph/lib/definitions.js';

type StatementType = { arg1: string, op: string, arg2: string, lval: string };
type Data = { registers: Map<string, number>, statements: StatementType[] }

function parse(fname: string): Data {
	const [ initRaw, statementsRaw ] = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n').map(block => block.split('\n').filter(i => i !== ''));

	const registers = new Map<string, number>();
	for (const line of initRaw) {
		const [ key, val ] = line.split(': ');
		registers.set(key, Number(val));
	}
	const statements: StatementType[] = [];
	for (const statement of statementsRaw) {
		const [ rval, lval ] = statement.split(' -> ');
		const [ arg1, op, arg2 ] = rval.split(' ');
		statements.push({ lval, arg1, op, arg2 });
	}

	return { registers, statements };
}

// TODO: can be added to helixgraph
function isCyclic(source: string, getNeighbors: AdjacencyFunc<string, unknown>) {
	const visited = new Set<string>();
	const open: Set<string> = new Set([ source ]);
	while (open.size > 0) {
		const node = open.keys().next().value!;
		open.delete(node);
		if (visited.has(node)) {
			return true;
		}
		visited.add(node);
		for (const [, neighbor] of getNeighbors(node)) {
			open.add(neighbor);
		}
	}
	return false;
}

function helperAlt(_statements: StatementType[], registers: Map<string, number>) {
	const graph = buildGraph(data.statements); // TODO - cache data.
	assert (!isCyclic('x01', node => Object.entries(graph.get(node))), 'Graph is cyclic!');

	// invert statements
	const outputMap = new Map<string, StatementType>();
	for (const statement of _statements) {
		assert(!outputMap.has(statement.lval));
		outputMap.set(statement.lval, statement);
	}

	const calc = memoize((name: string) => {
		if (registers.has(name)) {
			return registers.get(name)!;
		}
		const stmt = notNull(outputMap.get(name));
		const a1 = calc(stmt.arg1);
		const a2 = calc(stmt.arg2);
		let vv = 0;
		switch(stmt.op) {
			case 'OR':
				vv = a1 | a2; 
				break;
			case 'AND':
				vv = a1 & a2;
				break;
			case 'XOR':
				vv = a1 ^ a2;
				break;
			default:
				assert(false);
		}
		// console.log(`Calc ${name} returns ${vv}`);
		return vv;
	});

	let binary = '';
	for (let zkey of getRegister(_statements, 'z')) {
		binary = calc(zkey) + binary;
	}
	return BigInt('0b' + binary);
}

function testAlt(_statements: StatementType[], registers: Map<string, number>, output: Map<string, number>) {
	const graph = buildGraph(data.statements); // TODO - cache data.
	assert (!isCyclic('x01', node => Object.entries(graph.get(node))), 'Graph is cyclic!');

	// invert statements
	const outputMap = new Map<string, StatementType>();
	for (const statement of _statements) {
		assert(!outputMap.has(statement.lval));
		outputMap.set(statement.lval, statement);
	}

	const cache = new Map<string, number>()
	const expect = (name: string, expVal: number | undefined, indent: string): number => {
		// console.log(`${indent}Expect ${name} = ${expVal}`)
		if (cache.has(name)) {
			return cache.get(name)!;
		}

		if (registers.has(name)) {
			const vv = registers.get(name)!; 
			if (expVal !== undefined && vv !== expVal) {
				console.log(`Expected ${name} to be ${expVal} but was ${vv}`);
			}
			return vv;
		}
		
		const stmt = notNull(outputMap.get(name));
		let vv = 0;
		let a1, a2;

		switch(stmt.op) {
			case 'OR':
				// if we're expecting 0, then any incoming 1s is in the wrong
				a1 = expect(stmt.arg1, expVal === 0 ? 0 : undefined, indent + ' ');
				a2 = expect(stmt.arg2, expVal === 0 ? 0 : undefined, indent + ' ');
				if (expVal === 0) {
					if (a1 === 1) {
						console.log(`${stmt.arg1} should be 0 but is 1`);
					}
					if (a2 === 1) {
						console.log(`${stmt.arg2} should be 0 but is 1`);
					}
				}
				vv = a1 | a2;
				break;
			case 'AND':
				// if we're expecting 1, then any incoming 0s is in the wrong
				a1 = expect(stmt.arg1, expVal === 1 ? 1 : undefined, indent + ' ');
				a2 = expect(stmt.arg2, expVal === 1 ? 1 : undefined, indent + ' ');
				if (expVal === 1) {
					if (a1 === 0) {
						console.log(`${stmt.arg1} should be 1 but is 0`);
					}
					if (a2 === 0) {
						console.log(`${stmt.arg2} should be 1 but is 0`);
					}
				}
				vv = a1 & a2;
				break;
			case 'XOR':
				// can't expect anything wiht XOR
				a1 = expect(stmt.arg1, undefined, indent + ' ');
				a2 = expect(stmt.arg2, undefined, indent + ' ');
				vv = a1 ^ a2;
				break;
			default:
				assert(false);
		}
		console.log(`${indent}${name} = ${stmt.arg1} ${stmt.op} ${stmt.arg2}. Actual ${vv}, expected ${expVal}`);
		cache.set(name, vv);
		return vv;
	};

	let binary = '';
	for (let zkey of getRegister(_statements, 'z')) {
		binary = expect(zkey, output.get(zkey), '') + binary;
	}
	return BigInt('0b' + binary);
}

function helper(_statements: StatementType[], registers: Map<string, number>) {
	let statements = _statements.slice();
	while(statements.length > 0) {
		let progress = false;
		const next: StatementType[] = [];
		for (const statement of statements) {
			if ((registers.has(statement.arg1) && registers.has(statement.arg2))) {
				let vv = 0;
				const a1 = registers.get(statement.arg1)!;
				const a2 = registers.get(statement.arg2)!;
				switch(statement.op) {
					case 'OR':
						vv = a1 | a2; 
						break;
					case 'AND':
						vv = a1 & a2;
						break;
					case 'XOR':
						vv = a1 ^ a2;
						break;
					default:
						assert(false);
				}
				registers.set(statement.lval, vv);
				progress = true;
			}
			else {
				next.push(statement)
			}
		}
		statements = next;
		if (!progress) return -1;
	}

	const zkeys = getRegister(data.statements, 'z');
	let binary = '';
	for (const zkey of zkeys) {
		binary = registers.get(zkey) + binary;
	}
	return BigInt('0b' + binary);
}

function solve1(data: Data) {
	let result = 0;
	// console.log(data);

	const registers = data.registers;

	return helperAlt(data.statements, registers)
}

function test(data: Data, x: bigint, y: bigint, expected: bigint) {	
	const maxBits = getRegister(data.statements, 'x').length;
	const registers = new Map<string, number>();
	for (let bit = 0n; bit < maxBits; ++bit) {
		registers.set('x' + `${bit}`.padStart(2, '0'), (x & (1n << bit)) ? 1 : 0);
		registers.set('y' + `${bit}`.padStart(2, '0'), (y & (1n << bit)) ? 1 : 0);
	}
	const result = helperAlt(data.statements, registers);
	// console.log(`     ${x.toString(2).padStart(50, ' ')}\n   + ${y.toString(2).padStart(50, ' ' )}\nObs. ${result.toString(2).padStart(50, ' ')}\nExp. ${expected.toString(2).padStart(50, ' ')}`);
	
	if (result !== expected) {
		console.log("Deep dive");
		console.log(`     ${x.toString(2).padStart(50, ' ')}\n   + ${y.toString(2).padStart(50, ' ' )}\nObs. ${result.toString(2).padStart(50, ' ')}\nExp. ${expected.toString(2).padStart(50, ' ')}`);
		const maxzBits = getRegister(data.statements, 'z').length;
		const output = new Map<string, number>();
		for (let bit = 0n; bit < maxzBits; ++bit) {
			output.set('z' + `${bit}`.padStart(2, '0'), (expected & (1n << bit)) ? 1 : 0);
		}
		testAlt(data.statements, registers, output);
	}
	
	return result === expected ? 1 : 0;
}

function getRegister(statements: StatementType[], type: 'x'|'y'|'z') {
	return [...new Set(statements.flatMap(stmt => [ stmt.lval, stmt.arg1, stmt.arg2 ]).filter(r => r.startsWith(type)))].sort();
}

function testSuite(data: Data, maxBits: number) {	
	let successCount = 0;
	let totalCount = 0;

	successCount += test(data, 0n, 0n, 0n);
	totalCount++;

	for (let i = 0n; i < maxBits; ++i) {
		const power = 1n << i;
		successCount += test(data, power, power, power + power);
		totalCount++;

		successCount += test(data, 1n, power - 1n, power);
		totalCount++;

		successCount += test(data, power - 1n, 1n, power);
		totalCount++;

		successCount += test(data, power, 0n, power);
		totalCount++;

		successCount += test(data, 0n, power, power);
		totalCount++;

		successCount += test(data, power - 1n, power - 1n, 2n * (power - 1n));
		totalCount++;

	}

	return { success: successCount, total: totalCount, fail: totalCount - successCount };
}

// function extraTests(data: Data) {
// 	for (let i = 0n; i < 100; ++i) {
// 		successCount += test(data, 101n * i, 93n * i, (101n + 93n) * i);
// 		totalCount++;
// 	}
// }

function buildGraph(statements: StatementType[]) {
	const graph = new DefaultMap<string, string[]>(() => []);
	for (const stmt of data.statements) {
		graph.get(stmt.arg1).push(stmt.lval);
		graph.get(stmt.arg2).push(stmt.lval);
	}
	return graph;
}

function solve2Ex(data: Data) {
	// build index
	const graph = buildGraph(data.statements);

	// highest z:
	const allZ = getRegister(data.statements, 'z');
	const highestZ = allZ[allZ.length - 1];

	const src = 'y06';

	console.log(highestZ);
	const prevMap = breadthFirstSearch(src, highestZ, (src) => Object.entries(graph.get(src)));
	
	for (const z of allZ) {
		const path = trackbackNodes(src, z, prevMap) ?? [];
		console.log(path.join('>'));
	}

	let result = 0;
	return result;
}

function solve2(data: Data) {

	const maxBits = getRegister(data.statements, 'x').length;
	assert(maxBits === getRegister(data.statements, 'y').length); // x and y have same no. of bits.

	for (let bits = 0; bits < maxBits + 1; ++bits) {
		let { total, fail } = testSuite(data, bits);
		if (fail > 0) {
			console.log(`First fail at bit ${bits}`)
			break;
		}
		console.log(`Bits: ${bits}, failed: ${fail} out of ${total}`)
	}

	/*
	for (let i = 0; i < data.statements.length; ++i) {
		for (let j = i + 1; j < data.statements.length; ++j) {
			
			// swap outputs of j + i
			const tmp = data.statements[i].lval;
			data.statements[i].lval = data.statements[j].lval;
			data.statements[j].lval = tmp;
			
			let { success } = testSuite(data, maxBits);
			if (success !== 0) {
				console.log(`Test result swapping ${data.statements[i].lval}, ${data.statements[j].lval}: ${success}`);
			}

			// swap back
			const tmp2 = data.statements[i].lval;
			data.statements[i].lval = data.statements[j].lval;
			data.statements[j].lval = tmp2;
		}
	}
	*/
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
// console.log(solve1(data));
console.log(solve2(data));
