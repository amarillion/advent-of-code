import { Point } from "./point";

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
