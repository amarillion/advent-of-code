package dayX;

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

	public static String lookAndSay(String input) {
		List<String> parts = new ArrayList<>();
		StringBuilder currentPart = new StringBuilder();
		Character prev = null;
		for (int i = 0; i < input.length(); ++i) {
			Character ch = input.charAt(i);
			if (currentPart.isEmpty()) {
				currentPart = new StringBuilder();
			}
			else {
				if (ch != prev) {
					parts.add(currentPart.toString());
					currentPart = new StringBuilder();
				}
			}
			currentPart.append(ch);
			prev = ch;
		}
		if (!currentPart.isEmpty()) { parts.add(currentPart.toString()); }

		StringBuilder result = new StringBuilder();
		for(String part: parts) {
			result.append(part.length());
			result.append(part.charAt(0));
		}

		System.out.println(result.toString());
		return result.toString();
	}

	private static long solve1(String data) {
		String current = data;
		for (int i = 0; i < 40; ++i) {
			current = lookAndSay(current);
		}
		return current.length();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day10/test-input"));
//		Util.assertEqual(solve1(testData), XXX);
		System.out.println(solve1(testData));
		var data = parse(Path.of("day10/input"));
		System.out.println(solve1(data));
	}
}
