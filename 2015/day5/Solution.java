package day5;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	private static List<String> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).toList();
		}
	}

	private static long solve1(List<String> data) {
		return data.stream()
				.filter(line -> Pattern.compile("([aeiou].*){3}").matcher(line).find())
				.filter(line -> Pattern.compile("(.)\\1").matcher(line).find())
				.filter(line -> !Pattern.compile("(ab|cd|pq|xy)").matcher(line).find())
				.count();
	}

	private static long solve2(List<String> data) {
		return data.stream()
				.filter(line -> Pattern.compile("(..).*\\1").matcher(line).find())
				.filter(line -> Pattern.compile("(.).\\1").matcher(line).find())
				.count();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day5/test-input"));
		Util.assertEqual(solve1(testData), 2);
		Util.assertEqual(solve2(testData), 2);

		var data = parse(Path.of("day5/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
