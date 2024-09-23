package day14;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
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
			max = Math.max(dist, max);
		}
		return max;
	}

	private static long solve2(List<Deer> data, int after) {
		int[] points = new int[data.size()];

		for (int sec = 1; sec < after; ++sec) {
			int max = 0;
			for (int i = 0; i < data.size(); ++i) {
				var deer = data.get(i);
				var dist = deer.distance(sec);
				max = Math.max(dist, max);
			}
			for (int i = 0; i < data.size(); ++i) {
				var deer = data.get(i);
				if (deer.distance(sec) == max) {
					points[i]++;
				}
			}
		}

		long result = 0;
		for (int p: points) { result = Math.max(p, result); }
		return result;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day14/test-input"));
		Util.assertEqual(solve1(testData, 1000), 1120);
		System.out.println(solve2(testData, 1000));
		Util.assertEqual(solve2(testData, 1000), 689);

		var data = parse(Path.of("day14/input"));
		System.out.println(solve1(data, 2503));
		System.out.println(solve2(data, 2503));
	}
}
