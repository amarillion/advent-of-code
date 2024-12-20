/**
 * Convert a map to a string, using
 * @param map 
 * @param comparator optional comparator applied to keys 
 * @returns 
 */
export function sortedMapToString<K, V>(map: { keys(): Iterable<K>, get(key: K): V }, comparator?: (a: K, b: K) => number) {
	const keys = [...map.keys()];
	const indent = '    ';
	keys.sort(comparator);
	const prefixIndent = (val: unknown) => `${val}`.split('\n').join(`\n${indent}`);
	return `{\n${keys.map(key => `${indent}${key} => ${prefixIndent(map.get(key))}`).join(',\n')}\n}`;
}
