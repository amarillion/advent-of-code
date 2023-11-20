#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

class Statement {
	id: string;
	isLiteral: boolean;
	literal: number;
	op1: string;
	op2: string;
	operator: string;

	static literal(id: string, value: number) {
		const result = new Statement();
		result.id = id;
		result.literal = value;
		result.isLiteral = true;
		return result;
	}

	static operation(id: string, op1: string, op2: string, operator: string) {
		const result = new Statement();
		result.id = id;
		result.isLiteral = false;
		result.op1 = op1;
		result.op2 = op2;
		result.operator = operator;
		return result;
	}
}


function parse(fname: string) {
	const raw = readFileSync(fname).toString('utf-8');
	const lines = raw.split('\n');

	const result: { [key: string]: Statement } = {};
	for (const line of lines) {
		if (line === "") continue;
		const id = line.substring(0, 4);
		const remain = line.substring(6).split(" ");
		if (remain.length === 1) {
			result[id] = Statement.literal(id, +remain[0]);
		}
		else {
			result[id] = Statement.operation(id, remain[0], remain[2], remain[1]);
		}
	}

	return result;
}

function evaluate(data: ReturnType<typeof parse>, id: string) {
	if (data[id].isLiteral) {
		return data[id].literal;
	}
	else {
		switch (data[id].operator) {
			case '+': return evaluate(data, data[id].op1) + evaluate(data, data[id].op2);
			case '-': return evaluate(data, data[id].op1) - evaluate(data, data[id].op2);
			case '*': return evaluate(data, data[id].op1) * evaluate(data, data[id].op2);
			case '/': return evaluate(data, data[id].op1) / evaluate(data, data[id].op2);			
		}
	}
}

function solve(data: ReturnType<typeof parse>) {
	return evaluate(data, "root");
}

assert(solve(parse("test-input")) === 152);
console.log(solve(parse("input")));