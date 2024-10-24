package day20;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;

public class Solution {

	private static int parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(Integer::parseInt).findFirst().orElseThrow();
		}
	}

	// naive way to find divisors
	static long sumDivisors(long number) {
		long result = number > 1 ? 1 : 0;
		result += number;
		long root = (long) Math.sqrt(number);
		for (long i = 2; i <= root; ++i) {
			if ((number % i) == 0) {
				result += i;
				long other = number / i;
				if (other != i) { // exception for duplicate divisors... E.g. 9 has divisors 1, 3, 9 - not 1, 3, 3, 9
					result += number / i;
				}
			}
		}
		return result;
	}

	private static long solve1(int data) {
		long i = 6;
		while (true) {
			long sumDiv = sumDivisors(i);
			System.out.println(i + ": " + sumDiv);
			// lowest house number where sum of divisors = X / 10
			// divisors, times 10
			if (sumDiv * 10 > data) {
				break;
			}

			i++;
		}
		return i;
	}

	public static void main(String[] args) throws IOException {
//		var testData = parse(Path.of("day20/test-input"));
//		Util.assertEqual(solve1(testData), XXX);
		var data = parse(Path.of("day20/input"));
		System.out.println(solve1(data));
	}
}
