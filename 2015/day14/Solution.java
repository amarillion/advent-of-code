package day14;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;

public class Solution {

	static record Deer(int speed, int flyDuration, int restDuration) {
		int distance(int after) {
			int cycleDuration = flyDuration + restDuration;
			int remain = after % cycleDuration;
			int fullCycles = after / cycleDuration;
			if (remain < flyDuration) {
				return (fullCycles * flyDuration + remain) * speed;
			}
			else {
				return ((fullCycles + 1) * flyDuration) * speed;
			}
		}
	}

	private static List<Deer> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(l -> {
				String[] fields = l.split(" ");
				return new Deer(
						Integer.parseInt(fields[3]),
						Integer.parseInt(fields[6]),
						Integer.parseInt(fields[13]));
			}).toList();
		}
	}

	private static long solve1(List<Deer> data, int after) {
		long max = 0;
		for(var deer: data) {

			var dist = deer.distance(after);
			System.out.println(deer + " -> " + dist);
			max = Math.max(dist, max);
		}
		return max;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day14/test-input"));
		Util.assertEqual(solve1(testData, 1000), 1120);

		var data = parse(Path.of("day14/input"));
		System.out.println(solve1(data, 2503));
	}
}
