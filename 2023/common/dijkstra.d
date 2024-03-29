module common.dijkstra;

import std.typecons;
import std.container.binaryheap;

auto dijkstra(E,N)(
	N source, 
	bool delegate(N) isDest, 
	Tuple!(E,N)[] delegate(N) getAdjacent, 
	int delegate(N) getWeight
) {
	struct Result {
		int[N] dist;
		N[N] prev;
		N dest;
	}
	Result result;
	result.dist = [ source: 0 ];
	bool[N] visited;

	// priority queue	
	auto open = heapify!((a, b) => result.dist[a] > result.dist[b])([ source ]);

	while (open.length > 0) {
		auto current = open.front;
		open.popFront;
		
		if(current in visited) continue; // extra occurrences are possible if cost has been lowered. Ignore.

		foreach(pair; getAdjacent(current)) {
			N sibling = pair[1];

			if (!(sibling in visited)) {
				
				int alt = result.dist[current] + getWeight(sibling);
				int oldDist = sibling in result.dist ? result.dist[sibling] : int.max;

				if (alt < oldDist) {
					// set or update distance
					result.dist[sibling] = alt;
					// build back-tracking map
					result.prev[sibling] = current;
					
					// Any pre-existing paths to sibling are out of date now. But that's ok.
					// but the one with the lowest cost will be visited first, and the later ones will be ignored.
					open.insert(sibling);
				}
			}
		}

		// A visited node will never be checked again.
		visited[current] = true;

		if (isDest(current)) {
			result.dest = current;
			break;	
		}
	}

	return result;
}
