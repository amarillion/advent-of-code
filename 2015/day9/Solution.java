package day9;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.Consumer;
import java.util.stream.Stream;

public class Solution {

	private static class Data {
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

	// Heap's algorithm
	// https://stackoverflow.com/a/37580979/3306
	// TODO: convert to Iterator so we can stream the results...
	static <T> void permute(T[] permutation, Consumer<T[]> callback) {
		int length = permutation.length;
		var c = new int[length];
		int i = 1;
		int k;

		callback.accept(permutation.clone());
		while (i < length) {
			if (c[i] < i) {
				// Swap choice dependent on parity of k (even or odd)
				k = (i % 2 == 0) ? 0 : c[i];
				T temp = permutation[i];
				permutation[i] = permutation[k];
				permutation[k] = temp;
				++c[i];
				i = 1;
				callback.accept(permutation.clone());
			} else {
				c[i] = 0;
				++i;
			}
		}
	}
/*
London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141
 */
	private static Data parse(Path file) throws IOException {
		Data data = new Data();
		try (Stream<String> s = Files.lines(file)) {
			s.filter(l -> !l.isEmpty()).forEach(l -> {
				String[] fields = l.split(" ");
				data.putDistance(fields[0], fields[2], Integer.parseInt(fields[4]));
			});
		}
		return data;
	}

	private static long[] solve1(Data data) {
		AtomicLong min = new AtomicLong();
		AtomicLong max = new AtomicLong();
		AtomicBoolean first = new AtomicBoolean(true);
		String[] places = data.getPlaces().toArray(new String[0]);

		// all permutations...
		permute(places, order -> {
			long len = 0;
			for(int i = 1; i < order.length; ++i) {
				len += data.getDistance(order[i-1], order[i]);
			}
			if (first.get()) {
				min.set(len);
				max.set(len);
				first.set(false);
			}
			else {
				if (len < min.get()) {
					min.set(len);
				}
				if (len > max.get()) {
					max.set(len);
				}
			}
		});
		return new long[] { min.get(), max.get() };
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day9/test-input"));
		long[] result = solve1(testData);
		Util.assertEqual(result[0], 605);
		Util.assertEqual(result[1], 982);
		var data = parse(Path.of("day9/input"));
		result = solve1(data);
		System.out.println(result[0]);
		System.out.println(result[1]);
	}
}
