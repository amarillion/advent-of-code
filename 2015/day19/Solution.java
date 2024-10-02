package day19;

import common.AStar;
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

	private static Set<String> inverseReplacements(String input, List<Replacement> replacements) {
		Set<String> result = new HashSet<>();
		for (int i = 0; i < input.length(); ++i) {
			for (var replacement : replacements) {
				if (input.substring(i).startsWith(replacement.dest)) {
					String newStr = input.substring(0, i)
							+ replacement.source
							+ input.substring(i + replacement.dest.length());
					result.add(newStr);
				}
			}
		}
		return result;
	}

	private static long solve2(Data data) {
		// Here is the trick - run AStar in reverse, starting from the molecule, working your way down to the start.
		// this makes the search space much, much smaller
		String target = "e";
		String start = data.molecule;
		var astar = new AStar<>(start,
				target,
				(String s) -> inverseReplacements(s, data.replacements),
				(String s) -> 1.0 * Math.abs(s.length() - target.length()),
				1.0
		);
		var result = astar.run();
//		System.out.println("Astar result: " + String.join("-> \n", result));
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
