package day7;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Solution {

	private static enum Type {
		FIVE_OF_A_KIND,
		FOUR_OF_A_KIND,
		FULL_HOUSE,
		THREE_OF_A_KIND,
		TWO_PAIR,
		ONE_PAIR,
		HIGHEST_CARD
	}

	private static enum Card implements Comparable<Card> {

		A('A'), K('K'), Q('Q'), J('J'),
		TEN('T'), NINE('9'), EIGHT('8'), SEVEN('7'),
		SIX('6'), FIVE('5'), FOUR('4'), THREE('3'), TWO('2');

		Card(char _repr) {
			this.repr = _repr;
		}

		char repr;

		private static Map<Character, Card> registry = Arrays.stream(Card.values()).collect(Collectors.toMap(card -> card.repr, card->card));

		static Card fromChar(char _repr) {
			return registry.get(_repr);
		}
	}

	private static class Hand implements Comparable<Hand> {

		Hand(String init) {
			for (int i = 0; i < 5; ++i) {
				cards.add(Card.fromChar(init.charAt(i)));
			}
			type = detectType(cards);
		}

		private static Type detectType(List<Card> cards) {
			Map<Card, Long> frqMap = cards.stream().collect(Collectors.groupingBy(card -> card, Collectors.counting()));
			List<Long> countsList = frqMap.entrySet().stream().map(entry -> entry.getValue()).collect(Collectors.toList());
			Collections.sort(countsList, Collections.reverseOrder());
			Long[] counts = countsList.toArray(new Long[0]);
			if (Arrays.equals(counts, new Long[] { 5L })) {
				return Type.FIVE_OF_A_KIND;
			}
			else if (Arrays.equals(counts, new Long[] { 4L, 1L })) {
				return Type.FOUR_OF_A_KIND;
			}
			else if (Arrays.equals(counts, new Long[] { 3L, 2L })) {
				return Type.FULL_HOUSE;
			}
			else if (Arrays.equals(counts, new Long[] { 3L, 1L, 1L })) {
				return Type.THREE_OF_A_KIND;
			}
			else if (Arrays.equals(counts, new Long[] { 2L, 2L, 1L })) {
				return Type.TWO_PAIR;
			}
			else if (Arrays.equals(counts, new Long[] { 2L, 1L, 1L, 1L })) {
				return Type.ONE_PAIR;
			}
			else {
				return Type.HIGHEST_CARD;
			}
		}

		Type type;
		List<Card> cards = new ArrayList<>();

		@Override
		public int compareTo(Hand o) {
			if (o == this) return 0;
			int result = o.type.compareTo(type);
			if (result != 0) return result;

			for (int i = 0; i < 5; ++i) {
				result = o.cards.get(i).compareTo(cards.get(i));
				if (result != 0) return result;
			}

			return result;
		}

		public String toString() {
			return String.join("", cards.stream().map(cards -> "" + cards.repr).toList()) + "(" + type + ")";
		}
	}

	private record Bid(Hand hand, int amount) implements Comparable<Bid> {

		@Override
		public int compareTo(Bid o) {
			return this.hand.compareTo(o.hand);
		}
	};

	private static Bid parseBid(String line) {
		String[] fields = line.split(" ");
		return new Bid(
				new Hand(fields[0]),
				Integer.parseInt(fields[1])
		);
	}

	private static List<Bid> parse(Path file) throws IOException {
		return Files.lines(file).map(Solution::parseBid).collect(Collectors.toList());
	}

	private static long solve1(List<Bid> bids) {
		Collections.sort(bids);
		long result = 0;
		for (int i = 0; i < bids.size(); ++i) {
			System.out.println(bids.get(i).hand + ": " + (i + 1) + " * " + bids.get(i).amount);
			result += (i + 1) * bids.get(i).amount;
		}
		return result;
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day7/test-input"));
		Util.assertEqual(solve1(testData), 6440);
		var data = parse(Path.of("day7/input"));
		System.out.println(solve1(data));
	}

}
