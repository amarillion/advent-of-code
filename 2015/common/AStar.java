package common;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.function.Function;

// Used for day 19
// TODO: Validate correctness & optimize performance
public class AStar<N>
{
	private final Map<N, Double> priority = new HashMap<>();
	private final Map<N, Double> cost = new HashMap<>();
	private final Set<N> opened = new HashSet<>();
	private final Map<N, N> parents = new HashMap<>();

	// queue of open nodes to examine
	private final PriorityQueue<N> open = new PriorityQueue<>((a, b) -> {
		return Double.compare(priority.get(a), priority.get(b));
	});

	// some stats
	public int nodesOpened = 0;
	public int maxQueueSize = 0;

	public AStar(N start, N target, Function<N, Iterable<N>> getAdjacent, Function<N, Double> heuristic, double weight) {
		this.getAdjacent = getAdjacent;
		this.start = start;
		this.target = target;
		this.heuristic = heuristic;
		this.weight = weight;
	}

	private final Function<N, Iterable<N>> getAdjacent;
	private final N start;
	private final N target;
	private final Function<N, Double> heuristic;
	private final double weight;

	private N curr;
	private N found;

	// calculate the segments
	public List<N> run() {
		start();

		// get next open node from the queue
		while (!open.isEmpty()) {
			if (step()) break;
		}

		return getPath();
	}

	private void start() {
		// put start node on the queue
		openNode(start, null, 0, heuristic.apply(start));
	}

	private List<N> getPath() {
		List<N> result = new ArrayList<>();
		// now we start backtracking the node tree
		if (found == null) {
			return null;
		}
		else
		{
			//calculate segments
			while (parents.containsKey(curr)) {
				N parent = parents.get(curr);
				result.add(curr);
				curr = parent;
			}
		}

		return result;
	}

	private boolean step() {
//			if ((++i % printThrottle) == 0) {
//				System.out.println("Examining: " + curr);
//				System.out.println("Target   : " + target);
//				System.out.println("Cost: " + cost.get(curr) + ", Total: " + priority.get(curr) + " Nodes opened: " + nodesOpened + " Queue size " + open.size());
//			}

		curr = open.poll();
		if (curr == null) {
			return false;
		}

		if (curr.equals(target))
		{
			// finished!
			found = curr;
			return true;
		}
		else
		{
			for (var adj : getAdjacent.apply(curr)) {
				// open node in current direction
				openNode(adj, curr, cost.get(curr) + weight, heuristic.apply(adj));
			}
		}

		// track stats.
		maxQueueSize = Math.max(open.size(), maxQueueSize);
		return false;
	}

	// add a node to the queue, but only if it's not in the opened set,
	// or if it has a smaller g than the one in the opened set
	private void openNode(N n, N parent, double f, double h)
	{
		double g = f + h;
		if (!opened.contains(n) || priority.get(n) > g) {
			priority.put(n, g);
			cost.put(n, f);
			open.add (n);
			opened.add (n);
			parents.put(n, parent);
			nodesOpened++;
		}
	}

}
