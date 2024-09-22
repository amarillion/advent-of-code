package dayX;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;

public class Solution {

	private static String parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).findFirst().orElseThrow();
		}
	}

	static char[] increment (char[] current) {
		char[] result = current.clone();
		int i = result.length - 1;

		while (result[i] == 'z') {
			result[i] = 'a';
			i--;
			Util.assertTrue(i >= 0, "Running out of possibilities");
		}
		result[i] += 1;
		return result;
	}

	static boolean isValid(char[] current) {
		// no i, o or l
		for (int i = 0; i < current.length; ++i) {
			char c = current[i];
			if (c == 'i' || c == 'l' || c == 'o') { return false; }
		}

		// two double letters
		int pairCount = 0;
		char prev = current[0];
		for (int i = 1; i < current.length; ++i) {
			if (current[i] == prev) {
				pairCount++;
				prev = '\0'; // check non-overlapping pairs
			}
			else {
				prev = current[i];
			}
		}
		if (pairCount < 2) return false;

		int ascendingRun = 0;
		int maxAscendingRun = 1;
		for (int i = 1; i < current.length; ++i) {
			if (current[i] == current[i - 1] + 1) {
				ascendingRun++;
				maxAscendingRun = Math.max(maxAscendingRun, ascendingRun);
			} else {
				ascendingRun = 1;
			}
		}
		// increasing straight of three letters: abc
		return maxAscendingRun >= 3;
	}

	private static String solve1(String data) {
		char[] current = data.toCharArray();

		while (!isValid(current)) {
			current = increment(current);
		}
		return new String(current);
	}

	public static void main(String[] args) throws IOException {

		Util.assertFalse(isValid("hijklmmn".toCharArray()));
		Util.assertFalse(isValid("abbceffg".toCharArray()));
		Util.assertFalse(isValid("abbcegjk".toCharArray()));
		Util.assertFalse(isValid("hijklmmn".toCharArray()));

		Util.assertTrue(isValid("abcdffaa".toCharArray()));
		Util.assertTrue(isValid("ghjaabcc".toCharArray()));

		Util.assertEqual(solve1("abcdefgh"), "abcdffaa");
		Util.assertEqual(solve1("ghijklmn"), "ghjaabcc");

		var data = parse(Path.of("day11/input"));

		String part1 = solve1(data);
		System.out.println(part1);
		String next = new String(increment(part1.toCharArray()));
		String part2 = solve1(next);
		System.out.println(part2);
	}
}
