import { AdjacencyFunc, Step, WeightFunc } from '@amarillion/helixgraph/lib/definitions.js';
import { DefaultMap } from '../common/DefaultMap.js';

function spliceLowest<T>(queue: Set<T>, comparator: (a: T, b: T) => number) {
	let minElt: T | null = null;
	for (const elt of queue) {
		if (minElt === null || comparator(elt, minElt) < 0) {
			minElt = elt;
		}
	}
	if (minElt) queue.delete(minElt);
	return minElt;
}

function toSet<T>(value: T[] | T) {
	if (Array.isArray(value)) {
		return new Set(value);
	}
	else {
		return new Set([ value ]);
	}
}

/**
 * Given a weighted graph, find all paths from one source to one or more destinations
 * 
 * This alternative version can find _all_ paths with the lowest cost.
 * Instead of returning a map of steps, it returns a multimap with all possible steps that can reach a certain node with the same cost.
 * 
 * @param {*} source
 * @param {*} dest - the search destination node, or an array of destinations that must all be found
 * @param {*} getAdjacent
 * @param {*}
 *
 * @returns Map(to, { edge, from[], to, cost }[])
 */
//TODO: should this alternative dijkstra function be added back to HelixGraph somehow?
export function dijkstraEx<N, E>(source: N, dest: N | N[], getAdjacent: AdjacencyFunc<N, E>,
	{
		maxIterations = 0,
		getWeight = () => 1,
	}: {
		maxIterations?: number,
		getWeight?: WeightFunc<N, E>,
	} = {}
) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	const dist = new Map<N, number>();
	const visited = new Set<N>();
	const prev = new DefaultMap<N, Step<N, E>[]>([]);
	const remain = toSet(dest);
	
	// TODO: more efficient to use a priority queue here
	const open = new Set<N>();

	open.add(source);
	dist.set(source, 0);

	let i = maxIterations;
	while (open.size) {
		i--; // 0 -> -1 means Infinite.
		if (i === 0) break;

		// extract the element from Q with the lowest dist. Open is modified in-place.
		// TODO: optionally use PriorityQueue
		// O(N^2) like this, O(log N) with priority queue. But in my tests, priority queues only start pulling ahead in large graphs
		const current = spliceLowest(open, (a, b) => dist.get(a)! - dist.get(b)!)!;

		// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
		for (const [ edge, sibling ] of getAdjacent(current)) {
			if (!(visited.has(sibling))) {
				const alt = dist.get(current)! + getWeight(edge, current);
				
				// any node that is !visited and has a distance assigned should be in open set.
				open.add (sibling); // may be already in there, that is OK.

				const oldDist = dist.get(sibling) || Infinity;

				if (alt < oldDist) {
					// set or update distance
					dist.set(sibling, alt);
					// build back-tracking map
					prev.set(sibling, [{ edge, from: current, to: sibling, cost: alt }]);
				}
				// alternative path with equal cost
				else if (alt === oldDist) {
					prev.update(sibling, val => { val.push({ edge, from: current, to: sibling, cost: alt }); return val });
				}
			}
		}

		// A visited node will never be checked again.
		visited.add(current);

		if (remain.has(current)) {
			remain.delete(current);
			if (remain.size === 0) break;
		}
	}

	return prev;
}
