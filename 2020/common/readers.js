import fsp from 'fs/promises';
import fs from 'fs';
import readline from 'readline';
import { assert } from './assert.js';

/*
Reads file, returns array of lines.
If last line is empty, it is left out
*/
export async function readLines(fileName) {
	const data = await fsp.readFile(fileName, { encoding: 'utf-8' });
	const lines = data.split('\n'); 
	// remove last line if it's empty
	if (lines[lines.length-1] === '') lines.splice(lines.length-1);
	return lines;
}

/** read a list of numbers, one per line. 
 * includes conversion to numbers */
export async function readNumbers(file) {
	let data = [];
	for await (const line of readLinesGenerator(file)) {
		data.push(+line);
	}
	return data;
}

/*
Reads file, returns matrix: an array of arrays of characters.
If last line is empty, it is left out
*/
export async function readMatrix(fileName) {
	const lines = await readLines(fileName); 
	return lines.map(line => line.split(''));
}

/*
Read file line by line, but as a generator
*/
export async function *readLinesGenerator(fileName) {
	const fileStream = fs.createReadStream(fileName);

	const rl = readline.createInterface({
		input: fileStream,
		crlfDelay: Infinity
	});
	// Note: we use the crlfDelay option to recognize all instances of CR LF
	// ('\r\n') in input.txt as a single line break.

	for await (const line of rl) {
		yield line;
	}
}

/*
Read file in paragraphs.
Each paragraph is a group of lines separated by an empty line.
Each yield is a single paragraph, as an array of lines 
*/
export async function *paragraphGenerator(file) {
	let group = [];
	for await (const line of readLinesGenerator(file)) {
		if (line === '') {
			yield group;
			group = [];
			continue;
		}
		group.push(line);
	}
	yield group;
}

/* 
read a single char from STDIN synchronously
i.e. Blocks until there is input
*/
export function readChar() {
	// source: https://stackoverflow.com/a/64235311/3306
	let buffer = Buffer.alloc(1);
	let num = fs.readSync(0, buffer, 0, 1, null);
	assert(num === 1);
	return buffer[0];
}

/* 
Write a single char to STDOUT synchronously
*/
export function writeChar(ch) {
	let buffer = Buffer.alloc(1);
	assert (ch >= 0 && ch < 256);
	buffer[0] = ch;
	fs.writeSync(0, buffer);
}

export function readStdinLines() {
	const buffer = fs.readFileSync(0); // STDIN_FILENO = 0$
	return buffer.toString().split('\n');
}
