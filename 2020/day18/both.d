#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;

enum TokenType { PLUS, MUL, BR_OPEN, BR_CLOSE, NUMBER, EOF }

struct Token {
	TokenType type;
	long val;
}

Tokens tokenize(string exprStr) {
	Token[] result;
	char[] digitBuffer;
	
	void emitWaiting() {
		if (digitBuffer.length > 0) {
			result = result ~ Token(TokenType.NUMBER, to!long(digitBuffer));
		}
		digitBuffer = [];
	}

	void emit(TokenType type) {
		emitWaiting();
		result = result ~ Token(type, 0);
	}

	foreach (char ch; exprStr) {
		switch (ch) {
			case '0': case '1': case '2': case '3': case '4': 
			case '5': case '6': case '7': case '8': case '9':
				digitBuffer ~= ch;
				break;
			case '+': emit(TokenType.PLUS);
				break;
			case '*': emit(TokenType.MUL);
				break;
			case '(': emit(TokenType.BR_OPEN);
				break;
			case ')': emit(TokenType.BR_CLOSE);
				break;
			case ' ': // ignore
				break;
			default: assert(0, "Found unexpected character: " ~ ch);
		}
	}
	emitWaiting();
	return new Tokens(result);
}

class Tokens {
	private Token[] remain;

	this(Token[] t) {
		remain = t;
	}

	@property TokenType peek() {
		if (remain.empty) {
			return TokenType.EOF;
		}
		return remain[0].type;
	}

	void expect(TokenType[] types...) {
		assert(types.canFind(peek()), "Unexpected token " ~ to!string(this.peek));
	}

	long eat(TokenType type) {
		expect(type);
		assert(remain.length > 0, "Unexpected end of input");
		const long result = remain[0].val;
		remain = remain[1..$];
		return result;
	}
}

long evalPart2(Tokens t) {

	long evalExpr() {
		
		// value = number | '(' expr ')' 
		long evalValue() {
			if (t.peek == TokenType.BR_OPEN) {
				t.eat(TokenType.BR_OPEN);
				const long result = evalExpr();
				t.eat(TokenType.BR_CLOSE);
				return result;
			}
			else {
				return t.eat(TokenType.NUMBER);
			}
		}

		// terms = value [ '+' value [ '+' value ... ]]
		long evalTerms() {
			long result = evalValue();
			while (true) {
				if (t.peek == TokenType.PLUS) {
					t.eat(TokenType.PLUS);
					result += evalValue();
				}
				else {
					t.expect(TokenType.MUL, TokenType.BR_CLOSE, TokenType.EOF);
					return result;
				}
			}
		}

		// products = term [ '*' term [ '*' term ... ]]
		long evalProducts() {
			long result = evalTerms();
			while (true) {
				if (t.peek == TokenType.MUL) {
					t.eat(TokenType.MUL);
					result *= evalTerms();
				}
				else {
					t.expect(TokenType.BR_CLOSE, TokenType.EOF);
					return result;
				}
			}
		}

		return  evalProducts();
	}

	return evalExpr();
}

long evalPart1(Tokens t) {

	// value [ '+' | '*' value [ '+' | '*' value ... ]]
	long evalExpr() {
		
		// value = number | '(' expr ')' 
		long evalValue() {
			if (t.peek == TokenType.BR_OPEN) {
				t.eat(TokenType.BR_OPEN);
				const long result = evalExpr();
				t.eat(TokenType.BR_CLOSE);
				return result;
			}
			else {
				return t.eat(TokenType.NUMBER);
			}
		}

		long result = evalValue();
		while (true) {
			if (t.peek == TokenType.PLUS) {
				t.eat(TokenType.PLUS);
				result += evalValue();
			}
			else if (t.peek == TokenType.MUL) {
				t.eat(TokenType.MUL);
				result *= evalValue();
			}
			else {
				t.expect(TokenType.BR_CLOSE, TokenType.EOF);
			 	return result;
			}
		}
	}

	return evalExpr();
}

string[] readLines(string fname) {
	File file = File(fname, "rt");
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		result = result ~ line;
	}
	// Remove empty line...
	if (result[$-1].length == 0) { result = result[0..$-1]; }
	return result;
}

void main()
{
	long sum1 = 0;
	long sum2 = 0;
	foreach (line; readLines("input")) {
		sum1 += evalPart1(tokenize(line));
		sum2 += evalPart2(tokenize(line));
	}	

	writefln("Part 1: %s\nPart 2: %s", sum1, sum2);
}
