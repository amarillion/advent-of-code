#!/usr/bin/env python3

import sys
fname = "input"
with open(fname, "rt") as file:
    lines = file.readlines()

numbers = [int(x) for x in lines]

total = 0
# for i in range(0, len(numbers)):
# 	print (i / len(numbers) * 100)
# 	for j in range(0, i):
# 		for k in range(0, j):
# 			total += 1
# 			ni = numbers[i]
# 			nj = numbers[j]
# 			nk = numbers[k]
# 			# print ("%s %s %s %s %s" % (ni, nj, nk, ni + nj + nk, ni*nj*nk))
# 			if (ni + nj + nk == 2020):
# 				print ("%s %s %s %s %s" % (ni, nj, nk, ni + nj + nk, ni*nj*nk))


for i in numbers:
	for j in numbers:
		for k in numbers:
			if (i + j + k == 2020):
				print ("%s %s %s %s %s" % (i, j, k, i + j + k, i*j*k))
print (total)