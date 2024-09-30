package day18;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;

public class Solution {

	private static class Grid {
		int[] data;
		int width;
		int height;

		Grid(int width, int height) {
			data = new int[width * height];
			this.width = width;
			this.height = height;
		}

		boolean inRange(int x, int y) {
			return (x >= 0 && x < width && y >= 0 && y < height);
		}

		int index(int x, int y) {
			return x + y * width;
		}

		void set(int x, int y, int value) {
			if (!inRange(x, y)) return;
			data[index(x, y)] = value;
		}

		int get(int x, int y) {
			if (!inRange(x, y)) return 0;
			return data[index(x, y)];
		}

		int countNeighbors(int x, int y) {
			int result = 0;
			for (int dx = -1; dx <= 1; ++dx) {
				for (int dy = -1; dy <= 1; ++dy) {
					if (dx == 0 && dy == 0) continue;
					result += get(x + dx, y + dy);
				}
			}
			return result;
		}

	}

	private static Grid parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			var data = s.filter(l -> !l.isEmpty()).toList();
			var grid = new Grid(data.get(0).length(), data.size());
			for (int y = 0; y < grid.height; ++y) {
				for(int x = 0; x < grid.width; ++x) {
					grid.set(x, y, data.get(y).charAt(x) == '#' ? 1 : 0);
				}
			}
			return grid;
		}
	}

	private static long solve1(Grid initial, int steps) {
		Grid current = initial;
		for (int step = 0; step < steps; ++step) {
			Grid next = new Grid(current.width, current.height);
			for (int y = 0; y < current.height; ++y) {
				for (int x = 0; x < current.width; ++x) {
					int value = current.get(x, y);
					int neighbors = current.countNeighbors(x, y);
					int nextVal = ((neighbors == 2 && value == 1) || (neighbors == 3)) ? 1 : 0;
					next.set(x, y, nextVal);
				}
			}
			current = next;
		}
		long result = 0;
		for (int y = 0; y < current.height; ++y) {
			for (int x = 0; x < current.width; ++x) {
				result += current.get(x, y);
			}
		}
		return result;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day18/test-input"));
		Util.assertEqual(solve1(testData, 4), 4);
		var data = parse(Path.of("day18/input"));
		System.out.println(solve1(data, 100));
	}
}
