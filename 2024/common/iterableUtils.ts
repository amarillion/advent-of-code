export function times<T>(val: T, num: number): T[] {
	return new Array(num).fill(val);
}

export function initArray<T>(val: (idx: number) => T, num: number): T[] {
	const result: T[] = [];
	for(let i = 0; i < num; ++i) {
		result.push(val(i));
	}
	return result;
}

export function *unique<T>(generator: Generator<T>, identity: (t: T) => unknown = (t: T) => t, maxIterations = 1000) {
	let iterationsWithoutProgress = 0;
	const values = new Set<unknown>();
	for (const value of generator) {
		const id = identity(value);
		if (!values.has(id)) {
			values.add(id);
			iterationsWithoutProgress = 0;
			yield value;
		}
		else {
			iterationsWithoutProgress++;
			// Infitine loop protection
			if (iterationsWithoutProgress > maxIterations) {
				throw new Error('Max iterations reached');
			}
		}
	}
}

export function take<T>(count: number, generator: Generator<T>) {
	const result: T[] = [];
	let i = 0;
	for (const value of generator) {
		result.push(value);
		if (++i === count) break;
	}
	return result;
}

export function sum(array: Iterable<number>) {
	let result = 0;
	for (const val of array) {
		result += val;
	}
	return result;
}


/**
 * Type-safe variant for `array.filter(Boolean)`
 * 
 * Suppose you have an array of type (string | undefined)[]
 * With `array.filter(Boolean)`, undefined values will be filtered out but the resulting type remains the same.
 * Instead, `array.filter(Truthy)` will allow typeScript infer the type of the resulting expression as string[]
 * 
 * See: https://stackoverflow.com/questions/47632622/typescript-and-filter-boolean
 */
export type Truthy<T> = T extends false | '' | 0 | null | undefined ? never : T; // from lodash
export function truthy<T>(value: T): value is Truthy<T> {
	return !!value;
}

