import { TemplateGrid } from "@amarillion/helixgraph/lib/BaseGrid";

// TODO: make utility function
export function find<T>(grid: TemplateGrid<T>, predicate: (t: T) => boolean) {
	for (let y = 0; y < grid.height; ++y) {
		for (let x = 0; x < grid.width; ++x) {
			const cell = grid.get(x, y);
			if (predicate(cell)) {
				return cell;
			}
		}
	}
	return null;
}
