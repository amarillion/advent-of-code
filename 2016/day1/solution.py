#!/usr/bin/env python3

import sys

if len(sys.argv) <= 1:
	print("Expected at least 1 argument")
	sys.exit(1)

fname = sys.argv[1]

with open(fname, "r") as fin:
	line = fin.readline()

dx = 0
dy = -1

x = 0
y = 0

part2 = 0

visited: set[tuple] = set(())

instr = line.split(', ')
for i in instr:
	dir = i[0]
	count = int(i[1:])

	if dir == 'R':
		[dx, dy] = [-dy, dx]
	elif dir == 'L':
		[dx, dy] = [dy, -dx]

	for c in range(count):
		x += dx
		y += dy

		if part2 == 0 and (x, y) in visited:
			part2 = abs(x) + abs(y)
		else:
			visited.add((x, y))


print (abs(x) + abs(y))
print (part2)