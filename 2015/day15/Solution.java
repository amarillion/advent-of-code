package day15;

import common.StringUtils;
import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Iterator;
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

	// TODO: very wasteful with memory, this can be done smarter - implement an Iterable!
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
					System.arraycopy(child, 0, wrap, 1, child.length);
					wrap[0] = i;
					result.add(wrap);
				}
			}
		}
		return result;
	}

	private static long solve1(List<Ingredient> data, int calorieLimit) {
		int[] maxDist = null;
		long maxVal = Integer.MIN_VALUE;
		for (var distribution: distributions(100, data.size())) {
			long capacity = 0;
			long durability = 0;
			long flavor = 0;
			long texture = 0;
			long calories = 0;
			for (int j = 0; j < distribution.length; ++j) {
				capacity += (long) distribution[j] * data.get(j).capacity;
				durability += (long) distribution[j] * data.get(j).durability;
				flavor += (long) distribution[j] * data.get(j).flavor;
				texture += (long) distribution[j] * data.get(j).texture;
				calories += (long) distribution[j] * data.get(j).calories;
			}
			long val = Math.max(0, capacity) * Math.max(0, durability) * Math.max(0, flavor) * Math.max(0, texture);
			if (calorieLimit > 0 && calories != calorieLimit) {
				continue;
			}
			if (val > maxVal) {
//				System.out.println(StringUtils.join(", ", distribution) + " capacity: " + capacity + " durability: " + durability
//						+ " flavor: " + flavor + " texture: " + texture + " calories: " + calories + " total: " + val);
				maxVal = val;
				maxDist = distribution.clone();
			}
		}

//		System.out.println(maxVal + " " + StringUtils.join(", ", maxDist));
		return maxVal;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day15/test-input"));
		Util.assertEqual(solve1(testData, -1), 62842880);
		Util.assertEqual(solve1(testData, 500), 57600000);

		var data = parse(Path.of("day15/input"));
		System.out.println(solve1(data, -1));
		System.out.println(solve1(data, 500));
	}
}
