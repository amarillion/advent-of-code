package day15;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	record Ingredient(String name, int capacity, int durability, int flavor, int texture, int calories) {}

	private static List<Ingredient> parse(Path file) throws IOException {
		var pattern = Pattern.compile("(?<name>\\w+): capacity (?<capacity>[0-9-]+), durability (?<durability>[0-9-]+), flavor (?<flavor>[0-9-]+), texture (?<texture>[0-9-]+), calories (?<calories>[0-9-]+)");
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(l -> {
				var m = pattern.matcher(l);
				Util.assertTrue(m.matches());
				return new Ingredient(
						m.group("name"),
						Integer.parseInt(m.group("capacity")),
						Integer.parseInt(m.group("durability")),
						Integer.parseInt(m.group("flavor")),
						Integer.parseInt(m.group("texture")),
						Integer.parseInt(m.group("calories"))
						);
			}).toList();
		}
	}

/*

100,0,0,0

99,1,0,0
99,0,1,0
99,0,0,1

98,2,0,0
98,1,1,0
98,1,0,1
98,0,2,0
98,0,1,1
98,0,0,2

97,3,0,0
...



 */

	static List<int[]> distributions(int amount, int num) {
		Util.assertTrue(num > 0);
		List<int[]> result = new ArrayList<>();
		if (num == 1) {
			result.add(new int[] { amount });
		}
		else {
			for (int i = 0; i < amount; ++i) {
				List<int[]> children = distributions(amount - i, num - 1);
				for (var child: children) {
					int[] wrap = new int[num];
					for(int j = 0; j < child.length; j++) {
						wrap[j+1] = child[j];
					}
					wrap[0] = i;
					result.add(wrap);
				}
			}
		}
		return result;
	}

	private static long solve1(List<Ingredient> data) {
		int[] maxDist = null;
		long maxVal = Integer.MIN_VALUE;
		for (var distribution: distributions(100, data.size())) {
			long capacity = 0;
			long durability = 0;
			long flavor = 0;
			long texture = 0;
			for (int j = 0; j < distribution.length; ++j) {
				capacity += distribution[j] * data.get(j).capacity;
				durability += distribution[j] * data.get(j).durability;
				flavor += distribution[j] * data.get(j).flavor;
				texture += distribution[j] * data.get(j).texture;
			}
			long val = Math.max(0, capacity) * Math.max(0, durability) * Math.max(0, flavor) * Math.max(0, texture);
			System.out.println(arrayToString(distribution) + " capacity: " + capacity + " durability: " + durability + " flavor: " + flavor + " texture: " + texture + " total: " + val);
			if (val > maxVal) {
				maxVal = val;
				maxDist = distribution.clone();
			}
		}

		System.out.println(maxVal + " " + arrayToString(maxDist));
		return maxVal;
	}

	private static String arrayToString(int[] array) {
		if (array == null) return "null";
		StringBuilder result = new StringBuilder();
		boolean first = true;
		String sep = ", ";
		for (int i = 0; i < array.length; ++i) {
			if (!first) { result.append(sep); }
			else { first = false; }
			result.append(array[i]);
		}
		return result.toString();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day15/test-input"));
		Util.assertEqual(solve1(testData), 62842880);
		var data = parse(Path.of("day15/input"));
		System.out.println(solve1(data));
	}
}
