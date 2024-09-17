package day8;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;

public class Solution {

	private static List<String> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).toList();
		}
	}

	private static long solve1(List<String> data) {
		long result = 0;
		for(String line : data) {
			String after = line
					.replaceAll("\\\\([\\\\\"]|x[0-9a-f]{2})", ".")
					.replaceAll("^\"(.*)\"$", "$1");
//			System.out.println(line + "\n" + after + "\n");
			result += line.length() - after.length();
		}
		return result;
	}

	private static long solve2(List<String> data) {
		long result = 0;
		for(String line : data) {
			String after = "\"" + line
					.replaceAll("\\\\", "\\\\\\\\")
					.replaceAll("\"", "\\\\\"")
					.replaceAll("^\"(.*)\"$", "$1") + "\"";
//			System.out.println(line + "\n" + after + "\n");
			result += after.length() - line.length();
		}
		return result;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day8/test-input"));
		Util.assertEqual(solve1(testData), 12);
		Util.assertEqual(solve2(testData), 19);
		var data = parse(Path.of("day8/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
