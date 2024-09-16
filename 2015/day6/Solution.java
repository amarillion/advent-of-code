package day6;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	private record Point(int x, int y) {}
	private record Instruction(String command, Point topLeft, Point bottomRight) {}

	private static List<Instruction> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(
					l -> {
						var m = Pattern.compile("(toggle|turn on|turn off) (\\d+),(\\d+) through (\\d+),(\\d+)").matcher(l);
						if (!m.matches()) throw new Error("Expected match with " + l);
						return new Instruction(
								m.group(1),
								new Point(Integer.parseInt(m.group(2)), Integer.parseInt(m.group(3))),
								new Point(Integer.parseInt(m.group(4)), Integer.parseInt(m.group(5)))
						);
					}
			).toList();
		}
	}

	static class Grid {
		private int[] data;
		int w;
		int h;
		Grid(int w, int h) {
			data = new int[w * h];
			this.w = w;
			this.h = h;
		}
		void set(Point p, int value) {
			data[p.x + w * p.y] = value;
		}
		void modify(Point p, Function<Integer, Integer> func) {
			int idx = p.x + w * p.y;
			data[idx] = func.apply(data[idx]);
		}
		int get(Point p) {
			return data[p.x + w * p.y];
		}
	}

	private static long sumGrid(Grid grid) {
		long result = 0;
		for (int y = 0; y < 1000; ++y) {
			for (int x = 0; x < 1000; ++x) {
				Point pos = new Point(x, y);
				result += grid.get(pos);
			}
		}
		return result;
	}

	private static long solve1(List<Instruction> data) {
		var grid = new Grid(1000, 1000);
		for(var instr: data) {
			for (int y = instr.topLeft.y; y <= instr.bottomRight.y; ++y) {
				for (int x = instr.topLeft.x; x <= instr.bottomRight.x; ++x){
					var pos = new Point(x, y);
					if ("toggle".equals(instr.command)) {
						grid.modify(pos, i -> i > 0 ? 0 : 1);
					}
					else if ("turn on".equals(instr.command)) {
						grid.set(pos, 1);
					}
					else if ("turn off".equals(instr.command)) {
						grid.set(pos, 0);
					}
				}
			}
		}
		return sumGrid(grid);
	}

	private static long solve2(List<Instruction> data) {
		var grid = new Grid(1000, 1000);
		for(var instr: data) {
			for (int y = instr.topLeft.y; y <= instr.bottomRight.y; ++y) {
				for (int x = instr.topLeft.x; x <= instr.bottomRight.x; ++x){
					var pos = new Point(x, y);
					if ("toggle".equals(instr.command)) {
						grid.modify(pos, i -> i + 2);
					}
					else if ("turn on".equals(instr.command)) {
						grid.modify(pos, i -> i + 1);
					}
					else if ("turn off".equals(instr.command)) {
						grid.modify(pos, i -> Math.max(i - 1, 0));
					}
				}
			}
		}
		return sumGrid(grid);
	}

	public static void main(String[] args) throws IOException {
		var data = parse(Path.of("day6/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
