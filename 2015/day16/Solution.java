package day16;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Stream;


public class Solution {
	static final String CRITERIA = """
		children: 3
		cats: 7
		samoyeds: 2
		pomeranians: 3
		akitas: 0
		vizslas: 0
		goldfish: 5
		trees: 3
		cars: 2
		perfumes: 1""";

	private static List<Map<String, Integer>> parse(Path file) throws IOException {
		var pattern = Pattern.compile("Sue \\d+: (.*)");
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(l -> {
				Map<String, Integer> result = new HashMap<>();
				var m = pattern.matcher(l);
				Util.assertTrue(m.matches());
				var keyValuePairs = m.group(1).split(", ");
				for(var keyValuePair: keyValuePairs) {
					var fields = keyValuePair.split(": ");
					result.put(fields[0], Integer.parseInt(fields[1]));
				}
				return result;
			}).toList();
		}
	}

	private static long solve1(List<Map<String, Integer>> data) {
		Map<String, Integer> criteria = new HashMap<>();
		for (String line: CRITERIA.split("\n")) {
			String[] fields = line.split(": ");
			criteria.put(fields[0], Integer.parseInt(fields[1]));
		}

		long idx = 1;
		for (var row: data) {
			boolean match = true;
			for(var kv: criteria.entrySet()) {
				if (criterionEqual(row, kv.getKey(), kv.getValue())) {
					// mismatch - rejected
					match = false;
					break;
				}
			}
			if (match) {
				return idx;
			}
			idx++;
		}
		return -1;
	}

	private static boolean criterionEqual(Map<String, Integer> row, String key, int amount) {
		return row.containsKey(key) && row.get(key) != amount;
	}

	private static boolean criterionGt(Map<String, Integer> row, String key, int amount) {
		return row.containsKey(key) && row.get(key) <= amount;
	}

	private static boolean criterionLt(Map<String, Integer> row, String key, int amount) {
		return row.containsKey(key) && row.get(key) >= amount;
	}

	//TODO: clean up - some parts are redundant with solve1
	private static long solve2(List<Map<String, Integer>> data) {
		long idx = 1;
		for (var row: data) {
			boolean match = true;
			if (criterionEqual(row, "children", 3)) { match = false; }
			if (criterionGt(row, "cats", 7)) { match = false; }
			if (criterionEqual(row, "samoyeds", 2)) { match = false; }
			if (criterionLt(row, "pomeranians", 3)) { match = false; }
			if (criterionEqual(row, "akitas", 0)) { match = false; }
			if (criterionEqual(row, "vizslas", 0)) { match = false; }
			if (criterionLt(row, "goldfish", 5)) { match = false; }
			if (criterionGt(row, "trees", 3)) { match = false; }
			if (criterionEqual(row, "cars", 2)) { match = false; }
			if (criterionEqual(row, "perfumes", 1)) { match = false; }
			if (match) {
				return idx;
			}
			idx++;
		}
		return -1;
	}

	public static void main(String[] args) throws IOException {
		var data = parse(Path.of("day16/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
