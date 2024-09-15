package day5;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public class Solution {

	private static List<String> parse(Path file) throws IOException {
		return Files.lines(file).filter(l -> !l.isEmpty()).toList();
	}

	private static long solve1(List<String> data) {
		long result = 0;
		for(String line: data) {
			int vowels = 0;
			for(int i = 0; i < line.length(); ++i) {
				if ("aeiou".contains(line.substring(i, i + 1))) {
					vowels++;
				}
			}
			boolean hasDoubleLetters = false;
			boolean noForbiddenPairs = true;
			for(int i = 1; i < line.length(); ++i) {
				String pair = line.substring(i-1, i+1);
				if (pair.charAt(0) == pair.charAt(1)) {
					hasDoubleLetters = true;
				}
				if (pair.equals("ab") || pair.equals("cd") || pair.equals("pq") || pair.equals("xy")) {
					noForbiddenPairs = false;
				}
			}

//			System.out.println(line + " " + vowels + " " + hasDoubleLetters + " " + noForbiddenPairs);
			if (vowels >= 3 && hasDoubleLetters && noForbiddenPairs) {
				result++;
			}
		}

		return result;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day5/test-input"));
		Util.assertEqual(solve1(testData), 2);
		var data = parse(Path.of("day5/input"));
		System.out.println(solve1(data));
	}
}
