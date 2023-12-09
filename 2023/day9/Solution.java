package day9;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Solution {

	private static List<List<Integer>> parse(Path file) throws IOException {
		return Files.lines(file).map(
				l -> Arrays.stream(l.split(" ")).map(Integer::parseInt).toList()
		).toList();
	}

	private static List<Integer> takeDifferences(List<Integer> input) {
		List<Integer> result = new ArrayList<>();
		for (int i = 1; i < input.size(); ++i) {
			result.add(input.get(i) - input.get(i-1));
		}
		System.out.println(result);
		return result;
	}

	private static List<Integer> extrapolate(List<Integer> input, int start) {
		List<Integer> result = new ArrayList<>();
		result.add(start);
		int prev = start;
		for (Integer val : input) {
			result.add(prev + val);
			prev = prev + val;
		}
		System.out.println(result);
		return result;
	}

	private static long processRow(List<Integer> data) {
		System.out.println("-----");

		// first take differences
		List<Integer> current = data;
		int counter = 0;
		List<Integer> startValues = new ArrayList<>();
		while (current.stream().anyMatch(i -> i != 0)) {
			startValues.add(current.get(0));
			current = takeDifferences(current);
			counter++;
		}

		current.add(0);

		for (int i = 0; i < counter; ++i) {
			int startValue = startValues.removeLast();
			current = extrapolate(current, startValue);
		}

		return current.getLast();
	}

	private static long solve1(List<List<Integer>> data) {
		return data.stream().map(Solution::processRow).mapToLong(Long::valueOf).sum();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day9/test-input"));
		Util.assertEqual(solve1(testData), 114);
		var data = parse(Path.of("day9/input"));
		System.out.println(solve1(data));
	}
}
