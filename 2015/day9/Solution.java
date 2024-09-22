package day9;

import common.AllPermutations;
import common.Map2D;
import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;

public class Solution {

	private static Map2D<String, Integer> parse(Path file) throws IOException {
		var data = new Map2D<String, Integer>();
		try (Stream<String> s = Files.lines(file)) {
			s.filter(l -> !l.isEmpty()).forEach(l -> {
				String[] fields = l.split(" ");
				int dist = Integer.parseInt(fields[4]);
				data.put(fields[0], fields[2], dist);
				data.put(fields[2], fields[0], dist);
			});
		}
		return data;
	}

	private static long pathLength(Map2D<String, Integer> data, String[] order) {
		long len = 0;
		for(int i = 1; i < order.length; ++i) {
			len += data.get(order[i-1], order[i]);
		}
		return len;
	}

	private record MinMax(long min, long max) {};

	private static MinMax solve(Map2D<String, Integer> data) {
		var places = data.keySet().toArray(new String[0]);
		long initialLength = pathLength(data, places);
		long max = initialLength;
		long min = initialLength;
		for (String[] order: new AllPermutations<>(places)) {
			long pathLen = pathLength(data, order);
			max = Math.max(max, pathLen);
			min = Math.min(min, pathLen);
		}
		return new MinMax(min, max);
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day9/test-input"));
		var result = solve(testData);
		Util.assertEqual(result.min, 605);
		Util.assertEqual(result.max, 982);

		var data = parse(Path.of("day9/input"));
		result = solve(data);
		System.out.println(result.min);
		System.out.println(result.max);
	}
}
