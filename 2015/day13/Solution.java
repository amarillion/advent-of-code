package day13;

import common.AllPermutations;
import common.Map2D;
import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	private static Map2D<String, Integer> parse(Path file) throws IOException {
		var data = new Map2D<String, Integer>();
		try (Stream<String> s = Files.lines(file)) {
			s.filter(l -> !l.isEmpty()).forEach(l -> {
				var m = Pattern.compile("(?<from>\\w+) would (?<direction>gain|lose) (?<amount>\\d+) happiness units by sitting next to (?<to>\\w+).").matcher(l);
				Util.assertTrue(m.matches());
				int value = Integer.parseInt(m.group("amount"));
				if (m.group("direction").equals("lose")) { value = -value; }
				data.put(m.group("from"), m.group("to"), value);
			});
		}
		return data;
	}

	private static long solve(Map2D<String, Integer> data) {
		long result = Long.MIN_VALUE;
		String[] names = data.keySet().toArray(new String[0]);
		for (String[] p : new AllPermutations<>(names)) {
			// calculate score
			long score =
					data.get(p[0], p[p.length-1]) +
					data.get(p[p.length-1], p[0]);

			for (int i = 1; i < p.length; ++i) {
				score += data.get(p[i-1], p[i]) +
						data.get(p[i], p[i-1]);
			}
			result = Math.max(score, result);
//			System.out.println(String.join(", ", p) + " -> " + score);
		}
		return result;
	}

	static void expandMatrix(Map2D<String, Integer> data) {
		String[] names = data.keySet().toArray(new String[0]);
		for(String name: names) {
			data.put(name, "Me", 0);
			data.put("Me", name,0);
		}
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day13/test-input"));
		Util.assertEqual(solve(testData), 330);

		var data = parse(Path.of("day13/input"));
		System.out.println(solve(data));

		expandMatrix(data);
		System.out.println(solve(data));

	}
}
