package day24;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

public class Solution {

	private static List<Integer> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(Integer::parseInt).sorted().toList();
		}
	}

	private static int countBits(int n) {
		int mask = 1;
		int numBits = 0;
		while (mask <= n) {
			if ((n & mask) > 0) { numBits++; }
			mask <<= 1;
		}
		return numBits;
	}

	private static int countWeight(List<Integer> data, int n) {
		int mask = 1;
		int result = 0;
		for (Integer datum : data) {
			if ((n & mask) > 0) {
				result += datum;
			}
			mask <<= 1;
		}
		return result;
	}

	private static long calculateQe(List<Integer> data, int n) {
		int mask = 1;
		long result = 1;
		for (Integer datum : data) {
			if ((n & mask) > 0) {
				result *= datum;
			}
			mask <<= 1;
		}
		return result;
	}

	private static String subsetToString(List<Integer> data, int n) {
		int mask = 1;
		var sb = new StringBuilder("[");
		String sep = "";
		for (Integer datum : data) {
			if ((n & mask) > 0) {
				sb.append(sep).append(datum);
				sep = ", ";
			}
			mask <<= 1;
		}
		return sb.append("]").toString();
	}

	private static int divideInTwo(Set<Integer> validSubsets, int remainder) {
		// search for another subset that fully overlaps with remainder
		for (int s2 : validSubsets) {
			if ((remainder & s2) == s2) {
				// found second subset
				int s3 = remainder - s2;

				// This is now guaranteed
				assert (validSubsets.contains(s3));

				return s2;
			}
		}
		return 0;
	}

	private static long solve1(List<Integer> data) {
		int totalSize = data.size();
		int totalWeight = data.stream().mapToInt(Integer::intValue).sum();
		assert (totalWeight % 3 == 0);
		int packageWeight = totalWeight / 3;

		int numPossibleSubsets = (1 << totalSize);
		int fullSet = numPossibleSubsets - 1;

		Map<Integer, Integer> subsetSize = new HashMap<>();
		Map<Integer, Integer> subsetWeight = new HashMap<>();

		// create an index of valid subsets
		for (int subset = 1; subset < numPossibleSubsets; subset++) {
			// TODO: some optimizations should be possible here to reduce search space
			// maybe dynamic programming?
			int weight = countWeight(data, subset);
			if (weight != packageWeight) continue;

			subsetWeight.put(subset, weight);
			int size = countBits(subset);
			subsetSize.put(subset, size);
		}

		System.out.println("Total number of possible subsets: " + subsetWeight.size());

		// sort by size, ascending
		List<Integer> sortedSubsets = new ArrayList<>(subsetSize.keySet());
		sortedSubsets.sort(Comparator.comparingInt(subsetSize::get));

		int smallestSubsetSize = subsetSize.get(sortedSubsets.getFirst());

		long minQe = 0;
		boolean first = true;

		// Now go through all three-way pairs
		for (int subset : sortedSubsets) {
			int size = subsetSize.get(subset);
			if (size > smallestSubsetSize) { break; }

			int remainder = fullSet - subset;

			int s2 = divideInTwo(subsetSize.keySet(), remainder);
			if (s2 != 0) {
				int s3 = remainder - s2;
				long qe = calculateQe(data, subset);
				if (first || qe < minQe) { minQe = qe; first = false; }

				System.out.printf("Match: %s QE=%d %s %s\n", subsetToString(data, subset), qe, subsetToString(data, s2), subsetToString(data, s3));

			}

		}

		return minQe;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day24/test-input"));
		Util.assertEqual(solve1(testData), 99);
		var data = parse(Path.of("day24/input"));
		System.out.println(solve1(data));
	}
}
