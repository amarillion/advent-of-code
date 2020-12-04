import fsp from 'fs/promises';
import fs from 'fs';
import readline from "readline";

export async function readLines(fileName) {
	const data = await fsp.readFile(fileName, "UTF-8")
	const lines = data.split("\n"); 
	// remove last line if it's empty
	if (lines[lines.length-1] === '') lines.splice(lines.length-1);
	return lines;
}

export async function readMatrix(fileName) {
	const lines = await readLines(fileName); 
	return lines.map(line => line.split(''));
}

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

export async function *lineGroupGenerator(file) {
	let group = []
	for await (const line of readLinesGenerator(file)) {
		if (line === '') {
			yield group;
			group = [];
			continue;
		}
		group = group.concat(line.split(' '))
	}
	yield group;
}
