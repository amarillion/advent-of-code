import { AdjacencyFunc, PredicateFunc, Step, WeightFunc } from "@amarillion/helixgraph/lib/definitions";
import { PriorityQueue } from "@amarillion/helixgraph/lib/PriorityQueue";
import { notNull } from "./assert";

/**
 * Given a weighted graph, find all paths from one source to one or more destinations
 * @param {*} source
 * @param {*} dest - either a destination value, or a predicate function to check if a given node is a destination
 * @param {*} getAdjacent
 * @param {Object} options containing getHeuristic(node), maxIterations, getWeight(edge)
 *
 * @returns { prevMap: Map(to, { edge, from, to, cost }), dest: N }
 */
export function astarEx<N, E>(source: N, dest: N | PredicateFunc<N>, getAdjacent: AdjacencyFunc<N, E>,
	// see: https://mariusschulz.com/blog/typing-destructured-object-parameters-in-typescript
	{
		maxIterations = 0,
		getWeight = () => 1,
		getHeuristic = () => 0
	}: {
		maxIterations?: number,
		getWeight?: WeightFunc<N, E>,
		getHeuristic?: (node: N) => number,
	} = {}
) {
	const isDest = typeof(dest) === 'function' ? dest as PredicateFunc<N> : (n: N) => n === dest; 
	const dist = new Map<N, number>();
	const prev = new Map<N, Step<N, E>>();
	
	const priority = new Map();
	const open = new PriorityQueue<N>((a, b) => priority.get(b) - priority.get(a));

	open.push(source);
	dist.set(source, 0);
	let result: N | undefined = undefined;

	let i = maxIterations;
	while (open.size() > 0) {
		i--; // 0 -> -1 means Infinite.
		if (i === 0) break;

		const current = open.pop();

		if (isDest(current)) {
			result = current;
			break;
		}
		
		for (const [ edge, sibling ] of getAdjacent(current)) {
			const cost = notNull(dist.get(current)) + getWeight(edge, current);
			const oldCost = dist.get(sibling) ?? Infinity;
			if (cost < oldCost) {
				dist.set(sibling, cost);
				priority.set(sibling, cost + getHeuristic(sibling));
				open.push(sibling);
				
				// build back-tracking map
				prev.set(sibling, { edge, from: current, to: sibling, cost });
			}
		}
	}

	return { prevMap: prev, dest: result };
}
