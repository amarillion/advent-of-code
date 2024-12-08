/**
 * Wraps a Map<K, V>
 * Only difference is that get() returns a default value if key doesn't exist.
 */
export class DefaultMap<K, V> {
	
	readonly defaultValue: V;
	readonly supplier: () => V;
	readonly useSupplier: boolean;

	private _data = new Map<K, V>();

	constructor(defaultValue: V|(() => V)) {
		if (typeof defaultValue === 'function') {
			this.supplier = defaultValue as () => V;
			this.useSupplier = true;
		}
		else if (typeof(defaultValue) === 'object') {
			this.supplier = () => structuredClone(defaultValue);
			this.useSupplier = true;
		}
		else {
			this.defaultValue = defaultValue;
			this.useSupplier = false;
		}
	}

	set(key: K, value: V) {
		return this._data.set(key, value);
	}

	has(key: K) {
		return this._data.has(key);
	}

	get(key: K) {
		if (this._data.has(key)) {
			return this._data.get(key)!;
		}
		else { 
			if (this.useSupplier) {
				const copy = this.supplier();
				this._data.set(key, copy);
				return copy;
			}
			else {
				return this.defaultValue;	
			}
		}
	}

	keys() {
		return this._data.keys();
	}

	get size() {
		return this._data.size;
	}

	delete(key: K) {
		return this._data.delete(key);
	}

	clear() {
		this._data.clear();
	}

	entries() {
		return this._data.entries();
	}

	values() {
		return this._data.values();
	}

	[Symbol.iterator]() {
		return this._data[Symbol.iterator]();
	}

	get [Symbol.toStringTag]() {
		return this._data[Symbol.toStringTag];
	}

	forEach(callback: (val: V, key: K, map: Map<K, V>) => void) {
		this._data.forEach((val, key) => callback(val, key, this));
	}

	/** customization */
	update(key: K, updateFunc: (val?: V) => V) {
		this.set(key, updateFunc(this.get(key)));
	}

	/** customization */
	toString() {
		let result = 'DefaultMap {';
		let sep = '';
		const indent = '    ';
		for (const k of this.keys()) {
			const val = `${this.get(k)}`;
			result += `${sep}\n${indent}${k} => ${val.split('\n').join(`\n${indent}`)}`;
			sep = ','
		}
		result += '\n}';
		return result;
	}
}
