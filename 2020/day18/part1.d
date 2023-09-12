#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

enum TokenType { PLUS, MUL, BR_OPEN, BR_CLOSE, NUMBER }

struct Token {
	TokenType type;
	long val;
}

Token[] tokenize(string exprStr) {
	Token[] result;
	char[] digitBuffer;
	
	void emitWaiting() {
		if (digitBuffer.length > 0) {
			Token t = Token(TokenType.NUMBER, to!long(digitBuffer));
			result = result ~ [t];
		}
		digitBuffer = [];
	}

	void emit(TokenType type) {
		Token t = Token(type, 0);
		result = result ~ [ t ];
	}

	foreach (char ch; exprStr) {
		switch (ch) {
			case '0': case '1': case '2': case '3': case '4': 
			case '5': case '6': case '7': case '8': case '9':
				digitBuffer ~= ch;
				break;
			case '+': emitWaiting(), emit(TokenType.PLUS);
				break;
			case '*': emitWaiting(), emit(TokenType.MUL);
				break;
			case '(': emitWaiting(), emit(TokenType.BR_OPEN);
				break;
			case ')': emitWaiting(), emit(TokenType.BR_CLOSE);
				break;
			case ' ': 
				emitWaiting();
				break;
			default: assert(0);
		}
	}
	emitWaiting();
	return result;
}

long eval(Token[] t) {
	Token[] remain = t;

	long expect(TokenType type) {
		long result;
		assert (remain[0].type == type);
		result = remain[0].val;
		remain = remain[1..$];
		return result;
	}

	long evalExpr() {
		
		long evalNumber() {
			long result;
			assert(remain.length > 0);
			switch (remain[0].type) {
				case TokenType.BR_OPEN: {
					expect(TokenType.BR_OPEN);
					result = evalExpr();
					// writefln ("( %s )", result);
					expect(TokenType.BR_CLOSE);
					break;
				}
				case TokenType.NUMBER: {
					result = expect(TokenType.NUMBER);
					break;	
				}
				default: assert(0);
			}
			return result;
		}

		long result = evalNumber();
		long expr;

		bool expressionOpen = true;
		while (remain.length > 0 && expressionOpen) {
			switch(remain[0].type) {
				case TokenType.PLUS:
					expect(TokenType.PLUS);
					expr = evalNumber();
					// writefln ("%s + %s = %s", result, expr, result + expr);
					result += expr;
					break;
				case TokenType.MUL:
					expect(TokenType.MUL);
					expr = evalNumber();
					// writefln ("%s * %s = %s", result, expr, result * expr);
					result *= expr;
					break;
				case TokenType.BR_CLOSE:
					expressionOpen = false;
					break;
				default: assert(0);
			}
		}
		
		return result;
	}

	return evalExpr();
}

void main()
{
	long sum = 0;

	File file = File("input", "rt");

	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		Token[] t = tokenize(line);
		const long result = eval(t);
		writeln(line, " = ", result);	
		writeln("######");
		sum += result;
	}	

	writeln(sum);
}
