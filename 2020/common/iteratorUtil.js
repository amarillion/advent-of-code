
export function allMatch(iterable, predicate) {
	for(const val of iterable) {
		if (!predicate(val)) return false;
	}
	return true;
}

export function anyMatch(iterable, predicate) {
	for(const val of iterable) {
		if (predicate(val)) return true;
	}
	return false;
}

export function noneMatch(iterable, predicate) {
	for(const val of iterable) {
		if (predicate(val)) return false;
	}
	return true;
}

export function product(iterable) {
	let result = 1;
	for(const val of iterable) {
		result *= (+val);
	}
	return result;	
}

export function sum(iterable) {
	let result = 0;
	for(const val of iterable) {
		result += (+val);
	}
	return result;	
}
