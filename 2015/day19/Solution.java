package day19;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Solution {

	private record Replacement (String source, String dest) {}
	private record Data (List<Replacement> replacements, String molecule) {}

	private static Data parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			List<String> raw = s.filter(f -> !f.isEmpty()).collect(Collectors.toList());
			String molecule = raw.removeLast();

			List<Replacement> replacements = raw.stream().map(l -> {
				String[] fields = l.split(" => ");
				return new Replacement(fields[0], fields[1]);
			}).toList();

			return new Data(replacements, molecule);
		}
	}

	private static long solve1(Data data) {
		Set<String> result = getPossibleReplacements(data.molecule, data.replacements);
		return result.size();
	}

	private static Set<String> getPossibleReplacements(String input, List<Replacement> replacements) {
		Set<String> result = new HashSet<>();
		for (int i = 0; i < input.length(); ++i) {
			for (var replacement : replacements) {
				if (input.substring(i).startsWith(replacement.source)) {
					String newStr = input.substring(0, i)
							+ replacement.dest
							+ input.substring(i + replacement.source.length());
					result.add(newStr);
				}
			}
		}
		return result;
	}

	private static Set<String> getLocalReplacements(String target, String input, List<Replacement> replacements, int rangeMin, int rangeMax) {
		int stretch = equalStretch(target, input);
		Set<String> result = new HashSet<>();
		for (int i = Math.max(0, stretch - rangeMin); i < Math.min(stretch + rangeMax, input.length()); ++i) {
			for (var replacement : replacements) {
				if (input.substring(i).startsWith(replacement.source)) {
					String newStr = input.substring(0, i)
							+ replacement.dest
							+ input.substring(i + replacement.source.length());
					result.add(newStr);
				}
			}
		}
		return result;
	}

	private static double levenshteinDistance(String s, String t) {
		// create two work vectors of integer distances
		int m = s.length();
		int n = t.length();

		int[] v0 = new int[n + 1];

		// initialize v0 (the previous row of distances)
		// this row is A[0][i]: edit distance from an empty s to t;
		// that distance is the number of characters to append to  s to make t.
		for (int i = 0; i < n + 1; ++i) {
			v0[i] = i;
		}

		int[] v1 = new int[n + 1];

		for (int i = 0; i < m; ++i) {

			// calculate v1 (current row distances) from the previous row v0

			// first element of v1 is A[i + 1][0]
			//   edit distance is delete (i + 1) chars from s to match empty t
			v1[0] = i + 1;

			// use formula to fill in the rest of the row
			for (int j = 0; j < n; ++j) {
				// calculating costs for A[i + 1][j + 1]
				int deletionCost = v0[j + 1] + 1;
				int insertionCost = v1[j] + 1;
				int substitutionCost = (s.charAt(i) == t.charAt(j)) ? v0[j] : v0[j] + 1;
				v1[j + 1] = Math.min(deletionCost, Math.min(insertionCost, substitutionCost));
			}

			// copy v1 (current row) to v0 (previous row) for next iteration
			// swap is cheaper than new array allocation. V1 will be overwritten anyway.
			var temp = v0;
			v0 = v1;
			v1 = temp;
		}
		return v0[n];
	}

	private static double similarityScore(String current, String target) {
		double score = 0;
		for (int i = 0; i < Math.min(current.length(), target.length()); ++i) {
			if (current.charAt(i) != target.charAt(i)) score += 1.0;
		}
		score += Math.abs(current.length() - target.length());
		return score;
	}

	private static int equalStretch(String current, String target) {
		int score = 0;
		for (int i = 0; i < Math.min(current.length(), target.length()); ++i) {
			if (current.charAt(i) != target.charAt(i)) return score;
			score++;
		}
		return score;
	}

	private static long solve2(Data data) {
		var astar = new AStar<String>();
		var result = astar.doAstar("e",
				data.molecule,
				(String s) -> getLocalReplacements(data.molecule, s, data.replacements, 5, 1),
//				(String s) -> similarityScore(s, data.molecule),
				(String s) -> {
					int stretch = equalStretch(s, data.molecule);
//					String remainTarget = data.molecule.substring(stretch);
//					String remain = s.substring(stretch);
//					double l = levenshteinDistance(remain, remainTarget);
					double tieBreaker = (Math.abs(s.length() - data.molecule.length()));
					return
							+0.0001 * (s.hashCode() & 0xFFFF)
//							+ 1.0 * l
							+ 1.0 * Math.max(s.length(), data.molecule.length()) - stretch;
				},
				1.0,
				100000
		);
		System.out.println("Astar result: " + result);
		return result.size() - 1;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day19/test-input"));
		Util.assertEqual(solve1(testData), 4);
		Util.assertEqual(solve2(testData), 3);
		var data = parse(Path.of("day19/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
