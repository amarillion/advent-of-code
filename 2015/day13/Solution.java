package day13;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class Solution {

	private static class DistanceMatrix {
		Map <String, Map<String, Integer>> distances = new HashMap<>();

		private void putDistanceHelper(String from, String to, int distance) {
			if (!distances.containsKey(from)) {
				distances.put(from, new HashMap<>());
			}
			distances.get(from).put(to, distance);
		}
		void putDistance(String from, String to, int distance) {
			putDistanceHelper(from, to, distance);
//			putDistanceHelper(to, from, distance); // TODO - directional vs symmetrical
		}

		int getDistance(String from, String to) {
			return distances.get(from).get(to);
		}

		Set<String> getPlaces() {
			return distances.keySet();
		}
	}

	public static class AllPermutations<E> implements Iterable<E[]> {

		private final E[] original;
		public AllPermutations(E[] original) {
			this.original = original.clone();
		}

		@Override
		public Iterator<E[]> iterator() {
			return new Iterator<>() {
				private final E[] current = original.clone();
				private final int[] c = new int[original.length];
				private int idx = 1;

				@Override
				public boolean hasNext() {
					return idx < current.length;
				}

				// Heap's algorithm
				// https://stackoverflow.com/a/37580979/3306
				@Override
				public E[] next() {
					// losing a bit of efficiency here in favor of safety by cloning the array for each iteration.
					E[] result = current.clone();
					while (idx < current.length && c[idx] >= idx) {
						c[idx] = 0;
						++idx;
					}
					if (idx < current.length) {
						if (c[idx] < idx) {
							// Swap choice dependent on parity of k (even or odd)
							int k = (idx % 2 == 0) ? 0 : c[idx];
							E temp = current[idx];
							current[idx] = current[k];
							current[k] = temp;
							++c[idx];
							idx = 1;
						}
					}
					return result;
				}
			};
		}
	}

	private static DistanceMatrix parse(Path file) throws IOException {
		var data = new DistanceMatrix();
		try (Stream<String> s = Files.lines(file)) {
			s.filter(l -> !l.isEmpty()).forEach(l -> {
				var m = Pattern.compile("(?<from>\\w+) would (?<direction>gain|lose) (?<amount>\\d+) happiness units by sitting next to (?<to>\\w+).").matcher(l);
				Util.assertTrue(m.matches());
				int value = Integer.parseInt(m.group("amount"));
				if (m.group("direction").equals("lose")) { value = -value; }
				data.putDistance(m.group("from"), m.group("to"), value);
			});
		}
		return data;
	}

	private static long solve(DistanceMatrix data) {
		long result = Long.MIN_VALUE;
		String[] names = data.getPlaces().toArray(new String[0]);
		for (String[] p : new AllPermutations<>(names)) {
			// calculate score
			long score =
					data.getDistance(p[0], p[p.length-1]) +
					data.getDistance(p[p.length-1], p[0]);

			for (int i = 1; i < p.length; ++i) {
				score += data.getDistance(p[i-1], p[i]) +
						data.getDistance(p[i], p[i-1]);
			}
			result = Math.max(score, result);
			System.out.println(String.join(", ", p) + " -> " + score);
		}
		return result;
	}

	static void expandMatrix(DistanceMatrix data) {
		String[] names = data.getPlaces().toArray(new String[0]);
		for(String name: names) {
			data.putDistance(name, "Me", 0);
			data.putDistance("Me", name,0);
		}
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day13/test-input"));
		Util.assertEqual(solve(testData), 330);

		var data = parse(Path.of("day13/input"));
		System.out.println(solve(data));

		expandMatrix(data);
		System.out.println(solve(data));

	}
}
