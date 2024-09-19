package day10;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

public class Solution {

	private static String parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).findFirst().orElseThrow();
		}
	}

	public record Part(char ch, int len) {};

	public static String lookAndSay(String input) {
		List<Part> parts = new ArrayList<>();
		char prev = '\0';
		int count = 0;
		for (int i = 0; i < input.length(); ++i) {
			char ch = input.charAt(i);
			if (ch != prev) {
				if (count > 0) {
					parts.add(new Part(prev, count));
				}
				count = 0;
			}
			count++;
			prev = ch;
		}
		if (count > 0) {
			parts.add(new Part(prev, count));
		}

		StringBuilder result = new StringBuilder();
		for(Part part: parts) {
			result.append(part.len);
			result.append(part.ch);
		}

		return result.toString();
	}

	private static long solve(String data, int num) {
		String current = data;
		for (int i = 0; i < num; ++i) {
			current = lookAndSay(current);
		}
		return current.length();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day10/test-input"));
		Util.assertEqual(solve(testData, 40), 329356);

		var data = parse(Path.of("day10/input"));
		System.out.println(solve(data, 40));
		System.out.println(solve(data, 50));
	}
}
