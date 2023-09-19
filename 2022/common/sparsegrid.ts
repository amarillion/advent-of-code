import { Point } from "./point.js";

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
	
	set(p : Point, value: V) {
		const key = p.toString();
		if (!this.data.has(key)) {
			if (p.x < this._minX) { this._minX = p.x; }
			if (p.x > this._maxX) { this._maxX = p.x; }
			if (p.y < this._minY) { this._minY = p.y; }
			if (p.y > this._maxY) { this._maxY = p.y; }
		}
		this.data.set(key, value)
	}
	
	get(p : Point, fallback: V|undefined = undefined): V|undefined {
		const key = p.toString()
		if (!this.data.has(key)) {
			return fallback;
		}
		return this.data.get(key);
	}

	has(p: Point) {
		const key = p.toString()
		return this.data.has(key);
	}

	toString(colSep = '', rowTerm = '\n', fallback: V|undefined = undefined) {
		let result = '';
		for (let y = this._maxY; y >= this._minY; y--) {
			let firstCol = true;
			for (let x = this._minX; x <= this._maxX; ++x) {
				if (firstCol) { firstCol = false; } else { result += colSep; }
				result += this.get(new Point(x, y), fallback);
			}
			result += rowTerm;
		}
		return result;
	}
}
