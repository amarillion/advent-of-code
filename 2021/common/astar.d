module common.astar;

import std.typecons;
import std.container.binaryheap;
import std.stdio;

struct Step(N, E) {
	N src;
	E edge;
	N dest;
	int cost;
}

auto astar(N, E)(
	N source, 
	bool delegate(N) isDest, 
	Tuple!(E, N)[] delegate(N) getAdjacent, 
	int delegate(Tuple!(E, N)) getWeight,
	int delegate(N) getHeuristic = (N) => 0,
	int maxIterations = -1
) {
	int[N] dist = [ source: 0 ];
	int[N] priority = [ source: 0 ];
	struct Result {
		Step!(N, E)[N] prev;
		N dest;
	}
	Result result;

	// priority queue	
	auto open = heapify!((a, b) => priority[a] > priority[b])([ source ]);

	int i = maxIterations;
	while (open.length > 0) {
		N current = open.front;
		open.popFront;
		
		// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
		foreach(Tuple!(E, N) adj; getAdjacent(current)) {
			N sibling = adj[1];
			E edge = adj[0];
			const cost = dist[current] + getWeight(adj);
			const oldCost = sibling in dist ? dist[sibling] : int.max;

			if (cost < oldCost) {
				dist[sibling] = cost;
				priority[sibling] = cost + getHeuristic(sibling);
				open.insert(sibling);
				
				// build back-tracking map
				result.prev[sibling] = Step!(N, E)(current, edge, sibling, cost);
			}
		}

		if (isDest(current)) {
			result.dest = current;
			break;	
		}

		i--; // 0 -> -1 means Infinite.
		if (i == 0) break;
		// if (i % 10000 == 0) { writeln(-i, " ", open.length); }
	}

	return result;
}
