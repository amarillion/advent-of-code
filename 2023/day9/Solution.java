package day9;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
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
		return result;
	}

	private static long processRow(List<Integer> data) {
		// first take differences
		List<Integer> current = data;
		List<Integer> startValues = new ArrayList<>();
		while (current.stream().anyMatch(i -> i != 0)) {
			startValues.add(current.get(0));
			current = takeDifferences(current);
		}


		current.add(0);
		Collections.reverse(startValues);
		for (int startValue : startValues) {
			current = extrapolate(current, startValue);
		}

		return current.getLast();
	}

	private static long processRow2(List<Integer> data) {
		System.out.println("-----");

		// first take differences
		List<Integer> current = data;
		List<Integer> startValues = new ArrayList<>();
		while (current.stream().anyMatch(i -> i != 0)) {
			startValues.add(current.get(0));
			current = takeDifferences(current);
		}

		Collections.reverse(startValues);
		int extrapolated = 0;
		for (int startValue : startValues) {
			extrapolated = startValue - extrapolated;
			System.out.println(extrapolated);
		}

		return extrapolated;
	}

	private static long solve1(List<List<Integer>> data) {
		return data.stream().map(Solution::processRow).mapToLong(Long::valueOf).sum();
	}

	private static long solve2(List<List<Integer>> data) {
		return data.stream().map(Solution::processRow2).mapToLong(Long::valueOf).sum();
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day9/test-input"));
		Util.assertEqual(solve1(testData), 114);
		var data = parse(Path.of("day9/input"));
		Util.assertEqual(solve1(data), 2043677056);

		Util.assertEqual(solve2(testData), 2);
		System.out.println(solve2(data));

	}
}
