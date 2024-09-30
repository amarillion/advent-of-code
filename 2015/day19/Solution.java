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
		Set<String> result = new HashSet<>();
		for (int i = 0; i < data.molecule.length(); ++i) {
			for (var replacement : data.replacements) {
				if (data.molecule.substring(i).startsWith(replacement.source)) {
					String newStr = data.molecule.substring(0, i)
							+ replacement.dest
							+ data.molecule.substring(i + replacement.source.length());
					result.add(newStr);
					System.out.println(newStr);
				}
			}
		}
		return result.size();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day19/test-input"));
		Util.assertEqual(solve1(testData), 4);
		var data = parse(Path.of("day19/input"));
		System.out.println(solve1(data));
	}
}
