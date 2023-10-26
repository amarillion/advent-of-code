import { IPoint } from "./point.js";

/**
 * Wraps a Map<hash(Point), V>, while keeping track of coordinate range.
 */
export class SparseGrid<V> {

	private readonly data = new Map<string, V>();
	private _minY = Infinity;
	private _minX = Infinity;
	private _maxY = -Infinity;
	private _maxX = -Infinity;

	get minX() { return this._minX; }
	get minY() { return this._minY; }
	get maxX() { return this._maxX; }
	get maxY() { return this._maxY; }

	constructor() {
	}
	
	private static toKey(p: IPoint) {
		return `${p.x},${p.y}`;
	}

	set(p : IPoint, value: V) {
		const key = SparseGrid.toKey(p);
		if (!this.data.has(key)) {
			if (p.x < this._minX) { this._minX = p.x; }
			if (p.x > this._maxX) { this._maxX = p.x; }
			if (p.y < this._minY) { this._minY = p.y; }
			if (p.y > this._maxY) { this._maxY = p.y; }
		}
		this.data.set(key, value)
	}
	
	get(p : IPoint, fallback: V|undefined = undefined): V|undefined {
		const key = SparseGrid.toKey(p)
		if (!this.data.has(key)) {
			return fallback;
		}
		return this.data.get(key);
	}

	has(p: IPoint) {
		const key = SparseGrid.toKey(p)
		return this.data.has(key);
	}

	toString(colSep = '', rowTerm = '\n', fallback: V|undefined = undefined) {
		let result = '';
		for (let y = this._maxY; y >= this._minY; y--) {
			let firstCol = true;
			for (let x = this._minX; x <= this._maxX; ++x) {
				if (firstCol) { firstCol = false; } else { result += colSep; }
				result += this.get({ x, y }, fallback);
			}
			result += rowTerm;
		}
		return result;
	}
}
