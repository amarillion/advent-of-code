package day9;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
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
			putDistanceHelper(to, from, distance);
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
				String[] fields = l.split(" ");
				data.putDistance(fields[0], fields[2], Integer.parseInt(fields[4]));
			});
		}
		return data;
	}

	private static long pathLength(DistanceMatrix data, String[] order) {
		long len = 0;
		for(int i = 1; i < order.length; ++i) {
			len += data.getDistance(order[i-1], order[i]);
		}
		return len;
	}

	private record MinMax(long min, long max) {};

	private static MinMax solve(DistanceMatrix data) {
		var places = data.getPlaces().toArray(new String[0]);
		long initialLength = pathLength(data, places);
		long max = initialLength;
		long min = initialLength;
		for (String[] order: new AllPermutations<>(places)) {
			long pathLen = pathLength(data, order);
			max = Math.max(max, pathLen);
			min = Math.min(min, pathLen);
		}
		return new MinMax(min, max);
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day9/test-input"));
		var result = solve(testData);
		Util.assertEqual(result.min, 605);
		Util.assertEqual(result.max, 982);

		var data = parse(Path.of("day9/input"));
		result = solve(data);
		System.out.println(result.min);
		System.out.println(result.max);
	}
}
