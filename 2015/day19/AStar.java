package day19;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.function.Function;

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

	// calculate the segments
	List<N> doAstar(N start, N target, Function<N, Iterable<N> > getAdjacent, Function<N, Double> heuristic, double weight, int printThrottle) {
		// put start node on the queue
//		open.add(start);
		openNode(start, null, 0, heuristic.apply(start));

		N curr;
		N end = null;

		int i = 0;
		// get next open node from the queue
		while ((curr = open.poll()) != null)
		{
			if ((++i % printThrottle) == 0) {
				System.out.println("Examining: " + curr);
				System.out.println("Target   : " + target);
				System.out.println("Cost: " + cost.get(curr) + ", Total: " + priority.get(curr) + " Nodes opened: " + nodesOpened + " Queue size " + open.size());
			}

			if (curr.equals(target))
			{
				// finished!
				end = curr;
				break;
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
		}

		List<N> result = new ArrayList<>();
		// now we start backtracking the node tree
		if (end == null) {
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
}
