package day25;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	private record Data (
		int row,
		int col
	){
	}

	private static Data parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			String line = s.filter(l -> !l.isEmpty()).findFirst().orElseThrow();
			var p = Pattern.compile("row (?<row>[0-9]+), column (?<column>[0-9]+)");
			var m = p.matcher(line);
			assert(m.find());
			return new Data(
				Integer.parseInt(m.group("row")),
				Integer.parseInt(m.group("column"))
			);
		}
	}

	private static long solve1(Data data) {
		int x = 1;
		int y = 1;
		long current = 20151125;
		while (true) {
			current *= 252533;
			current %= 33554393;
			x++; y--;
			if (y <= 0) {
				y = x;
				x = 1;
			}
//			System.out.printf("%d, %d: %d\n", x, y, current);
			if (x == data.col && y == data.row) {
				return current;
			}
		}
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day25/test-input"));
		Util.assertEqual(solve1(testData), 27995004);
		var data = parse(Path.of("day25/input"));
		System.out.println(solve1(data));
	}
}
