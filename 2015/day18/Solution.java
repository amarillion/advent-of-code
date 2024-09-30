package day18;

import common.Grid;
import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Stream;

public class Solution {

	private static Grid<Boolean> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			var data = s.filter(l -> !l.isEmpty()).toList();
			var grid = new Grid<Boolean>(data.getFirst().length(), data.size());
			grid.forEach((x, y, value) -> {
				grid.set(x, y, data.get(y).charAt(x) == '#');
			});
			return grid;
		}
	}

	private static void simulationStep(Grid<Boolean> current, Grid<Boolean> next) {
		current.forEach((x, y, value) -> {
			AtomicInteger neighbors = new AtomicInteger();
			current.visitNeighbors(x, y, val -> neighbors.addAndGet(val ? 1 : 0));
			boolean nextVal = ((neighbors.get() == 2 && value) || (neighbors.get() == 3));
			next.set(x, y, nextVal);
		});
	}

	private static long countCompleteGrid(Grid<Boolean> current) {
		AtomicLong result = new AtomicLong();
		current.forEach((x, y, val) -> result.addAndGet(val ? 1 : 0));
		return result.get();
	}

	private static long solve1(Grid<Boolean> initial, int steps) {
		var current = new Grid<Boolean>(initial);
		var buffer = new Grid<Boolean>(current);
		for (int step = 0; step < steps; ++step) {
			simulationStep(current, buffer);
			var temp = current;
			current = buffer;
			buffer = temp;
		}
		return countCompleteGrid(current);
	}

	private static long solve2(Grid<Boolean> initial, int steps) {
		var current = new Grid<Boolean>(initial);
		var buffer = new Grid<Boolean>(current);

		setCorners(current);
		for (int step = 0; step < steps; ++step) {
			simulationStep(current, buffer);
			setCorners(buffer);
			var temp = current;
			current = buffer;
			buffer = temp;

			System.out.println("Step: " + step);
			printGrid(current);

		}
		return countCompleteGrid(current);
	}

	private static void printGrid(Grid<Boolean> current) {
		final var ref = current;
		current.forEach((x, y, val) -> {
			System.out.print(ref.get(x, y) ? '#' : '.');
			if (x == ref.width-1) System.out.println();
		});
		System.out.println();
	}

	private static void setCorners(Grid<Boolean> current) {
		current.set(0, 0, true);
		current.set(0, current.height-1, true);
		current.set(current.width-1, 0, true);
		current.set(current.width-1, current.height-1, true);
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day18/test-input"));
		Util.assertEqual(solve1(testData, 4), 4);
		Util.assertEqual(solve2(testData, 5), 17);
		var data = parse(Path.of("day18/input"));
		System.out.println(solve1(data, 100));
		System.out.println(solve2(data, 100));
	}
}
