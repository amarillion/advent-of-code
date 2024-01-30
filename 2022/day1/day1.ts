#!/usr/bin/env tsx
import { readFileSync } from 'fs';

let raw = readFileSync('input').toString('utf-8');
const elves = raw.split("\n\n");
let elfSums = elves.map(n => n.split("\n").map(Number).reduce((acc, cur) => acc + cur, 0));

elfSums = elfSums.sort((a, b) => b - a);
console.log(elfSums[0]);

console.log(elfSums[0]+elfSums[1]+elfSums[2]);