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
import java.util.stream.Collectors;
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

	private static List<Integer> splitEqually(Set<Integer> validSubsets, int remainder, int n) {
		if (n == 1) {
			if (validSubsets.contains(remainder)) {
				return new ArrayList<>(remainder);
			}
			else {
				return null;
			}
		}

		// search for another subset that fully overlaps with remainder
		for (int s2 : validSubsets) {
			if ((remainder & s2) == s2) {
				// found second subset
				List<Integer> result = splitEqually(validSubsets, remainder - s2, n - 1);
				if (result != null) {
					result.add(s2);
					return result;
				}
			}
		}

		return null;
	}

	private static long solve1(List<Integer> data) {
		return equalDivisionSmallestQe(data, 3);
	}

	private static long solve2(List<Integer> data) {
		return equalDivisionSmallestQe(data, 4);
	}

	private static long equalDivisionSmallestQe(List<Integer> data, int divisor) {
		int totalSize = data.size();
		int totalWeight = data.stream().mapToInt(Integer::intValue).sum();
		assert (totalWeight % divisor == 0);
		int packageWeight = totalWeight / divisor;

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

//		System.out.println("Total number of possible subsets: " + subsetWeight.size());

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

			List<Integer> remainingSubsets = splitEqually(subsetSize.keySet(), remainder, (divisor - 1));
			if (remainingSubsets != null) {
				long qe = calculateQe(data, subset);
				if (first || qe < minQe) { minQe = qe; first = false; }

//				System.out.printf("Match: %s QE=%d %s\n", subsetToString(data, subset), qe,
//					remainingSubsets.stream().map(s -> subsetToString(data, s)).collect(Collectors.joining(" "))
//				);
			}

		}

		return minQe;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day24/test-input"));
		Util.assertEqual(solve1(testData), 99);
		Util.assertEqual(solve2(testData), 44);
		var data = parse(Path.of("day24/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
