import { Point } from './point.js';

// visit each point surrounding 0,0 in a diamond shape
export function *diamondRange(size: number) {
	if (size < 0) return;
	// going in reverse order to avoid negative zeroes
	for (let x = size; x >= -size; x--) {
		const ortho = size - Math.abs(x);
		for (let y = ortho; y >= -ortho; y--) {
			yield new Point(x, y);
		}
	}
}

/**
 * Go over all points in an area in a fixed order: horizontal row by row.
 * Yield each coordinate pair.
 *
 * @param width
 * @param height
 */
export function *pointRange(width: number, height: number) {
	for (let y = 0; y < height; ++y) {
		for (let x = 0; x < width; ++x) {
			yield ({ x, y });
		}
	}
}
