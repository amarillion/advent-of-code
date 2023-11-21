#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { linearSolver } from '../common/linear.js';

type OperatorType = '+'|'-'|'/'|'*';

class Statement {
	id: string;
	type: 'literal'|'comparison'|'variable'|'operation'
	literal: number;
	op1: Statement;
	op2: Statement;
	operator: string;

	static literal(id: string, value: number) {
		const result = new Statement();
		result.literal = value;
		result.id = id;
		result.type = 'literal';
		return result;
	}

	static variable(id: string) {
		const result = new Statement();
		result.id = id;
		result.type = 'variable';
		return result;
	}

	static comparison(op1: Statement, op2: Statement) {
		const result = new Statement();
		result.type = 'comparison';
		result.op1 = op1;
		result.op2 = op2;
		return result;
	}

	static operation(op1: Statement, op2: Statement, operator: OperatorType) {
		const result = new Statement();
		result.type = 'operation';
		result.op1 = op1;
		result.op2 = op2;
		result.operator = operator;
		return result;
	}
}

function parse(fname: string) {
	const raw = readFileSync(fname).toString('utf-8');
	const lines = raw.split('\n');

	const result: { [key: string]: string }= {};
	for (const line of lines) {
		if (line === "") continue;
		const id = line.substring(0, 4);
		result[id] = line.substring(6);
	}

	return result;
}

function createStatement(data: ReturnType<typeof parse>, id: string) {
	const tokens = data[id].split(" ");
	if (tokens.length === 1) {
		return Statement.literal(id, +tokens[0]);
	}
	else {
		return Statement.operation(createStatement(data, tokens[0]), createStatement(data, tokens[2]), tokens[1] as OperatorType);
	}
}

function createStatement2(data: ReturnType<typeof parse>, id: string) {
	const tokens = data[id].split(" ");
	if (id === 'root') {
		return Statement.comparison(createStatement2(data, tokens[0]), createStatement2(data, tokens[2]));
	}
	else if (id === 'humn') {
		return Statement.variable(id);
	}
	else if (tokens.length === 1) {
		return Statement.literal(id, +tokens[0]);
	}
	else {
		return Statement.operation(createStatement2(data, tokens[0]), createStatement2(data, tokens[2]), tokens[1] as OperatorType);
	}
}

interface ASTVisitor<T> {
	literal(id: string, value: number): T;
	operation(op: string, operand1: T, operand2: T): T;
	variable(id: string): T;
	comparison(operand1: T, operand2: T): T;
}

class ToStringVisitor implements ASTVisitor<string> {
	literal(id: string, value: number) {
		return String(value);
	}
	
	operation(op: OperatorType, operand1: string, operand2: string) {
		return `(${operand1} ${op} ${operand2})`;
	}

	variable(id: string) {
		return id;
	}

	comparison(operand1: string, operand2: string) {
		return `${operand1} = ${operand2}`;
	}
}

class EvalVisitor implements ASTVisitor<number> {
	val = 0;

	literal(id: string, value: number) {
		return value;
	}

	operation(op: OperatorType, operand1: number, operand2: number) {
		switch (op) {
			case '+': return operand1 + operand2;
			case '-': return operand1 - operand2;
			case '*': return operand1 * operand2;
			case '/': return operand1 / operand2;
		}
	}

	variable(id: string) {
		return this.val;
	}

	comparison(operand1: number, operand2: number) {
		return operand2 - operand1;
	}
}

function visit<T>(data: Statement, visitor: ASTVisitor<T>): T {
	switch(data.type) {
	case 'literal':
		return visitor.literal(data.id, data.literal);
	case 'operation':
		return visitor.operation(data.operator, 
			visit(data.op1, visitor), 
			visit(data.op2, visitor)
		);
	case 'variable':
		return visitor.variable(data.id);
	case 'comparison':
		return visitor.comparison(
			visit(data.op1, visitor), 
			visit(data.op2, visitor)
		);
	default:
		assert(false, `Impossible type ${data.type}`);
	};
}

function toString(data: Statement) {
	return visit(data, new ToStringVisitor());
}


class SimplifyVisitor implements ASTVisitor<Statement> {
	literal(id: string, value: number) {
		return Statement.literal(id, value);
	}

	operation(op: OperatorType, op1: Statement, op2: Statement) {
		if (op1.type === 'literal' && op2.type === 'literal') {
			let res; 
			switch(op) {
				case '+': res = Statement.literal("", op1.literal + op2.literal); break;
				case '-': res = Statement.literal("", op1.literal - op2.literal); break;
				case '*': res = Statement.literal("", op1.literal * op2.literal); break;
				case '/': res = Statement.literal("", op1.literal / op2.literal); break;
			}
			return res;
		}
		else {
			return Statement.operation(op1, op2, op);
		}
	}

	variable(id: string) {
		return Statement.variable(id);
	}

	comparison(op1: Statement, op2: Statement) {
		return Statement.comparison(op1, op2);
	}
}

function solve(data: Statement) {
	return visit(data, new EvalVisitor());
}

function solve2(data: Statement) {
	const simplified = visit(data, new SimplifyVisitor());
	console.log("Simplified:\n", toString(simplified));
	// const simplified = data;

	const evalVisitor = new EvalVisitor();
	
	function f(x: number) {
		evalVisitor.val = x;
		return visit(simplified, evalVisitor);
	}

	return linearSolver(f);
}

const testInput = parse("test-input");
const testRoot = createStatement(testInput, 'root');

console.log(toString(testRoot));
assert(solve(testRoot) === 152);

const input = parse('input');
const inputRoot = createStatement(input, 'root');
assert(solve(inputRoot) === 232974643455000);

const testRoot2 = createStatement2(testInput, 'root');
assert(solve2(testRoot2) === 301);

const inputRoot2 = createStatement2(input, 'root');
// console.log(toString(inputRoot2));

console.log(solve2(inputRoot2)); // 3740214169961
