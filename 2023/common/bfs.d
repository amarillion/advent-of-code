module common.bfs;

import std.typecons;
import std.range;

auto bfs(N, E)(N source, bool delegate(N) isSink, Tuple!(E, N)[] delegate(N) getAdjacent) {
	
	struct Result {
		int[N] dist;
		N[N] prev;
	}
	
	Result result;
	result.dist = [ source: 0 ];

	bool[N] visited;
	
	const(N)[] open = [ source ];
	visited[source] = true;

	while (open.length > 0) {
		
		N current = open[0];
		open.popFront();

		// check adjacents
		foreach(pair; getAdjacent(current)) {
			N sibling = pair[1];
			if (!(sibling in visited)) {
				open ~= sibling;
				visited[sibling] = true;
				// set or update distance
				result.dist[sibling] = result.dist[current] + 1;
				// writefln("step %s: from %s to %s, visited: %s", result.dist[current] + 1, current, sibling, visited);
				result.prev[sibling] = current;
			}
		}

		if (isSink(current)) {
			break;
		}
	}

	return result;
}

auto bfs(N)(N source, bool delegate(N) isSink, N[] delegate(N) getAdjacent) {
	
	struct Result {
		int[N] dist;
		N[N] prev;
	}
	
	Result result;
	result.dist = [ source: 0 ];

	bool[N] visited;
	
	const(N)[] open = [ source ];
	visited[source] = true;

	while (open.length > 0) {
		N current = open.front;
		open.popFront();

		// check adjacents
		foreach(sibling; getAdjacent(current)) {
			if (!(sibling in visited)) {
				open ~= sibling;
				visited[sibling] = true;
				// set or update distance
				result.dist[sibling] = result.dist[current] + 1;
				// writefln("step %s: from %s to %s, visited: %s", result.dist[current] + 1, current, sibling, visited);
				result.prev[sibling] = current;
			}
		}

		if (isSink(current)) {
			break;
		}
	}

	return result;
}
