/**
 * Usage:
 * const fibonacci = memoize(n => n <= 2 ? 1 : fibonacci(n-1) + fibonacci(n-2))
 * 
 * @param fn: pure function with a single argument and single result.
 * @returns 
 */
export function memoize<U, V>(fn: (u: U) => V) {
	const cache = new Map<U, V>();
	return (arg: U) => {
		if (cache.has(arg)) {
			return cache.get(arg)!;
		}

		const result = fn(arg);
		cache.set(arg, result);
		return result;
	}
}
