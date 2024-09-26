package day17;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Stack;
import java.util.stream.Stream;

public class Solution {

	private static List<Integer> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(Integer::parseInt).toList();
		}
	}

	private record WIP(List<Integer> pick, int size, int start) {}

	// TODO: make iterable
	static List<List<Integer>> allCombinations(List<Integer> data, int target) {
		List<List<Integer>> result = new ArrayList<>();
		for (int num = data.size() - 1; num >= 1; num--) {
			// all the ways to pick num items from the list...
			Stack<WIP> stack = new Stack<>();
			stack.push(new WIP(Collections.emptyList(), 0, 0));
			while (!stack.empty()) {
				var current = stack.pop();
				if (current.pick.size() == num) {
					// TODO: to make more generic, target matching should be moved outside this function
					if (current.size == target) {
						result.add(current.pick);
						System.out.println("Match! " + current.pick);
					}
				}
				else {
					for (int i = current.start; i < data.size(); ++i) {
						var nextPick = new ArrayList<>(current.pick);
						nextPick.add(data.get(i));
						int nextSize = current.size + data.get(i);
						stack.push(new WIP(nextPick, nextSize, i + 1));
					}
				}
			}
 		}
		return result;
	}

	static void solve(List<Integer> data, int target) {
		List<List<Integer>> combinations = allCombinations(data, target);
		System.out.println(combinations.size());
		int minSize = Integer.MAX_VALUE;
		long result = 0;
		for (var comb: combinations) {
			int size = comb.size();
			if (size < minSize) {
				minSize = comb.size();
				result = 1;
			}
			else if (size == minSize) {
				result++;
			}
		}
		System.out.println("Minimum size: " + minSize + " Minimum combinations: " + result);
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day17/test-input"));
		Util.assertEqual(allCombinations(testData, 25).size(), 4);

		var data = parse(Path.of("day17/input"));
		solve(data, 150);
	}
}
