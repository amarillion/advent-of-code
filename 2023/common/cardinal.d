module common.cardinal;

import common.vec;

enum Dir {
	E = 1,
	S = 2,
	W = 4,
	N = 8
}

enum Dir[Dir] REVERSE = [
	Dir.N: Dir.S,
	Dir.E: Dir.W,
	Dir.S: Dir.N,
	Dir.W: Dir.E
];

enum Point[Dir] DELTA = [
	Dir.E: Point(1, 0), 
	Dir.S: Point(0, 1), 
	Dir.W: Point(-1, 0), 
	Dir.N: Point(0, -1)
];

enum char[Dir] SHORT = [
	Dir.E: '>',
	Dir.S: 'v',
	Dir.W: '<',
	Dir.N: '^'
];

