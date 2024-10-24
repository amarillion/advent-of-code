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
		long result = 0;
		long root = (long) Math.sqrt(number);
		for (long i = 1; i <= root; ++i) {
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

	// naive way to find divisors
	static long sumDivisors50(long number) {
		long result = 0;
		long root = (long) Math.sqrt(number);
		for (long a = 1; a <= Math.min(50, root); ++a) {
			if ((number % a) == 0) {
				long b = number / a;
				if (a == b) { // exception for duplicate divisors... E.g. 9 has divisors 1, 3, 9 - not 1, 3, 3, 9
					result += a;
				}
				else if (b <= 50) {
					result += a + b;
				}
				else {
					result += b;
				}
			}
		}
		return result;
	}

	private static long solve1(int data) {
		for (long i = 1; true; i++) {
			if (sumDivisors(i) * 10 > data) {
				return i;
			}
		}
	}

	private static long solve2(int data) {
		for (long i = 1; true; i++) {
			if (sumDivisors50(i) * 11 > data) {
				return i;
			}
		}
	}

	public static void main(String[] args) throws IOException {
		var data = parse(Path.of("day20/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
