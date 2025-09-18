export const MEMOIZE_STATS = Symbol();

/**
 * Usage:
 * const fibonacci = memoize(n => n <= 2 ? 1 : fibonacci(n-1) + fibonacci(n-2))
 * 
 * // check cache hits / misses with:
 * console.log(fibonacci[MEMOIZE_STATS]);
 * 
 * @param fn: /pure/ function with a single argument and single result.
 * @returns same function, but with calculations cached.
 */
export function memoize<U, R>(fn: (u: U) => R) {
	const cache = new Map<U, R>();
	const stats = { miss: 0, hit: 0 };
	let result = (arg: U) => {
		if (cache.has(arg)) {
			stats.hit++;
			return cache.get(arg)!;
		}

		stats.miss++;
		const result = fn(arg);
		cache.set(arg, result);
		return result;
	}
	result[MEMOIZE_STATS] = stats;
	return result;
}

/**
 * Memoize a pure function with two arguments.
*/
export function memoize2<U, V, R>(fn: (u: U, v: V) => R) {
	// NOTE possible alternative is using JSON.stringify([u, v]) as key.
	// slightly simpler, and allowing for more types, but with overhead of stringify.
	const cache = new Map<U, Map <V, R>>();
	const stats = { miss: 0, hit: 0 };
	const result = ((u: U, v: V): R => {
		if (!cache.has(u)) {
			cache.set(u, new Map<V, R>());
		}

		const elt = cache.get(u)!;
		if (!elt.has(v)) {
			stats.miss++;
			elt.set(v, fn(u, v));
		}
		else {
			stats.hit++;
		}

		return elt.get(v)!;
	});
	result[MEMOIZE_STATS] = stats;
	return result;
}
