#!/usr/bin/env python3

import sys
fname = "input"
with open(fname, "rt") as file:
    lines = file.readlines()

numbers = [int(x) for x in lines]

for i in numbers:
	for j in numbers:
		if (i + j == 2020):
			print ("%s %s %s %s" % (i, j, i + j, i*j))