package day6;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import static common.Util.assertEqual;

class Solution {

	record RaceData(int time, int distance) {}

	private static List<RaceData> parse(Path file) throws IOException {
		List<String> lines = Files.lines(file).map(l -> l.substring(10)).toList();
		List<Integer> times = Stream.of(lines.get(0).trim().split("\s+")).map(Integer::parseInt).toList();
		List<Integer> distances = Stream.of(lines.get(1).trim().split("\s+")).map(Integer::parseInt).toList();
		List<RaceData> result = new ArrayList<>();
		for (int i = 0; i < times.size(); ++i) {
			result.add(new RaceData(times.get(i), distances.get(i)));
		}
		return result;
	}

	private static int numberOfWays(RaceData race) {
		int ways = 0;
		for (int hold = 0; hold < race.time; ++hold) {
			int timeRemain = race.time - hold;
			int distance = timeRemain * hold;
			boolean success = distance > race.distance;
			if (success) ways++;
		}
		return ways;
	}

	private static int solve1(List<RaceData> races) {
		return races.stream().map(Solution::numberOfWays).reduce(1, (cur, acc) -> cur * acc);
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day6/test-input"));
		assertEqual(solve1(testData), 288);

		var data = parse(Path.of("day6/input"));
		System.out.println(solve1(data));
	}
}