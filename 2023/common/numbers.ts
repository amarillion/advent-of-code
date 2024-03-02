/*
Some functions from number theory, used in Advent of Code.

Note: D has functions for gcd and lcm built into phobos.
*/

/**
 * Greatest common divisor of two numbers.
 * Euclid's algorithm (tail recursive)
 * 
 * One application of GCD is simplifying fractions.
 */
export function GCD(a: number, b: number){ 
	let greater = Math.max(a, b); 
	let smallest = Math.min(a, b); 
	let remainder = greater % smallest;
	
	if (remainder == 0) {
		return smallest;
	}
	else {
		return GCD(smallest, remainder);
	}
} 

/**
 * Least common multiple of two numbers, i.e. the smallest integer that can be divided evenly by two numbers.
 * 
 * LCM can be used to calculate when cycles line up.
 * For example: one train departs every 15 minutes. The other departs every 20 minutes
 * LCM(15,20) == 60, so they depart together every 60 minutes
 * 
 * For more than two numbers, simply chain, e.g.: LCM(a, LCM(b, c))
 */
export function LCM(a: number, b: number){ 
	let greater = Math.max(a, b); 
	let smallest = Math.min(a, b); 
	for(let i = greater; i <= a*b; i+=greater){ 
		if(i % smallest == 0){ 
			return i; 
		} 
	} 
} 
