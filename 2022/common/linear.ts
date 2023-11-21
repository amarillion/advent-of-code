/** 
 * Assuming function f(x),
 * find x where f(x) === 0
 * Iterates to increase precision
 * 
 * If the function is not linear, it will find the local minimum around xstart.
 */
export function linearSolver(f: (x: number) => number, xstart = 0, dx = 1, maxIterations = 100) {
	let x = xstart;
	let itRemain = maxIterations;
	while (true) { 
		
		const y1 = f(x);
		const y2 = f(x + dx);

		// estimate a & b for f(x) = ax * b
		const a = (y2 - y1) / (-dx)
		const b = y1 + (a * x);

		// f(x) will cross x-axis at b / a,
		// assuming f(x) is linear, and we have enough bits of precision.
		x = b / a;

		// continue with increasing precision, until we've reached zero, or hit our limit of tries
		if (f(x) === 0 || itRemain <= 0) { return x; }
		itRemain--;
	}
}
