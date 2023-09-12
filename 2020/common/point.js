import { assert } from './assert.js';

export class Point {

	constructor(x, y) {
		this.x = x;
		this.y = y;
	}
	
	/**
	 * @param {*} degrees on a 360 degree circle. Positive: rotate left. Negative: rotate right
	 * returns a new Point()
	 */
	rotate(degrees) {
		const { x, y } = this;
		switch((degrees + 360) % 360) {
			case 270: return new Point(-y, x);
			case 180: return new Point(-x, -y);
			case  90: return new Point(y, -x);
			case   0: return new Point(x, y);
			default: assert(false, `Invalid value ${degrees}`);
		}
	}

	/**
		Scale the vector
		returns a new Point
 	*/
	mul(val) {
		return new Point(this.x * val, this.y * val);
	}

	/**
	 * @param {*} p point to add to this
	 * returns a new Point containing the sum 
	 */
	plus(p) {
		return new Point(p.x + this.x, p.y + this.y);
	}

	/**
	 * returns the manhattan distance from 0,0 to this point.
	 */
	manhattan() {
		return Math.abs(this.x) + Math.abs(this.y);
	}
}
