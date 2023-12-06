package day3;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static java.nio.charset.StandardCharsets.UTF_8;

class Day3 {

	public static void main(String[] args) throws IOException {
		List<String> testInput = Files.readAllLines(Path.of("day3/test"), UTF_8);
		List<String> input = Files.readAllLines(Path.of("day3/input"), UTF_8);

		assertEqual(solvePart1(testInput), 7);
		System.out.println(solvePart1(input));

		assertEqual(solvePart2(testInput), 336);
		System.out.println(solvePart2(input));
	}

	private static long solvePart1(List<String> data) throws IOException {
		return countSlope(data, 3, 1);
	}

	private static long solvePart2(List<String> data) throws IOException {
		return	countSlope(data, 1, 1) *
				countSlope(data, 3, 1) *
				countSlope(data, 5, 1) *
				countSlope(data, 7, 1) *
				countSlope(data, 1, 2);
	}

	private static long countSlope(List<String> data, int dx, int dy) {
		final int height = data.size();
		final int width = data.get(0).length();

		long counter = 0;
		int xco = 0;
		for (int yco = 0; yco < height; yco += dy) {
			char ch = data.get(yco).charAt(xco);
			if (ch == '#') counter++;
			xco = (xco + dx) % width;
		}
		return counter;
	}

	private static void assertEqual(long observed, long expected) {
		System.out.println(observed);
		if (observed != expected) throw new Error("Assertion failed");
	}

}
