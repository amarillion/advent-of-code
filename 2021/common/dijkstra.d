module common.dijkstra;

import std.typecons;
import std.container.binaryheap;

/** 
 Simplified variant: with simplified getAdjacent function,
 Templated on Node only, so not on Edge 

 In one test, this is 15% faster than the other variant that also tracks edges.
 */
auto dijkstra(N)(
	N source, 
	bool delegate(N) isDest, 
	N[] delegate(N) getAdjacent, 
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

		foreach(sibling; getAdjacent(current)) {
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

/** 
 * Complex variant
 * Tracks nodes and edges together in the getAdjacent function.
 */
auto dijkstra(E,N)(
	N source, 
	bool delegate(N) isDest, 
	Tuple!(E,N)[] delegate(N) getAdjacent, 
	int delegate(E, N) getWeight
) {
	struct Step(N, E) {
		N src;
		E edge;
		N dest;
		int cost;
	}

	struct DijkstraResult {
		Step!(N,E)[N] steps;
		N dest;
	}

	DijkstraResult result;
	int[N] dist = [ source: 0 ];
	bool[N] visited;

	// priority queue	
	auto open = heapify!((a, b) => dist[a] > dist[b])([ source ]);

	while (open.length > 0) {
		auto current = open.front;
		open.popFront;
		
		if(current in visited) continue; // extra occurrences are possible if cost has been lowered. Ignore.

		foreach(pair; getAdjacent(current)) {
			N sibling = pair[1];
					E edge = pair[0];

			if (!(sibling in visited)) {
				
				int alt = dist[current] + getWeight(edge, sibling);
				int oldDist = sibling in dist ? dist[sibling] : int.max;

				if (alt < oldDist) {
					// set or update distance
					dist[sibling] = alt;
					result.steps[sibling] = Step!(N, E)(current, edge, sibling, alt);
					
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
